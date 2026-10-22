#!/usr/bin/env bash
# Portao do motor, sem juiz: cada caso e um fluxo completo em dois (ou tres) turnos, por modelo.
#
# Turno 1: run-case.sh com prompt_novo (o tema). Precisa parar na aprovacao da peca
#   principal: post em saida/, linha `rascunho` em base-conteudo.md com tantas celulas
#   quanto o cabecalho, pedido de aprovacao na resposta, linha Revisor dizendo se a
#   checagem mecanica do revisor rodou ou foi por leitura, linha "Checagem da peca" com
#   o check-voz.sh rodado pelo proprio motor no arquivo do post (codigo 0), nenhum
#   carrossel e nenhuma pasta publicar/.
# Turno 2: run-case.sh com prompt_turno_2 ("aprovado, segue ate o pacote") sobre uma
#   fixture temporaria que e a copia do que o turno 1 deixou em disco (a conversa nao
#   e retomada; o estado do motor vive em saida/ e na base). Precisa entregar
#   publicar/<data>-<tema>/ com post.txt, primeiro-comentario.txt, legenda-instagram.txt,
#   NN.png em 1080x1350, carrossel.pdf e passo-a-passo.md; check-voz limpo nos .txt;
#   base com a mesma linha do turno 1 e so a celula Status trocada para `aprovado`.
# COPY=1: o turno 2 usa prompt_turno_2_copy ("aprovado, com carrossel", sem "segue ate o
#   pacote") e precisa parar na copy do carrossel: base `aprovado`, carrossel.json
#   gravado, nenhum PNG, nenhuma pasta publicar/, resposta terminando em "Aprova a copy?".
#   O turno 3 usa prompt_turno_3 sobre o estado do turno 2 e passa pelos criterios do
#   turno 2 direto.
# ENCURTA=1: tira a ultima celula da linha rascunho antes do turno 2 e exige que o motor
#   complete a linha (so com celula vazia) e diga isso na resposta.
# Caso 04 (fato dito na aprovacao vira prova): o turno 2 traz o numero que o tema deixou como
#   [FALTA] ("37 empresas atendidas"). Alem dos criterios do turno 2, prova.md precisa ter
#   exatamente uma linha de tabela com 37 e "resposta da pessoa", nenhuma outra linha mudou
#   (fora a linha Atualizado:, que se existir traz a data da execucao) e, se a tabela tem a
#   coluna Tipo, a linha traz credencial ou operacao.
# PROVA_CONFLITO=1 (so caso 04): antes do turno 2 a fixture temporaria ganha a linha
#   "35 empresas atendidas" em prova.md. O 37 precisa estar em "Divergencias entre fontes"
#   com o 35, nao na tabela, e toda linha antiga de prova.md continua no arquivo.
# Caso 04, fim do turno 2 (seguir e mostrar no fim): a mensagem final traz, letra por letra, a
#   frase do post que tem "37"; se o veredito do revisor citado na mensagem nao for `aprovar`,
#   nao existe publicar/ na saida (a peca para de novo, com a frase e o veredito).
# Caso 05 (pauta do radar vira peca e fica usada): so o turno 1 roda. O caso e a fixture passam por
#   scripts/eval/datas-relativas.sh antes de rodar. Alem dos criterios do turno 1, pautas.md precisa
#   ter a linha `Status: usada em <hoje>` no bloco do identificador do pedido e nenhuma outra linha mudada.
# ESTADO_DE=<rodada>: reaproveita o turno 1 daquela rodada (so os turnos seguintes rodam).
#
# A linha da peca e ancorada por Data e Tema (as duas primeiras celulas da linha rascunho
# do turno 1), nao pela primeira linha que casa. Celulas sao contadas pelos `|` da linha
# depois de remover trechos entre aspas (o Gancho e citado entre aspas e pode conter `|`).
# `sips` (medida dos PNG) e do macOS, como o `perl -e alarm` que substitui o `timeout`
# que o macOS nao tem; em Linux troque por `identify` ou `file`.
#
# Duas faixas em paralelo (uma por modelo, casos em sequencia), ate 3 tentativas por
# execucao. Log em evals/results/nova/motor-<rodada>/_log.txt e placar em _placar.txt.
#
# uso: bash evals/cases/motor/portao.sh [rodada]   (env: CASOS, MODELOS, LIMITE, ESTADO_DE, ENCURTA, COPY, PROVA_CONFLITO)
#   nohup bash evals/cases/motor/portao.sh r1 > /dev/null 2>&1 &
set -u
raiz=$(cd "$(dirname "$0")/../../.." && pwd); cd "$raiz"
rodada="${1:-r1}"
R="evals/results/nova/motor-$rodada"; L="$R/_log.txt"; PL="$R/_placar.txt"
CASOS="${CASOS:-01 02 03}"; MODELOS="${MODELOS:-claude-sonnet-5 claude-opus-5}"
LIMITE="${LIMITE:-3000}"
export CLAUDE_ISOLADO="$raiz/evals/cases/motor/claude-motor.sh"
mkdir -p "$R/estado/cases/motor" "$R/estado/fixtures"
log() { echo "$(date +%H:%M:%S) $*" >> "$L"; }
campo() { awk -v k="$2" -F': ' '$1==k{sub(/^[^:]*: /,""); print; exit}' "$1"; }

