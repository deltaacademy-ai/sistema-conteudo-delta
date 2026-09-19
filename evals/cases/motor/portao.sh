#!/usr/bin/env bash
# Portao do motor, sem juiz: cada caso e um fluxo completo em dois turnos, por modelo.
#
# Turno 1: run-case.sh com prompt_novo (o tema). Precisa parar na aprovacao da peca
#   principal: post em saida/, linha `rascunho` em base-conteudo.md, pedido de aprovacao
#   na resposta, nenhum carrossel e nenhuma pasta publicar/.
# Turno 2: run-case.sh com prompt_turno_2 ("aprovado, segue ate o pacote") sobre uma
#   fixture temporaria que e a copia do que o turno 1 deixou em disco (a conversa nao
#   e retomada; o estado do motor vive em saida/ e na base). Precisa entregar
#   publicar/<data>-<tema>/ com post.txt, primeiro-comentario.txt, legenda-instagram.txt,
#   NN.png em 1080x1350, carrossel.pdf e passo-a-passo.md; check-voz limpo nos .txt;
#   base com a mesma linha do turno 1 e so a celula Status trocada para `aprovado`
#   (coluna CTA intacta).
#
# Duas faixas em paralelo (uma por modelo, casos em sequencia), ate 3 tentativas por
# execucao, alarm do perl no lugar do `timeout` que o macOS nao tem. Log em
# evals/results/nova/motor-<rodada>/_log.txt e placar em _placar.txt.
#
# Contagem de celulas: em cada turno a linha que o fluxo escreveu (rascunho no turno 1,
#   aprovado no turno 2) precisa ter o mesmo numero de celulas que o cabecalho, porque a
#   base carrega colunas de controle (CTA, Assinatura) que uma linha curta quebra em
#   silencio. Com ENCURTA=1 o portao tira a ultima celula da linha rascunho antes do
#   turno 2 e passa a exigir que o motor complete a linha e diga isso na resposta.
# Com ESTADO_DE=<rodada> o turno 1 e reaproveitado daquela rodada (so o turno 2 roda).
#
# uso: bash evals/cases/motor/portao.sh [rodada]      (env: CASOS, MODELOS, LIMITE, ESTADO_DE, ENCURTA)
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
    log "retentativa $(basename "$s") motivo=$(tail -c 200 "$s.log" 2>/dev/null | tr '\n' ' ')"; sleep 120
  done
  log "FALHOU $(basename "$s")"; return 1
}

pipes() { awk '{print gsub(/\|/,"|")}' <<< "$1"; }

confere_t1() { # confere_t1 <arquivos> <saida.md> -> imprime achados (vazio = ok)
  local a="$1" s="$2" m="" post
  [ -d "$a/publicar" ] && m="$m publicar-antes-da-aprovacao"
  ls -d "$a"/saida/carrossel-* >/dev/null 2>&1 && m="$m carrossel-antes-da-aprovacao"
  post=$(ls "$a"/saida/post-*.md 2>/dev/null | head -1)
  if [ -z "$post" ]; then m="$m sem-post"; else
    bash scripts/check-voz.sh "$post" "$a/banidas.txt" >/dev/null || m="$m check-voz-post"
  fi
  grep -q '| *rascunho *|' "$a/base-conteudo.md" || m="$m base-sem-rascunho"
  [ "$(pipes "$(grep -m1 '^| *Data' "$a/base-conteudo.md")")" = "$(pipes "$(grep -m1 '| *rascunho *|' "$a/base-conteudo.md")")" ] || m="$m celulas-diferem-do-cabecalho"
  head -20 "$a/base-conteudo.md" | grep -q 'CTA' || m="$m base-sem-coluna-cta"
  grep -qi 'aprova' "$s" || m="$m sem-pedido-de-aprovacao"
  grep -qi 'contexto limpo' "$s" || m="$m sem-linha-revisor"
  echo "$m"
}

