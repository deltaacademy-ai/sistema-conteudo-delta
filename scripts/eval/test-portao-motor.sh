#!/usr/bin/env bash
# Confere duas partes do portao do motor (evals/cases/motor/portao.sh) sem modelo, com saidas falsas
# reaproveitadas por ESTADO_DE: o caso 06 (pedido de pautas numa pasta sem icp.md) e o caso 05 usando o
# dia da execucao original em vez do dia de agora.
set -u
raiz=$(cd "$(dirname "$0")/../.." && pwd); cd "$raiz"
portao=evals/cases/motor/portao.sh
orig=tst-motor-origem; saida=tst-motor-saida
trap 'rm -rf "evals/results/nova/motor-$orig" "evals/results/nova/motor-$saida"' EXIT
falhas=0
O="evals/results/nova/motor-$orig"; S="evals/results/nova/motor-$saida"

roda() { # roda <caso> <esperado> <trecho|-> <descricao>
  local caso="$1" esp="$2" trecho="$3" d="$4" lin
  rm -rf "$S"
  CASOS="$caso" MODELOS=fake ESTADO_DE="$orig" bash "$portao" "$saida" > /dev/null 2>&1
  lin=$(grep "^$caso-fake" "$S/_placar.txt" 2>/dev/null)
  if [[ "$lin" != *"$esp"* ]]; then echo "FALHA $d: esperado $esp, veio: $lin"; falhas=$((falhas+1)); return; fi
  if [ "$trecho" != "-" ] && [[ "$lin" != *"$trecho"* ]]; then echo "FALHA $d: sem '$trecho': $lin"; falhas=$((falhas+1)); return; fi
  echo "ok $d"
}
caso06() { # caso06 <texto-da-resposta>: monta o turno 1 falso do caso 06 com a pasta igual a fixture
  rm -rf "$O"; mkdir -p "$O/06-fake-t1.md.arquivos"
  cp -R evals/fixtures/hugo-radar-sem-icp/. "$O/06-fake-t1.md.arquivos/"
  printf '%s\n' "$1" > "$O/06-fake-t1.md"
}

caso06 'Falta o icp.md nesta pasta. O contexto-negocio monta esse arquivo, e depois eu rodo o radar.'
roda 06 PASSA - "06 resposta direta passa"
caso06 'Falta o icp.md. Quer que eu chame o contexto-negocio agora?'
roda 06 "NAO PASSA" "resposta-com-pergunta" "06 com pergunta reprova"
caso06 'Vamos montar o seu contexto. Falta o icp.md e o contexto-negocio faz isso.'
printf 'Quem le: x\n' > "$O/06-fake-t1.md.arquivos/icp.md"
roda 06 "NAO PASSA" "arquivo-novo:icp.md" "06 com icp.md criado reprova"
caso06 'Tudo certo, aqui estao as pautas.'
roda 06 "NAO PASSA" "resposta-nao-diz-que-falta-icp.md" "06 sem dizer que falta o icp reprova"

# caso 05: o dia da execucao original vem de estado/datas-<modelo>/hoje.txt, e nao do relogio
rm -rf "$O"; mkdir -p "$O/estado"
est="$O/estado/datas-fake"
bash scripts/eval/datas-relativas.sh evals/cases/motor/05.md "$est" > /dev/null
ontem=$(date -j -v-1d +%F 2>/dev/null || date -d yesterday +%F); echo "$ontem" > "$est/hoje.txt"
id=$(grep -oE 'P-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]+' "$est/cases/motor/05.md" | head -1)
mkdir -p "$O/05-fake-t1.md.arquivos"; cp -R "$est/fixtures/hugo-radar-anterior/." "$O/05-fake-t1.md.arquivos/"
echo "resposta falsa" > "$O/05-fake-t1.md"
awk -v id="$id" -v hoje="$ontem" '/^### /{ em = (index($0, "### " id ":") == 1) } /^## /{ em = 0 } em && /^Status:/ { print "Status: usada em " hoje; next } { print }' \
  "$est/fixtures/hugo-radar-anterior/pautas.md" > "$O/05-fake-t1.md.arquivos/pautas.md"
roda 05 - "pautas: ok" "05 usa o dia da execucao original (hoje.txt)"
awk -v id="$id" -v hoje="$(date +%F)" '/^### /{ em = (index($0, "### " id ":") == 1) } /^## /{ em = 0 } em && /^Status:/ { print "Status: usada em " hoje; next } { print }' \
  "$est/fixtures/hugo-radar-anterior/pautas.md" > "$O/05-fake-t1.md.arquivos/pautas.md"
roda 05 - "pautas-diferem-do-esperado" "05 com o dia de agora no lugar do original reprova"
# linha em branco a mais em pautas.md nao passa mais (sem diff -B)
printf '\n' >> "$O/05-fake-t1.md.arquivos/pautas.md"
awk -v id="$id" -v hoje="$ontem" '/^### /{ em = (index($0, "### " id ":") == 1) } /^## /{ em = 0 } em && /^Status:/ { print "Status: usada em " hoje; next } { print }' \
  "$est/fixtures/hugo-radar-anterior/pautas.md" > "$O/05-fake-t1.md.arquivos/pautas.md"; printf '\n\n' >> "$O/05-fake-t1.md.arquivos/pautas.md"
roda 05 - "pautas-diferem-do-esperado" "05 com linhas em branco a mais reprova"

[ "$falhas" = 0 ] || exit 1