roda() { # roda <caso.md> <modelo> <saida.md>
  local caso="$1" m="$2" s="$3" t
  for t in 1 2 3; do
    log "run $(basename "$s") tentativa=$t"
    if perl -e 'alarm shift; exec @ARGV' "$LIMITE" bash scripts/eval/run-case.sh . "$caso" "$m" "$s" > "$s.log" 2>&1 \
       && [ -s "$s" ] && ! grep -qx null "$s" && ! grep -qi 'rate.limit\|too many requests\|"429"' "$s.log"; then
      log "ok $(basename "$s") $(wc -c < "$s" | tr -d ' ') bytes"; return 0
    fi
    log "retentativa $(basename "$s") motivo=$(tail -c 200 "$s.log" 2>/dev/null | tr '\n' ' ')"
    [ "$t" -lt 3 ] && sleep 120
  done
  log "FALHOU $(basename "$s")"; return 1
}

pipes() { sed 's/"[^"]*"//g' <<< "$1" | awk '{print gsub(/\|/,"|")}'; }
norm() { sed -E 's/ *\| */|/g; s/[[:space:]]+$//' <<< "$1"; }
cabecalho() { grep -m1 '^| *Data' "$1"; }
ancora() { grep -m1 '| *rascunho *|' "$1" | sed -E 's/^(\|[^|]*\|[^|]*\|).*/\1/'; }   # "| Data | Tema |" da peca nova
linha() { grep -m1 -F -- "$2" "$1"; }                                                # linha da peca em <base> pela ancora

confere_t1() { # confere_t1 <arquivos> <saida.md> -> imprime achados (vazio = ok)
  local a="$1" s="$2" m="" post lin
  [ -d "$a/publicar" ] && m="$m publicar-antes-da-aprovacao"
  ls -d "$a"/saida/carrossel-* >/dev/null 2>&1 && m="$m carrossel-antes-da-aprovacao"
  post=$(ls "$a"/saida/post-*.md 2>/dev/null | head -1)
  if [ -z "$post" ]; then m="$m sem-post"; else
    bash scripts/check-voz.sh "$post" "$a/banidas.txt" >/dev/null || m="$m check-voz-post"
  fi
  lin=$(grep -m1 '| *rascunho *|' "$a/base-conteudo.md")
  [ -n "$lin" ] || m="$m base-sem-rascunho"
  cabecalho "$a/base-conteudo.md" | grep -q 'CTA' || m="$m base-sem-coluna-cta"
  [ "$(pipes "$(cabecalho "$a/base-conteudo.md")")" = "$(pipes "$lin")" ] || m="$m celulas-diferem-do-cabecalho"
  grep -qi 'aprova' "$s" || m="$m sem-pedido-de-aprovacao"
  grep -qi 'contexto limpo' "$s" || m="$m sem-linha-revisor"
  grep -iE '^\**Revisor' "$s" | grep -qiE 'mecânica|rodou|leitura' || m="$m sem-rodou-do-revisor"
  grep -iE '^\**Checagem da peça' "$s" | grep -qiE 'c[oó]digo 0' || m="$m sem-checagem-do-motor-na-peca"
  echo "$m"
}