confere_t2() { # confere_t2 <fixture-t2> <arquivos-t2> <saida-t2> -> imprime achados (vazio = ok)
  local a1="$1" a="$2" s="$3" m="" pk f n cab lin1 esperada post
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
  cab=$(grep -m1 '^| *Data' "$a/base-conteudo.md")
  echo "$cab" | grep -q 'CTA' || m="$m base-sem-coluna-cta"
  lin1=$(grep -m1 '| *rascunho *|' "$a1/base-conteudo.md")
  esperada=$(sed 's/| *rascunho *|/| aprovado |/' <<< "$lin1")
  if [ "${ENCURTA:-0}" = 1 ]; then
    grep -q '| *aprovado *|' "$a/base-conteudo.md" || m="$m base-sem-aprovado"
    grep -qi 'curta' "$s" || m="$m linha-curta-nao-acusada"
  elif ! grep -qF -- "$esperada" "$a/base-conteudo.md"; then
    grep -q '| *aprovado *|' "$a/base-conteudo.md" && m="$m linha-mudou-alem-do-status" || m="$m base-sem-aprovado"
  fi
  [ "$(pipes "$cab")" = "$(pipes "$(grep -m1 '| *aprovado *|' "$a/base-conteudo.md")")" ] || m="$m celulas-diferem-do-cabecalho"
  echo "$m"
}

job() { # job <caso> <modelo>
  local c="$1" m="$2" n="$1-$2" caso="evals/cases/motor/$1.md" t1 t2 a1 a2 f1 f2 p2 fx caso2
  t1="$R/$n-t1.md"; t2="$R/$n-t2.md"; a1="$t1.arquivos"; a2="$t2.arquivos"
  if [ ! -s "$t1" ] && [ -n "${ESTADO_DE:-}" ] && [ -s "evals/results/nova/motor-$ESTADO_DE/$n-t1.md" ]; then
    cp "evals/results/nova/motor-$ESTADO_DE/$n-t1.md" "$t1"; rm -rf "$a1"; cp -R "evals/results/nova/motor-$ESTADO_DE/$n-t1.md.arquivos" "$a1"
    log "t1 $n reaproveitado de $ESTADO_DE"
  fi
  if [ ! -s "$t1" ]; then roda "$caso" "$m" "$t1" || { echo "$n | turno 1 FALHOU (sem saida) | | NAO PASSA" >> "$PL"; return; }; fi
  f1=$(confere_t1 "$a1" "$t1"); log "t1 $n:${f1:- ok}"
  fx="$n-t2"; rm -rf "$R/estado/fixtures/$fx"; mkdir -p "$R/estado/fixtures/$fx"; cp -R "$a1/." "$R/estado/fixtures/$fx/"
  if [ "${ENCURTA:-0}" = 1 ]; then  # tira a ultima celula da linha rascunho: o motor precisa completar e avisar
    perl -i -pe 'if (/\| *rascunho *\|/ && !$f) { s/\|[^|]*\|\s*$/|\n/; $f=1 }' "$R/estado/fixtures/$fx/base-conteudo.md"
    log "t2 $n fixture com linha rascunho encurtada: $(grep -m1 '| *rascunho *|' "$R/estado/fixtures/$fx/base-conteudo.md" | cut -c1-80)..."
  fi
  p2=$(campo "$caso" prompt_turno_2); caso2="$R/estado/cases/motor/$fx.md"
  awk -v fx="$fx" -v p2="$p2" -F': ' '$1=="fixture"{print "fixture: " fx; next} $1=="prompt_novo"{print "prompt_novo: " p2; next} {print}' "$caso" > "$caso2"
  if [ ! -s "$t2" ]; then roda "$caso2" "$m" "$t2" || { echo "$n | t1:${f1:- ok} | turno 2 FALHOU (sem saida) | NAO PASSA" >> "$PL"; return; }; fi
  f2=$(confere_t2 "$R/estado/fixtures/$fx" "$a2" "$t2"); log "t2 $n:${f2:- ok}"
  if [ -z "$f1" ] && [ -z "$f2" ]; then echo "$n | t1: ok | t2: ok | PASSA" >> "$PL"; else echo "$n | t1:${f1:- ok} | t2:${f2:- ok} | NAO PASSA" >> "$PL"; fi
}

faixa() { local m="$1" c; for c in $CASOS; do job "$c" "$m"; done; log "faixa $m encerrada"; }

log "inicio rodada=$rodada casos=$CASOS modelos=$MODELOS"
for m in $MODELOS; do faixa "$m" & done
wait
log "fim"; sort "$PL"
