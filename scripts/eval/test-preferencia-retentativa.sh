#!/usr/bin/env bash
set -u
# uso: bash scripts/eval/test-preferencia-retentativa.sh
# Prova, sem gastar modelo (claude-falso.sh no lugar do claude-isolado.sh):
# 1. a retentativa de chamar_claude roda sob set -euo pipefail quando o claude sai com
#    codigo diferente de zero (achado 6 da revisao da Tarefa 4): o falso falha na primeira
#    chamada de cada pedido com o JSON de limite de sessao (exit 1, is_error, 429) e a
#    segunda responde; o script inteiro chega ao fim com 3 pares julgados;
# 2. o JSON de erro nunca vira candidato (is_error e tratado);
# 3. leave-one-out: o briefing dos 3 pares vem do material retido;
# 4. a medida de reuso conta 8-gramas distintos contra os posts reais e anula a vitoria
#    quando o candidato com voz reusa mais que o dobro do neutro (e nao anula quando
#    os dois reusam o mesmo tanto);
# 5. run-case.sh remove o material do campo retido: da copia de trabalho.
dir=$(cd "$(dirname "$0")" && pwd)
raiz=$(cd "$dir/../.." && pwd)
d=$(mktemp -d); falhou=0
ok() { echo "ok $1"; }
falha() { echo "FALHA $1"; falhou=1; }
export FAKE_DIR="$d"; export CLAUDE_ISOLADO="$dir/claude-falso.sh"
export TENTATIVAS=3 ESPERA=0 ESPERA_LIMITE=0
chmod +x "$dir/claude-falso.sh"

mkdir -p "$d/mat"
printf 'Post real um: um dois tres quatro cinco seis sete oito nove dez, e mais coisa.\n' > "$d/mat/a-real-1.md"
printf 'Post real dois, com outro texto sem repeticao.\n' > "$d/mat/b-real-2.md"
printf 'Post real tres, texto diferente ainda.\n' > "$d/mat/c-real-3.md"
printf '<sobre_mim>\n<uso>perfil falso</uso>\n</sobre_mim>\n' > "$d/voz.md"

echo 0 > "$d/contador"
if bash "$dir/preferencia-voz.sh" "$d/voz.md" "$d/mat" "$d/saida.json" claude-sonnet-5 b-real-2.md > "$d/log.txt" 2>&1; then
  ok "preferencia-voz.sh chega ao fim com o claude falhando na primeira chamada"
else
  falha "preferencia-voz.sh abortou"; tail -n 20 "$d/log.txt"
fi
chamadas=$(cat "$d/contador")
# 1 briefing + 6 geracoes + 3 juizes = 10 pedidos, cada um com 1 falha e 1 sucesso = 20 chamadas
[ "$chamadas" -eq 20 ] && ok "20 chamadas para 10 pedidos: cada pedido passou pela retentativa" || falha "esperava 20 chamadas, houve $chamadas"
grep -q 'chamada falhou (tentativa 1/3, exit 1, status 429)' "$d/log.txt" && ok "log registra a falha com exit 1 e status 429" || { falha "log sem registro da falha"; head -n 5 "$d/log.txt"; }
grep -q 'limite da API: esperando' "$d/log.txt" && ok "429 entra no caminho de espera de limite" || falha "429 nao entrou no caminho de limite"
if [ -s "$d/saida.json" ]; then
  j="$d/saida.json"
  [ "$(jq -r '.pares | length' "$j")" = 3 ] && ok "3 pares no JSON" || falha "pares != 3"
  [ "$(jq -r '.retido' "$j")" = b-real-2.md ] && ok "retido registrado" || falha "retido nao registrado"
  [ "$(jq -r '[.pares[].briefing] | unique | join(",")' "$j")" = 2 ] && ok "os 3 pares usam o briefing do material retido (indice 2)" || falha "briefing nao e o do retido: $(jq -c '[.pares[].briefing]' "$j")"
  grep -q 'You have hit your session limit' "$d/saida.json.arquivos/textos/"*.txt && falha "JSON de erro virou candidato" || ok "JSON de erro nunca virou candidato"
  grep -q 'assunto: teste do harness' "$d/saida.json.arquivos/briefings/briefing-2.txt" && ok "briefing extraido do retido" || falha "briefing-2 nao extraido"
  [ "$(jq -r '[.pares[].reuso_voz] | unique | join(",")' "$j")" = 3 ] && ok "reuso_voz = 3 sequencias distintas de 8 palavras" || falha "reuso_voz errado: $(jq -c '[.pares[].reuso_voz]' "$j")"
  [ "$(jq -r '[.pares[].reuso_neutro] | unique | join(",")' "$j")" = 0 ] && ok "reuso_neutro = 0" || falha "reuso_neutro errado"
  [ "$(jq -r '[.pares[].vencedor_juiz] | unique | join(",")' "$j")" = voz ] && ok "juiz escolheu o candidato com voz nos 3 pares" || falha "vencedor_juiz: $(jq -c '[.pares[].vencedor_juiz]' "$j")"
  [ "$(jq -r '[.pares[].vencedor] | unique | join(",")' "$j")" = reuso ] && ok "vitoria anulada por reuso nos 3 pares (3 > 2 x 0)" || falha "vencedor: $(jq -c '[.pares[].vencedor]' "$j")"
  [ "$(jq -r '.anuladas_por_reuso' "$j")" = 3 ] && [ "$(jq -r '.resultado' "$j")" = empate ] && ok "resultado do caso vira empate, nao vitoria" || falha "resultado: $(jq -c '{resultado, anuladas_por_reuso}' "$j")"
