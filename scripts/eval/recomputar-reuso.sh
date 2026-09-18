#!/usr/bin/env bash
set -euo pipefail
# uso: recomputar-reuso.sh <pasta-com-jsons-do-portao> <pasta-de-saida> [fator]
#
# Recalcula, sobre os artefatos ja gravados de um lote do portao (preferencia-voz.sh),
# a medida de reuso liquido (ngramas_reusados_liquidos: 8-gramas do candidato presentes
# nos posts reais, descontados os que compartilham janela de 5 palavras com o briefing)
# e reaplica a regra de anulacao, sem gerar nem julgar nada de novo. Serve para reler
# um lote antigo com a regra nova: os vereditos do juiz (vencedor_juiz) e as posicoes
# ficam como estavam; mudam reuso_voz, reuso_neutro, vencedor, os totais e o resultado.
# Grava um JSON por caso na pasta de saida, com reuso_bruto_* preenchidos e uma nota no
# detalhe, e imprime uma linha por caso: antes e depois.
src=$(cd "$1" && pwd); out="$2"; fator="${3:-${FATOR_REUSO:-2}}"
dir=$(cd "$(dirname "$0")" && pwd)
. "$dir/briefing-lib.sh"
mkdir -p "$out"; out=$(cd "$out" && pwd)
printf '%-22s %-28s %-28s\n' caso antes depois
for j in "$src"/*.json; do
  n=$(basename "$j" .json); a="$j.arquivos"
  [ -d "$a/textos" ] || { echo "$n: sem artefatos, pulado" >&2; continue; }
  pares="[]"; vv=0; vn=0; ve=0; vr=0
  for k in $(jq -r '.pares[].par' "$j"); do
    i=$(jq -r ".pares[] | select(.par == $k) | .briefing" "$j")
    wj=$(jq -r ".pares[] | select(.par == $k) | .vencedor_juiz" "$j")
    reais="$a/textos/real-1.txt $a/textos/real-2.txt $a/textos/real-3.txt"
    rvb=$(ngramas_reusados 8 "$a/textos/voz-$k.txt" $reais)
    rnb=$(ngramas_reusados 8 "$a/textos/neutro-$k.txt" $reais)
    rv=$(ngramas_reusados_liquidos 8 "$a/textos/voz-$k.txt" "$a/briefings/briefing-$i.txt" $reais)
    rn=$(ngramas_reusados_liquidos 8 "$a/textos/neutro-$k.txt" "$a/briefings/briefing-$i.txt" $reais)
    w="$wj"; if [ "$wj" = voz ] && [ "$rv" -gt $((rn * fator)) ]; then w=reuso; fi
    case $w in voz) vv=$((vv + 1));; neutro) vn=$((vn + 1));; empate) ve=$((ve + 1));; reuso) vr=$((vr + 1));; esac
    pares=$(printf '%s' "$pares" | jq --argjson k "$k" --argjson rv "$rv" --argjson rn "$rn" --argjson rvb "$rvb" --argjson rnb "$rnb" --arg w "$w" \
      --argjson p "$(jq -c ".pares[] | select(.par == $k)" "$j")" \
      '. + [$p + {vencedor:$w, reuso_voz:$rv, reuso_neutro:$rn, reuso_bruto_voz:$rvb, reuso_bruto_neutro:$rnb}]')
  done
  if [ $vv -gt $vn ]; then r=voz; elif [ $vn -gt $vv ]; then r=neutro; else r=empate; fi
  jq --arg r "$r" --argjson vv $vv --argjson vn $vn --argjson ve $ve --argjson vr $vr --argjson p "$pares" --arg src "$j" \
    '. + {resultado:$r, vitorias_voz:$vv, vitorias_neutro:$vn, empates:$ve, anuladas_por_reuso:$vr, pares:$p,
          detalhe:(.detalhe + " reuso recomputado com desconto do briefing (recomputar-reuso.sh) sobre " + $src + ";")}' "$j" > "$out/$n.json"
  antes=$(jq -r '"\(.resultado) \(.vitorias_voz)-\(.vitorias_neutro)-\(.empates) anul=\(.anuladas_por_reuso) \([.pares[]|"\(.reuso_voz)/\(.reuso_neutro)"]|join(","))"' "$j")
  depois=$(jq -r '"\(.resultado) \(.vitorias_voz)-\(.vitorias_neutro)-\(.empates) anul=\(.anuladas_por_reuso) \([.pares[]|"\(.reuso_voz)/\(.reuso_neutro)"]|join(","))"' "$out/$n.json")
  printf '%-22s %-28s %-28s\n' "$n" "$antes" "$depois"
done
