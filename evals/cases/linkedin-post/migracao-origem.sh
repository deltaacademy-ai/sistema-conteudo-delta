#!/usr/bin/env bash
# Portao da migracao da base antiga (caso linkedin-post/06), sem juiz: uma execucao por modelo, conferida
# por criterio mecanico. A fixture hugo-base-7col tem base de 7 colunas (sem Origem) e o pedido traz um
# briefing com a linha Origem. Criterios:
#   cabecalho com 8 colunas, a ultima Origem; separador com 8 celulas; toda linha com 8 celulas;
#   as 3 linhas antigas iguais as da fixture nas 7 primeiras celulas e com a oitava vazia; exatamente uma
#   linha nova, com Data de hoje, Status rascunho e Origem "reaproveita 2026-09-14 Caso da fila de chamados";
#   o post gravado em saida/post-<hoje>-*.md; checkup.sh na pasta sai 0 e conta 2 rascunho, 0 aprovado;
#   a resposta tem a linha "Base:" falando da coluna Origem; check-voz.sh 0 na resposta e no post;
#   nenhum arquivo novo alem do post; as pecas antigas de saida/ iguais.
# uso: bash evals/cases/linkedin-post/migracao-origem.sh [rodada]   (env: MODELOS, TEMPO, REAVALIAR, HOJE)
#   REAVALIAR=<rodada>: nao roda modelo; confere de novo as saidas de evals/results/nova/migracao-origem-<rodada>.
#   Roda os modelos em paralelo (2 no maximo, que e o numero de modelos).
set -u
raiz=$(cd "$(dirname "$0")/../../.." && pwd); cd "$raiz"
rodada="${1:-t1}"
R="evals/results/nova/migracao-origem-$rodada"; L="$R/_log.txt"; PL="$R/_placar.txt"
MODELOS="${MODELOS:-claude-sonnet-5 claude-opus-5}"; TEMPO="${TEMPO:-1800}"
hoje="${HOJE:-$(date +%F)}"
mkdir -p "$R/estado"
log() { echo "$(date +%H:%M:%S) $*" >> "$L"; }

roda() { # roda <caso.md> <modelo> <saida.md>
  local caso="$1" m="$2" s="$3" t
  for t in 1 2 3; do
    log "run $(basename "$s") tentativa=$t"
    if perl -e 'alarm shift; exec @ARGV' "$TEMPO" bash scripts/eval/run-case.sh . "$caso" "$m" "$s" > "$s.log" 2>&1 \
       && [ -s "$s" ] && ! grep -qx null "$s" && ! grep -qi 'rate.limit\|too many requests\|"429"' "$s.log"; then
      log "ok $(basename "$s") $(wc -c < "$s" | tr -d ' ') bytes"; return 0
    fi
    log "retentativa $(basename "$s") motivo=$(tail -c 200 "$s.log" 2>/dev/null | tr '\n' ' ')"
    [ "$t" -lt 3 ] && sleep 120
  done
  log "FALHOU $(basename "$s")"; return 1
}

# celulas <linha>: numero de celulas da tabela, ignorando barra dentro de aspas
celulas() { sed 's/"[^"]*"//g' <<< "$1" | awk '{n=gsub(/\|/,"|"); print n-1}'; }
# celula <linha> <n>: a n-esima celula, sem espacos nas pontas
celula() { sed 's/"[^"]*"/"X"/g' <<< "$1" | awk -F'|' -v k="$2" '{ c=$(k+1); gsub(/^[ \t]+|[ \t]+$/, "", c); print c }'; }

