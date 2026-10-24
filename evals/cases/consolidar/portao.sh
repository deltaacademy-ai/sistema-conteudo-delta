#!/usr/bin/env bash
# Portao do consolidar, sem juiz: cada caso e uma execucao por modelo, conferida por criterio mecanico.
#
# Cada caso passa por scripts/eval/datas-relativas.sh antes de rodar, para {HOJE} e {HOJE-N}
# virarem datas do dia da execucao no prompt e na fixture. A saida de cada execucao fica em
# <saida>.md (resposta) e <saida>.md.arquivos/ (a pasta de contexto depois da execucao).
#
# Criterios de todos os casos: check-voz.sh da codigo 0 na resposta; nenhum arquivo da fixture sumiu.
# Sem ok depois da proposta, nada grava: nos casos 01, 03, 04, 05, 06 e 07, voz.md, icp.md e
# learnings.md ficam byte a byte iguais aos da fixture.
# Caso 01 ("consolida", tabela nova): exatamente uma "### Proposta", de destino voz.md, da regra de
#   3 datas ("time" e "equipe"); o bloco tem Regra hoje, Regra proposta, Sustentam (com as tres
#   datas) e Conflito; a resposta tem a linha "Pergunta:".
# Caso 02 (segundo turno, "ok"): voz.md ganha linha <lei> ou <nunca> com "time" e "equipe", sem perder
#   nenhuma linha, ate 17.500 caracteres, check-voz.sh 0; as tres linhas da regra em learnings.md
#   terminam em "voz.md <hoje>"; nenhuma outra celula de learnings.md muda; icp.md igual.
# Caso 03 ("isso vira regra", 1 ocasiao): exatamente uma proposta, com "nome completo" e Sustentam.
# Caso 04 (regra de 2 linhas na mesma data): nenhuma proposta; a resposta diz que e uma ocasiao.
# Caso 05 (regra que contradiz um <nunca>, "ok, todas" antecipado): ha proposta com Conflito que
#   cita o <nunca> literal.
# Caso 06 (linha ambigua): nenhuma proposta com a linha; uma pergunta que a cita.
# Caso 07 (learnings em texto livre): exatamente uma proposta (a datada); nenhuma com "solucao"; a
#   resposta diz que o arquivo nao esta no formato e fala em converter.
#
# Placar: evals/results/nova/consolidar-<rodada>/_placar.txt, uma linha por caso e modelo.
# uso: bash evals/cases/consolidar/portao.sh [rodada]   (env: CASOS, MODELOS, LIMITE, TEMPO, REAVALIAR, HOJE)
#   REAVALIAR=<rodada>: nao roda modelo; confere de novo as saidas de evals/results/nova/consolidar-<rodada>.
#   HOJE=AAAA-MM-DD: o dia da execucao original. LIMITE = execucoes em paralelo (padrao 2, o maximo).
#   nohup bash evals/cases/consolidar/portao.sh t1 > /dev/null 2>&1 &
set -u
raiz=$(cd "$(dirname "$0")/../../.." && pwd); cd "$raiz"

if [ "${1:-}" = "--job" ]; then modo_job=1; shift; else modo_job=0; fi
rodada="${1:-t1}"
R="evals/results/nova/consolidar-$rodada"; L="$R/_log.txt"; PL="$R/_placar.txt"
CASOS="${CASOS:-01 02 03 04 05 06 07}"
MODELOS="${MODELOS:-claude-sonnet-5 claude-opus-5}"
LIMITE="${LIMITE:-2}"; TEMPO="${TEMPO:-1800}"
hoje="${HOJE:-$(date +%F)}"
rel() { date -j -v-"$1"d -f %F "$hoje" +%F 2>/dev/null || date -d "$hoje -$1 days" +%F; }
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

blocos() { # blocos <resposta>: imprime cada bloco "### Proposta" separado por \f
  awk '/^### Proposta/{if(b!="")printf "%s\f", b; b=$0 "\n"; next} /^(Fora das propostas|Pergunta|Checagem|Sem proposta):/{if(b!="")printf "%s\f", b; b=""; next} b!=""{b=b $0 "\n"} END{if(b!="")printf "%s\f", b}' "$1"
}
n_propostas() { grep -c '^### Proposta' "$1"; }

comum() { # comum <arquivos> <resposta> <estado-da-fixture>: check-voz na resposta e fixture inteira presente
  local a="$1" s="$2" fx="$3" m="" f rel
  bash scripts/check-voz.sh "$s" "$a/banidas.txt" >/dev/null || m="$m check-voz-resposta"
  while IFS= read -r -d '' f; do
    rel="${f#$fx/}"; [ -e "$a/$rel" ] || m="$m arquivo-da-fixture-sumiu:$rel"
  done < <(find "$fx" -type f -print0)
  echo "$m"
}

