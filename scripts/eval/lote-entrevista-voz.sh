#!/usr/bin/env bash
set -u
# uso: lote-entrevista-voz.sh <rodada> [paralelismo]
#
# Roda o portao inteiro do especialista entrevista-voz: os 5 casos de
# evals/cases/entrevista-voz nos dois modelos (compilacao via run-case.sh, com o
# material do campo `retido:` fora de materiais/) e, para cada voz.md, a validacao
# mecanica (validar-voz.sh) e o teste pareado (preferencia-voz.sh, leave-one-out com o
# mesmo material retido). N jobs por vez (padrao 2), cada job = um caso num modelo.
#
# Pensado para rodar em fundo:
#   nohup bash scripts/eval/lote-entrevista-voz.sh r3 > /dev/null 2>&1 &
#   tail -f evals/results/preferencia/entrevista-voz-r3/_log.txt
# Idempotente: pula a compilacao quando o voz.md ja existe e o portao quando o JSON ja
# existe, entao pode ser relancado depois de um limite de sessao. Sem `timeout` no
# macOS, o relogio de cada passo e um alarm do perl que sobrevive ao exec.
#
# Saidas (fora do git):
#   evals/results/nova/entrevista-voz-<rodada>/<caso>-<modelo>.md{,.arquivos/,.log,.validacao.txt}
#   evals/results/preferencia/entrevista-voz-<rodada>/<caso>-<modelo>.json{,.arquivos/,.log}
#   evals/results/preferencia/briefings-cache/  (briefings extraidos uma vez, por post)
rodada="${1:?rodada, ex.: r3}"; par="${2:-2}"
raiz=$(cd "$(dirname "$0")/../.." && pwd); cd "$raiz"
export R="evals/results/nova/entrevista-voz-$rodada" P="evals/results/preferencia/entrevista-voz-$rodada"
export BRIEFINGS_CACHE="$raiz/evals/results/preferencia/briefings-cache" MAT="evals/fixtures/hugo-materiais/materiais"
export L="$P/_log.txt" LIMITE_COMPILA="${LIMITE_COMPILA:-3000}" LIMITE_PORTAO="${LIMITE_PORTAO:-3600}"
mkdir -p "$R" "$P" "$BRIEFINGS_CACHE"
log() { echo "$(date +%H:%M:%S) $*" >> "$L"; }
export -f log

job() {
  local c="$1" m="$2" n="$1-$2" caso="evals/cases/entrevista-voz/$1.md" t ret vozf
  vozf="$R/$n.md.arquivos/voz.md"
  ret=$(awk -F': ' '$1=="retido"{sub(/^[^:]*: /,""); print; exit}' "$caso")
  if [ ! -s "$vozf" ]; then
    for t in 1 2 3; do
      log "compila $n tentativa=$t modelo=$m retido=$ret"
      if perl -e 'alarm shift; exec @ARGV' "$LIMITE_COMPILA" bash scripts/eval/run-case.sh . "$caso" "$m" "$R/$n.md" > "$R/$n.log" 2>&1 && [ -s "$vozf" ]; then
        log "ok compila $n $(perl -CSD -ne '$k += length; END { print $k + 0 }' "$vozf") caracteres"; break
      fi
      log "retentativa compila $n tentativa=$t motivo=$(tail -c 200 "$R/$n.log" 2>/dev/null | tr '\n' ' ')"; sleep 300
    done
    [ -s "$vozf" ] || { log "FALHOU compila $n"; return; }
  fi
  if bash scripts/eval/validar-voz.sh "$vozf" "$R/$n.md.arquivos/banidas.txt" > "$R/$n.validacao.txt" 2>&1; then
    log "validacao ok $n $(grep -E '^(tamanho|banidas)' "$R/$n.validacao.txt" | tr '\n' ';')"
  else
    log "VALIDACAO FALHOU $n $(grep -E '^[A-Z]+:' "$R/$n.validacao.txt" | cut -c1-80 | tr '\n' ';')"
  fi
  [ -s "$P/$n.json" ] && { log "portao ja pronto $n"; return; }
  for t in 1 2 3; do
    log "portao $n tentativa=$t retido=$ret"
    if perl -e 'alarm shift; exec @ARGV' "$LIMITE_PORTAO" bash scripts/eval/preferencia-voz.sh "$vozf" "$MAT" "$P/$n.json" "$m" "$ret" > "$P/$n.log" 2>&1 && [ -s "$P/$n.json" ]; then
      log "ok portao $n $(jq -r '"\(.resultado) voz=\(.vitorias_voz) neutro=\(.vitorias_neutro) empate=\(.empates) reuso=\(.anuladas_por_reuso) pos=\([.pares[].posicao_voz]|join("")) reusoVN=\([.pares[]|"\(.reuso_voz)/\(.reuso_neutro)"]|join(","))"' "$P/$n.json")"; return
    fi
    log "retentativa portao $n tentativa=$t motivo=$(tail -c 200 "$P/$n.log" 2>/dev/null | tr '\n' ' ')"; sleep 300
  done
  log "FALHOU portao $n"
}
export -f job
log "INICIO lote $rodada paralelismo=$par"
for c in 01 02 03 04 05; do for m in claude-sonnet-5 claude-opus-5; do echo "$c $m"; done; done \
  | xargs -P "$par" -n 2 bash -c 'job "$0" "$1"'
log "FIM lote $rodada voz=$(ls "$R"/*.md.arquivos/voz.md 2>/dev/null | wc -l | tr -d ' ') json=$(ls "$P"/*.json 2>/dev/null | wc -l | tr -d ' ')"