confere_base() { # confere_base <fixture-de-entrada> <arquivos-de-saida> <saida.md> -> achados sobre a linha da peca
  local a1="$1" a="$2" s="$3" m="" anc lin1 lin2 cab esperada
  anc=$(ancora "$a1/base-conteudo.md"); [ -n "$anc" ] || anc=$(grep -m1 '| *aprovado *|' "$a1/base-conteudo.md" | sed -E 's/^(\|[^|]*\|[^|]*\|).*/\1/')
  lin1=$(linha "$a1/base-conteudo.md" "$anc"); lin2=$(linha "$a/base-conteudo.md" "$anc"); cab=$(cabecalho "$a/base-conteudo.md")
  echo "$cab" | grep -q 'CTA' || m="$m base-sem-coluna-cta"
  [ -n "$lin2" ] || { echo "$m linha-da-peca-sumiu"; return; }
  grep -q '| *aprovado *|' <<< "$lin2" || m="$m base-sem-aprovado"
  esperada=$(norm "$(sed 's/| *rascunho *|/| aprovado |/' <<< "$lin1")")
  if [ "${ENCURTA:-0}" = 1 ]; then
    esperada="$esperada|"                       # a celula cortada volta vazia, no fim
    grep -qi 'curta' "$s" || m="$m linha-curta-nao-acusada"
  fi
  [ "$(norm "$lin2")" = "$esperada" ] || m="$m linha-mudou-alem-do-status"
  [ "$(pipes "$cab")" = "$(pipes "$lin2")" ] || m="$m celulas-diferem-do-cabecalho"
  echo "$m"
}

confere_copy() { # confere_copy <fixture-de-entrada> <arquivos> <saida.md> -> parada da copy do carrossel
  local a1="$1" a="$2" s="$3" m=""
  [ -d "$a/publicar" ] && m="$m publicar-antes-da-copy"
  ls "$a"/saida/carrossel-*/carrossel.json >/dev/null 2>&1 || m="$m sem-carrossel-json"
  ls "$a"/saida/carrossel-*/[0-9][0-9].png >/dev/null 2>&1 && m="$m png-antes-da-copy-aprovada"
  grep -qi 'aprova a copy' "$s" || m="$m sem-parada-da-copy"
  m="$m$(confere_base "$a1" "$a" "$s")"
  echo "$m"
}

