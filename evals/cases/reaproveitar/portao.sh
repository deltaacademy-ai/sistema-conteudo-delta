#!/usr/bin/env bash
# Portao do reaproveitar, sem juiz: cada caso e uma execucao por modelo, conferida por criterio mecanico.
#
# Cada caso passa por scripts/eval/datas-relativas.sh antes de rodar, para {HOJE} virar a data do dia
# da execucao no prompt. A saida de cada execucao fica em <saida>.md (resposta) e <saida>.md.arquivos/
# (a pasta de contexto depois da execucao).
#
# Criterios de todos os casos: check-voz.sh da codigo 0 na resposta e em todo briefing novo; nenhum
# arquivo da fixture sumiu; o unico arquivo novo possivel e saida/briefing-<hoje>-*.md; base-conteudo.md,
# metricas.md e as pecas de saida/ iguais (a base e do linkedin-post, que so entra no fluxo do motor).
# Casos 01, 03 e 04 (recorte de peca publicada): de 2 a 3 blocos "### Recorte <letra>", cada um com
#   "Tipo:", "O que muda frente à origem:" e "Faltas:"; uma so linha "Recomendado: <letra>" de uma letra que
#   existe; exatamente um briefing novo, com Tipo, Tese, Ângulo, Leitura da pessoa, Formato, Material bruto,
#   Falta e a linha "Origem: reaproveita 2026-09-22 Caso do relatório mensal automatizado"; a linha 1 e o fecho da
#   origem nao reaparecem (6 palavras seguidas) nos recortes nem no briefing fora do Material bruto; "dez minutos"
#   e invencao; o recorte recomendado diz a tese de la e a nova (a palavra "tese" em "O que muda"); nenhum numero de 3 ou mais digitos fora dos arquivos.
#   Fatos ancorados (volta 3): todo recorte tem "Tese:" e "Fatos:" com 2 a 5 trechos "entre aspas" (origem) ou
#   (prova.md), e so as linhas Tipo, Tese, Fatos, O que muda e Faltas; a Tese tem uma frase, e o "O que muda"
#   dos nao recomendados tambem. Cada trecho, de 3 palavras ou mais, existe literal na fonte citada (espaco e
#   caixa normalizados, pontuacao final do trecho ignorada) e nao vem so da linha 1 nem do fecho da origem. O
#   Material bruto do briefing traz os trechos do recomendado e so itens com trecho (ou [FALTA]), conferidos
#   do mesmo jeito. Uma linha "Fato novo:": a fixture nao tem fato de prova.md sobre o caso, entao ela diz
#   "nenhum" e de onde vem a distancia (Tipo ou leitor).
# Caso 02 (peca em rascunho): nenhum arquivo novo, sem recorte e sem "Recomendado:"; a resposta diz que so
#   peca publicada entra e cita o status.
# Caso 03 (o pedido traz "50 clientes"): o 50 nao esta no briefing fora de um "[FALTA ...]"; a resposta ou o
#   briefing traz um "[FALTA ...]" sobre o numero ou os clientes.
# Caso 04 (carrossel): o recorte recomendado tem "Tipo: carrossel" e o briefing tem "Formato: carrossel".
# Caso 05 ("o que vale reaproveitar?"): nenhum arquivo novo; a primeira linha "Candidata" e a fila de chamados,
#   com 1.780 e "colado pela pessoa em 2026-09-24"; nenhuma candidata e a peca em rascunho; sem recorte.
# Codigos como U+2014 (da linha Checagem) nao contam como numero.
#
# Placar: evals/results/nova/reaproveitar-<rodada>/_placar.txt, uma linha por caso e modelo.
# uso: bash evals/cases/reaproveitar/portao.sh [rodada]   (env: CASOS, MODELOS, LIMITE, TEMPO, REAVALIAR, HOJE)
#   REAVALIAR=<rodada>: nao roda modelo; confere de novo as saidas de evals/results/nova/reaproveitar-<rodada>.
#   HOJE=AAAA-MM-DD: o dia da execucao original. LIMITE = execucoes em paralelo (padrao 2, o maximo).
#   nohup bash evals/cases/reaproveitar/portao.sh t1 > /dev/null 2>&1 &
set -u
raiz=$(cd "$(dirname "$0")/../../.." && pwd); cd "$raiz"

