#!/usr/bin/env bash
# Confere scripts/eval/datas-relativas.sh com um caso e uma fixture de brinquedo:
# {HOJE} e {HOJE-N} viram AAAA-MM-DD no prompt_novo e nos arquivos de texto da
# fixture copiada, o caso copiado enxerga a fixture copiada pelo run-case.sh, e
# o caso e a fixture originais nao mudam. Sai 1 com uma linha FALHA por conferencia.
set -u
raiz=$(cd "$(dirname "$0")/../.." && pwd)
script="$raiz/scripts/eval/datas-relativas.sh"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
dia() { date -v-"$1"d +%F 2>/dev/null || date -d "-$1 days" +%F; }   # BSD ou GNU
hoje=$(dia 0); d20=$(dia 20); d3=$(dia 3)

mkdir -p "$tmp/origem/cases/toy" "$tmp/origem/fixtures/brinquedo/sub"
cat > "$tmp/origem/cases/toy/01.md" <<'CASO'
---
especialista: toy
fixture: brinquedo
prompt_novo: Rodada de {HOJE} com noticia de {HOJE-20}. Id P-{HOJE-3}-1.
---

Corpo com {HOJE} que nao e prompt e pode ficar como esta.
CASO
printf 'Hoje e {HOJE}.\nPublicada em {HOJE-20}.\n' > "$tmp/origem/fixtures/brinquedo/pautas.md"
printf 'id P-{HOJE-3}-2\n' > "$tmp/origem/fixtures/brinquedo/sub/nota.md"
printf '\211PNG {HOJE}\000\001' > "$tmp/origem/fixtures/brinquedo/imagem.png"
cp -R "$tmp/origem" "$tmp/guardado"

falhas=0
confere() { # confere <descricao> <comando...>
  local d="$1"; shift
  if "$@"; then echo "ok    $d"; else echo "FALHA $d"; falhas=$((falhas+1)); fi
}

caminho=$(bash "$script" "$tmp/origem/cases/toy/01.md" "$tmp/saida" 2>"$tmp/erro" </dev/null)
[ -f "$caminho" ] || caminho="$tmp/inexistente.md"
confere "imprime o caminho do caso copiado" test -f "$caminho"
confere "prompt_novo com as datas trocadas" \
  grep -qxF "prompt_novo: Rodada de $hoje com noticia de $d20. Id P-$d3-1." "$caminho"
confere "campo fixture aponta para a fixture copiada" \
  bash -c 'f=$(awk -F": " "\$1==\"fixture\"{print \$2}" "$1" </dev/null) && test -d "$(cd "$(dirname "$1")/../.." && pwd)/fixtures/$f"' _ "$caminho"
confere "arquivo da fixture copiada com as datas trocadas" \
  grep -qxF "Publicada em $d20." "$tmp/saida/fixtures/brinquedo/pautas.md"
confere "subpasta da fixture copiada com a data trocada" \
  grep -qxF "id P-$d3-2" "$tmp/saida/fixtures/brinquedo/sub/nota.md"
confere "binario copiado sem alteracao" \
  cmp -s "$tmp/origem/fixtures/brinquedo/imagem.png" "$tmp/saida/fixtures/brinquedo/imagem.png"
confere "caso e fixture originais intactos" diff -rq "$tmp/guardado" "$tmp/origem"
confere "sem marcador no que foi trocado" \
  bash -c 'test -f "$1/pautas.md" && ! grep -rqE "\{HOJE" "$1/pautas.md" "$1/sub"' _ "$tmp/saida/fixtures/brinquedo"
confere "run-case enxerga a fixture (mesma convencao de pastas)" \
  test -d "$(cd "$(dirname "$caminho")/../.." && pwd)/fixtures"
[ "$falhas" -eq 0 ] || exit 1
