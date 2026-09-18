#!/usr/bin/env bash
set -euo pipefail
# uso: preferencia-voz.sh <voz.md> <materiais-dir> <saida.json> [modelo-gerador] [retido]
#
# Portao do especialista entrevista-voz: teste pareado de preferencia.
#
# Contrato:
# 1. Pega os 3 posts reais de <materiais-dir> (primeiro bloco <!-- ai:start --> a
#    <!-- ai:end --> de cada arquivo, ou o arquivo inteiro), em ordem C de nome. Sao a
#    referencia de autoria que o juiz recebe.
# 2. Leave-one-out (ruling do controlador, revisao da Tarefa 4, achado 3): [retido] e o
#    nome do material que ficou FORA da pasta materiais/ quando o voz.md foi compilado
#    (run-case.sh remove o arquivo do campo `retido:` do caso). O briefing dos 3 pares
#    vem so desse post: o voz.md nunca o leu, entao o que o candidato acerta dele e voz,
#    nao memoria. Sem [retido], o script roda os 3 briefings de antes e marca em
#    `detalhe` que nao houve leave-one-out; esse modo nao vale como portao.
# 3. Extrai o briefing factual do post retido (briefing-lib.sh: modelo isolado
#    claude-sonnet-5, prompt reconhecimento-briefing.md, sem frase do original; com
#    BRIEFINGS_CACHE=<pasta> os briefings sao extraidos uma vez e reutilizados).
# 4. Para cada par (3 por caso), gera a mesma peca duas vezes no modelo [modelo-gerador]
#    (padrao claude-sonnet-5; nos portoes, o mesmo modelo que compilou o voz.md): uma
#    com o voz.md sob teste como prompt de sistema, outra com perfil-neutro.md, um
#    perfil generico forte (boa escrita, sem cara de IA, sem voz autoral). As duas
#    recebem o mesmo prompt de geracao (preferencia-gerador.md). Os 3 pares partem do
#    mesmo briefing e sao 3 geracoes independentes.
# 5. Mede o reaproveitamento literal de cada candidato: sequencias distintas de 8
#    palavras que aparecem em algum dos 3 posts reais (ngramas_reusados), descontando
#    as que compartilham uma janela de 5 palavras com o briefing que os dois receberam
#    (ngramas_reusados_liquidos): o que o briefing repete do original nao e colagem do
#    perfil. Par em que o juiz escolhe o candidato do voz.md, mas esse candidato reusa
#    (liquido) mais que FATOR_REUSO (padrao 2) vezes o que o neutro reusa, nao conta
#    como vitoria: vira "reuso", que pesa como empate no resultado do caso. Por par
#    ficam registrados reuso_voz e reuso_neutro (liquidos, os que decidem) e
#    reuso_bruto_voz e reuso_bruto_neutro (sem o desconto).
# 6. Para cada par, um juiz isolado (claude-opus-5, preferencia-juiz.md) recebe os
#    3 posts reais como referencia e os dois candidatos como A e B, em ordem sorteada
#    por par, e diz qual le como escrito pelo mesmo autor, com motivo. O juiz nao sabe
#    que um dos candidatos usou perfil de voz (achado 4).
# 7. Grava em <saida.json>:
#    {"resultado":"voz"|"neutro"|"empate","vitorias_voz":n,"vitorias_neutro":n,
#     "empates":n,"anuladas_por_reuso":n,"retido":"nome.md",
#     "pares":[{"par":k,"briefing":i,"vencedor_juiz":"voz"|"neutro"|"empate",
#               "vencedor":"voz"|"neutro"|"empate"|"reuso","posicao_voz":"A"|"B",
#               "reuso_voz":n,"reuso_neutro":n,"reuso_bruto_voz":n,"reuso_bruto_neutro":n,
#               "motivo":"..."}],"detalhe":"..."}
#    resultado do caso = maioria dos 3 pares depois da regra de reuso (voz > neutro:
#    voz; neutro > voz: neutro; iguais: empate). Textos, briefings, JSON cru de cada
#    chamada e respostas do juiz ficam em <saida.json>.arquivos/.
#
# Regra do portao (ruling do controlador, Tarefa 4):
# - Por modelo, passa quando o voz.md vence ou empata em pelo menos 4 dos 5 casos,
#   com vitoria clara (resultado "voz") em pelo menos 3. Par anulado por reuso nunca
#   conta como vitoria.
# - Este script e portao de engenharia. A aceitacao real do voz.md continua sendo
#   a pessoa ler e aprovar, e o teste cego dela na Etapa 4 da skill.
#
# Falhas de API: toda chamada passa por chamar_claude (briefing-lib.sh), que tenta de
# novo sozinha e, em 429 ou limite de sessao, espera e repete sem mudar o protocolo.
#
# Por que o teste de reconhecimento (reconhecimento.sh) deixou de ser portao:
#   Ele pedia ao juiz para achar os 3 reais entre 3 reais e 3 gerados. Nas
#   referencias, o juiz acertou 3 de 3 tanto com o voz.md de referencia do autor
#   quanto com um perfil neutro de uma linha: texto gerado de uma vez so e sempre
#   identificavel, com ou sem perfil, entao o teste media o gerador, nao o voz.md.
#   Ele continua disponivel como metrica informativa.
voz=$(cd "$(dirname "$1")" && pwd)/$(basename "$1"); mat=$(cd "$2" && pwd); out=$(cd "$(dirname "$3")" && pwd)/$(basename "$3")
modelo="${4:-claude-sonnet-5}"; retido="${5:-${RETIDO:-}}"; fator="${FATOR_REUSO:-2}"
extrator=claude-sonnet-5
dir=$(cd "$(dirname "$0")" && pwd)
. "$dir/briefing-lib.sh"
[ -s "$voz" ] || { echo "voz.md vazio ou ausente: $voz" >&2; exit 1; }
[ -d "$mat" ] || { echo "pasta de materiais ausente: $mat" >&2; exit 1; }
# artefatos vao para uma pasta temporaria e so substituem a anterior no fim, para uma
# execucao que falhe no meio nao apagar os artefatos de um veredito ja gravado
arq="$out.arquivos.tmp"; rm -rf "$arq"; mkdir -p "$arq/textos" "$arq/briefings" "$arq/juiz"