if [ "${1:-}" = "--job" ]; then modo_job=1; shift; else modo_job=0; fi
rodada="${1:-t1}"
R="evals/results/nova/reaproveitar-$rodada"; L="$R/_log.txt"; PL="$R/_placar.txt"
CASOS="${CASOS:-01 02 03 04 05}"
MODELOS="${MODELOS:-claude-sonnet-5 claude-opus-5}"
LIMITE="${LIMITE:-2}"; TEMPO="${TEMPO:-1800}"
hoje="${HOJE:-$(date +%F)}"
mkdir -p "$R/estado"
log() { echo "$(date +%H:%M:%S) $*" >> "$L"; }

roda() { # roda <caso.md> <modelo> <saida.md>
  local caso="$1" m="$2" s="$3" t
  for t in 1 2 3; do
    log "run $(basename "$s") tentativa=$t"
    if perl -e 'alarm shift; exec @ARGV' "$TEMPO" bash scripts/eval/run-case.sh . "$caso" "$m" "$s" > "$s.log" 2>&1 \
       && [ -s "$s" ] && ! grep -qx null "$s" && ! grep -qi 'rate.limit\|too many requests\|"429"' "$s.log"; then
      log "ok $(basename "$s") $(wc -c < "$s" | tr -d ' ') bytes"; return 0
    fi
    log "retentativa $(basename "$s") motivo=$(tail -c 200 "$s.log" 2>/dev/null | tr '\n' ' ')"
    [ "$t" -lt 3 ] && sleep 120
  done
  log "FALHOU $(basename "$s")"; return 1
}

ORIGEM_LINHA="Origem: reaproveita 2026-09-22 Caso do relatório mensal automatizado"

briefings_novos() { find "$1/saida" -type f -name "briefing-*.md" 2>/dev/null | sort; } # briefings_novos <arquivos>

comum() { # comum <arquivos> <resposta> <fixture>
  local a="$1" s="$2" fx="$3" m="" f rel
  bash scripts/check-voz.sh "$s" "$a/banidas.txt" >/dev/null || m="$m check-voz-resposta"
  while IFS= read -r f; do
    bash scripts/check-voz.sh "$f" "$a/banidas.txt" >/dev/null || m="$m check-voz-briefing:$(basename "$f")"
  done < <(briefings_novos "$a")
  while IFS= read -r -d '' f; do
    rel="${f#$fx/}"; [ -e "$a/$rel" ] || m="$m arquivo-da-fixture-sumiu:$rel"
  done < <(find "$fx" -type f -print0)
  while IFS= read -r -d '' f; do
    rel="${f#$a/}"; [ -e "$fx/$rel" ] && continue
    case "$rel" in saida/briefing-"$hoje"-*.md) ;; *) m="$m arquivo-novo:$rel" ;; esac
  done < <(find "$a" -type f -print0)
  cmp -s "$a/base-conteudo.md" "$fx/base-conteudo.md" || m="$m base-conteudo.md-alterado"
  cmp -s "$a/metricas.md" "$fx/metricas.md" || m="$m metricas.md-alterado"
  for f in "$fx"/saida/*; do cmp -s "$f" "$a/saida/$(basename "$f")" || m="$m peca-de-saida-alterada:$(basename "$f")"; done
  echo "$m"
}

nenhum_arquivo_novo() { # nenhum_arquivo_novo <arquivos>
  [ -z "$(briefings_novos "$1")" ] || echo " briefing-gravado-sem-dever"
}

letras() { grep -oE '^### Recorte [A-Z]' "$1" | awk '{print $3}' | tr '\n' ' '; }
bloco_recorte() { # bloco_recorte <resposta> <letra>: do "### Recorte <letra>" ate o proximo titulo ou a linha Recomendado
  awk -v l="$2" '$0 ~ "^### Recorte " l "([^A-Za-z]|$)"{d=1; next} d && (/^### / || /^Recomendado:/ || /^Checagem:/){d=0} d' "$1"
}
recomendada() { grep -E '^Recomendado:' "$1" | head -1 | grep -oE '[A-Z]' | sed -n 2p; } # "Recomendado: B" -> B (o primeiro R e da palavra)

ORIGEM_POST="saida/post-2026-09-22-relatorio-mensal-automatizado.md"
FATO_NOVO_ESPERADO="nenhum" # a prova.md da fixture nao tem fato sobre a distribuidora (conferido na volta 3)

trechos() { # trechos <origem> <prova> < texto: cada par "trecho" (fonte) do texto, um por linha, e o achado de cada um
  perl -CSDA -e '
    sub n{ my $t=lc shift; $t=~s/\s+/ /g; $t=~s/^ | $//g; $t }
    sub ler{ open my $F,"<:utf8",shift or return ""; local $/; my $t=<$F>; $t }
    my $o=ler($ARGV[0]); my $p=n(ler($ARGV[1]));
    my @pp=split /\n\s*\n/, $o; my @ll=split /\n/, $pp[0]; shift @ll; $pp[0]=join "\n",@ll; pop @pp;
    my $corpo=n(join "\n",@pp); $o=n($o);
    local $/; my $x=<STDIN>;
    while($x=~/["\x{201C}]([^"\x{201C}\x{201D}\n]+)["\x{201D}]\s*\(([^)]*)\)/g){
      my ($t,$f)=($1,n($2)); $t=n($t); $t=~s/[.,;:!?]+$//; (my $k=substr($t,0,40))=~s/ /_/g;
      my @w=split / /,$t;
      if(@w<3){ print "trecho-curto:$k\n"; next }
      if($f eq "origem"){
        if(index($o,$t)<0){ print "trecho-nao-existe-na-origem:$k\n" }
        elsif(index($corpo,$t)<0){ print "trecho-da-linha-1-ou-do-fecho:$k\n" }
        else { print "ok:$t\n" }
      } elsif($f eq "prova.md"){
        if(index($p,$t)<0){ print "trecho-nao-existe-em-prova.md:$k\n" } else { print "ok:$t\n" }
      } else { (my $g=$f)=~s/ /_/g; print "fonte-desconhecida:$g\n" }
    }' "$1" "$2"
}

campo_mb() { awk '/^Material bruto:/{d=1} d && /^(Aval|Falta|Origem|Checagem|Funil|Tom|Tipo|Tese|Ângulo|Leitura da pessoa|Formato|Tamanho|Fechamento|Fontes e links|Tipo de gancho):/ && !/^Material bruto:/{d=0} d' "$1"; }

uma_frase() { grep -qE '[.!?] +[^ ]' <<< "$(sed -E 's/^[^:]+: *//; s/[[:space:]]+$//' <<< "$1")" && return 1; return 0; } # uma_frase <linha>

