# Funcoes compartilhadas por reconhecimento.sh e preferencia-voz.sh.
# Uso: dir=$(cd "$(dirname "$0")" && pwd); . "$dir/briefing-lib.sh"
# Espera as variaveis: dir (pasta dos scripts), arq (pasta de artefatos), extrator (modelo).

# chamar_claude <bruto.json> [argumentos do claude...]
# Roda claude-isolado.sh numa pasta temporaria, grava o JSON cru em <bruto.json> (e o
# stderr em <bruto.json>.err) e devolve 0 so quando a chamada saiu com 0, sem is_error
# e com .result nao vazio. A retentativa fica aqui dentro, e nao no chamador, porque os
# scripts rodam com set -euo pipefail: um pipeline que sai diferente de zero encerra o
# script antes da segunda tentativa (achado 6 da revisao da Tarefa 4). O claude -p, em
# erro de API, sai com 1 e imprime JSON com is_error true e api_error_status; o .result
# nesse caso e a mensagem de erro, entao nunca pode virar candidato.
# Em 429 ou 529 (ou mensagem de rate limit, session limit, overloaded) espera ESPERA_LIMITE
# segundos e tenta de novo, sem mudar o protocolo; em outra falha espera ESPERA e dobra a
# cada tentativa. Teste do roteamento em test-chamar-claude.sh.
# Ambiente: TENTATIVAS (padrao 6), ESPERA (padrao 30), ESPERA_LIMITE (padrao 300),
# CLAUDE_ISOLADO (troca o binario; os testes usam um claude falso).
chamar_claude() {
  local bruto="$1"; shift
  local bin="${CLAUDE_ISOLADO:-$dir/claude-isolado.sh}"
  local tent="${TENTATIVAS:-6}" espera="${ESPERA:-30}" lim="${ESPERA_LIMITE:-300}" t rc status res
  for t in $(seq 1 "$tent"); do
    rc=0
    ( cd "$(mktemp -d)" && "$bin" "$@" ) > "$bruto" 2> "$bruto.err" || rc=$?
    status=$(jq -r '.api_error_status // empty' "$bruto" 2>/dev/null || true)
    res=$(jq -r 'if .is_error == true then "" else (.result // "") end' "$bruto" 2>/dev/null || true)
    if [ "$rc" -eq 0 ] && [ -n "$res" ]; then return 0; fi
    echo "chamada falhou (tentativa $t/$tent, exit $rc, status ${status:-?}): $({ cat "$bruto.err"; cat "$bruto"; } 2>/dev/null | tr '\n' ' ' | head -c 200)" >&2
    [ "$t" -lt "$tent" ] || break
    # sinal real de limite: status 429 ou 529, ou a mensagem de rate limit, limite de sessao
    # ou sobrecarga; "limit" solto casava dentro de "limite" em qualquer erro em portugues e
    # custava ESPERA_LIMITE por tentativa (menor da re-revisao da Tarefa 4)
    if [ "$status" = 429 ] || [ "$status" = 529 ] || grep -qiE 'rate.?limit|session limit|usage limit|too many requests|overloaded' "$bruto" "$bruto.err" 2>/dev/null; then
      echo "limite da API: esperando ${lim}s antes da tentativa $((t + 1))" >&2; sleep "$lim"
    else
      sleep "$espera"; espera=$((espera * 2))
    fi
  done
  return 1
}

# resultado <bruto.json>: o texto de .result, sem cercas de codigo.
resultado() { jq -r '.result' "$1" | sed '/^```/d'; }

# extrair_reais <materiais-dir>: grava $arq/textos/real-1..3.txt com o primeiro
# bloco <!-- ai:start --> a <!-- ai:end --> de cada arquivo (ou o arquivo inteiro),
# na ordem C dos nomes, e $arq/textos/reais.txt com "indice<TAB>nome". Precisa de
# pelo menos 3 arquivos; usa os 3 primeiros.
extrair_reais() {
  local mat="$1" n=0 f
  mkdir -p "$arq/textos"; : > "$arq/textos/reais.txt"
  while IFS= read -r -d '' f; do
    n=$((n + 1)); [ $n -le 3 ] || break
    perl -ne 'if (/<!-- ai:start -->/) { $in=1; next } if (/<!-- ai:end -->/ && $in) { exit } print if $in' "$f" > "$arq/textos/real-$n.txt"
    [ -s "$arq/textos/real-$n.txt" ] || cp "$f" "$arq/textos/real-$n.txt"
    printf '%s\t%s\n' "$n" "$(basename "$f")" >> "$arq/textos/reais.txt"
  done < <(find "$mat" -type f -name '*.md' -print0 | LC_ALL=C sort -z)
  [ "$n" -ge 3 ] || { echo "precisa de 3 materiais, achou $n" >&2; return 1; }
}

# indice_real <nome-do-arquivo>: imprime o indice (1..3) do material com esse nome.
indice_real() { awk -F'\t' -v k="$1" '$2 == k { print $1; f = 1 } END { exit(f ? 0 : 1) }' "$arq/textos/reais.txt"; }

