#!/usr/bin/env bash
set -euo pipefail
# uso: run-case.sh <plugin-dir> <caso.md> <modelo> <saida.md> [novo|antigo]
dir=$(cd "$(dirname "$0")" && pwd)
plugin=$(cd "$1" && pwd); caso="$2"; modelo="$3"; saida="$4"; lado="${5:-novo}"
raiz=$(cd "$(dirname "$caso")/../.." && pwd)
campo() { awk -v k="$1" -F': ' '$1==k{sub(/^[^:]*: /,""); print; exit}' "$caso"; }
if [ "$lado" = antigo ]; then fx=$(campo fixture_legado); pr=$(campo prompt_antigo); else fx=$(campo fixture); pr=$(campo prompt_novo); fi
work=$(mktemp -d); cp -R "$raiz/fixtures/$fx/." "$work/"
( cd "$work" && "$dir/claude-isolado.sh" --model "$modelo" --plugin-dir "$plugin" --allowedTools "Read(/$plugin/skills/**)" --permission-mode acceptEdits --output-format json "$pr" ) | jq -r '.result' > "$saida"
mkdir -p "$saida.arquivos" && cp -R "$work/." "$saida.arquivos/"