confere_fatos() { # confere_fatos <fixture> <resposta> <briefing> <letras> <recomendada>
  local fx="$1" s="$2" br="$3" ls="$4" rec="$5" m="" l b fa t n tt mb fn o="$1/$ORIGEM_POST" p="$1/prova.md"
  for l in $ls; do
    b=$(bloco_recorte "$s" "$l")
    grep -qE '^Tese:' <<< "$b" || m="$m recorte-$l-sem-Tese"
    grep -vE '^(Tipo|Tese|Fatos|O que muda frente à origem|Faltas):|^[[:space:]]*$' <<< "$b" | grep -q . && m="$m recorte-$l-linha-fora-dos-campos"
    uma_frase "$(grep -m1 -E '^Tese:' <<< "$b")" || m="$m recorte-$l-Tese-com-mais-de-uma-frase"
    [ "$l" = "$rec" ] || uma_frase "$(grep -m1 -E '^O que muda frente à origem:' <<< "$b")" || m="$m recorte-$l-O-que-muda-com-mais-de-uma-frase"
    fa=$(grep -E '^Fatos:' <<< "$b")
    [ -n "$fa" ] || { m="$m recorte-$l-sem-Fatos"; continue; }
    t=$(trechos "$o" "$p" <<< "$fa"); n=$(grep -c . <<< "$t")
    { [ "$n" -ge 2 ] && [ "$n" -le 5 ]; } || m="$m recorte-$l-Fatos=$n"
    while IFS= read -r tt; do case "$tt" in ok:*|"") ;; *) m="$m recorte-$l-$tt" ;; esac; done <<< "$t"
    [ "$l" = "$rec" ] && fn="$t"
  done
  mb=$(campo_mb "$br")
  t=$(trechos "$o" "$p" <<< "$mb")
  while IFS= read -r tt; do case "$tt" in ok:*|"") ;; *) m="$m Material-bruto-$tt" ;; esac; done <<< "$t"
  sed -E '1s/^Material bruto: *//' <<< "$mb" | perl -CSDA -ne 'print unless /^\s*$/ || /["\x{201C}][^"\x{201D}]+["\x{201D}]\s*\(|\[FALTA/' | grep -q . && m="$m Material-bruto-item-sem-trecho"
  while IFS= read -r tt; do
    case "$tt" in ok:*) grep -qxF "$tt" <<< "$t" || { tt="${tt#ok:}"; m="$m Material-bruto-sem-o-trecho-do-recomendado:$(printf '%s' "$tt" | cut -c1-40 | tr ' ' _)"; } ;; esac
  done <<< "${fn:-}"
  n=$(grep -cE '^Fato novo:' "$s")
  if [ "$n" != 1 ]; then m="$m linhas-Fato-novo=$n"; else
    fa=$(grep -m1 -E '^Fato novo:' "$s")
    if [ "$FATO_NOVO_ESPERADO" = nenhum ]; then
      grep -qiE '^Fato novo: *nenhum' <<< "$fa" || m="$m Fato-novo-que-a-prova-nao-tem"
      grep -qiE 'tipo|leitor' <<< "$fa" || m="$m Fato-novo-sem-dizer-de-onde-vem-a-distancia"
    fi
    while IFS= read -r tt; do case "$tt" in ok:*|"") ;; *) m="$m Fato-novo-$tt" ;; esac; done <<< "$(trechos "$o" "$p" <<< "$fa")"
  fi
  echo "$m"
}

