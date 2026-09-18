#!/usr/bin/env bash
set -euo pipefail
# uso: judge-msg.sh <caso.md> <fixture-contexto> <A-saida> <A-fixture> <B-saida> <B-fixture>
#
# Monta a mensagem que vai ao juiz e imprime no stdout. Extraido de judge.sh
# para o teste test-judge-cego.sh poder conferir a mensagem sem gastar modelo.
#
# O juiz recebe: voz e ICP do autor, o campo `pedido` do caso (pedido de negocio
# neutro, sem nome de skill nem de plugin), a rubrica e as duas saidas completas.
# Nunca recebe prompt_novo nem prompt_antigo, que dizem qual plugin rodou.
# Tudo passa por limpar-nomes.sh antes de sair.
caso="$1"; ctx="$2"; a="$3"; fa="$4"; b="$5"; fb="$6"
dir=$(cd "$(dirname "$0")" && pwd)
pedido=$(awk -F': ' '$1=="pedido"{sub(/^pedido: /,""); print; exit}' "$caso")
[ -n "$pedido" ] || { echo "caso sem campo pedido: $caso" >&2; exit 1; }
rubrica=$(awk 'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' "$caso")
printf 'CONTEXTO (voz e ICP do autor):\n%s\n\n%s\n\nPEDIDO:\n%s\n\nRUBRICA:\n%s\n\nA:\n%s\n\nB:\n%s\n' \
  "$(cat "$ctx/voz.md")" "$(cat "$ctx/icp.md")" "$pedido" "$rubrica" \
  "$("$dir/coletar-saida.sh" "$a" "$fa")" "$("$dir/coletar-saida.sh" "$b" "$fb")" \
  | "$dir/limpar-nomes.sh"
