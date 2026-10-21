#!/usr/bin/env bash
# Portao do radar-pautas, sem juiz: cada caso e uma execucao por modelo, conferida por criterio mecanico.
#
# Cada caso passa por scripts/eval/datas-relativas.sh antes de rodar, para {HOJE} e {HOJE-N}
# virarem datas do dia da execucao no prompt e na fixture. A saida de cada execucao fica em
# <saida>.md (resposta) e <saida>.md.arquivos/ (a pasta de contexto depois da execucao).
#
# Criterios de todos os casos em que pautas.md deve existir (01 e 03): pautas.md existe;
#   check-voz.sh da codigo 0 nele; toda pauta da rodada nova (cabecalho "## Rodada <hoje>")
#   tem as sete linhas rotuladas na ordem Origem, Por que agora, Ganho, Confianca, Nota, Faltas,
#   Status e uma cerca de codigo com o identificador da pauta; toda "Origem: noticia" traz data
#   AAAA-MM-DD; a resposta tem uma linha dizendo que a busca nao estava disponivel (o runner
#   nao libera busca).
# Caso 01 (sem pautas.md): de 3 a 5 pautas na rodada nova; nenhuma com "NPS" no titulo ou na
#   origem (tema ja publicado em base-conteudo.md); pautas.md abre com "# Pautas" e, depois, a
#   rodada de hoje.
# Caso 02 (fixture sem icp.md): pautas.md nao existe; a resposta diz que falta icp.md e cita
#   contexto-negocio. Os criterios de todos os casos nao valem: o radar para antes de buscar.
# Caso 03 (pautas.md de {HOJE-3}): a pauta usada (-1) e a de noticia de 20 dias (-3) nao estao
#   mais no arquivo; a de fato (-2) esta, abaixo da rodada nova e sob a rodada original; a
#   rodada nova nao repete a pauta de fato.
#
# Placar: evals/results/nova/radar-pautas-<rodada>/_placar.txt, uma linha por caso e modelo.
# uso: bash evals/cases/radar-pautas/portao.sh [rodada]   (env: CASOS, MODELOS, LIMITE, TEMPO)
#   LIMITE = execucoes em paralelo (padrao 2, o maximo permitido); TEMPO = segundos por execucao.
#   nohup bash evals/cases/radar-pautas/portao.sh t1 > /dev/null 2>&1 &
set -u
raiz=$(cd "$(dirname "$0")/../../.." && pwd); cd "$raiz"

# Modo interno: xargs chama este mesmo script para uma execucao (caso, modelo).
if [ "${1:-}" = "--job" ]; then modo_job=1; shift; else modo_job=0; fi
rodada="${1:-t1}"
R="evals/results/nova/radar-pautas-$rodada"; L="$R/_log.txt"; PL="$R/_placar.txt"
CASOS="${CASOS:-01 02 03}"; MODELOS="${MODELOS:-claude-sonnet-5 claude-opus-5}"
LIMITE="${LIMITE:-2}"; TEMPO="${TEMPO:-1800}"
hoje=$(date +%F)
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

secao_nova() { # imprime a secao "## Rodada <hoje>..." de pautas.md (ate o proximo "## ")
  awk -v h="## Rodada $hoje" 'index($0,h)==1{f=1;print;next} /^## /{f=0} f' "$1"
}

confere_pauta() { # confere_pauta <bloco-de-uma-pauta> -> achados
  local b="$1" m="" id rot n anterior=0 l
  id=$(sed -nE 's/^### (P-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]+):.*/\1/p' <<< "$b" | head -1)
  [ -n "$id" ] || { echo " pauta-sem-identificador"; return; }
  # ordem: Origem, Por que agora, Ganho, Confianca, Nota, Faltas, Status
  for rot in "Origem:" "Por que agora:" "Ganho:" "Confiança:" "Nota:" "Faltas:" "Status:"; do
    n=$(grep -n -m1 "^$rot" <<< "$b" | cut -d: -f1)
    if [ -z "$n" ]; then m="$m $id:sem-linha-${rot%:}"; continue; fi
    [ "$n" -gt "$anterior" ] || m="$m $id:linha-fora-de-ordem-${rot%:}"
    anterior=$n
  done
  awk '/^```/{c++} END{exit !(c>=2)}' <<< "$b" || m="$m $id:sem-cerca-de-codigo"
  awk '/^```/{c++; next} c%2==1' <<< "$b" | grep -qF -- "$id" || m="$m $id:cerca-sem-o-identificador"
  l=$(grep -m1 '^Origem:' <<< "$b")
  if grep -qiE '^Origem: *not[ií]cia' <<< "$l"; then
    grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}' <<< "$l" || m="$m $id:noticia-sem-data"
  fi
  grep -qE '^Origem: *(continuação|fato|dor|notícia)' <<< "$b" || m="$m $id:origem-fora-das-quatro-palavras"
  grep -qE '^Status: *(aberta|usada em [0-9]{4}-[0-9]{2}-[0-9]{2})' <<< "$b" || m="$m $id:status-invalido"
  echo "$m"
}

pautas_da_secao() { # imprime cada bloco "### P-..." separado por \f
  awk '/^### /{if(b!="")printf "%s\f", b; b=$0 "\n"; next} b!=""{b=b $0 "\n"} END{if(b!="")printf "%s\f", b}' <<< "$1"
}

