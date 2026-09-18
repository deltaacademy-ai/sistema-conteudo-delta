#!/usr/bin/env bash
set -euo pipefail
# uso: preferencia-voz.sh <voz.md> <materiais-dir> <saida.json> [modelo-gerador]
#
# Portao do especialista entrevista-voz: teste pareado de preferencia.
#
# Contrato:
# 1. Pega os 3 posts reais de <materiais-dir> (primeiro bloco <!-- ai:start --> a
#    <!-- ai:end --> de cada arquivo, ou o arquivo inteiro). Sao a referencia de autoria.
# 2. Extrai um briefing factual de cada post real (briefing-lib.sh: modelo isolado
#    claude-sonnet-5, prompt reconhecimento-briefing.md, sem frase do original; com
#    BRIEFINGS_CACHE=<pasta> os briefings sao extraidos uma vez e reutilizados, para
#    todos os casos partirem do mesmo texto).
# 3. Para cada briefing, gera a mesma peca duas vezes no modelo [modelo-gerador]
#    (padrao claude-sonnet-5; nos portoes, o mesmo modelo que compilou o voz.md):
#    uma com o voz.md sob teste como prompt de sistema, outra com perfil-neutro.md.
#    As duas recebem o mesmo prompt de geracao (preferencia-gerador.md), inclusive
#    a regra mecanica de sem travessao e sem emoji, para a diferenca ser so a voz.
# 4. Para cada par, um juiz isolado (claude-opus-5, preferencia-juiz.md) recebe os
#    3 posts reais como referencia e os dois candidatos como A e B, em ordem
#    sorteada por par, e diz qual le como escrito pelo mesmo autor, com motivo.
# 5. Grava em <saida.json>:
#    {"resultado":"voz"|"neutro"|"empate","vitorias_voz":n,"vitorias_neutro":n,
#     "empates":n,"pares":[{"briefing":i,"vencedor":"voz"|"neutro"|"empate",
#     "posicao_voz":"A"|"B","motivo":"..."}],"detalhe":"..."}
#    resultado do caso = maioria dos 3 pares (voz > neutro: voz; iguais: empate).
#    posicao_voz por par permite ver vies de posicao do juiz. Textos, briefings e
#    respostas cruas do juiz ficam em <saida.json>.arquivos/.
#
# Regra do portao (ruling do controlador, Tarefa 4):
# - Por modelo, passa quando o voz.md vence ou empata em pelo menos 4 dos 5 casos,
#   com vitoria clara (resultado "voz") em pelo menos 3.
# - Este script e portao de engenharia. A aceitacao real do voz.md continua sendo
#   a pessoa ler e aprovar, e o teste cego dela na Etapa 4 da skill.
#
# Por que o teste de reconhecimento (reconhecimento.sh) deixou de ser portao:
#   Ele pedia ao juiz para achar os 3 reais entre 3 reais e 3 gerados. Nas
#   referencias, o juiz acertou 3 de 3 tanto com o voz.md de referencia do autor
#   quanto com um perfil neutro de uma linha: texto gerado de uma vez so e sempre
#   identificavel, com ou sem perfil, entao o teste media o gerador, nao o voz.md.
#   Ele continua disponivel como metrica informativa. O teste pareado mede o que
#   importa: com os mesmos fatos e o mesmo gerador, o voz.md aproxima o texto do
#   autor mais do que a ausencia dele.
voz=$(cd "$(dirname "$1")" && pwd)/$(basename "$1"); mat=$(cd "$2" && pwd); out=$(cd "$(dirname "$3")" && pwd)/$(basename "$3"); modelo="${4:-claude-sonnet-5}"
extrator=claude-sonnet-5
dir=$(cd "$(dirname "$0")" && pwd)
. "$dir/briefing-lib.sh"
[ -s "$voz" ] || { echo "voz.md vazio ou ausente: $voz" >&2; exit 1; }
[ -d "$mat" ] || { echo "pasta de materiais ausente: $mat" >&2; exit 1; }
# artefatos vao para uma pasta temporaria e so substituem a anterior no fim, para uma
# execucao que falhe (ex.: limite de sessao da API) nao apagar os artefatos de um veredito ja gravado
arq="$out.arquivos.tmp"; rm -rf "$arq"; mkdir -p "$arq/textos" "$arq/briefings" "$arq/juiz"

