#!/usr/bin/env bash
# Confere scripts/checa-pautas.sh com um pautas.md bom e variantes ruins: cada defeito
# precisa sair com codigo 1 e uma linha que o nomeia; o arquivo bom sai 0 sem saida;
# so a rodada mais nova conta. Sai 1 com uma linha FALHA por conferencia.
set -u
raiz=$(cd "$(dirname "$0")/../.." && pwd)
script="$raiz/scripts/checa-pautas.sh"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

bom() { cat <<'P'
# Pautas

## Rodada 2026-10-21

### P-2026-10-21-1: Titulo curto
Origem: notícia, colada pela pessoa, publicada em 2026-10-19, "trecho"
Por que agora: a nota saiu em 2026-10-19.
Ganho: traz o caso de prova.md que o post comum nao traz.
Confiança: média
Nota: 12/16
Faltas: [FALTA: leitura da pessoa sobre o tema]
Status: aberta

```
Use a skill motor do plugin sistema-conteudo. Pauta P-2026-10-21-1. TEMA: x
```

### P-2026-10-21-2: Outro titulo
Origem: fato, prova.md, linha "63 check-ins"
Por que agora: gatilho em icp.md.
Ganho: numero com fonte.
Confiança: alta
Nota: 14/16
Faltas: nada
Status: aberta

```
Use a skill motor. Pauta P-2026-10-21-2. TEMA: y
```

## Rodada 2026-10-18

### P-2026-10-18-1: Pauta antiga mal formada
Origem: dor
Status: aberta
P
}

falhas=0
confere() { # confere <descricao> <codigo-esperado> <trecho-esperado-na-saida|-> <arquivo> [valores...]
  local d="$1" cod="$2" trecho="$3" arq="$4" saida rc; shift 4
  saida=$(bash "$script" "$arq" "$@" 2>&1); rc=$?
  if [ "$rc" != "$cod" ]; then echo "FALHA $d: codigo $rc, esperado $cod"; falhas=$((falhas+1)); return; fi
  if [ "$trecho" = "-" ]; then
    [ -z "$saida" ] || { echo "FALHA $d: saida nao vazia: $saida"; falhas=$((falhas+1)); return; }
  else
    grep -qF -- "$trecho" <<< "$saida" || { echo "FALHA $d: saida sem '$trecho': $saida"; falhas=$((falhas+1)); return; }
  fi
  echo "ok $d"
}
variante() { # variante <nome> <perl-substituicao>  -> grava $tmp/<nome>.md
  bom | perl -0pe "$2" > "$tmp/$1.md"
}

bom > "$tmp/bom.md"
confere "arquivo bom" 0 - "$tmp/bom.md"
confere "arquivo bom com valor que nao aparece" 0 - "$tmp/bom.md" "48%"
confere "arquivo inexistente" 1 "nao existe" "$tmp/nao-existe.md"
printf '# Pautas\n' > "$tmp/sem-rodada.md"
confere "sem rodada" 1 "rodada" "$tmp/sem-rodada.md"

