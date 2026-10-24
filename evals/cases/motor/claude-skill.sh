#!/usr/bin/env bash
# uso: CLAUDE_ISOLADO=evals/cases/motor/claude-skill.sh scripts/eval/run-case.sh ...
#
# Wrapper do run-case.sh para provar o `allowed-tools` dos frontmatters. Em `claude -p`
# a propria ferramenta Skill pede permissao e o pedido nao tem quem aprove, entao a skill
# nem carrega e o cabecalho dela nunca vale. Este wrapper libera so a ferramenta Skill
# (a lista de --allowedTools do run-case.sh termina na proxima flag, entao o item entra
# antes de --permission-mode) e nada mais: checkup.sh, render e jq ficam por conta do
# cabecalho da skill. Sem isso o caso checkup.md nao mede nada.
dir=$(cd "$(dirname "$0")" && pwd); raiz=$(cd "$dir/../../.." && pwd)
args=()
for a in "$@"; do
  [ "$a" = "--permission-mode" ] && args+=("Skill")
  args+=("$a")
done
exec "$raiz/scripts/eval/claude-isolado.sh" "${args[@]}"
