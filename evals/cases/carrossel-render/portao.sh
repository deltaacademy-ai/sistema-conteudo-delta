#!/usr/bin/env bash
# Portao mecanico do carrossel-render, sem juiz.
# Renderiza cada carrossel.json que o portao do carrossel-roteiro gravou (evals/results/nova/carrossel-roteiro/**),
# com a marca.md e a banidas.txt da propria pasta de fixture (o render confere o carrossel.json em
# modo --json e o slides.html com essa lista, e para no primeiro acerto), e imprime uma linha por
# caso: slides, PNGs e tamanho, paginas e fontes do PDF, escala aplicada e check-voz do HTML e do
# CSS gerados, de novo com a lista da fixture.
# Passa quando toda linha termina em "ok". Olhar as imagens continua sendo passo manual: o script
# so prova contagem, medida e fonte, nao legibilidade.
#
# uso: bash evals/cases/carrossel-render/portao.sh [pasta-de-resultados-do-roteiro] [pasta-de-saida]
set -u
RAIZ="$(cd "$(dirname "$0")/../../.." && pwd)"
ORIGEM="${1:-$RAIZ/evals/results/nova/carrossel-roteiro}"
SAIDA="${2:-$RAIZ/evals/results/nova/carrossel-render}"
mkdir -p "$SAIDA"
falhas=0; total=0
printf '%-20s %-6s %-14s %-8s %-52s %-28s %s\n' caso slides png pdf fontes escala resultado
while IFS= read -r json; do
  total=$((total+1))
  run="$(basename "$(echo "$json" | sed -E 's#/saida/.*##')" .md.arquivos)"   # ex.: 01-claude-opus-5
  marca="$(echo "$json" | sed -E 's#/saida/.*##')/marca.md"
  banidas="$(dirname "$marca")/banidas.txt"
  dest="$SAIDA/$run"
  rm -rf "$dest"; mkdir -p "$dest"
  log="$dest/render.log"
  if node "$RAIZ/scripts/render-carrossel.mjs" "$json" "$dest" --marca "$marca" >"$log" 2>&1; then r=ok; else r=FALHOU; falhas=$((falhas+1)); fi
  slides=$(node -e 'console.log(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).slides.length)' "$json")
  pngs=$(ls "$dest"/[0-9][0-9].png 2>/dev/null | wc -l | tr -d ' ')
  medidas=$(for p in "$dest"/[0-9][0-9].png; do sips -g pixelWidth -g pixelHeight "$p" 2>/dev/null | awk '/pixelWidth/{w=$2}/pixelHeight/{h=$2}END{print w"x"h}'; done | sort -u | paste -sd, -)
  paginas=$(grep -o 'pdf: [0-9]* paginas' "$log" | grep -o '[0-9]*' | head -1)
  fontes=$(grep -o 'fontes embutidas: .*' "$log" | sed 's/fontes embutidas: //; s/[A-Z]\{6\}+//g')
  escala=$(grep -o 'escala por slide: .*' "$log" | sed 's/escala por slide: //')
  for g in "$dest/slides.html" "$dest/tokens.css"; do
    if [ -f "$g" ] && ! bash "$RAIZ/scripts/check-voz.sh" "$g" "$banidas" >/dev/null; then r="$r check-voz:$(basename "$g")"; falhas=$((falhas+1)); fi
  done
  printf '%-20s %-6s %-14s %-8s %-52s %-28s %s\n' "$run" "$slides" "$pngs@$medidas" "${paginas:-?}p" "${fontes:-?}" "${escala:-?}" "$r"
done < <(find "$ORIGEM" -name carrossel.json | sort)
echo "casos: $total, falhas: $falhas"
[ "$falhas" -eq 0 ] && [ "$total" -gt 0 ]
