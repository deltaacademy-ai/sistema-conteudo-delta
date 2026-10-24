#!/usr/bin/env bash
# Confere o portao do radar-pautas (evals/cases/radar-pautas/portao.sh) com saidas falsas, sem modelo:
# usa REAVALIAR e HOJE fixo, e diz se o portao PASSA ou NAO PASSA e por qual achado.
# Cobre o que o portao precisa pegar: caso rede sem noticia de verdade ou com a data errada (a de
# publicacao, nao a primeira da linha), caso 05 com pauta da noticia escrita sem a palavra-chave,
# caso 06 com consumo final, e o caso 03 com HOJE diferente do relogio.
set -u
raiz=$(cd "$(dirname "$0")/../.." && pwd); cd "$raiz"
portao=evals/cases/radar-pautas/portao.sh
fonte=tst-portao-fonte; saida=tst-portao-saida
base="evals/results/nova/radar-pautas-$fonte"
trap 'rm -rf "evals/results/nova/radar-pautas-$fonte" "evals/results/nova/radar-pautas-$saida"' EXIT
export HOJE=2026-10-22
falhas=0

pauta() { # pauta <n> <titulo> <origem> <confianca> <faltas>
  cat <<P

### P-$HOJE-$1: $2
Origem: $3
Por que agora: gatilho do leitor.
Ganho: traz o caso de prova.md.
Confiança: $4
Nota: 10/16
Faltas: $5
Status: aberta

\`\`\`
Use a skill motor do plugin sistema-conteudo. Pauta P-$HOJE-$1. TEMA: x
\`\`\`
P
}
resposta() { printf 'P-%s-1 | titulo | fato | Nota 10/16 | alta\nA busca na web não estava disponível. A lista saiu só dos arquivos da pessoa.\nPerplexity e Grok não estavam configurados. Ficou sem a camada das últimas 24 horas.\nChecagem: check-voz.sh código 0 em pautas.md\n' "$HOJE"; }
prepara() { # prepara <caso> -> zera a saida falsa em $base/<caso>-fake.md
  rm -rf "$base"; mkdir -p "$base/$1-fake.md.arquivos"
  cp evals/fixtures/hugo-radar/banidas.txt "$base/$1-fake.md.arquivos/banidas.txt"
  resposta > "$base/$1-fake.md"
}
roda() { # roda <caso> <esperado: PASSA|NAO PASSA> <trecho do achado|-> <descricao>
  local caso="$1" esp="$2" trecho="$3" d="$4" lin
  rm -rf "evals/results/nova/radar-pautas-$saida"
  CASOS="$caso" MODELOS=fake REAVALIAR="$fonte" bash "$portao" "$saida" > /dev/null 2>&1
  lin=$(grep "^$caso-fake" "evals/results/nova/radar-pautas-$saida/_placar.txt" 2>/dev/null)
  if [[ "$lin" != *"| $esp |"* ]]; then echo "FALHA $d: esperado $esp, veio: $lin"; falhas=$((falhas+1)); return; fi
  if [ "$trecho" != "-" ] && [[ "$lin" != *"$trecho"* ]]; then echo "FALHA $d: achado sem '$trecho': $lin"; falhas=$((falhas+1)); return; fi
  echo "ok $d"
}
grava() { printf '# Pautas\n\n## Rodada %s\n' "$HOJE" > "$base/$1-fake.md.arquivos/pautas.md"; cat >> "$base/$1-fake.md.arquivos/pautas.md"; }

L1='https://exemplo.com.br/a'
# rede bom: noticia com link e data dentro dos 15 dias
prepara rede
{ pauta 1 "Noticia recente" "notícia, $L1, publicada em 2026-10-20, \"trecho\"" média "nada"
  pauta 2 "Fato local" 'fato, prova.md, linha "63 check-ins"' alta nada
  pauta 3 "Dor do leitor" 'dor, icp.md, item "O que preocupa"' média nada; } | grava rede
roda rede PASSA - "rede com noticia recente passa"

# (ad) a primeira data da linha e do link (dentro da janela), a de publicacao e antiga
prepara rede
{ pauta 1 "Noticia velha" "notícia, https://exemplo.com.br/2026-10-20-a, publicada em 2026-08-01, \"trecho\"" média "nada"
  pauta 2 "Fato local" 'fato, prova.md, linha "63 check-ins"' alta nada
  pauta 3 "Dor do leitor" 'dor, icp.md, item "O que preocupa"' média nada; } | grava rede
roda rede "NAO PASSA" "sem-pauta-de-noticia-com-link-e-data-dentro-de-15-dias" "rede pega a data de publicacao e nao a primeira da linha"

# (ac) nenhuma pauta de noticia na saida
prepara rede
{ pauta 1 "Fato local" 'fato, prova.md, linha "63 check-ins"' alta nada
  pauta 2 "Dor do leitor" 'dor, icp.md, item "O que preocupa"' média nada
  pauta 3 "Outra dor" 'dor, icp.md, item "Quem le"' média nada; } | grava rede
roda rede "NAO PASSA" "sem-pauta-de-noticia-com-link-e-data-dentro-de-15-dias" "rede sem pauta de noticia"

# rede com noticia sem link
prepara rede
{ pauta 1 "Noticia sem link" 'notícia, colada pela pessoa, publicada em 2026-10-20, "trecho"' média "nada"
  pauta 2 "Fato local" 'fato, prova.md, linha "63 check-ins"' alta nada
  pauta 3 "Dor do leitor" 'dor, icp.md, item "O que preocupa"' média nada; } | grava rede
roda rede "NAO PASSA" "sem-pauta-de-noticia-com-link" "rede sem link http"

# M-5: caso 05, a pauta da noticia sem data fala de conciliacao de frete (sem a palavra "romaneio") e nao traz a falta
prepara 05
{ pauta 1 "Conciliacao de frete com IA" 'notícia, colada pela pessoa, publicada em 2026-10-20, "trecho"' média "nada"
  pauta 2 "Fato local" 'fato, prova.md, linha "63 check-ins"' alta nada
  pauta 3 "Dor do leitor" 'dor, icp.md, item "O que preocupa"' média nada; } | grava 05
printf 'Notícia sem data de publicação: entrou.\n' >> "$base/05-fake.md"
roda 05 "NAO PASSA" "noticia-sem-data-sem-a-falta" "05 pega a pauta da noticia sem a palavra-chave"

# M-5: caso 05 com a falta e confianca baixa passa
prepara 05
{ pauta 1 "Conciliacao de frete com IA" 'notícia, colada pela pessoa, "trecho"' baixa "[FALTA: data de publicação]"
  pauta 2 "Fato local" 'fato, prova.md, linha "63 check-ins"' alta nada
  pauta 3 "Dor do leitor" 'dor, icp.md, item "O que preocupa"' média nada; } | grava 05
printf 'Notícia sem data de publicação: entrou com a falta e confiança baixa.\n' >> "$base/05-fake.md"
roda 05 PASSA - "05 com a falta e confianca baixa passa"

# M-5: caso 06, pauta de consumo final escrita sem "cashback"
prepara 06
{ pauta 1 "Promocao para pessoas fisicas" 'notícia, colada pela pessoa, publicada em 2026-10-21, "trecho"' média "nada"
  pauta 2 "Fato local" 'fato, prova.md, linha "63 check-ins"' alta nada
  pauta 3 "Dor do leitor" 'dor, icp.md, item "O que preocupa"' média nada; } | grava 06
printf 'A noticia do aplicativo de entrega de comida ficou fora do ICP.\n' >> "$base/06-fake.md"
roda 06 "NAO PASSA" "noticia-de-consumo-final-no-arquivo" "06 pega consumo final sem a palavra cashback"

# M-6: caso 03 com HOJE diferente do relogio: os ids de hoje-3 vem de $HOJE
prepara 03
{ pauta 1 "Dor do leitor" 'dor, icp.md, item "O que preocupa"' média nada
  pauta 2 "Outra dor" 'dor, icp.md, item "Quem le"' média nada
  pauta 3 "Fato novo" 'fato, prova.md, linha "12 capacitacoes"' alta nada
  cat <<'P'

## Rodada 2026-10-19

### P-2026-10-19-2: Cafe Cursor NE
Origem: fato, prova.md, linha "63 check-ins"
Por que agora: gatilho.
Ganho: caso.
Confiança: alta
Nota: 12/16
Faltas: nada
Status: aberta

```
Use a skill motor. Pauta P-2026-10-19-2. TEMA: y
```

### P-2026-10-19-4: Continuacao
Origem: continuação, base-conteudo.md, peça de setembro
Por que agora: gatilho.
Ganho: caso.
Confiança: alta
Nota: 12/16
Faltas: nada
Status: aberta

```
Use a skill motor. Pauta P-2026-10-19-4. TEMA: z
```
P
} | grava 03
roda 03 PASSA - "03 usa HOJE e nao o relogio"

[ "$falhas" = 0 ] || exit 1
