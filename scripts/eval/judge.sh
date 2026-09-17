#!/usr/bin/env bash
set -euo pipefail
# uso: judge.sh <caso.md> <saida-nova> <saida-antiga> <veredito.json> <fixture-dir>
caso="$1"; nova="$2"; antiga="$3"; out="$4"; fx="$5"
dir=$(cd "$(dirname "$0")" && pwd)
if [ $((RANDOM % 2)) -eq 0 ]; then A="$nova"; B="$antiga"; mapa=nova; else A="$antiga"; B="$nova"; mapa=antiga; fi
msg=$(printf 'CONTEXTO:\n%s\n\n%s\n\nPEDIDO E RUBRICA:\n%s\n\nA:\n%s\n\nB:\n%s\n' "$(cat "$fx/voz.md")" "$(cat "$fx/icp.md")" "$(cat "$caso")" "$(cat "$A")" "$(cat "$B")")
res=$(cd "$(mktemp -d)" && "$dir/claude-isolado.sh" --model claude-opus-5 --append-system-prompt "$(cat "$dir/judge-prompt.md")" --output-format json "$msg" | jq -r .result | sed -n '/^{/,/}$/p')
v=$(echo "$res" | jq -r .vencedor)
if [ "$v" = empate ]; then r=empate; elif [ "$v" = A ]; then r=$mapa; else [ "$mapa" = nova ] && r=antiga || r=nova; fi
echo "$res" | jq --arg r "$r" '{vencedor:$r, motivo:.motivo}' > "$out"