nada_gravado() { # nada_gravado <arquivos> <estado-da-fixture>
  local m="" x
  for x in voz.md icp.md learnings.md; do cmp -s "$1/$x" "$2/$x" || m="$m $x-alterado-sem-ok"; done
  echo "$m"
}

tem_proposta_com() { # tem_proposta_com <resposta> <regex>: algum bloco de proposta casa o regex
  local b; while IFS= read -r -d $'\f' b; do grep -qiE "$2" <<< "$b" && return 0; done < <(blocos "$1"); return 1
}

confere_01() { # confere_01 <resposta> <d20> <d14> <d6>
  local s="$1" m="" b
  [ "$(n_propostas "$s")" = 1 ] || m="$m propostas=$(n_propostas "$s")"
  b=$(blocos "$s" | tr '\f' '\n')
  grep -qE '^### Proposta [0-9]+: voz\.md' <<< "$b" || m="$m destino-nao-e-voz.md"
  grep -qiE 'equipe' <<< "$b" && grep -qE 'time' <<< "$b" || m="$m proposta-nao-e-a-de-time-e-equipe"
  local rot; for rot in 'Regra hoje:' 'Regra proposta:' 'Sustentam:' 'Conflito:'; do grep -qF "$rot" <<< "$b" || m="$m sem-$rot"; done
  local d; for d in "$2" "$3" "$4"; do grep -F "Sustentam:" -A6 <<< "$b" | grep -qF "$d" || m="$m sustentam-sem-$d"; done
  grep -q '^Pergunta:' "$s" || m="$m sem-linha-Pergunta"
  echo "$m"
}

confere_02() { # confere_02 <arquivos> <estado-da-fixture> <d20> <d14> <d6>
  local a="$1" fx="$2" m="" novas perdidas tam f
  novas=$(diff "$fx/voz.md" "$a/voz.md" | grep -c '^> ')
  perdidas=$(diff "$fx/voz.md" "$a/voz.md" | grep -c '^< ')
  [ "$novas" -ge 1 ] || m="$m voz.md-sem-linha-nova"
  [ "$perdidas" = 0 ] || m="$m voz.md-perdeu-$perdidas-linhas"
  diff "$fx/voz.md" "$a/voz.md" | grep '^> ' | grep -E '<(lei|nunca)>' | grep -qi 'equipe' || m="$m linha-nova-sem-lei-ou-nunca-com-equipe"
  diff "$fx/voz.md" "$a/voz.md" | grep '^> ' | grep -E '<(lei|nunca)>' | grep -q 'time' || m="$m linha-nova-sem-time"
  tam=$(wc -m < "$a/voz.md" | tr -d ' '); [ "$tam" -le 17500 ] || m="$m voz.md-com-$tam-caracteres"
  bash scripts/check-voz.sh "$a/voz.md" >/dev/null || m="$m check-voz-voz.md"
  cmp -s "$a/icp.md" "$fx/icp.md" || m="$m icp.md-alterado"
  # learnings.md: so a ultima celula muda, e so nas tres linhas da regra
  local tira='BEGIN{FS=OFS="|"} /^\|/{$(NF-1)=""} {print}'
  diff <(awk "$tira" "$fx/learnings.md") <(awk "$tira" "$a/learnings.md") >/dev/null || m="$m learnings-mudou-alem-da-coluna-Promovida"
  for f in "$3" "$4" "$5"; do
    grep -E "^\| $f \|" "$a/learnings.md" | grep -E 'time|equipe' | grep -qE "\| voz\.md $hoje \|$" || m="$m linha-$f-sem-marca"
  done
  local marcadas; marcadas=$(grep -cE '\| (voz|icp)\.md [0-9-]+ \|$' "$a/learnings.md")
  [ "$marcadas" = 3 ] || m="$m linhas-marcadas=$marcadas"
  echo "$m"
}

confere_03() { # confere_03 <resposta>
  local s="$1" m="" b
  [ "$(n_propostas "$s")" = 1 ] || m="$m propostas=$(n_propostas "$s")"
  b=$(blocos "$s" | tr '\f' '\n')
  grep -qi 'nome completo' <<< "$b" || m="$m proposta-sem-nome-completo"
  grep -F 'Sustentam:' -A2 <<< "$b" | grep -qE '[0-9]{4}-[0-9]{2}-[0-9]{2}|pedido' || m="$m sustentam-vazio"
  echo "$m"
}

