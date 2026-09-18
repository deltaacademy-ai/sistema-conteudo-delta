#!/usr/bin/env bash
set -euo pipefail
# uso: coletar-saida.sh <saida.md> [fixture-dir]
#
# Imprime tudo que uma execucao entregou: a mensagem final (que run-case.sh
# grava em <saida.md>) mais os arquivos que a execucao escreveu no diretorio de
# trabalho, cada um rotulado pelo nome. Arquivo escrito e todo arquivo de
# <saida.md>.arquivos que nao existe na fixture ou que mudou em relacao a ela,
# o que inclui saida/**.
#
# Motivo: run-case.sh guarda so a mensagem final. Em contexto-negocio e em
# entrevista-voz o entregavel sao os arquivos, e a mensagem final as vezes so
# diz "esta nos blocos acima". Sem esta coleta o juiz compara um resumo de um
# lado com o texto inteiro do outro.
saida=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
fx=""; [ $# -ge 2 ] && [ -n "$2" ] && fx=$(cd "$2" && pwd)
cat "$saida"
arq="$saida.arquivos"
[ -d "$arq" ] || exit 0
cd "$arq"
find . -type f ! -name '.DS_Store' | sed 's|^\./||' | LC_ALL=C sort | while IFS= read -r rel; do
  if [ -n "$fx" ] && [ -f "$fx/$rel" ] && cmp -s "$fx/$rel" "$rel"; then continue; fi
  printf '\n=== arquivo gravado pela execucao: %s ===\n' "$rel"
  cat "$rel"
done