fi

# reuso dentro do fator nao anula: o neutro reusa o mesmo tanto que a voz (3 nao e maior que 2 x 3)
echo 0 > "$d/contador"
FAKE_NEUTRO_REUSA=1 bash "$dir/preferencia-voz.sh" "$d/voz.md" "$d/mat" "$d/saida2.json" claude-sonnet-5 b-real-2.md > "$d/log2.txt" 2>&1 \
  && [ "$(jq -r '.resultado' "$d/saida2.json")" = voz ] && [ "$(jq -r '.vitorias_voz' "$d/saida2.json")" = 3 ] \
  && [ "$(jq -r '[.pares[].reuso_neutro] | unique | join(",")' "$d/saida2.json")" = 3 ] \
  && ok "reuso igual dos dois lados: a vitoria conta (voz 3-0-0)" || falha "reuso igual anulou a vitoria: $(jq -c '{resultado, vitorias_voz, anuladas_por_reuso}' "$d/saida2.json" 2>/dev/null)"

# desconto do briefing: o briefing repete a sequencia do real 1 que a voz recola, entao os
# 3 8-gramas compartilham janela de 5 palavras com ele; o reuso bruto continua 3, o
# liquido cai a 0 e a vitoria conta
rm -rf "$d/cache-b"; echo 0 > "$d/contador"
FAKE_BRIEFING_REUSA=1 BRIEFINGS_CACHE="$d/cache-b" bash "$dir/preferencia-voz.sh" "$d/voz.md" "$d/mat" "$d/saida4.json" claude-sonnet-5 b-real-2.md > "$d/log4.txt" 2>&1 \
  && [ "$(jq -r '[.pares[].reuso_bruto_voz] | unique | join(",")' "$d/saida4.json")" = 3 ] \
  && [ "$(jq -r '[.pares[].reuso_voz] | unique | join(",")' "$d/saida4.json")" = 0 ] \
  && [ "$(jq -r '.resultado + " " + (.vitorias_voz|tostring) + " " + (.anuladas_por_reuso|tostring)' "$d/saida4.json")" = "voz 3 0" ] \
  && ok "desconto do briefing: bruto 3, liquido 0, vitoria conta" || falha "desconto do briefing: $(jq -c '{resultado, vitorias_voz, anuladas_por_reuso, r:[.pares[]|[.reuso_voz,.reuso_bruto_voz]]}' "$d/saida4.json" 2>/dev/null)"

