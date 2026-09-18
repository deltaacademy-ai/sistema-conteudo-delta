#!/usr/bin/env bash
# claude falso para os testes do harness (test-preferencia-retentativa.sh).
# Imita o claude -p --output-format json: na primeira chamada de cada pedido sai com 1 e
# imprime o JSON de erro que o claude real imprime em limite de sessao (is_error true,
# api_error_status 429); na segunda, responde. Assim toda chamada exercita a retentativa.
# Distingue o tipo de pedido pelo texto: mensagem com "CANDIDATO A:" e julgamento;
# prompt de sistema com "briefing factual" e extracao; prompt de sistema com
# "<sobre_mim>" e geracao com voz; o resto e geracao neutra.
# FAKE_DIR guarda o contador de chamadas; FAKE_SEMPRE_OK=1 desliga a falha da primeira chamada.
cnt="${FAKE_DIR:?}/contador"; n=$(cat "$cnt" 2>/dev/null || echo 0); n=$((n + 1)); echo "$n" > "$cnt"
prompt="${@: -1}"; sys=""
args=("$@"); for ((i = 0; i < ${#args[@]}; i++)); do [ "${args[$i]}" = "--append-system-prompt" ] && sys="${args[$((i + 1))]}"; done
if [ "${FAKE_SEMPRE_OK:-0}" != 1 ] && [ $((n % 2)) -eq 1 ]; then
  printf '{"type":"result","is_error":true,"api_error_status":429,"result":"You have hit your session limit","total_cost_usd":0}\n'
  exit 1
fi
case "$prompt" in
  *"CANDIDATO A:"*)
    # escolhe o candidato que carrega a marca do voz.md falso
    a=$(printf '%s' "$prompt" | sed -n '/^CANDIDATO A:/,/^CANDIDATO B:/p')
    if printf '%s' "$a" | grep -q 'MARCA-VOZ'; then v=A; else v=B; fi
    r="{\"vencedor\":\"$v\",\"motivo\":\"teste: candidato com a marca\"}";;
  *)
    if printf '%s' "$sys" | grep -q 'briefing factual'; then
      r="- tipo: caso, 600 caracteres
- assunto: teste do harness
- fatos: numero 42, nome Beta, data 2026-09-18"
    elif printf '%s' "$sys" | grep -q '<sobre_mim>'; then
      # recola uma sequencia de 10 palavras do post real 1 (3 sequencias distintas de 8 palavras)
      r="MARCA-VOZ Texto com voz. um dois tres quatro cinco seis sete oito nove dez. Fato 42, nome Beta."
    else
      r="Texto neutro sobre o numero 42 e o nome Beta em 2026-09-18. Segunda frase curta."
      [ "${FAKE_NEUTRO_REUSA:-0}" = 1 ] && r="Texto neutro: um dois tres quatro cinco seis sete oito nove dez. Fato 42, nome Beta."
    fi;;
esac
jq -n --arg r "$r" '{type:"result", is_error:false, result:$r, total_cost_usd:0}'