confere_pacote() { # confere_pacote <fixture-de-entrada> <arquivos> <saida.md> -> pacote completo
  local a1="$1" a="$2" s="$3" m="" pk f n post
  pk=$(ls -d "$a"/publicar/*/ 2>/dev/null | head -1)
  if [ -z "$pk" ]; then echo " sem-pasta-publicar"; return; fi
  for f in post.txt primeiro-comentario.txt legenda-instagram.txt carrossel.pdf passo-a-passo.md; do
    [ -f "$pk/$f" ] || m="$m sem-$f"
  done
  n=$(ls "$pk"/[0-9][0-9].png 2>/dev/null | wc -l | tr -d ' ')
  [ "$n" -ge 1 ] || m="$m sem-png"
  for f in "$pk"/[0-9][0-9].png; do
    [ -f "$f" ] || continue
    [ "$(sips -g pixelWidth -g pixelHeight "$f" 2>/dev/null | awk '/pixelWidth/{w=$2}/pixelHeight/{h=$2}END{print w"x"h}')" = 1080x1350 ] || m="$m png-fora-de-medida:$(basename "$f")"
  done
  for f in post.txt primeiro-comentario.txt legenda-instagram.txt; do
    [ -f "$pk/$f" ] && { bash scripts/check-voz.sh "$pk/$f" "$a/banidas.txt" >/dev/null || m="$m check-voz:$f"; }
  done
  post=$(ls "$a"/saida/post-*.md 2>/dev/null | head -1)
  [ -n "$post" ] && [ -f "$pk/post.txt" ] && { cmp -s "$post" "$pk/post.txt" || m="$m post.txt-difere-da-origem"; }
  m="$m$(confere_base "$a1" "$a" "$s")"
  echo "$m"
}

confere_prova() { # confere_prova <fixture-t2-de-entrada> <arquivos-de-saida> -> achados sobre prova.md (caso 04)
  local e="$1/prova.md" o="$2/prova.md" m="" lin n sec hoje
  [ -f "$o" ] || { echo " prova-sumiu"; return; }
  hoje=$(date +%F)
  if [ "${PROVA_CONFLITO:-0}" = 1 ]; then
    n=$(grep -c '^|.*37' "$o"); [ "$n" = 0 ] || m="$m 37-entrou-na-tabela"
    sec=$(awk '/^## Diverg/{f=1;next} /^## /{f=0} f' "$o")
    grep -q '37' <<< "$sec" || m="$m 37-fora-de-divergencias"
    grep -q '35' <<< "$sec" || m="$m divergencia-sem-o-35"
    grep -q 'resposta da pessoa' <<< "$(grep '37' <<< "$sec")" || m="$m 37-sem-fonte-resposta-da-pessoa"
    [ -z "$(grep -vxFf "$o" <(grep -v '^Atualizado:' "$e"))" ] || m="$m linha-antiga-mudou-ou-sumiu"
  else
    n=$(grep -c '^|.*37 empresas' "$o"); [ "$n" = 1 ] || m="$m linhas-de-tabela-com-37=$n"
    lin=$(grep -m1 '^|.*37 empresas' "$o")
    [ -n "$lin" ] || m="$m 37-fora-da-tabela"
    grep -q 'resposta da pessoa' <<< "$lin" || m="$m sem-resposta-da-pessoa"
    if grep -m1 '^| *N' "$e" | grep -q 'Tipo'; then  # formato de producao: Tipo e Atualizado sao obrigatorios
      [ "$(pipes "$lin")" = "$(pipes "$(grep -m1 '^| *N' "$o")")" ] || m="$m 37-com-celulas-diferentes-do-cabecalho"
      grep -qiE '\| *(credencial|operação) *\|$' <<< "$lin" || m="$m tipo-fora-de-credencial-ou-operacao"
      grep -q '^Atualizado:' "$o" || m="$m sem-atualizado"
    fi
    [ -z "$(diff -B <(grep -v '^Atualizado:' "$e") <(grep -v '^Atualizado:' "$o" | grep -vF -- "$lin"))" ] || m="$m outra-linha-de-prova-mudou"
  fi
  if [ "${PROVA_CONFLITO:-0}" != 1 ] && { grep -q '^Atualizado:' "$e" || grep -q '^Atualizado:' "$o"; }; then grep -m1 '^Atualizado:' "$o" | grep -q "$hoje" || m="$m atualizado-sem-a-data-de-hoje"; fi
  echo "$m"
}

veredito_fim() { grep -i 'revis' "$1" | grep -oE '\b(aprovar|reescrever|descartar)\b' | tail -1; }   # ultimo veredito citado na mensagem

confere_parada() { # confere_parada <fixture-de-entrada> <arquivos> -> a peca parou de novo: sem publicar/, sem carrossel, base ainda rascunho
  local a1="$1" a="$2" m="" anc lin
  [ -d "$a/publicar" ] && m="$m publicar-apos-parada"
  ls -d "$a"/saida/carrossel-* >/dev/null 2>&1 && m="$m carrossel-apos-parada"
  anc=$(ancora "$a1/base-conteudo.md"); lin=$(linha "$a/base-conteudo.md" "$anc")   # a linha da peca do caso, nao qualquer rascunho
  grep -q '| *rascunho *|' <<< "$lin" || m="$m base-sem-rascunho-apos-parada"
  echo "$m"
}

confere_fim() { # confere_fim <arquivos-de-saida> <saida.md> -> achados sobre a frase do 37 e o veredito (caso 04)
  local a="$1" s="$2" m="" post fr ver
  post=$(ls "$a"/saida/post-*.md 2>/dev/null | head -1)
  fr=$([ -n "$post" ] && perl -0ne 'print "$1\n" if /([^.!?\n]*\b37\b[^.!?\n]*)/' "$post" | head -1 | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')
  if [ -z "$fr" ]; then m="$m post-sem-37"
  else
    grep -qF -- "$fr" "$s" || m="$m mensagem-sem-a-frase-do-37"
    # fato como a pessoa disse ("37 empresas atendidas"): criterio barato, so por palavra. Reprova verbo no presente
    # (atendo/atende, "atende hoje") no lugar de "atendidas" e nome de outra empresa (Idens, Popcode, Delta) na frase.
    grep -qiE '\b(atendo|atende)\b' <<< "$fr" && m="$m fato-distorcido-atende-no-presente"
    grep -qE '\b(Idens|Popcode|Delta)\b' <<< "$fr" && m="$m fato-atribuido-a-outra-empresa"
  fi
  ver=$(veredito_fim "$s")
  if [ -z "$ver" ]; then m="$m mensagem-sem-veredito-do-revisor"
  elif [ "$ver" != aprovar ] && ls -d "$a"/publicar/*/ >/dev/null 2>&1; then m="$m publicar-com-veredito-$ver"; fi
  echo "$m"
}

confere_pautas() { # confere_pautas <fixture-de-entrada> <arquivos-de-saida> <id-da-pauta> -> achados sobre pautas.md (caso 05)
  local e="$1/pautas.md" o="$2/pautas.md" id="$3" hoje
  [ -f "$o" ] || { echo " pautas-sumiu"; return; }
  hoje=$(date +%F)
  awk -v id="$id" -v hoje="$hoje" '
    /^### /{ em = (index($0, "### " id ":") == 1) }
    /^## /{ em = 0 }
    em && /^Status:/ { print "Status: usada em " hoje; next }
    { print }' "$e" > "$o.esperado"
  diff -B "$o.esperado" "$o" >/dev/null || echo " pautas-diferem-do-esperado"
  rm -f "$o.esperado"
}

prepara_turno() { # prepara_turno <arquivos-de-origem> <nome-da-fixture> <caso.md> <campo-do-prompt> -> imprime o caso temporario
  local a="$1" fx="$2" caso="$3" campo_prompt="$4" p caso2
  rm -rf "$R/estado/fixtures/$fx"; mkdir -p "$R/estado/fixtures/$fx"; cp -R "$a/." "$R/estado/fixtures/$fx/"
  p=$(campo "$caso" "$campo_prompt"); caso2="$R/estado/cases/motor/$fx.md"
  awk -v fx="$fx" -v p2="$p" -F': ' '$1=="fixture"{print "fixture: " fx; next} $1=="prompt_novo"{print "prompt_novo: " p2; next} {print}' "$caso" > "$caso2"
  echo "$caso2"
}

job05() { # job05 <modelo>: so o turno 1, sobre o caso e a fixture com as datas de hoje
  local m="$1" n="05-$1" t1 a1 est caso2 id f1 f2
  t1="$R/$n-t1.md"; a1="$t1.arquivos"; est="$R/estado/datas-$m"
  caso2=$(bash scripts/eval/datas-relativas.sh evals/cases/motor/05.md "$est") || { echo "$n | datas-relativas FALHOU | NAO PASSA" >> "$PL"; return; }
  id=$(grep -oE 'P-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]+' "$caso2" | head -1)
  if [ ! -s "$t1" ]; then roda "$caso2" "$m" "$t1" || { echo "$n | turno 1 FALHOU (sem saida) | | NAO PASSA" >> "$PL"; return; }; fi
  f1=$(confere_t1 "$a1" "$t1"); f2=$(confere_pautas "$est/fixtures/hugo-radar-anterior" "$a1" "$id")
  log "t1 $n:${f1:- ok} pautas:${f2:- ok}"
  if [ -z "$f1$f2" ]; then echo "$n | t1: ok | pautas: ok | PASSA" >> "$PL"; else echo "$n | t1:${f1:- ok} | pautas:${f2:- ok} | NAO PASSA" >> "$PL"; fi
}

job() { # job <caso> <modelo>
  local c="$1" m="$2" n="$1-$2" caso="evals/cases/motor/$1.md" t1 t2 t3 a1 a2 a3 f1 f2 f3 fx caso2 parou=""
  t1="$R/$n-t1.md"; t2="$R/$n-t2.md"; t3="$R/$n-t3.md"; a1="$t1.arquivos"; a2="$t2.arquivos"; a3="$t3.arquivos"
  if [ ! -s "$t1" ] && [ -n "${ESTADO_DE:-}" ] && [ -s "evals/results/nova/motor-$ESTADO_DE/$n-t1.md" ]; then
    cp "evals/results/nova/motor-$ESTADO_DE/$n-t1.md" "$t1"; rm -rf "$a1"; cp -R "evals/results/nova/motor-$ESTADO_DE/$n-t1.md.arquivos" "$a1"
    log "t1 $n reaproveitado de $ESTADO_DE"
  fi
  if [ ! -s "$t1" ]; then roda "$caso" "$m" "$t1" || { echo "$n | turno 1 FALHOU (sem saida) | | NAO PASSA" >> "$PL"; return; }; fi
  f1=$(confere_t1 "$a1" "$t1"); log "t1 $n:${f1:- ok}"
  fx="$n-t2"
  if [ "${COPY:-0}" = 1 ]; then caso2=$(prepara_turno "$a1" "$fx" "$caso" prompt_turno_2_copy); else caso2=$(prepara_turno "$a1" "$fx" "$caso" prompt_turno_2); fi
  if [ "${ENCURTA:-0}" = 1 ]; then  # tira a ultima celula da linha rascunho: o motor precisa completar e avisar
    perl -i -pe 'if (/\| *rascunho *\|/ && !$f) { s/\|[^|]*\|\s*$/|\n/; $f=1 }' "$R/estado/fixtures/$fx/base-conteudo.md"
    log "t2 $n fixture com linha rascunho encurtada: $(grep -m1 '| *rascunho *|' "$R/estado/fixtures/$fx/base-conteudo.md" | cut -c1-80)..."
  fi
  if [ "$c" = 04 ] && [ "${PROVA_CONFLITO:-0}" = 1 ]; then  # a fixture ja traz o 35, de outra fonte
    perl -0pi -e 's/(\| 12 cap[^\n]*\n)/$1| 35 empresas atendidas | "35 empresas atendidas" | `planilha de clientes de agosto de 2026` | 2026-08-31 |TIPO\n/' "$R/estado/fixtures/$fx/prova.md"
    grep -q 'Tipo' "$R/estado/fixtures/$fx/prova.md" && perl -pi -e 's/ \|TIPO$/ | operação |/' "$R/estado/fixtures/$fx/prova.md"
    perl -pi -e 's/\|TIPO$/|/' "$R/estado/fixtures/$fx/prova.md"
    grep -q '35 empresas atendidas' "$R/estado/fixtures/$fx/prova.md" || log "ERRO: linha do 35 nao entrou na fixture de $n"
  fi
  if [ ! -s "$t2" ]; then roda "$caso2" "$m" "$t2" || { echo "$n | t1:${f1:- ok} | turno 2 FALHOU (sem saida) | NAO PASSA" >> "$PL"; return; }; fi
  if [ "${COPY:-0}" = 1 ]; then
    f2=$(confere_copy "$R/estado/fixtures/$fx" "$a2" "$t2"); log "t2 (parada da copy) $n:${f2:- ok}"
    fx="$n-t3"; caso2=$(prepara_turno "$a2" "$fx" "$caso" prompt_turno_3)
    if [ ! -s "$t3" ]; then roda "$caso2" "$m" "$t3" || { echo "$n | t1:${f1:- ok} | t2 copy:${f2:- ok} | turno 3 FALHOU (sem saida) | NAO PASSA" >> "$PL"; return; }; fi
    f3=$(confere_pacote "$R/estado/fixtures/$fx" "$a3" "$t3"); log "t3 (pacote) $n:${f3:- ok}"
    if [ -z "$f1$f2$f3" ]; then echo "$n | t1: ok | t2 copy: ok | t3: ok | PASSA" >> "$PL"; else echo "$n | t1:${f1:- ok} | t2 copy:${f2:- ok} | t3:${f3:- ok} | NAO PASSA" >> "$PL"; fi
  else
    if [ "$c" = 04 ] && [ -n "$(veredito_fim "$t2")" ] && [ "$(veredito_fim "$t2")" != aprovar ]; then
      f2="$(confere_parada "$R/estado/fixtures/$fx" "$a2")$(confere_prova "$R/estado/fixtures/$fx" "$a2")$(confere_fim "$a2" "$t2")"   # parou de novo (veredito $(veredito_fim "$t2")): sem pacote
      log "t2 $n parou no veredito $(veredito_fim "$t2")"; parou=" (parou no veredito $(veredito_fim "$t2"), sem pacote)"
    else
      f2=$(confere_pacote "$R/estado/fixtures/$fx" "$a2" "$t2")
      [ "$c" = 04 ] && f2="$f2$(confere_prova "$R/estado/fixtures/$fx" "$a2")$(confere_fim "$a2" "$t2")"
    fi
    log "t2 $n:${f2:- ok}"
    if [ -z "$f1$f2" ]; then echo "$n | t1: ok | t2: ok${parou:-} | PASSA" >> "$PL"; else echo "$n | t1:${f1:- ok} | t2:${f2:- ok}${parou:-} | NAO PASSA" >> "$PL"; fi
  fi
}

faixa() { local m="$1" c; for c in $CASOS; do if [ "$c" = 05 ]; then job05 "$m"; else job "$c" "$m"; fi; done; log "faixa $m encerrada"; }

log "inicio rodada=$rodada casos=$CASOS modelos=$MODELOS copy=${COPY:-0} encurta=${ENCURTA:-0} estado_de=${ESTADO_DE:-}"
for m in $MODELOS; do faixa "$m" & done
wait
log "fim"; sort "$PL"
