#!/usr/bin/env bash
# Testes do scripts/render-carrossel.mjs nos caminhos que a revisao da Tarefa 11 apontou:
# 1) piso de legibilidade: texto que exigiria escala abaixo de 0.78 e falha nomeada, nao slide menor;
# 2) @ e dominio ausentes (ou secao de marca.md com outro titulo) saem como aviso e padrao, nunca em silencio;
# 3) a checagem de voz do HTML le so o texto renderizado: termo banido que coincide com identificador
#    do template ("escala") nao trava o render, e termo no texto de um slide trava nomeando o slide.
# Precisa de Playwright instalado (npm i playwright && npx playwright install chromium).
# uso: bash evals/cases/carrossel-render/test-render.sh
set -u
RAIZ="$(cd "$(dirname "$0")/../../.." && pwd)"
F="$RAIZ/evals/cases/carrossel-render"
render() { node "$RAIZ/scripts/render-carrossel.mjs" "$@"; }
d=$(mktemp -d); falhas=0
ok()    { echo "ok    $1"; }
falha() { echo "FALHA $1"; falhas=$((falhas+1)); }
gera() { # gera <pasta> <chars por linha do corpo do slide 2> <linhas>
  mkdir -p "$1"
  node -e '
    const [p, n, k] = process.argv.slice(1);
    const l = ("Frase de teste com acento, cedilha e número 1080 que se repete até encher a linha inteira do slide. ").repeat(20).slice(0, +n);
    const j = { slides: [
      { tipo: "capa", titulo: "Capa de teste", corpo: "", apoio: "Apoio da capa." },
      { tipo: "conteudo", titulo: "Slide de conteúdo", corpo: Array(+k).fill(l).join("\n"), apoio: "Apoio curto." },
      { tipo: "fecho", titulo: "Fecho", corpo: "Fim.", apoio: "@teste" } ],
      legenda_instagram: "x", titulo_pdf: "teste" };
    require("fs").writeFileSync(p + "/carrossel.json", JSON.stringify(j));' "$1" "$2" "$3"
}

# 1) piso de legibilidade
gera "$d/piso" 700 3
out=$(render "$d/piso/carrossel.json" "$d/piso/out" --marca "$F/marca.md" 2>&1); code=$?
if [ $code -eq 1 ] && grep -q 'FALHA: slide 2: texto nao coube no quadro sem descer do piso de 28px' <<<"$out" && grep -q 'sobram [0-9]*px, cerca de [0-9]* caracteres a menos' <<<"$out" && grep -q '02=0.78!' <<<"$out"; then ok "piso: 3 linhas de 700 falham nomeando o slide, a sobra e a escala 0.78"; else falha "piso: esperava saida 1 com slide, sobra e escala 0.78; saida $code:"; echo "$out" | tail -3; fi
gera "$d/cabe" 220 3
out=$(render "$d/cabe/carrossel.json" "$d/cabe/out" --marca "$F/marca.md" 2>&1); code=$?
esc=$(grep -o '02=[0-9.]*' <<<"$out")
if [ $code -eq 0 ] && [ "$esc" != "02=1.00" ] && ! grep -q '!' <<<"$(grep 'escala por slide' <<<"$out")"; then ok "piso: 3 linhas de 220 reduzem ($esc) e passam"; else falha "piso: 3 linhas de 220 deviam reduzir e passar; saida $code, $esc"; fi
grep -qE '02=0\.(7[89]|[89][0-9])' <<<"$out" && ok "piso: escala reduzida fica em 0.78 ou acima" || falha "piso: escala abaixo de 0.78 ($esc)"

