#!/usr/bin/env bash
set -u
# uso: bash scripts/eval/test-chamar-claude.sh
# Prova que chamar_claude (briefing-lib.sh) so entra na espera longa de limite quando o
# sinal e real (api_error_status 429 ou 529, "rate limit", "session limit", "overloaded")
# e nao quando a mensagem de erro so contem a palavra "limite" (menor da re-revisao da
# Tarefa 4: "limit" casava dentro de "limite" e custava 300 s por tentativa). Usa um
# claude falso que devolve sempre o JSON de $FALSO_RESPOSTA e sai com 1.
dir=$(cd "$(dirname "$0")" && pwd)
d=$(mktemp -d); falhou=0
ok() { echo "ok $1"; }
falha() { echo "FALHA $1"; falhou=1; }
arq="$d"; extrator=teste
. "$dir/briefing-lib.sh"
printf '#!/usr/bin/env bash\ncat "$FALSO_RESPOSTA"; exit 1\n' > "$d/falso.sh"; chmod +x "$d/falso.sh"
export CLAUDE_ISOLADO="$d/falso.sh" TENTATIVAS=2 ESPERA=0 ESPERA_LIMITE=0 FALSO_RESPOSTA="$d/resposta"

caso() {  # caso <nome> <json-do-claude> <espera-de-limite: sim|nao>
  printf '%s\n' "$2" > "$d/resposta"
  chamar_claude "$d/bruto.json" --model teste "pedido" 2> "$d/err.txt" && falha "$1: chamada que falha devolveu 0"
  if grep -q 'limite da API' "$d/err.txt"; then deu=sim; else deu=nao; fi
  [ "$deu" = "$3" ] && ok "$1" || { falha "$1 (esperava espera de limite=$3, deu $deu)"; cat "$d/err.txt"; }
}
caso "status 429 entra na espera de limite" '{"type":"result","is_error":true,"api_error_status":429,"result":"x"}' sim
caso "status 529 entra na espera de limite" '{"type":"result","is_error":true,"api_error_status":529,"result":"x"}' sim
caso "mensagem de session limit entra" '{"type":"result","is_error":true,"result":"You have hit your session limit, resets 11:40am"}' sim
caso "mensagem de rate limit entra" '{"type":"result","is_error":true,"result":"rate_limit_error: too many requests"}' sim
caso "overloaded entra" '{"type":"result","is_error":true,"result":"overloaded_error"}' sim
caso "palavra limite em erro comum nao entra" '{"type":"result","is_error":true,"result":"erro: limite de contexto do prompt excedido"}' nao
caso "erro generico nao entra" '{"type":"result","is_error":true,"result":"internal server error"}' nao
caso "resultado vazio sem erro nao entra" '{"type":"result","is_error":false,"result":""}' nao
rm -rf "$d"
exit $falhou