# piso absoluto: o briefing repete so 5 palavras, o liquido da voz cai de 3 para 2, e 2 nao
# passa do piso (PISO_REUSO, padrao 2), entao a vitoria conta mesmo com o neutro em 0;
# com PISO_REUSO=0 a mesma execucao anula (2 > 2 x 0), o que prova que a regra do dobro
# continua valendo acima do piso
rm -rf "$d/cache-c"; echo 0 > "$d/contador"
FAKE_BRIEFING_REUSA=2 BRIEFINGS_CACHE="$d/cache-c" bash "$dir/preferencia-voz.sh" "$d/voz.md" "$d/mat" "$d/saida5.json" claude-sonnet-5 b-real-2.md > "$d/log5.txt" 2>&1 \
  && [ "$(jq -r '[.pares[].reuso_voz] | unique | join(",")' "$d/saida5.json")" = 2 ] \
  && [ "$(jq -r '.resultado + " " + (.vitorias_voz|tostring) + " " + (.anuladas_por_reuso|tostring)' "$d/saida5.json")" = "voz 3 0" ] \
  && ok "piso: liquido 2 com neutro 0 nao anula (voz 3-0-0)" || falha "piso: $(jq -c '{resultado, vitorias_voz, anuladas_por_reuso, r:[.pares[]|[.reuso_voz,.reuso_neutro]]}' "$d/saida5.json" 2>/dev/null)"
rm -rf "$d/cache-c"; echo 0 > "$d/contador"
PISO_REUSO=0 FAKE_BRIEFING_REUSA=2 BRIEFINGS_CACHE="$d/cache-c" bash "$dir/preferencia-voz.sh" "$d/voz.md" "$d/mat" "$d/saida6.json" claude-sonnet-5 b-real-2.md > "$d/log6.txt" 2>&1 \
  && [ "$(jq -r '.resultado + " " + (.anuladas_por_reuso|tostring)' "$d/saida6.json")" = "empate 3" ] \
  && ok "sem piso a mesma execucao anula: a regra do dobro segue acima do piso" || falha "sem piso: $(jq -c '{resultado, anuladas_por_reuso}' "$d/saida6.json" 2>/dev/null)"

# sem retido: roda os 3 briefings e avisa que nao vale como portao
echo 0 > "$d/contador"
bash "$dir/preferencia-voz.sh" "$d/voz.md" "$d/mat" "$d/saida3.json" > "$d/log3.txt" 2>&1 \
  && jq -r '.detalhe' "$d/saida3.json" | grep -q 'SEM leave-one-out' \
  && [ "$(jq -r '[.pares[].briefing] | join(",")' "$d/saida3.json")" = "1,2,3" ] \
  && ok "sem retido: 3 briefings e aviso no detalhe" || falha "modo sem retido"

# retido inexistente falha antes de chamar modelo
echo 0 > "$d/contador"
bash "$dir/preferencia-voz.sh" "$d/voz.md" "$d/mat" "$d/saida4.json" claude-sonnet-5 nao-existe.md > "$d/log4.txt" 2>&1 \
  && falha "retido inexistente passou" || { [ "$(cat "$d/contador")" = 0 ] && ok "retido inexistente falha sem gastar chamada" || falha "retido inexistente gastou chamada"; }

# run-case.sh remove o retido da copia de trabalho
mkdir -p "$d/evals/fixtures/fx/materiais" "$d/evals/cases/x"
printf 'a\n' > "$d/evals/fixtures/fx/materiais/fica.md"; printf 'b\n' > "$d/evals/fixtures/fx/materiais/sai.md"
printf -- '---\nespecialista: x\nfixture: fx\nretido: sai.md\nfixture_legado: (nenhuma)\npedido: teste\nprompt_novo: gere\nprompt_antigo: (nenhum)\n---\n' > "$d/evals/cases/x/01.md"
echo 0 > "$d/contador"; export FAKE_SEMPRE_OK=1
bash "$dir/run-case.sh" "$raiz" "$d/evals/cases/x/01.md" claude-sonnet-5 "$d/rc.md" > "$d/log5.txt" 2>&1 \
  && [ -f "$d/rc.md.arquivos/materiais/fica.md" ] && [ ! -e "$d/rc.md.arquivos/materiais/sai.md" ] \
  && ok "run-case.sh removeu o material retido da copia de trabalho" || { falha "run-case.sh nao removeu o retido"; cat "$d/log5.txt"; }
printf -- '---\nespecialista: x\nfixture: fx\nretido: nao-existe.md\nfixture_legado: (nenhuma)\npedido: teste\nprompt_novo: gere\nprompt_antigo: (nenhum)\n---\n' > "$d/evals/cases/x/02.md"
bash "$dir/run-case.sh" "$raiz" "$d/evals/cases/x/02.md" claude-sonnet-5 "$d/rc2.md" > "$d/log6.txt" 2>&1 \
  && falha "run-case.sh aceitou retido inexistente" || ok "run-case.sh falha com retido inexistente"

exit $falhou
