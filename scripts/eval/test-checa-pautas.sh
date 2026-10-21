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
variante velha-so 's/## Rodada 2026-10-21/## Rodada 2026-10-21: tema/'
confere "cabecalho com tema" 0 - "$tmp/velha-so.md"

[ "$falhas" = 0 ] || exit 1