confere_04() { # confere_04 <resposta>
  local s="$1" m=""
  [ "$(n_propostas "$s")" = 0 ] || m="$m propostas=$(n_propostas "$s")"
  grep -qiE 'mesma data|mesmo dia|uma (só )?ocasi|1 ocasi|uma ocorr' "$s" || m="$m resposta-nao-diz-que-e-uma-ocasiao"
  grep -qi 'sigla' "$s" || m="$m resposta-nao-cita-a-sigla"
  echo "$m"
}

confere_05() { # confere_05 <resposta>
  local s="$1" m=""
  blocos "$s" | tr '\f' '\n' | grep '^Conflito:' | grep -viE '^Conflito: *nenhum' | grep -q . || m="$m sem-proposta-com-conflito"
  tem_proposta_com "$s" 'Nunca prove autoridade com dinheiro ganho' || m="$m conflito-sem-o-nunca-literal"
  echo "$m"
}

confere_06() { # confere_06 <resposta>
  local s="$1" m=""
  tem_proposta_com "$s" 'não gostei|nao gostei|daquilo' && m="$m proposta-com-a-linha-ambigua"
  grep -iE 'não gostei|nao gostei|daquilo' "$s" | grep -q '?' || m="$m sem-pergunta-sobre-a-linha"
  echo "$m"
}

confere_07() { # confere_07 <resposta> <d20> <d14> <d6>
  local s="$1" m="" b d
  [ "$(n_propostas "$s")" = 1 ] || m="$m propostas=$(n_propostas "$s")"
  b=$(blocos "$s" | tr '\f' '\n')
  grep -qi 'equipe' <<< "$b" || m="$m proposta-nao-e-a-de-time-e-equipe"
  tem_proposta_com "$s" 'solução|solucao' && m="$m proposta-com-regra-sem-data"
  for d in "$2" "$3" "$4"; do grep -qF "$d" <<< "$b" || m="$m sustentam-sem-$d"; done
  grep -qiE 'não está (no|na) (formato|tabela)|nao esta (no|na) (formato|tabela)|fora do formato|texto livre|sem a tabela' "$s" || m="$m resposta-nao-diz-que-esta-fora-do-formato"
  grep -qi 'convert' "$s" || m="$m resposta-sem-oferta-de-converter"
  echo "$m"
}

job() { # job <caso> <modelo>
  local c="$1" m="$2" n="$1-$2" caso2 s a f="" fonte est fx d20 d14 d6
  if [ -n "${REAVALIAR:-}" ]; then
    fonte="evals/results/nova/consolidar-$REAVALIAR"; s="$fonte/$n.md"; a="$s.arquivos"; est="$fonte/estado/$n"
    [ -s "$s" ] || { echo "$n | saida da rodada $REAVALIAR nao existe | NAO PASSA" >> "$PL"; return; }
  else
    s="$R/$n.md"; a="$s.arquivos"; est="$R/estado/$n"
    caso2=$(bash scripts/eval/datas-relativas.sh "evals/cases/consolidar/$c.md" "$est") || { echo "$n | datas-relativas FALHOU | NAO PASSA" >> "$PL"; return; }
    roda "$caso2" "$m" "$s" || { echo "$n | execucao FALHOU (sem saida) | NAO PASSA" >> "$PL"; return; }
  fi
  fx=$(ls -d "$est"/fixtures/* | head -1)
  d20=$(rel 20); d14=$(rel 14); d6=$(rel 6)
  f="$(comum "$a" "$s" "$fx")"
  case "$c" in
    01) f="$f$(nada_gravado "$a" "$fx")$(confere_01 "$s" "$d20" "$d14" "$d6")" ;;
    02) f="$f$(confere_02 "$a" "$fx" "$d20" "$d14" "$d6")" ;;
    03) f="$f$(nada_gravado "$a" "$fx")$(confere_03 "$s")" ;;
    04) f="$f$(nada_gravado "$a" "$fx")$(confere_04 "$s")" ;;
    05) f="$f$(nada_gravado "$a" "$fx")$(confere_05 "$s")" ;;
    06) f="$f$(nada_gravado "$a" "$fx")$(confere_06 "$s")" ;;
    07) f="$f$(nada_gravado "$a" "$fx")$(confere_07 "$s" "$d20" "$d14" "$d6")" ;;
  esac
  log "$n:${f:- ok}"
  if [ -z "$f" ]; then echo "$n | PASSA |" >> "$PL"; else echo "$n | NAO PASSA |$f" >> "$PL"; fi
}

if [ "$modo_job" = 1 ]; then job "$2" "$3"; exit 0; fi

log "inicio rodada=$rodada casos=$CASOS modelos=$MODELOS limite=$LIMITE"
rm -f "$PL"
for m in $MODELOS; do for c in $CASOS; do echo "$c $m"; done; done | xargs -L1 -P "$LIMITE" bash "$0" --job "$rodada"
log "fim"; sort "$PL"