confere_recortes() { # confere_recortes <arquivos> <fixture> <resposta> <caso.md>
  local a="$1" fx="$2" s="$3" caso="$4" m="" ls n l b br nb rec todo
  ls=$(letras "$s"); n=$(wc -w <<< "$ls" | tr -d ' ')
  { [ "$n" -ge 2 ] && [ "$n" -le 3 ]; } || m="$m recortes=$n"
  for l in $ls; do
    b=$(bloco_recorte "$s" "$l")
    grep -qE '^Tipo:' <<< "$b" || m="$m recorte-$l-sem-Tipo"
    grep -qE '^O que muda frente à origem:' <<< "$b" || m="$m recorte-$l-sem-O-que-muda"
    grep -qE '^Faltas:' <<< "$b" || m="$m recorte-$l-sem-Faltas"
  done
  [ "$(grep -cE '^Recomendado:' "$s")" = 1 ] || m="$m linhas-Recomendado=$(grep -cE '^Recomendado:' "$s")"
  rec=$(recomendada "$s")
  case " $ls" in *" $rec "*) ;; *) m="$m recomendado-nao-e-um-recorte:${rec:-vazio}" ;; esac
  nb=$(briefings_novos "$a" | wc -l | tr -d ' ')
  if [ "$nb" != 1 ]; then m="$m briefings-novos=$nb"; echo "$m"; return; fi
  br=$(briefings_novos "$a")
  for k in 'Tipo' 'Tese' 'Ângulo' 'Leitura da pessoa' 'Formato' 'Material bruto' 'Falta'; do
    grep -qE "^$k:" "$br" || m="$m briefing-sem-$k"
  done
  head -1 "$br" | grep -qxF "Briefing do ângulo $rec" || m="$m briefing-sem-cabecalho-com-a-letra-do-Recomendado:$(head -1 "$br" | cut -c1-30)"
  tr_r=$(bloco_recorte "$s" "$rec" | grep -m1 -E '^Tipo:' | sed -E 's/^Tipo: *//; s/ *$//'); tr_b=$(grep -m1 -E '^Tipo:' "$br" | sed -E 's/^Tipo: *//; s/ *$//')
  [ "$(perl -CSDA -e "print lc shift" "$tr_r")" = "$(perl -CSDA -e "print lc shift" "$tr_b")" ] || m="$m Tipo-do-briefing-difere-do-recorte:'$tr_b'/'$tr_r'"
  grep -qxF "$ORIGEM_LINHA" "$br" || m="$m briefing-sem-a-linha-Origem"
  # A linha 1 e o fecho da origem nao reaparecem: nenhuma sequencia de 6 palavras seguidas delas (texto
  # normalizado, sem maiusculas nem pontuacao) nos recortes nem no briefing fora do Material bruto. O fato
  # "o dono confere em dez" so existe na linha 1, entao fica permitido dentro do Material bruto, e la a
  # unidade "minutos" depois do dez e invencao. A linha "O que muda frente a origem" fica fora desta
  # conta: ela existe para nomear a tese de la, e nomea-la fiel ecoa o fecho (o resto do recorte continua conferido).
  todo=$({ awk '/^### Recorte/{d=1} /^Recomendado:/{d=0} d' "$s" | grep -v '^O que muda frente à origem:'; awk '/^Material bruto:/{d=1; next} d && /^(Aval|Falta|Origem|Checagem|Funil|Tom|Tipo|Tese|Ângulo|Leitura da pessoa|Formato|Tamanho|Fechamento|Fontes e links|Tipo de gancho):/{d=0} !d' "$br"; })
  src=$(perl -CSDA -e 'open F,"<:utf8",$ARGV[0]; local $/; $t=<F>; ($p)=split /\n/,$t; @pp=split /\n\n+/,$t; $u=$pp[-1]; print "$p\n$u\n"' "$fx/saida/post-2026-09-22-relatorio-mensal-automatizado.md")
  sob=$(sobrepoe "$src" <<< "$todo"); [ -z "$sob" ] || m="$m repete-a-linha-1-ou-o-fecho-da-origem:$sob"
  grep -qiE 'dez minutos' <<< "$todo$(awk '/^Material bruto:/{d=1} d && /^(Aval|Falta|Origem|Checagem|Funil|Tom|Tipo|Tese|Ângulo|Leitura da pessoa|Formato|Tamanho|Fechamento|Fontes e links|Tipo de gancho):/ && !/^Material bruto:/{d=0} d' "$br")" && m="$m dez-minutos-inventado"
  recb=$(bloco_recorte "$s" "$rec"); grep -E '^O que muda frente à origem:' <<< "$recb" | grep -qi 'tese' || m="$m recomendado-sem-tese-de-la-e-nova"
  n=$(grep -v '^Tamanho:' "$br" > "$a/.sem-tamanho.tmp"; numeros_novos "$a/.sem-tamanho.tmp" "$fx" "$caso"; rm -f "$a/.sem-tamanho.tmp"); [ -z "$n" ] || m="$m numero-novo-no-briefing:$n"
  m="$m$(confere_fatos "$fx" "$s" "$br" "$ls" "$rec")"
  echo "$m"
}

