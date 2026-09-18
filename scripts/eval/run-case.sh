#!/usr/bin/env bash
set -euo pipefail
# uso: run-case.sh <plugin-dir> <caso.md> <modelo> <saida.md> [novo|antigo]
#
# Campo opcional do caso: `retido: <nome-de-arquivo>`. O arquivo com esse nome e
# removido de materiais/ na copia de trabalho antes de rodar (leave-one-out do portao
# de entrevista-voz: o post que vira briefing no teste pareado nao pode ter sido lido
# pelo compilador). O nome precisa existir na fixture, senao o caso falha aqui, antes
# de gastar modelo.
dir=$(cd "$(dirname "$0")" && pwd)
plugin=$(cd "$1" && pwd); caso="$2"; modelo="$3"; saida="$4"; lado="${5:-novo}"
raiz=$(cd "$(dirname "$caso")/../.." && pwd)
campo() { awk -v k="$1" -F': ' '$1==k{sub(/^[^:]*: /,""); print; exit}' "$caso"; }
if [ "$lado" = antigo ]; then fx=$(campo fixture_legado); pr=$(campo prompt_antigo); else fx=$(campo fixture); pr=$(campo prompt_novo); fi
work=$(mktemp -d); cp -R "$raiz/fixtures/$fx/." "$work/"
retido=$(campo retido)
if [ -n "$retido" ]; then
  [ -f "$work/materiais/$retido" ] || { echo "retido nao existe na fixture $fx: materiais/$retido" >&2; exit 1; }
  rm -f "$work/materiais/$retido"
fi
( cd "$work" && "${CLAUDE_ISOLADO:-$dir/claude-isolado.sh}" --model "$modelo" --plugin-dir "$plugin" --allowedTools "Read(/$plugin/skills/**)" --permission-mode acceptEdits --output-format json "$pr" ) | jq -r '.result' > "$saida"
mkdir -p "$saida.arquivos" && cp -R "$work/." "$saida.arquivos/"