confere_lista() { # confere_lista <arquivos> <saida.md> -> criterios de todos os casos com lista
  local a="$1" s="$2" m="" sec blocos b r
  [ -f "$a/pautas.md" ] || { echo " sem-pautas.md"; return; }
  bash scripts/check-voz.sh "$a/pautas.md" "$a/banidas.txt" >/dev/null || m="$m check-voz-pautas"
  sec=$(secao_nova "$a/pautas.md")
  [ -n "$sec" ] || m="$m sem-rodada-de-hoje"
  blocos=$(pautas_da_secao "$sec")
  [ -n "$blocos" ] || m="$m rodada-sem-pautas"
  while IFS= read -r -d $'\f' b; do
    [ -n "$b" ] || continue
    r=$(confere_pauta "$b"); m="$m$r"
  done < <(printf '%s' "$blocos")
  grep -qiE 'busca[^.]*(não estava|nao estava|indispon|sem acesso)|(sem|não tive|nao tive) (a )?busca' "$s" || m="$m sem-linha-de-busca-indisponivel"
  echo "$m"
}

conta_pautas() { secao_nova "$1" | grep -c '^### P-'; }

confere_01() { # confere_01 <arquivos>
  local p="$1/pautas.md" m="" n prim seg
  [ -f "$p" ] || { echo ""; return; }
  prim=$(grep -m1 . "$p"); [ "$prim" = "# Pautas" ] || m="$m nao-abre-com-# Pautas"
  seg=$(grep -v '^# Pautas$' "$p" | grep -m1 .); case "$seg" in "## Rodada $hoje"*) ;; *) m="$m rodada-do-dia-nao-vem-primeiro";; esac
  n=$(conta_pautas "$p"); { [ "$n" -ge 3 ] && [ "$n" -le 5 ]; } || m="$m pautas-na-rodada=$n"
  secao_nova "$p" | grep -E '^(### P-|Origem:)' | grep -q 'NPS' && m="$m pauta-com-NPS"
  echo "$m"
}

confere_02() { # confere_02 <arquivos> <saida.md>
  local m=""
  [ ! -e "$1/pautas.md" ] || m="$m pautas.md-existe"
  grep -qi 'icp.md' "$2" || m="$m resposta-sem-icp.md"
  grep -q 'contexto-negocio' "$2" || m="$m resposta-sem-contexto-negocio"
  echo "$m"
}

confere_03() { # confere_03 <arquivos>
  local p="$1/pautas.md" m="" d3 id1 id2 id3 l_nova l_fato l_orig
  [ -f "$p" ] || { echo ""; return; }
  d3=$(date -v-3d +%F 2>/dev/null || date -d "-3 days" +%F)
  id1="P-$d3-1"; id2="P-$d3-2"; id3="P-$d3-3"
  grep -qF "$id1" "$p" && m="$m pauta-usada-continua"
  grep -qF "$id3" "$p" && m="$m noticia-velha-continua"
  grep -qi 'cobrar por uso' "$p" && m="$m noticia-velha-no-texto"
  if grep -qF "### $id2" "$p"; then
    l_nova=$(grep -n -m1 "^## Rodada $hoje" "$p" | cut -d: -f1)
    l_fato=$(grep -n -m1 "^### $id2" "$p" | cut -d: -f1)
    l_orig=$(grep -n -m1 "^## Rodada $d3" "$p" | cut -d: -f1)
    { [ -n "$l_nova" ] && [ "$l_fato" -gt "$l_nova" ]; } || m="$m fato-nao-fica-abaixo-da-rodada-nova"
    { [ -n "$l_orig" ] && [ "$l_orig" -lt "$l_fato" ]; } || m="$m fato-fora-da-rodada-original"
  else
    m="$m pauta-de-fato-sumiu"
  fi
  secao_nova "$p" | grep -E '^(### P-|Origem:)' | grep -qiE 'Café Cursor|63 check' && m="$m rodada-nova-repete-a-pauta-de-fato"
  echo "$m"
}

job() { # job <caso> <modelo>
  local c="$1" m="$2" n="$1-$2" caso2 s a f=""
  s="$R/$n.md"; a="$s.arquivos"
  caso2=$(bash scripts/eval/datas-relativas.sh "evals/cases/radar-pautas/$c.md" "$R/estado/$n") || { echo "$n | datas-relativas FALHOU | NAO PASSA" >> "$PL"; return; }
  roda "$caso2" "$m" "$s" || { echo "$n | execucao FALHOU (sem saida) | NAO PASSA" >> "$PL"; return; }
  case "$c" in
    02) f=$(confere_02 "$a" "$s") ;;
    01) f="$(confere_lista "$a" "$s")$(confere_01 "$a")" ;;
    03) f="$(confere_lista "$a" "$s")$(confere_03 "$a")" ;;
  esac
  log "$n:${f:- ok}"
  if [ -z "$f" ]; then echo "$n | PASSA |" >> "$PL"; else echo "$n | NAO PASSA |$f" >> "$PL"; fi
}

if [ "$modo_job" = 1 ]; then job "$2" "$3"; exit 0; fi

log "inicio rodada=$rodada casos=$CASOS modelos=$MODELOS limite=$LIMITE"
rm -f "$PL"
for m in $MODELOS; do for c in $CASOS; do echo "$c $m"; done; done | xargs -L1 -P "$LIMITE" bash "$0" --job "$rodada" 
log "fim"; sort "$PL"
