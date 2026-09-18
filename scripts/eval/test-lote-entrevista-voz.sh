#!/usr/bin/env bash
set -u
# uso: bash scripts/eval/test-lote-entrevista-voz.sh
# Prova, sem gastar modelo, que lote-entrevista-voz.sh:
# 1. para o caso quando validar-voz.sh reprova o voz.md ja compilado (registra
#    "FALHOU validacao" no log, nao roda o portao, nao grava JSON); menor da re-revisao da
#    Tarefa 4: na rodada 3 dois casos com banidas.txt vazio foram ao portao;
# 2. com validacao ok, segue ao portao (claude-falso.sh no lugar do claude) e grava o JSON.
# O lote e restrito a um caso e um modelo por CASOS e MODELOS; a rodada de teste e apagada
# no fim. O cache de briefings aponta para uma pasta temporaria, para nao tocar no real.
dir=$(cd "$(dirname "$0")" && pwd)
raiz=$(cd "$dir/../.." && pwd)
d=$(mktemp -d); falhou=0
ok() { echo "ok $1"; }
falha() { echo "FALHA $1"; falhou=1; }
rod="teste-lote-$$"
R="$raiz/evals/results/nova/entrevista-voz-$rod"; P="$raiz/evals/results/preferencia/entrevista-voz-$rod"
limpar() { rm -rf "$R" "$P" "$d"; }
trap limpar EXIT
export CASOS=01 MODELOS=claude-sonnet-5 BRIEFINGS_CACHE="$d/cache"
export FAKE_DIR="$d" CLAUDE_ISOLADO="$dir/claude-falso.sh" TENTATIVAS=3 ESPERA=0 ESPERA_LIMITE=0
chmod +x "$dir/claude-falso.sh"
blocos="uso prioridade contexto_de_identidade assinatura_de_voz leis_de_escrita leis_de_comunicacao recusas_duras gostos_que_amo gostos_que_detesto banco_de_frases sinais_de_assinatura regras_de_decisao contradicoes_produtivas exemplos_de_ouro nao_inferir instrucao_final"
n=01-claude-sonnet-5

# 1. voz.md ja compilado e invalido (sem os 16 blocos): o lote pula a compilacao, valida, reprova e para
mkdir -p "$R/$n.md.arquivos"
printf '<sobre_mim>\nsem blocos\n</sobre_mim>\n' > "$R/$n.md.arquivos/voz.md"
printf 'alavancar\n' > "$R/$n.md.arquivos/banidas.txt"
bash "$dir/lote-entrevista-voz.sh" "$rod" 1 > /dev/null 2>&1
L="$P/_log.txt"
grep -q "VALIDACAO FALHOU $n" "$L" && ok "validacao reprovada registrada no log" || { falha "sem VALIDACAO FALHOU no log"; cat "$L"; }
grep -q "FALHOU validacao $n" "$L" && ok "caso marcado como falhado" || falha "sem FALHOU validacao no log"
grep -q "portao $n" "$L" && falha "caso reprovado foi ao portao" || ok "caso reprovado nao foi ao portao"
[ -e "$P/$n.json" ] && falha "JSON do portao gravado para caso reprovado" || ok "sem JSON do portao"
grep -q "FIM lote $rod voz=1 json=0" "$L" && ok "FIM do lote conta 1 voz.md e 0 json" || { falha "linha FIM: $(grep FIM "$L")"; }

# 2. voz.md valido: segue ao portao com o claude falso e grava o JSON
rm -rf "$R" "$P"; echo 0 > "$d/contador"
mkdir -p "$R/$n.md.arquivos"
{ echo "<sobre_mim>"; for b in $blocos; do echo "<$b>"; echo "linha de $b"; echo "</$b>"; done; echo "</sobre_mim>"; } > "$R/$n.md.arquivos/voz.md"
printf 'alavancar\n' > "$R/$n.md.arquivos/banidas.txt"
bash "$dir/lote-entrevista-voz.sh" "$rod" 1 > /dev/null 2>&1
grep -q "validacao ok $n" "$L" && ok "validacao ok registrada" || { falha "sem validacao ok"; cat "$L"; }
grep -q "ok portao $n" "$L" && [ -s "$P/$n.json" ] && ok "caso valido foi ao portao e gravou JSON" || { falha "caso valido nao chegou ao portao"; cat "$L"; tail -5 "$P/$n.log" 2>/dev/null; }
[ "$(jq -r '.retido' "$P/$n.json" 2>/dev/null)" = post-grok-bot-time-de-agentes.md ] && ok "portao rodou com o retido do caso" || falha "retido errado no JSON"

exit $falhou