extrair_reais "$mat"
aviso=""
if [ -n "$retido" ]; then
  ir=$(indice_real "$retido") || { echo "retido nao esta entre os 3 materiais de $mat: $retido" >&2; exit 1; }
  briefs="$ir $ir $ir"
  extrair_briefings "$ir"
else
  briefs="1 2 3"
  aviso=" SEM leave-one-out (nenhum material retido): os briefings vem de posts que o voz.md leu, nao vale como portao;"
  extrair_briefings 1 2 3
fi

# 4. duas versoes por par, mesmo briefing
gerar() {  # gerar <perfil.md> <briefing-i> <saida.txt> <bruto.json>
  chamar_claude "$4" --model "$modelo" --append-system-prompt "$(cat "$1")" --output-format json \
    "$(cat "$dir/preferencia-gerador.md")
$(cat "$arq/briefings/briefing-$2.txt")" || { echo "gerador nao entregou ($1, briefing $2)" >&2; return 1; }
  resultado "$4" > "$3"
  [ -s "$3" ] || { echo "gerador devolveu vazio ($1, briefing $2)" >&2; return 1; }
}
k=0
for i in $briefs; do
  k=$((k + 1))
  gerar "$voz" "$i" "$arq/textos/voz-$k.txt" "$arq/textos/voz-$k.bruto.json"
  gerar "$dir/perfil-neutro.md" "$i" "$arq/textos/neutro-$k.txt" "$arq/textos/neutro-$k.bruto.json"
done

# 5 e 6. reuso literal e um julgamento por par, posicao sorteada
ref="REFERÊNCIA DE AUTORIA (3 posts publicados pelo autor):"
for i in 1 2 3; do ref="$ref

