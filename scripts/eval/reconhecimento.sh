#!/usr/bin/env bash
set -euo pipefail
# uso: reconhecimento.sh <voz.md> <materiais-dir> <saida.json> [modelo-gerador]
#
# Teste de reconhecimento de um voz.md compilado pelo especialista entrevista-voz.
#
# STATUS: metrica informativa, nao e mais portao (ruling do controlador, Tarefa 4).
#   Nas referencias o juiz acertou 3 de 3 tanto com o voz.md de referencia do
#   autor quanto com um perfil neutro de uma linha: texto gerado de uma vez so e
#   sempre identificavel, com ou sem perfil, entao este teste mede o gerador e
#   nao o voz.md. O portao do especialista e o teste pareado de preferencia em
#   preferencia-voz.sh. Este script segue util para ver o que ainda denuncia
#   texto gerado (o motivo do juiz).
#
# Contrato:
# 1. Pega os 3 posts reais de <materiais-dir>: em cada arquivo, o primeiro bloco
#    entre <!-- ai:start --> e <!-- ai:end --> (formato das notas do vault); se
#    o arquivo nao tem cerca, vale o arquivo inteiro. Precisa haver pelo menos 3;
#    usa os 3 primeiros em ordem C de nome.
# 2. Para cada post real, extrai um briefing factual (tipo, tamanho, fatos,
#    numeros, nomes, ordem do que aconteceu, o que o autor pede no fim) com um
#    modelo isolado fixo (claude-sonnet-5, prompt em reconhecimento-briefing.md),
#    sem nenhuma frase do original. Um verificador mecanico confere que nenhuma
#    sequencia de 5 palavras do post sobrevive no briefing; se sobreviver, a
#    extracao roda de novo uma vez, e o que restar fica registrado no detalhe.
#    Com BRIEFINGS_CACHE=<pasta> os briefings sao extraidos uma vez e reutilizados.
# 3. Gera 3 posts, um por briefing, com o voz.md recebido como prompt de
#    sistema (prompt em reconhecimento-gerador.md), em contexto isolado
#    (claude-isolado.sh), sem plugin, no modelo passado em [modelo-gerador]
#    (padrao claude-sonnet-5); nos portoes, e o mesmo modelo que compilou o voz.md.
# 4. Embaralha os 6, numera de 1 a 6 e pede a um juiz isolado (claude-opus-5,
#    prompt em reconhecimento-juiz.md) que aponte os 3 reais. O juiz nunca ve
#    qual modelo gerou, nem o voz.md, nem os briefings.
# 5. Grava em <saida.json>: {"acertos": n, "detalhe": "..."}, onde acertos e
#    quantos dos 3 apontados pelo juiz sao reais (0 a 3). Os 6 textos, os
#    briefings, o mapa do embaralhamento e a resposta crua do juiz ficam em
#    <saida.json>.arquivos/.
#
# Por que briefing por post real (ruling do controlador, Tarefa 4):
#   A primeira versao gerava os 3 posts sobre temas livres do autor. O juiz
#   comparava post publicado (fato, numero, link, contexto vivido) com post
#   gerado a frio, e vencia por especificidade factual, nao por voz: ate a
#   fixture de referencia (voz.md compilado do DNA completo, em Opus) tomou
#   3 de 3. Isso mede o instrumento, nao a skill. Com o briefing, os dois lados
#   partem dos mesmos fatos, do mesmo tipo e do mesmo tamanho, e o que sobra
#   para o juiz e a voz. O briefing e reescrito sem frase do original para o
#   gerador nao herdar a redacao do autor.
#
# Leitura do numero (era a regra do portao antes do ruling):
# - acertos <= 1 significa que o juiz errou 2 ou mais dos 3; 3 errados tambem
#   significa que nao distinguiu.
# - Acaso puro: escolher 3 de 6 da esperanca de 1,5 acertos e P(acertos <= 1) = 0,5.
# - A validacao final do voz.md continua sendo a da skill: a pessoa le e aprova,
#   e depois faz o teste cego dela.
voz=$(cd "$(dirname "$1")" && pwd)/$(basename "$1"); mat=$(cd "$2" && pwd); out=$(cd "$(dirname "$3")" && pwd)/$(basename "$3"); modelo="${4:-claude-sonnet-5}"
extrator=claude-sonnet-5
dir=$(cd "$(dirname "$0")" && pwd)
[ -s "$voz" ] || { echo "voz.md vazio ou ausente: $voz" >&2; exit 1; }
[ -d "$mat" ] || { echo "pasta de materiais ausente: $mat" >&2; exit 1; }
# artefatos em pasta temporaria, substituem a anterior so no fim (ver preferencia-voz.sh)
arq="$out.arquivos.tmp"; rm -rf "$arq"; mkdir -p "$arq/textos" "$arq/briefings"

