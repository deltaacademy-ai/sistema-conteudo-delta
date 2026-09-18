#!/usr/bin/env bash
set -euo pipefail
# uso: judge.sh <caso.md> <saida-nova> <saida-antiga> <veredito.json> <fixture-dir>
caso="$1"; nova="$2"; antiga="$3"; out="$4"; fx="$5"
dir=$(cd "$(dirname "$0")" && pwd)
raiz=$(cd "$(dirname "$caso")/../.." && pwd)
campo() { awk -v k="$1" -F': ' '$1==k{sub(/^[^:]*: /,""); print; exit}' "$caso"; }
fxn="$raiz/fixtures/$(campo fixture)"; fxa="$raiz/fixtures/$(campo fixture_legado)"
[ -d "$fxa" ] || fxa=""
if [ $((RANDOM % 2)) -eq 0 ]; then A="$nova"; fA="$fxn"; B="$antiga"; fB="$fxa"; mapa=nova
else A="$antiga"; fA="$fxa"; B="$nova"; fB="$fxn"; mapa=antiga; fi
msg=$("$dir/judge-msg.sh" "$caso" "$fx" "$A" "$fA" "$B" "$fB")
res=$(cd "$(mktemp -d)" && "$dir/claude-isolado.sh" --model claude-opus-5 --append-system-prompt "$(cat "$dir/judge-prompt.md")" --output-format json "$msg" | jq -r .result | sed -n '/^{/,/}$/p')
v=$(echo "$res" | jq -r .vencedor)
if [ "$v" = empate ]; then r=empate; elif [ "$v" = A ]; then r=$mapa; else [ "$mapa" = nova ] && r=antiga || r=nova; fi
echo "$res" | jq --arg r "$r" '{vencedor:$r, motivo:.motivo}' > "$out"
