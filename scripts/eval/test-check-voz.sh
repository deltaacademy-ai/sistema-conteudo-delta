#!/usr/bin/env bash
set -u
d=$(mktemp -d)
printf 'texto limpo, sem nada.\n' > "$d/ok.md"
printf 'texto com travess\xe2\x80\x94o\n' > "$d/trav.md"
printf 'vamos alavancar isso\n' > "$d/ban.md"
printf 'alavancar\n' > "$d/banidas.txt"
s=scripts/check-voz.sh
bash $s "$d/ok.md" "$d/banidas.txt" >/dev/null && echo "ok limpo" || { echo "FALHA limpo"; exit 1; }
bash $s "$d/trav.md" >/dev/null && { echo "FALHA travessao"; exit 1; } || echo "ok travessao"
bash $s "$d/ban.md" "$d/banidas.txt" >/dev/null && { echo "FALHA banida"; exit 1; } || echo "ok banida"