# 2) @ e dominio: secao com titulo que o parser nao reconhece ("## Redes") nunca sai em silencio
mkdir -p "$d/ident"; sed 's/## Identificação/## Redes/' "$F/marca.md" > "$d/ident/marca.md"
gera "$d/ident" 60 2
out=$(render "$d/ident/carrossel.json" "$d/ident/out" --marca "$d/ident/marca.md" 2>&1); code=$?
if [ $code -eq 0 ] && grep -q 'aviso: marca.md: secao "Identificacao" nao encontrada (titulos lidos: .*Redes' <<<"$out" && grep -q 'aviso: marca.md: @ (handle) nao encontrado' <<<"$out" && grep -q 'aviso: marca.md: dominio nao encontrado' <<<"$out" && grep -q 'padroes aplicados: .*@ = vazio.*dominio = vazio' <<<"$out"; then ok "marca: secao Redes gera aviso de secao, de @ e de dominio, e entra em padroes"; else falha "marca: faltou aviso ou padrao para @ e dominio; saida $code:"; echo "$out" | grep -E 'aviso|padroes'; fi
grep -q '"@ = vazio' "$d/ident/out/render-relatorio.json" && ok "marca: padrao de @ vazio gravado no relatorio" || falha "marca: relatorio sem o padrao de @"
# a variante "## Identidade" (repro da revisao) passou a ser reconhecida: @ e dominio entram, sem aviso
mkdir -p "$d/ident2"; sed 's/## Identificação/## Identidade/' "$F/marca.md" > "$d/ident2/marca.md"
out=$(render "$d/ident/carrossel.json" "$d/ident2/out" --marca "$d/ident2/marca.md" 2>&1); code=$?
[ $code -eq 0 ] && ! grep -q 'aviso: marca.md' <<<"$out" && grep -q '@hdoria' "$d/ident2/out/slides.html" && ok "marca: titulo Identidade e reconhecido, @ entra nos slides" || falha "marca: titulo Identidade devia ser reconhecido; saida $code"
out=$(render "$d/cabe/carrossel.json" "$d/cabe/out2" --marca "$F/marca.md" 2>&1)
grep -q 'padroes aplicados: nenhum' <<<"$out" && ! grep -q 'aviso: marca.md' <<<"$out" && ok "marca: marca.md completa nao gera aviso nem padrao" || falha "marca: marca.md completa gerou aviso ou padrao"

# 3) checagem de voz do HTML so no texto renderizado
printf 'escala\n' > "$d/ban-escala.txt"
out=$(render "$d/cabe/carrossel.json" "$d/voz-css/out" --marca "$F/marca.md" --banidas "$d/ban-escala.txt" 2>&1); code=$?
if [ $code -eq 0 ] && [ "$(grep -c '^voz: .*: limpo' <<<"$out")" -eq 2 ]; then ok "voz: termo 'escala' (identificador do CSS) nao trava o render"; else falha "voz: 'escala' na lista travou ou nao conferiu; saida $code:"; echo "$out" | grep -E 'voz|FALHA' | head -3; fi
printf 'frase\n' > "$d/ban-frase.txt"
out=$(render "$d/cabe/out/slides.html" "$d/voz-html/out" --banidas "$d/ban-frase.txt" 2>&1); code=$?
if [ $code -eq 1 ] && grep -q 'slides.html (texto renderizado) acusou' <<<"$out" && grep -q '^slide 2: \[frase\]' <<<"$out" && ! grep -q '^slide 1:' <<<"$out"; then ok "voz: termo no texto do slide 2 trava nomeando o slide 2, e so ele"; else falha "voz: termo no texto devia travar nomeando o slide 2; saida $code:"; echo "$out" | head -4; fi
printf 'hdoria\n' > "$d/ban-marca.txt"
out=$(render "$d/cabe/out/slides.html" "$d/voz-marca/out" --banidas "$d/ban-marca.txt" 2>&1); code=$?
[ $code -eq 1 ] && grep -q '^slide 1: \[hdoria\] @hdoria' <<<"$out" && ok "voz: texto do template que chega ao leitor (@ do topo) tambem e conferido" || falha "voz: @ do topo devia ser conferido; saida $code"

rm -rf "$d"
[ "$falhas" -eq 0 ] && echo "todos os testes de render passaram" || { echo "$falhas teste(s) de render falharam"; exit 1; }