POST REAL $i:
$(cat "$arq/textos/real-$i.txt")"; done
vv=0; vn=0; ve=0; vr=0; pares="[]"; k=0
for i in $briefs; do
  k=$((k + 1))
  rvb=$(ngramas_reusados 8 "$arq/textos/voz-$k.txt" "$arq/textos/real-1.txt" "$arq/textos/real-2.txt" "$arq/textos/real-3.txt")
  rnb=$(ngramas_reusados 8 "$arq/textos/neutro-$k.txt" "$arq/textos/real-1.txt" "$arq/textos/real-2.txt" "$arq/textos/real-3.txt")
  rv=$(ngramas_reusados_liquidos 8 "$arq/textos/voz-$k.txt" "$arq/briefings/briefing-$i.txt" "$arq/textos/real-1.txt" "$arq/textos/real-2.txt" "$arq/textos/real-3.txt")
  rn=$(ngramas_reusados_liquidos 8 "$arq/textos/neutro-$k.txt" "$arq/briefings/briefing-$i.txt" "$arq/textos/real-1.txt" "$arq/textos/real-2.txt" "$arq/textos/real-3.txt")
  if [ $((RANDOM % 2)) -eq 0 ]; then pa="voz"; pb="neutro"; pos=A; else pa="neutro"; pb="voz"; pos=B; fi
  msg="$ref

BRIEFING COMUM AOS DOIS CANDIDATOS:
$(cat "$arq/briefings/briefing-$i.txt")

CANDIDATO A:
$(cat "$arq/textos/$pa-$k.txt")

CANDIDATO B:
$(cat "$arq/textos/$pb-$k.txt")"
  printf '%s' "$msg" > "$arq/juiz/mensagem-$k.txt"
  v=""; mo=""
  for tj in 1 2; do
    chamar_claude "$arq/juiz/bruto-$k.json" --model claude-opus-5 \
      --append-system-prompt "$(cat "$dir/preferencia-juiz.md")" --output-format json "$msg" || { echo "juiz nao respondeu no par $k" >&2; exit 1; }
    res=$(resultado "$arq/juiz/bruto-$k.json" | sed -n '/^{/,/}$/p')
    printf '%s\n' "$res" > "$arq/juiz/resposta-$k.json"
    v=$(printf '%s' "$res" | jq -r '.vencedor' 2>/dev/null || echo "")
    mo=$(printf '%s' "$res" | jq -r '.motivo' 2>/dev/null || echo "")
    case "$v" in A|B|empate) break;; esac
    echo "juiz nao devolveu vencedor no par $k (tentativa $tj): $res" >&2
  done
  case "$v" in
    A) [ "$pa" = voz ] && wj=voz || wj=neutro;;
    B) [ "$pb" = voz ] && wj=voz || wj=neutro;;
    empate) wj=empate;;
    *) echo "juiz nao devolveu vencedor no par $k: $res" >&2; exit 1;;
  esac
  w="$wj"
  if [ "$wj" = voz ] && [ "$rv" -gt $((rn * fator)) ]; then w=reuso; fi
  case $w in voz) vv=$((vv + 1));; neutro) vn=$((vn + 1));; empate) ve=$((ve + 1));; reuso) vr=$((vr + 1));; esac
  pares=$(printf '%s' "$pares" | jq --argjson k "$k" --argjson i "$i" --arg wj "$wj" --arg w "$w" --arg p "$pos" \
    --argjson rv "$rv" --argjson rn "$rn" --argjson rvb "$rvb" --argjson rnb "$rnb" --arg m "$mo" \
    '. + [{par:$k, briefing:$i, vencedor_juiz:$wj, vencedor:$w, posicao_voz:$p, reuso_voz:$rv, reuso_neutro:$rn, reuso_bruto_voz:$rvb, reuso_bruto_neutro:$rnb, motivo:$m}]')
done
if [ $vv -gt $vn ]; then r=voz; elif [ $vn -gt $vv ]; then r=neutro; else r=empate; fi
jq -n --arg r "$r" --argjson vv $vv --argjson vn $vn --argjson ve $ve --argjson vr $vr --arg ret "$retido" --argjson p "$pares" \
  --arg d "gerador: $modelo; extrator: $extrator; fator de reuso: $fator; neutro: perfil-neutro.md;$aviso" \
  '{resultado:$r, vitorias_voz:$vv, vitorias_neutro:$vn, empates:$ve, anuladas_por_reuso:$vr, retido:$ret, pares:$p, detalhe:$d}' > "$out"
rm -rf "$out.arquivos"; mv "$arq" "$out.arquivos"
cat "$out"