. "$dir/briefing-lib.sh"
extrair_reais "$mat"
extrair_briefings

# 3. posts gerados com o voz.md como prompt de sistema, um por briefing
msg_ger="$(cat "$dir/reconhecimento-gerador.md")"
for i in 1 2 3; do msg_ger="$msg_ger

BRIEFING $i:
$(cat "$arq/briefings/briefing-$i.txt")"; done
printf '%s\n' "$msg_ger" > "$arq/mensagem-gerador.txt"
gerar() {
  ( cd "$(mktemp -d)" && "$dir/claude-isolado.sh" --model "$modelo" \
      --append-system-prompt "$(cat "$voz")" --output-format json "$msg_ger" ) \
    | jq -r '.result' > "$arq/gerador-bruto.txt"
  rm -f "$arq"/textos/gerado-*.txt
  awk -v d="$arq/textos" '
    /^=== POST [0-9] ===$/ { k++; next }
    /^```/ { next }
    k>=1 && k<=3 { print > (d "/gerado-" k ".txt") }' "$arq/gerador-bruto.txt"
  [ -s "$arq/textos/gerado-1.txt" ] && [ -s "$arq/textos/gerado-2.txt" ] && [ -s "$arq/textos/gerado-3.txt" ]
}
gerar || gerar || { echo "gerador nao entregou 3 posts" >&2; exit 1; }

# 4. embaralha e monta a mensagem do juiz
perl -MList::Util=shuffle -e 'print join("\n", shuffle(qw(real-1 real-2 real-3 gerado-1 gerado-2 gerado-3))), "\n"' > "$arq/ordem.txt"
msg=""; i=0; reais=""
while IFS= read -r id; do
  i=$((i+1))
  case "$id" in real-*) reais="$reais $i";; esac
  msg="$msg
POST $i:
$(cat "$arq/textos/$id.txt")
"
done < "$arq/ordem.txt"
printf '%s' "$msg" > "$arq/mensagem-juiz.txt"

# 5. juiz isolado
res=$(cd "$(mktemp -d)" && "$dir/claude-isolado.sh" --model claude-opus-5 \
  --append-system-prompt "$(cat "$dir/reconhecimento-juiz.md")" --output-format json "$msg" \
  | jq -r '.result' | sed -n '/^{/,/}$/p')
printf '%s\n' "$res" > "$arq/juiz-bruto.json"
apontados=$(printf '%s' "$res" | jq -r '.reais[]' 2>/dev/null | tr '\n' ' ')
motivo=$(printf '%s' "$res" | jq -r '.motivo' 2>/dev/null)
[ -n "$apontados" ] || { echo "juiz nao devolveu JSON com reais: $res" >&2; exit 1; }
acertos=0
for p in $apontados; do case " $reais " in *" $p "*) acertos=$((acertos+1));; esac; done
jq -n --argjson a "$acertos" --arg d "reais eram:$reais; juiz apontou: $apontados; gerador: $modelo; extrator: $extrator;$aviso motivo: $motivo" \
  '{acertos:$a, detalhe:$d}' > "$out"
rm -rf "$out.arquivos"; mv "$arq" "$out.arquivos"
cat "$out"
