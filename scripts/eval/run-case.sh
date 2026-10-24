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
# Campo opcional `ferramentas_extra: <ferramenta> <ferramenta> ...` (separado por espaco):
# soma-se ao que ja e liberado abaixo, no fim de --allowedTools. Sem o campo, a linha de
# comando sai identica. Usado so pelo caso de rede do radar-pautas (WebSearch, WebFetch).
extra=(); read -r -a extra <<< "$(campo ferramentas_extra)"
# A ferramenta Skill entra na lista porque skill com `allowed-tools` no cabecalho deixa de ser
# aprovada sozinha: em `claude -p` o pedido "Execute skill" nao tem quem aprove, a skill nao
# carrega e o cabecalho dela nunca vale (medido na Tarefa 2 de prontidao: base carrega,
# com `allowed-tools` nega).
# Alem de ler as skills do plugin, a execucao pode rodar o check-voz.sh e o checa-pautas.sh do
# repositorio: a sessao de um comprador tem esse script disponivel, e sem ele
# o portao media as skills sem a checagem mecanica que elas mandam rodar
# (ruling da Tarefa 5, depois do lote de contexto-negocio, que rodou inteiro
# sem essa permissao). A permissao e por prefixo (`:*`): autoriza qualquer
# comando que comece pela chamada do script, inclusive um encadeamento depois
# dela; nao e "so esse script" no sentido estrito. Basta aqui porque o lado
# executado nao e adversario; nao reutilize o padrao onde for.
( cd "$work" && "${CLAUDE_ISOLADO:-$dir/claude-isolado.sh}" --model "$modelo" --plugin-dir "$plugin" --allowedTools "Skill" "Read(/$plugin/skills/**)" "Bash(bash $plugin/scripts/check-voz.sh:*)" "Bash($plugin/scripts/check-voz.sh:*)" "Bash(bash $plugin/scripts/checa-pautas.sh:*)" "Bash($plugin/scripts/checa-pautas.sh:*)" ${extra[@]+"${extra[@]}"} --permission-mode acceptEdits --output-format json "$pr" ) | jq -r '.result' > "$saida"
mkdir -p "$saida.arquivos" && cp -R "$work/." "$saida.arquivos/"