variante nota-depois 's/(Nota: 12\/16\n)(Faltas: [^\n]*\n)/$2$1/'
confere "Faltas antes de Nota" 1 "P-2026-10-21-1" "$tmp/nota-depois.md"
variante sem-ganho 's/Ganho: traz[^\n]*\n//'
confere "sem a linha Ganho" 1 "Ganho" "$tmp/sem-ganho.md"
variante ganho-vazio 's/Ganho: traz[^\n]*\n/Ganho:\n/'
confere "Ganho vazio" 1 "Ganho" "$tmp/ganho-vazio.md"
variante faltas-vazio 's/Faltas: \[FALTA[^\n]*\n/Faltas:\n/'
confere "Faltas vazio" 1 "Faltas" "$tmp/faltas-vazio.md"
variante sem-id-na-cerca 's/Pauta P-2026-10-21-2\. //'
confere "cerca sem o id" 1 "P-2026-10-21-2" "$tmp/sem-id-na-cerca.md"
variante sem-cerca 's/```\nUse a skill motor do plugin[^\n]*\n```\n//'
confere "sem cerca" 1 "cerca" "$tmp/sem-cerca.md"
variante origem-ruim 's/Origem: fato,/Origem: ideia,/'
confere "Origem fora das quatro palavras" 1 "Origem" "$tmp/origem-ruim.md"
variante id-ruim 's/### P-2026-10-21-2:/### P-2026-10-2:/'
confere "id fora do molde" 1 "identificador" "$tmp/id-ruim.md"
variante linha-solta 's/(Status: aberta\n)(\n```\nUse a skill motor do plugin)/Nota sobre a fonte: algo\n$1$2/'
confere "linha solta no bloco" 1 "Nota sobre a fonte" "$tmp/linha-solta.md"
variante confianca-ruim 's/Confiança: alta/Confiança: otima/'
confere "Confiança fora de alta, média, baixa" 1 "Confiança" "$tmp/confianca-ruim.md"
variante status-ruim 's/Status: aberta\n\n```\nUse a skill motor\./Status: feita\n\n```\nUse a skill motor./'
confere "Status invalido" 1 "Status" "$tmp/status-ruim.md"
variante nota-ruim 's/Nota: 14\/16/Nota: alta/'
confere "Nota fora de N/16" 1 "Nota" "$tmp/nota-ruim.md"
confere "valor proibido em qualquer lugar" 1 "63 check-ins" "$tmp/bom.md" "63 check-ins"
variante cabecalho-com-tema 's/## Rodada 2026-10-21/## Rodada 2026-10-21: tema/'
confere "cabecalho com tema" 0 - "$tmp/cabecalho-com-tema.md"
variante cerca-aberta 's/(TEMA: y\n)```\n/$1/'
confere "cerca sem fechamento" 1 "sem fechamento" "$tmp/cerca-aberta.md"
variante solta-depois 's/(TEMA: x\n```\n)/$1Comentario solto\n/'
confere "linha solta depois da cerca" 1 "Comentario solto" "$tmp/solta-depois.md"
variante titulo-sem-dois-pontos 's/### P-2026-10-21-2: Outro titulo/### P-2026-10-21-2 Outro titulo/'
confere "titulo sem dois-pontos" 1 "identificador" "$tmp/titulo-sem-dois-pontos.md"
saida=$(bash "$script" --rodada 2026-10-18 "$tmp/bom.md" 2>&1); rc=$?
if [ "$rc" = 1 ] && grep -q "P-2026-10-18-1" <<< "$saida"; then echo "ok --rodada confere a rodada pedida (a antiga mal formada acusa)"; else echo "FALHA --rodada 2026-10-18: codigo $rc, saida: $saida"; falhas=$((falhas+1)); fi
saida=$(bash "$script" --rodada 2026-10-21 "$tmp/bom.md" 2>&1); rc=$?
if [ "$rc" = 0 ] && [ -z "$saida" ]; then echo "ok --rodada da data de hoje passa sem olhar a antiga"; else echo "FALHA --rodada 2026-10-21: codigo $rc, saida: $saida"; falhas=$((falhas+1)); fi
saida=$(bash "$script" --rodada 2026-01-01 "$tmp/bom.md" 2>&1); rc=$?
if [ "$rc" = 1 ] && grep -q "sem rodada" <<< "$saida"; then echo "ok --rodada de data que nao existe"; else echo "FALHA --rodada 2026-01-01: codigo $rc, saida: $saida"; falhas=$((falhas+1)); fi

