#!/usr/bin/env bash
# uso: checa-pautas.sh [--rodada AAAA-MM-DD] <pautas.md> [valor-proibido ...]
#
# Confere a forma da rodada mais nova de um pautas.md (a primeira "## Rodada" do arquivo, ou a
# de --rodada AAAA-MM-DD, com ou sem tema no cabecalho):
# cada pauta tem o titulo "### P-AAAA-MM-DD-N: ...", as sete linhas Origem, Por que agora,
# Ganho, Confianca, Nota, Faltas e Status, nessa ordem, coladas e com valor, e depois uma
# cerca de codigo com o identificador da pauta dentro; nenhuma outra linha entra no bloco.
# Origem comeca por continuacao, fato, dor ou noticia; Confianca e alta, media ou baixa;
# Nota e N/16 com N de 0 a 16; Status e aberta ou "usada em AAAA-MM-DD". Cada valor proibido
# (por exemplo um numero que so veio de resumo) nao pode aparecer em lugar nenhum do arquivo.
# Alem da forma, confere o que e mecanico na rodada conferida: o id leva a data do cabecalho da
# rodada; a cerca abre sem linguagem; a Origem carrega a referencia que o tipo exige (continuacao:
# base-conteudo.md; fato: prova.md ou materiais/; dor: icp.md, sempre com algo depois do arquivo;
# noticia: link http ou "colada pela pessoa") e nao cita o proprio sistema; noticia traz
# "publicada em AAAA-MM-DD" a ate 15 dias antes da rodada (nem depois dela) ou entao
# [FALTA: data de publicacao] em Faltas com Confianca baixa; Confianca alta em noticia pede dois
# sites diferentes na Origem; numero do titulo aparece em outra linha da pauta.
# Rodadas anteriores nao entram. Sai 0 quando esta limpo; fora isso, sai 1 com uma linha por problema.
alvo=""
if [ "${1:-}" = "--rodada" ]; then alvo="${2:-}"; shift 2 2>/dev/null || shift $#; fi
arq="${1:-}"; [ $# -gt 0 ] && shift
[ -f "$arq" ] || { echo "arquivo nao existe: $arq"; exit 1; }
n=0
for v in "$@"; do
  if grep -qF -- "$v" "$arq"; then echo "valor proibido no arquivo: $v"; n=$((n+1)); fi
done
saida=$(awk -v alvo="$alvo" '
  function prob(msg) { print (id != "" ? id ": " : "") msg; ruim++; bloco_ruim++ }
  function dias(d,   y, m, dd, era, yoe, doy) { # AAAA-MM-DD -> numero de dias (calendario gregoriano)
    y = substr(d, 1, 4) + 0; m = substr(d, 6, 2) + 0; dd = substr(d, 9, 2) + 0
    if (m <= 2) y--
    era = int(y / 400); yoe = y - era * 400
    doy = int((153 * (m + (m > 2 ? -3 : 9)) + 2) / 5) + dd - 1
    return era * 146097 + yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy
  }
  function sites(o,   rest, n, h, vistos) { # quantos sites diferentes (sem www.) tem a linha
    rest = o; n = 0
    while (match(rest, /https?:\/\/[^\/ ,;")>]+/)) {
      h = substr(rest, RSTART, RLENGTH); sub(/^https?:\/\//, "", h); sub(/^www\./, "", h)
      if (!(h in vistos)) { vistos[h] = 1; n++ }
      rest = substr(rest, RSTART + RLENGTH)
    }
    return n
  }
  function tem_numero(texto, n,   pos, ant, dep, resto, off) { # n aparece em texto sem digito colado
    off = 0; resto = texto
    while ((pos = index(resto, n)) > 0) {
      ant = (off + pos > 1) ? substr(texto, off + pos - 1, 1) : ""
      dep = substr(texto, off + pos + length(n), 1)
      if (ant !~ /[0-9]/ && dep !~ /[0-9]/) return 1
      off += pos; resto = substr(resto, pos + 1)
    }
    return 0
  }
  function depois_do_arquivo(o, fim) { return substr(o, fim) ~ /[A-Za-z0-9]/ }
  function semantica(   o, tipo, ok, fim, pd, delta, resto, n, corpo, i) {
    o = lin[1]
    if (substr(id, 3, 10) != rd) prob("id com data diferente da rodada " rd)
    if (o ~ /SKILL\.md|skills\/|radar-pautas|sistema-conteudo/ || lin[2] ~ /SKILL\.md|skills\/|radar-pautas|sistema-conteudo/ || lin[3] ~ /SKILL\.md|skills\/|radar-pautas|sistema-conteudo/)
      prob("Origem, Por que agora ou Ganho citam o proprio sistema; ele nao e fonte de fato da pessoa")
    if (o ~ /^Origem: continuação/) {
      if (!(fim = index(o, "base-conteudo.md")) || !depois_do_arquivo(o, fim + 16)) prob("Origem de continuacao sem base-conteudo.md e a peca citada: " o)
    } else if (o ~ /^Origem: fato/) {
      if (match(o, /materiais\/[^ ,;"]+/)) fim = RSTART + RLENGTH
      else if ((fim = index(o, "prova.md"))) fim += 8
      if (!fim || !depois_do_arquivo(o, fim)) prob("Origem de fato sem prova.md ou materiais/<arquivo> e a linha citada: " o)
    } else if (o ~ /^Origem: dor/) {
      if (!(fim = index(o, "icp.md")) || !depois_do_arquivo(o, fim + 6)) prob("Origem de dor sem icp.md e o item citado: " o)
    } else if (o ~ /^Origem: notícia/) {
      if (o !~ /https?:\/\// && o !~ /colada pela pessoa/) prob("Origem de noticia sem link http nem \"colada pela pessoa\": " o)
      if (match(o, /publicada em [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) {
        pd = substr(o, RSTART + 13, 10); delta = dias(rd) - dias(pd)
        if (delta < 0) prob("noticia com data de publicacao depois da rodada: " pd)
        else if (delta > 15) prob("noticia publicada ha " delta " dias (" pd "), fora da janela de 15 dias da rodada " rd)
      } else {
        if (lin[6] !~ /FALTA: data de publicação/) prob("noticia sem \"publicada em AAAA-MM-DD\" na Origem e sem [FALTA: data de publicacao] em Faltas")
        if (lin[4] !~ /^Confiança: baixa/) prob("noticia sem data de publicacao so pode ter Confianca: baixa")
      }
      if (lin[4] ~ /^Confiança: alta/ && sites(o) < 2) prob("Confianca alta em noticia pede duas fontes independentes (dois sites diferentes com link na Origem)")
    }
    if (match(lin[5], /[0-9]+\/16/) && substr(lin[5], RSTART, RLENGTH - 3) + 0 > 16) prob("Nota acima de 16: " lin[5])
    corpo = lin[1] "\n" lin[2] "\n" lin[3] "\n" lin[4] "\n" lin[6] "\n" cerca
    gsub(/P-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9]+/, "", corpo)
    resto = tit
    while (match(resto, /[0-9]+([.,][0-9]+)*/)) {
      n = substr(resto, RSTART, RLENGTH); resto = substr(resto, RSTART + RLENGTH)
      if (!tem_numero(corpo, n)) prob("numero " n " do titulo nao aparece em nenhuma outra linha da pauta; tire do titulo ou cite a fonte")
    }
  }
  function fecha_bloco(   i) {
    if (!em_bloco) return
    if (!achou_cerca) prob("sem cerca de codigo")
    if (id != "" && bloco_ruim == 0) semantica()
    em_bloco = 0
  }
  BEGIN { split("Origem|Por que agora|Ganho|Confiança|Nota|Faltas|Status", rot, "|") }
  /^## / {
    if (rodada) { fecha_bloco(); exit }
    if ($0 ~ /^## Rodada / && (alvo == "" || index($0, "## Rodada " alvo) == 1)) {
      rodada = 1; achou = 1
      if (match($0, /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) rd = substr($0, RSTART, 10)
      else { print "cabecalho da rodada sem data AAAA-MM-DD: " $0; ruim++ }
    }
    next
  }
  !rodada { next }
  /^### / {
    fecha_bloco(); em_bloco = 1; k = 0; achou_cerca = 0; na_cerca = 0; id = ""; bloco_ruim = 0; cerca = ""; tit = ""
    for (i = 1; i <= 7; i++) lin[i] = ""
    if ($0 ~ /^### P-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9]+: ./) { id = $2; sub(/:$/, "", id); tit = $0; sub(/^### [^:]*: */, "", tit) }
    else prob("titulo com identificador fora do molde P-AAAA-MM-DD-N: " $0)
    next
  }
  !em_bloco { if ($0 ~ /[^ \t]/) { id = ""; prob("linha fora do molde antes da primeira pauta: " $0) } next }
  na_cerca {
    if ($0 ~ /^```/) { na_cerca = 0; if (id != "" && !id_na_cerca) prob("cerca sem o identificador da pauta"); next }
    if (id != "" && index($0, id)) id_na_cerca = 1
    cerca = cerca $0 "\n"
    next
  }
  $0 ~ /^```/ && !achou_cerca {
    for (i = k + 1; i <= 7; i++) prob("sem a linha " rot[i] ":")
    if ($0 !~ /^```[ \t]*$/) prob("cerca de codigo com linguagem; abra com tres crases sem nome: " $0)
    achou_cerca = 1; na_cerca = 1; id_na_cerca = 0
    next
  }
  achou_cerca { if ($0 ~ /[^ \t]/) prob("linha fora do molde depois da cerca: " $0); next }
  $0 !~ /[^ \t]/ { next }
  {
    k++
    if (k > 7) { prob("linha fora do molde: " $0); next }
    r = rot[k]; lin[k] = $0
    if (index($0, r ":") != 1) { prob("linha " k " deveria ser " r ": mas e: " $0); next }
    v = substr($0, length(r) + 2); gsub(/^[ \t]+|[ \t]+$/, "", v)
    if (v == "") { prob(r " vazio"); next }
    if (r == "Origem" && $0 !~ /^Origem: (continuação|fato|dor|notícia)/) prob("Origem fora das quatro palavras: " $0)
    if (r == "Confiança" && $0 !~ /^Confiança: (alta|média|baixa)/) prob("Confiança fora de alta, média ou baixa: " $0)
    if (r == "Nota" && $0 !~ /^Nota: [0-9]+\/16/) prob("Nota fora de N/16: " $0)
    if (r == "Status" && $0 !~ /^Status: (aberta|usada em [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])/) prob("Status invalido: " $0)
  }
  END {
    if (!achou) { print "sem rodada: nenhum cabecalho ## Rodada" (alvo != "" ? " " alvo : ""); ruim++ }
    else { if (na_cerca) prob("cerca de codigo sem fechamento"); fecha_bloco() }
  }
' "$arq")
echo "$saida" | grep -q . && { echo "$saida"; n=$((n+1)); }
[ "$n" = 0 ] || exit 1