sobrepoe() { # sobrepoe <fontes (uma por linha)> < texto: imprime a primeira sequencia de 6 palavras da fonte que aparece no texto
  perl -CSDA -e 'sub n{ my $t=lc shift; $t=~s/[^\p{L}\p{N}]+/ /g; $t=~s/^ | $//g; $t } my @f=split /\n/,$ARGV[0]; local $/; my $x=" ".n(<STDIN>)." ";
    for my $l (@f){ my @w=split / /,n($l); for my $i (0..$#w-5){ my $s=join " ",@w[$i..$i+5]; if(index($x," $s ")>=0){ $s=~s/ /_/g; print $s; exit } } }' "$1"
}

numeros_novos() { # numeros_novos <arquivo> <fixture> <caso.md>: numeros de 3+ digitos que nao estao em nenhum arquivo da fixture
  local n d
  for n in $(sed -E 's/U\+[0-9A-Fa-f]+//g' "$1" | grep -oE '[0-9][0-9.,]*[0-9]'); do
    d=$(printf '%s' "$n" | tr -d '.,'); [ "${#d}" -ge 3 ] || continue
    grep -rqF -- "$n" "$2" "$3" || echo "$n"
  done | sort -u | tr '\n' ' '
}

confere_02() { # confere_02 <resposta>
  local m=""
  grep -qE '^### Recorte' "$1" && m="$m recorte-de-peca-em-rascunho"
  grep -qE '^Recomendado:' "$1" && m="$m Recomendado-de-peca-em-rascunho"
  grep -qiE '(só|apenas|somente) [^.]*publicad|publicad[^.]*(só|apenas|somente)|não (está|foi|esta) publicad|ainda não (foi )?publicad|não publicad' "$1" || m="$m resposta-nao-diz-que-so-peca-publicada-entra"
  grep -qi 'rascunho' "$1" || m="$m resposta-nao-cita-o-status"
  echo "$m"
}

confere_03() { # confere_03 <arquivos> <resposta>
  local m="" br sem
  br=$(briefings_novos "$1" | head -1)
  perl -0pe 's/\[FALTA[^\]]*\]//g' <(grep -E '^Recomendado:' "$2") | grep -qE '(^|[^0-9.,/-])50([^0-9.,/-]|$)|cinquenta' && m="$m 50-na-linha-Recomendado-fora-de-FALTA"
  if [ -n "$br" ]; then
    sem=$(perl -0pe 's/\[FALTA[^\]]*\]//g' "$br")
    grep -qE '(^|[^0-9.,/-])50([^0-9.,/-]|$)|cinquenta' <<< "$sem" && m="$m 50-no-briefing-fora-de-FALTA"
  fi
  grep -qE '\[FALTA[^]]*(50|cliente)' "$2" || { [ -n "$br" ] && grep -qE '\[FALTA[^]]*(50|cliente)' "$br"; } || m="$m sem-FALTA-sobre-o-numero"
  echo "$m"
}

confere_04() { # confere_04 <arquivos> <resposta>
  local m="" rec br
  rec=$(recomendada "$2"); br=$(briefings_novos "$1" | head -1)
  bloco_recorte "$2" "$rec" | grep -qiE '^Tipo: *carrossel *$' || m="$m recorte-recomendado-sem-Tipo-carrossel"
  [ -n "$br" ] && { grep -qiE '^Formato: *carrossel' "$br" || m="$m briefing-sem-Formato-carrossel"; grep -qiE '^Tipo: *carrossel *$' "$br" || m="$m briefing-sem-Tipo-carrossel"; }
  echo "$m"
}

confere_05() { # confere_05 <resposta>
  local m="" c1
  c1=$(grep -m1 -E '^Candidata' "$1")
  [ -n "$c1" ] || { echo " sem-linha-Candidata"; return; }
  grep -qi 'fila' <<< "$c1" || m="$m primeira-candidata-nao-e-a-fila"
  grep -qF '1.780' <<< "$c1" || m="$m primeira-candidata-sem-1.780"
  grep -qF 'colado pela pessoa em 2026-09-24' <<< "$c1" || m="$m primeira-candidata-sem-a-fonte"
  grep -E '^Candidata' "$1" | grep -qi 'checagem antes' && m="$m candidata-em-rascunho"
  grep -qE '^### Recorte' "$1" && m="$m recorte-em-pergunta-de-sugestao"
  echo "$m"
}

job() { # job <caso> <modelo>
  local c="$1" m="$2" n="$1-$2" caso2 s a f="" fonte est fx
  if [ -n "${REAVALIAR:-}" ]; then
    fonte="evals/results/nova/reaproveitar-$REAVALIAR"; s="$fonte/$n.md"; a="$s.arquivos"; est="$fonte/estado/$n"
    [ -s "$s" ] || { echo "$n | saida da rodada $REAVALIAR nao existe | NAO PASSA" >> "$PL"; return; }
    caso2="$est/cases/reaproveitar/$c.md"
  else
    s="$R/$n.md"; a="$s.arquivos"; est="$R/estado/$n"
    caso2=$(bash scripts/eval/datas-relativas.sh "evals/cases/reaproveitar/$c.md" "$est") || { echo "$n | datas-relativas FALHOU | NAO PASSA" >> "$PL"; return; }
    roda "$caso2" "$m" "$s" || { echo "$n | execucao FALHOU (sem saida) | NAO PASSA" >> "$PL"; return; }
  fi
  fx=$(ls -d "$est"/fixtures/* | head -1)
  f="$(comum "$a" "$s" "$fx")"
  case "$c" in
    01) f="$f$(confere_recortes "$a" "$fx" "$s" "$caso2")" ;;
    02) f="$f$(nenhum_arquivo_novo "$a")$(confere_02 "$s")" ;;
    03) f="$f$(confere_recortes "$a" "$fx" "$s" "$caso2")$(confere_03 "$a" "$s")" ;;
    04) f="$f$(confere_recortes "$a" "$fx" "$s" "$caso2")$(confere_04 "$a" "$s")" ;;
    05) f="$f$(nenhum_arquivo_novo "$a")$(confere_05 "$s")" ;;
  esac
  f="${f# }"
  log "$n:${f:- ok}"
  if [ -z "$f" ]; then echo "$n | PASSA |" >> "$PL"; else echo "$n | NAO PASSA | $f" >> "$PL"; fi
}

if [ "$modo_job" = 1 ]; then job "$2" "$3"; exit 0; fi

log "inicio rodada=$rodada casos=$CASOS modelos=$MODELOS limite=$LIMITE"
rm -f "$PL"
for m in $MODELOS; do for c in $CASOS; do echo "$c $m"; done; done | xargs -L1 -P "$LIMITE" bash "$0" --job "$rodada"
log "fim"; sort "$PL"