# sobreposicao <original> <briefing>: quantas sequencias de 5 palavras do original aparecem no briefing.
sobreposicao() {
  perl -CSD -e '
    sub toks { my $t = lc shift; $t =~ s/[^\p{L}\p{N}\s]/ /g; return grep { length } split /\s+/, $t }
    local $/; open my $o, "<", $ARGV[0]; my @a = toks(<$o>); open my $b, "<", $ARGV[1]; my @c = toks(<$b>);
    my %g; for my $i (0 .. $#a-4) { $g{join " ", @a[$i..$i+4]} = 1 }
    my $hit = 0; for my $i (0 .. $#c-4) { $hit++ if $g{join " ", @c[$i..$i+4]} }
    print "$hit\n"' "$1" "$2"
}

# ngramas_reusados <n> <candidato> <real.txt...>: quantas sequencias distintas de n
# palavras do candidato aparecem em algum dos textos reais. Mede reaproveitamento
# literal (achado 3 da revisao da Tarefa 4): o voz.md carrega trechos dos posts que o
# compilaram, e um candidato que os recola nao esta mostrando voz, esta colando.
ngramas_reusados() {
  perl -CSD -e '
    my $n = shift @ARGV; my $cand = shift @ARGV;
    sub toks { my $t = lc shift; $t =~ s/[^\p{L}\p{N}\s]/ /g; return grep { length } split /\s+/, $t }
    local $/; my %g;
    for my $f (@ARGV) { open my $h, "<", $f or die "$f: $!"; my @a = toks(<$h>); for my $i (0 .. $#a-$n+1) { $g{join " ", @a[$i..$i+$n-1]} = 1 } }
    open my $c, "<", $cand or die "$cand: $!"; my @b = toks(<$c>); my %hit;
    for my $i (0 .. $#b-$n+1) { my $k = join " ", @b[$i..$i+$n-1]; $hit{$k} = 1 if $g{$k} }
    print scalar(keys %hit), "\n"' "$@"
}

# ngramas_reusados_liquidos <n> <candidato> <briefing> <real.txt...>: igual a
# ngramas_reusados, descontando toda sequencia que compartilha uma janela de 5 palavras
# com o briefing que os dois candidatos receberam (ruling do controlador, rodada de
# correcao da Tarefa 4: 6 das 11 anulacoes da rodada 3 vinham do briefing repetindo a
# formulacao do post original em nomes e cronologia, e um candidato que a reproduz esta
# seguindo o briefing, nao colando o perfil). A janela e de 5 palavras porque e a unidade
# do proprio verificador de vazamento do extrator (sobreposicao) e porque nenhum 8-grama
# inteiro aparece no briefing: o vazamento chega em pedacos menores.
ngramas_reusados_liquidos() {
  perl -CSD -e '
    my $n = shift @ARGV; my $cand = shift @ARGV; my $brief = shift @ARGV;
    sub toks { my $t = lc shift; $t =~ s/[^\p{L}\p{N}\s]/ /g; return grep { length } split /\s+/, $t }
    local $/; my %g;
    for my $f (@ARGV) { open my $h, "<", $f or die "$f: $!"; my @a = toks(<$h>); for my $i (0 .. $#a-$n+1) { $g{join " ", @a[$i..$i+$n-1]} = 1 } }
    open my $bh, "<", $brief or die "$brief: $!"; my @bt = toks(<$bh>); my %b5; for my $i (0 .. $#bt-4) { $b5{join " ", @bt[$i..$i+4]} = 1 }
    open my $c, "<", $cand or die "$cand: $!"; my @b = toks(<$c>); my %hit;
    for my $i (0 .. $#b-$n+1) { my @w = @b[$i..$i+$n-1]; my $k = join " ", @w; next unless $g{$k};
      my $viab = 0; for my $j (0 .. $n-5) { $viab = 1 if $b5{join " ", @w[$j..$j+4]} }
      $hit{$k} = 1 unless $viab }
    print scalar(keys %hit), "\n"' "$@"
}

# extrair_briefings [indices]: grava $arq/briefings/briefing-<i>.txt a partir dos reais
# (padrao 1 2 3), sem frase do original (prompt reconhecimento-briefing.md, modelo
# $extrator). Se BRIEFINGS_CACHE apontar para uma pasta com o briefing, copia de la;
# se nao tiver, extrai e guarda la tambem. A sobreposicao de 5 palavras com o original
# e conferida sempre, inclusive no caminho do cache, e vai para a variavel aviso.
extrair_briefings() {
  local i h lista="${*:-1 2 3}"
  mkdir -p "$arq/briefings"; aviso="${aviso:-}"
  _extrair() {
    chamar_claude "$arq/briefings/briefing-$1.bruto.json" --model "$extrator" \
      --append-system-prompt "$(cat "$dir/reconhecimento-briefing.md")" --output-format json "$(cat "$arq/textos/real-$1.txt")" || return 1
    resultado "$arq/briefings/briefing-$1.bruto.json" > "$arq/briefings/briefing-$1.txt"
    [ -s "$arq/briefings/briefing-$1.txt" ]
  }
  for i in $lista; do
    if [ -n "${BRIEFINGS_CACHE:-}" ] && [ -s "$BRIEFINGS_CACHE/briefing-$i.txt" ]; then
      cp "$BRIEFINGS_CACHE/briefing-$i.txt" "$arq/briefings/briefing-$i.txt"
      aviso="$aviso briefing-$i do cache;"
    else
      _extrair $i || { echo "extracao do briefing $i falhou" >&2; return 1; }
      h=$(sobreposicao "$arq/textos/real-$i.txt" "$arq/briefings/briefing-$i.txt")
      if [ "$h" -gt 0 ]; then _extrair $i || true; fi
      if [ -n "${BRIEFINGS_CACHE:-}" ]; then mkdir -p "$BRIEFINGS_CACHE"; cp "$arq/briefings/briefing-$i.txt" "$BRIEFINGS_CACHE/"; fi
    fi
    h=$(sobreposicao "$arq/textos/real-$i.txt" "$arq/briefings/briefing-$i.txt")
    if [ "$h" -gt 0 ]; then aviso="$aviso briefing-$i com $h sequencias de 5 palavras do original;"; fi
  done
  return 0
}