extrair_reais "$mat"
extrair_briefings

# 3. duas versoes por briefing
gerar() {  # gerar <perfil.md> <briefing-i> <saida.txt>
  local perfil="$1" i="$2" saida="$3" t
  for t in 1 2; do
    ( cd "$(mktemp -d)" && "$dir/claude-isolado.sh" --model "$modelo" \
        --append-system-prompt "$(cat "$perfil")" --output-format json \
        "$(cat "$dir/preferencia-gerador.md")
$(cat "$arq/briefings/briefing-$i.txt")" ) | jq -r '.result' | sed '/^```/d' > "$saida"
    [ -s "$saida" ] && return 0
  done
  echo "gerador nao entregou ($perfil, briefing $i)" >&2; return 1
}
for i in 1 2 3; do
  gerar "$voz" $i "$arq/textos/voz-$i.txt"
  gerar "$dir/perfil-neutro.md" $i "$arq/textos/neutro-$i.txt"
done

# 4. um julgamento por par, posicao sorteada
ref="REFERÊNCIA DE AUTORIA (3 posts publicados pelo autor):"
for i in 1 2 3; do ref="$ref

POST REAL $i:
$(cat "$arq/textos/real-$i.txt")"; done
vv=0; vn=0; ve=0; pares="[]"
for i in 1 2 3; do
  if [ $((RANDOM % 2)) -eq 0 ]; then pa="voz"; pb="neutro"; pos=A; else pa="neutro"; pb="voz"; pos=B; fi
  msg="$ref

BRIEFING COMUM AOS DOIS CANDIDATOS:
$(cat "$arq/briefings/briefing-$i.txt")

CANDIDATO A:
$(cat "$arq/textos/$pa-$i.txt")

CANDIDATO B:
$(cat "$arq/textos/$pb-$i.txt")"
  printf '%s' "$msg" > "$arq/juiz/mensagem-$i.txt"
  res=$(cd "$(mktemp -d)" && "$dir/claude-isolado.sh" --model claude-opus-5 \
    --append-system-prompt "$(cat "$dir/preferencia-juiz.md")" --output-format json "$msg" \
    | jq -r '.result' | sed -n '/^{/,/}$/p')
  printf '%s\n' "$res" > "$arq/juiz/resposta-$i.json"
  v=$(printf '%s' "$res" | jq -r '.vencedor' 2>/dev/null || echo "")
  mo=$(printf '%s' "$res" | jq -r '.motivo' 2>/dev/null || echo "")
  case "$v" in
    A) [ "$pa" = voz ] && w=voz || w=neutro;;
    B) [ "$pb" = voz ] && w=voz || w=neutro;;
    empate) w=empate;;
    *) echo "juiz nao devolveu vencedor no par $i: $res" >&2; exit 1;;
  esac
  case $w in voz) vv=$((vv+1));; neutro) vn=$((vn+1));; empate) ve=$((ve+1));; esac
  pares=$(printf '%s' "$pares" | jq --argjson i $i --arg w "$w" --arg p "$pos" --arg m "$mo" '. + [{briefing:$i, vencedor:$w, posicao_voz:$p, motivo:$m}]')
done
if [ $vv -gt $vn ]; then r=voz; elif [ $vn -gt $vv ]; then r=neutro; else r=empate; fi
jq -n --arg r "$r" --argjson vv $vv --argjson vn $vn --argjson ve $ve --argjson p "$pares" \
  --arg d "gerador: $modelo; extrator: $extrator;$aviso" \
  '{resultado:$r, vitorias_voz:$vv, vitorias_neutro:$vn, empates:$ve, pares:$p, detalhe:$d}' > "$out"
rm -rf "$out.arquivos"; mv "$arq" "$out.arquivos"
cat "$out"