confere() { # confere <arquivos> <resposta> <fixture>
  local a="$1" s="$2" fx="$3" m="" cab sep l velha n novas f rel
  cab=$(grep -m1 -E '^\| *Data *\|' "$a/base-conteudo.md")
  [ "$(celulas "$cab")" = 8 ] || m="$m cabecalho-sem-8-colunas"
  [ "$(celula "$cab" 8)" = Origem ] || m="$m cabecalho-sem-Origem-no-fim"
  sep=$(grep -m1 -E '^\|[ :-]*---' "$a/base-conteudo.md")
  [ "$(celulas "$sep")" = 8 ] || m="$m separador-sem-8-celulas"
  while IFS= read -r l; do
    [ "$(celulas "$l")" = 8 ] || m="$m linha-sem-8-celulas:$(cut -c1-30 <<< "$l")"
  done < <(grep -E '^\| *[0-9]{4}-' "$a/base-conteudo.md")
  while IFS= read -r velha; do
    n=$(grep -cF -- "${velha%|}" "$a/base-conteudo.md")
    [ "$n" -ge 1 ] || { m="$m linha-antiga-perdida:$(cut -c1-30 <<< "$velha")"; continue; }
    l=$(grep -F -- "${velha%|}" "$a/base-conteudo.md" | head -1)
    [ "$(celula "$l" 8)" = "" ] || m="$m linha-antiga-com-Origem-preenchida:$(cut -c1-30 <<< "$velha")"
  done < <(grep -E '^\| *[0-9]{4}-' "$fx/base-conteudo.md" | sed -E 's/ *\|$//' | sed 's/$/|/')
  novas=$(grep -E '^\| *[0-9]{4}-' "$a/base-conteudo.md" | grep -cF -- "| $hoje |")
  [ "$novas" = 1 ] || m="$m linhas-de-hoje=$novas"
  l=$(grep -F -- "| $hoje |" "$a/base-conteudo.md" | head -1)
  [ "$(celula "$l" 5)" = rascunho ] || m="$m linha-nova-sem-status-rascunho"
  [ "$(celula "$l" 8)" = "reaproveita 2026-09-14 Caso da fila de chamados" ] || m="$m Origem-da-linha-nova-errada:$(celula "$l" 8)"
  [ "$(grep -cE '^\| *[0-9]{4}-' "$a/base-conteudo.md")" = 4 ] || m="$m linhas-na-base=$(grep -cE '^\| *[0-9]{4}-' "$a/base-conteudo.md")"
  f=$(ls "$a"/saida/post-"$hoje"-*.md 2>/dev/null | head -1)
  if [ -z "$f" ]; then m="$m post-nao-gravado"; else bash scripts/check-voz.sh "$f" "$a/banidas.txt" > /dev/null || m="$m check-voz-post"; fi
  bash scripts/check-voz.sh "$s" "$a/banidas.txt" > /dev/null || m="$m check-voz-resposta"
  grep -E '^Base:' "$s" | grep -qi 'origem' || m="$m resposta-sem-linha-Base-sobre-Origem"
  l=$(bash scripts/checkup.sh "$a" 2>&1 | grep '^pecas em aberto')
  [ "$l" = "pecas em aberto: 2 rascunho, 0 aprovado" ] || m="$m checkup-conta-errado:${l:-vazio}"
  while IFS= read -r -d '' f; do
    rel="${f#$a/}"; [ -e "$fx/$rel" ] && continue
    case "$rel" in saida/post-"$hoje"-*.md) ;; *) m="$m arquivo-novo:$rel" ;; esac
  done < <(find "$a" -type f -print0)
  for f in "$fx"/saida/*; do cmp -s "$f" "$a/saida/$(basename "$f")" || m="$m peca-antiga-alterada:$(basename "$f")"; done
  echo "$m"
}

job() { # job <modelo>
  local m="$1" n="06-$1" caso2 s a est fx f fonte
  if [ -n "${REAVALIAR:-}" ]; then
    fonte="evals/results/nova/migracao-origem-$REAVALIAR"; s="$fonte/$n.md"; a="$s.arquivos"; est="$fonte/estado/$n"
    [ -s "$s" ] || { echo "$n | saida da rodada $REAVALIAR nao existe | NAO PASSA" >> "$PL"; return; }
  else
    s="$R/$n.md"; a="$s.arquivos"; est="$R/estado/$n"
    caso2=$(bash scripts/eval/datas-relativas.sh "evals/cases/linkedin-post/06.md" "$est") || { echo "$n | datas-relativas FALHOU | NAO PASSA" >> "$PL"; return; }
    roda "$caso2" "$m" "$s" || { echo "$n | execucao FALHOU (sem saida) | NAO PASSA" >> "$PL"; return; }
  fi
  fx=$(ls -d "$est"/fixtures/* | head -1)
  f="$(confere "$a" "$s" "$fx")"; f="${f# }"
  log "$n:${f:- ok}"
  if [ -z "$f" ]; then echo "$n | PASSA |" >> "$PL"; else echo "$n | NAO PASSA | $f" >> "$PL"; fi
}

log "inicio rodada=$rodada modelos=$MODELOS"
rm -f "$PL"
for m in $MODELOS; do job "$m" & done
wait
log "fim"; sort "$PL"