# --- regras que dependem do conteudo: data, nota, confianca, origem, titulo ---
variante id-outra-data 's/P-2026-10-21-2/P-2026-10-20-2/g'
confere "id com data que nao e a da rodada" 1 "data diferente da rodada" "$tmp/id-outra-data.md"
variante noticia-velha 's/publicada em 2026-10-19/publicada em 2026-09-01/'
confere "noticia publicada ha mais de 15 dias" 1 "fora da janela" "$tmp/noticia-velha.md"
variante noticia-no-limite 's/publicada em 2026-10-19/publicada em 2026-10-06/'
confere "noticia de exatamente 15 dias passa" 0 - "$tmp/noticia-no-limite.md"
variante noticia-16-dias 's/publicada em 2026-10-19/publicada em 2026-10-05/'
confere "noticia de 16 dias cai" 1 "fora da janela" "$tmp/noticia-16-dias.md"
variante noticia-futura 's/publicada em 2026-10-19/publicada em 2026-10-25/'
confere "noticia com data depois da rodada" 1 "depois da rodada" "$tmp/noticia-futura.md"
variante noticia-sem-data 's/, publicada em 2026-10-19//'
confere "noticia sem data e sem FALTA" 1 "sem \"publicada em" "$tmp/noticia-sem-data.md"
variante noticia-sem-data-conf-media 's/, publicada em 2026-10-19//; s/Faltas: \[FALTA: leitura da pessoa sobre o tema\]/Faltas: [FALTA: data de publicação]/'
confere "noticia sem data com FALTA mas confianca media" 1 "so pode ter Confianca: baixa" "$tmp/noticia-sem-data-conf-media.md"
variante noticia-sem-data-ok 's/, publicada em 2026-10-19//; s/Faltas: \[FALTA: leitura da pessoa sobre o tema\]/Faltas: [FALTA: data de publicação]/; s/Confiança: média/Confiança: baixa/'
confere "noticia sem data com FALTA e confianca baixa passa" 0 - "$tmp/noticia-sem-data-ok.md"
variante noticia-sem-data-alta 's/, publicada em 2026-10-19//; s/Faltas: \[FALTA: leitura da pessoa sobre o tema\]/Faltas: [FALTA: data de publicação]/; s/Confiança: média/Confiança: alta/'
confere "noticia sem data nao tem confianca alta" 1 "so pode ter Confianca: baixa" "$tmp/noticia-sem-data-alta.md"
variante noticia-alta-uma-fonte 's/Origem: notícia, colada pela pessoa,/Origem: notícia, https:\/\/a.com.br\/x,/; s/Confiança: média/Confiança: alta/'
confere "confianca alta com uma fonte so" 1 "duas fontes independentes" "$tmp/noticia-alta-uma-fonte.md"
variante noticia-alta-mesmo-site 's/Origem: notícia, colada pela pessoa,/Origem: notícia, https:\/\/a.com.br\/x e https:\/\/www.a.com.br\/y,/; s/Confiança: média/Confiança: alta/'
confere "confianca alta com dois links do mesmo site" 1 "duas fontes independentes" "$tmp/noticia-alta-mesmo-site.md"
variante noticia-alta-dois-sites 's/Origem: notícia, colada pela pessoa,/Origem: notícia, https:\/\/a.com.br\/x e https:\/\/b.com\/y,/; s/Confiança: média/Confiança: alta/'
confere "confianca alta com dois sites diferentes passa" 0 - "$tmp/noticia-alta-dois-sites.md"
variante noticia-sem-fonte 's/Origem: notícia, colada pela pessoa,/Origem: notícia,/'
confere "noticia sem link nem colada pela pessoa" 1 "sem link http" "$tmp/noticia-sem-fonte.md"
variante nota-17 's/Nota: 14\/16/Nota: 17\/16/'
confere "nota acima de 16" 1 "Nota acima de 16" "$tmp/nota-17.md"
variante nota-16 's/Nota: 14\/16/Nota: 16\/16/'
confere "nota 16 passa" 0 - "$tmp/nota-16.md"
variante nota-99 's/Nota: 12\/16/Nota: 99\/16/'
confere "nota 99 de 16" 1 "Nota acima de 16" "$tmp/nota-99.md"
variante fato-sem-arquivo 's/Origem: fato, prova.md, linha "63 check-ins"/Origem: fato, conversa com a pessoa/'
confere "fato sem prova.md nem materiais" 1 "Origem de fato" "$tmp/fato-sem-arquivo.md"
variante fato-sem-linha 's/Origem: fato, prova.md, linha "63 check-ins"/Origem: fato, prova.md/'
confere "fato sem a linha citada" 1 "Origem de fato" "$tmp/fato-sem-linha.md"
variante fato-materiais 's/Origem: fato, prova.md, linha "63 check-ins"/Origem: fato, materiais\/post-x.md, secao 2/'
confere "fato de materiais com secao passa" 0 - "$tmp/fato-materiais.md"
variante dor-sem-icp 's/Origem: fato, prova.md, linha "63 check-ins"/Origem: dor, o leitor se perde no financeiro/'
confere "dor sem icp.md" 1 "Origem de dor" "$tmp/dor-sem-icp.md"
variante dor-ok 's/Origem: fato, prova.md, linha "63 check-ins"/Origem: dor, icp.md, item "O que preocupa"/'
confere "dor com icp.md e item passa" 0 - "$tmp/dor-ok.md"
variante continuacao-sem-base 's/Origem: fato, prova.md, linha "63 check-ins"/Origem: continuação, a peça de setembro/'
confere "continuacao sem base-conteudo.md" 1 "Origem de continuacao" "$tmp/continuacao-sem-base.md"
variante continuacao-ok 's/Origem: fato, prova.md, linha "63 check-ins"/Origem: continuação, base-conteudo.md, peça de 2026-09-12/'
confere "continuacao com base-conteudo.md passa" 0 - "$tmp/continuacao-ok.md"
variante origem-sistema 's/Origem: fato, prova.md, linha "63 check-ins"/Origem: fato, prova.md, linha vinda do SKILL.md do radar/'
confere "origem que cita o proprio sistema" 1 "proprio sistema" "$tmp/origem-sistema.md"
variante ganho-sistema 's/Ganho: numero com fonte\./Ganho: o sistema ganhou o radar-pautas hoje./'
confere "ganho que cita o proprio sistema" 1 "proprio sistema" "$tmp/ganho-sistema.md"
variante cerca-com-linguagem 's/```\nUse a skill motor do plugin/```python\nUse a skill motor do plugin/'
confere "cerca com linguagem" 1 "com linguagem" "$tmp/cerca-com-linguagem.md"
variante titulo-numero-solto 's/### P-2026-10-21-2: Outro titulo/### P-2026-10-21-2: 5 erros que custam caro/'
confere "numero no titulo sem lastro" 1 "numero 5 do titulo" "$tmp/titulo-numero-solto.md"
variante titulo-numero-com-lastro 's/### P-2026-10-21-2: Outro titulo/### P-2026-10-21-2: 63 check-ins em um dia/'
confere "numero no titulo que aparece na Origem passa" 0 - "$tmp/titulo-numero-com-lastro.md"
variante titulo-numero-no-id 's/### P-2026-10-21-2: Outro titulo/### P-2026-10-21-2: 21 motivos/'
confere "numero do titulo igual a parte do id nao conta" 1 "numero 21 do titulo" "$tmp/titulo-numero-no-id.md"
variante titulo-numero-colado 's/### P-2026-10-21-2: Outro titulo/### P-2026-10-21-2: 3 check-ins/'
confere "numero do titulo dentro de outro numero nao conta" 1 "numero 3 do titulo" "$tmp/titulo-numero-colado.md"
variante cabecalho-sem-data 's/## Rodada 2026-10-21/## Rodada de hoje/'
confere "cabecalho da rodada sem data" 1 "cabecalho da rodada sem data" "$tmp/cabecalho-sem-data.md"


[ "$falhas" = 0 ] || exit 1
