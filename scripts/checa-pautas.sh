#!/usr/bin/env bash
# uso: checa-pautas.sh <pautas.md> [valor-proibido ...]
#
# Confere a forma da rodada mais nova de um pautas.md (a primeira "## Rodada" do arquivo):
# cada pauta tem o titulo "### P-AAAA-MM-DD-N: ...", as sete linhas Origem, Por que agora,
# Ganho, Confianca, Nota, Faltas e Status, nessa ordem, coladas e com valor, e depois uma
# cerca de codigo com o identificador da pauta dentro; nenhuma outra linha entra no bloco.
# Origem comeca por continuacao, fato, dor ou noticia; Confianca e alta, media ou baixa;
# Nota e N/16; Status e aberta ou "usada em AAAA-MM-DD". Cada valor proibido
# (por exemplo um numero que so veio de resumo) nao pode aparecer em lugar nenhum do arquivo.
# Rodadas anteriores nao entram. Sai 0 quando esta limpo; fora isso, sai 1 com uma linha por problema.
arq="${1:-}"; [ $# -gt 0 ] && shift
[ -f "$arq" ] || { echo "arquivo nao existe: $arq"; exit 1; }
n=0
for v in "$@"; do
  if grep -qF -- "$v" "$arq"; then echo "valor proibido no arquivo: $v"; n=$((n+1)); fi
done
saida=$(awk '
  function prob(msg) { print (id != "" ? id ": " : "") msg; ruim++ }
  function fecha_bloco(   i) {
    if (!em_bloco) return
    if (!achou_cerca) prob("sem cerca de codigo")
    em_bloco = 0
  }
  BEGIN { split("Origem|Por que agora|Ganho|Confiança|Nota|Faltas|Status", rot, "|") }
  /^## Rodada / { if (rodada) { fecha_bloco(); exit } rodada = 1; next }
  !rodada { next }
  /^### / {
    fecha_bloco(); em_bloco = 1; k = 0; achou_cerca = 0; na_cerca = 0; id = ""
    if ($0 ~ /^### P-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9]+: ./) { id = $2; sub(/:$/, "", id) }
    else prob("titulo com identificador fora do molde P-AAAA-MM-DD-N: " $0)
    next
  }
  !em_bloco { if ($0 ~ /[^ \t]/) { id = ""; prob("linha fora do molde antes da primeira pauta: " $0) } next }
  na_cerca {
    if ($0 ~ /^```/) { na_cerca = 0; if (id != "" && !id_na_cerca) prob("cerca sem o identificador da pauta"); next }
    if (id != "" && index($0, id)) id_na_cerca = 1
    next
  }
  $0 ~ /^```/ && !achou_cerca {
    for (i = k + 1; i <= 7; i++) prob("sem a linha " rot[i] ":")
    achou_cerca = 1; na_cerca = 1; id_na_cerca = 0
    next
  }
  achou_cerca { if ($0 ~ /[^ \t]/) prob("linha fora do molde depois da cerca: " $0); next }
  $0 !~ /[^ \t]/ { next }
  {
    k++
    if (k > 7) { prob("linha fora do molde: " $0); next }
    r = rot[k]
    if (index($0, r ":") != 1) { prob("linha " k " deveria ser " r ": mas e: " $0); next }
    v = substr($0, length(r) + 2); gsub(/^[ \t]+|[ \t]+$/, "", v)
    if (v == "") { prob(r " vazio"); next }
    if (r == "Origem" && $0 !~ /^Origem: (continuação|fato|dor|notícia)/) prob("Origem fora das quatro palavras: " $0)
    if (r == "Confiança" && $0 !~ /^Confiança: (alta|média|baixa)/) prob("Confiança fora de alta, média ou baixa: " $0)
    if (r == "Nota" && $0 !~ /^Nota: [0-9]+\/16/) prob("Nota fora de N/16: " $0)
    if (r == "Status" && $0 !~ /^Status: (aberta|usada em [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])/) prob("Status invalido: " $0)
  }
  END {
    if (!rodada) { print "sem rodada: nenhum cabecalho ## Rodada"; ruim++ }
    else { if (na_cerca) prob("cerca de codigo sem fechamento"); fecha_bloco() }
  }
' "$arq")
echo "$saida" | grep -q . && { echo "$saida"; n=$((n+1)); }
[ "$n" = 0 ] || exit 1
