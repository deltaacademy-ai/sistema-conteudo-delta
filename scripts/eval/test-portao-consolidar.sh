#!/usr/bin/env bash
# Confere o portao do consolidar (evals/cases/consolidar/portao.sh) com saidas falsas, sem modelo:
# usa REAVALIAR e HOJE fixo, e diz se o portao PASSA ou NAO PASSA e por qual achado.
# Cobre o que o portao precisa reprovar: proposta a mais, gravacao sem ok, marca em menos linhas,
# voz.md que perde linha, regra de uma data so virando proposta, conflito sem o <nunca> literal,
# linha ambigua virando proposta, learnings em texto livre sem o aviso de formato.
set -u
raiz=$(cd "$(dirname "$0")/../.." && pwd); cd "$raiz"
portao=evals/cases/consolidar/portao.sh
fonte=tst-cons-fonte; saida=tst-cons-saida
base="evals/results/nova/consolidar-$fonte"
trap 'rm -rf "evals/results/nova/consolidar-$fonte" "evals/results/nova/consolidar-$saida"' EXIT
export HOJE=2026-10-22
falhas=0
rel() { date -j -v-"$1"d -f %F "$HOJE" +%F 2>/dev/null || date -d "$HOJE -$1 days" +%F; }
d20=$(rel 20); d14=$(rel 14); d6=$(rel 6)

copia() { # copia <fixture> <destino>: fixture com {HOJE-N} trocado pelo dia fixo
  local f
  rm -rf "$2"; mkdir -p "$2"; cp -R "evals/fixtures/$1/." "$2/"
  while IFS= read -r -d '' f; do
    grep -Iq . "$f" 2>/dev/null || continue
    perl -i -pe 'BEGIN{ for $n (0..40){ $r[$n]=`date -j -v-${n}d -f %F $ENV{HOJE} +%F 2>/dev/null || date -d "$ENV{HOJE} -$n days" +%F`; chomp $r[$n] } } s/\{HOJE-(\d+)\}/$r[$1]/ge; s/\{HOJE\}/$ENV{HOJE}/g' "$f"
  done < <(find "$2" -type f -print0)
}
prepara() { # prepara <caso> <fixture>: zera a saida falsa de <caso>
  local n="$1-fake"
  rm -rf "$base"; mkdir -p "$base/estado/$n/fixtures"
  copia "$2" "$base/estado/$n/fixtures/$2"
  copia "$2" "$base/$n.md.arquivos"
}
resp() { printf '%s\n' "$1" > "$base/$2-fake.md"; }
roda() { # roda <caso> <esperado: PASSA|NAO PASSA> <trecho do achado|-> <descricao>
  local caso="$1" esp="$2" trecho="$3" d="$4" lin
  rm -rf "evals/results/nova/consolidar-$saida"
  CASOS="$caso" MODELOS=fake REAVALIAR="$fonte" bash "$portao" "$saida" > /dev/null 2>&1
  lin=$(grep "^$caso-fake" "evals/results/nova/consolidar-$saida/_placar.txt" 2>/dev/null)
  if [[ "$lin" != *"| $esp |"* ]]; then echo "FALHA $d: esperado $esp, veio: $lin"; falhas=$((falhas+1)); return; fi
  if [ "$trecho" != "-" ] && [[ "$lin" != *"$trecho"* ]]; then echo "FALHA $d: achado sem '$trecho': $lin"; falhas=$((falhas+1)); return; fi
  echo "ok $d"
}

PROP_TIME="### Proposta 1: voz.md
Regra hoje: nenhuma
Regra proposta: Faça: escreva \"time\". Evite: \"equipe\".
Sustentam: $d20 (linkedin-post: \"Escrever time e não equipe\"), $d14 (revisor: \"Trocar equipe por time\"), $d6 (gancho: \"Time, nunca equipe\")
Conflito: nenhum"
RESTO="Fora das propostas: \"solução\", 2 ocasiões, abaixo de 3.
Pergunta: ok para gravar a 1?
Checagem: check-voz.sh código 0, rascunho apagado."
grava_voz() { # acrescenta uma lei antes de </leis_de_escrita>
  perl -i -pe 's{^</leis_de_escrita>}{<lei>Faça: escreva "time". Evite: "equipe".</lei>\n</leis_de_escrita>}' "$base/$1-fake.md.arquivos/voz.md"
}
marca() { # marca <caso> <data>: Promovida nas linhas de <data> que citam time ou equipe
  perl -i -pe "s{\\| \\|\$}{| voz.md $HOJE |} if /^\\| $2 \\|.*(time|equipe)/" "$base/$1-fake.md.arquivos/learnings.md"
}

# 01 certo
prepara 01 hugo-learnings; resp "Consolidar: 11 regras.
$PROP_TIME
$RESTO" 01
roda 01 PASSA - "01 certo passa"

# 01 duas propostas
prepara 01 hugo-learnings; resp "$PROP_TIME

### Proposta 2: voz.md
Regra hoje: nenhuma
Regra proposta: Evite: \"solução\".
Sustentam: $d14 (revisor: \"Cortar solução\")
Conflito: nenhum
$RESTO" 01
roda 01 "NAO PASSA" "propostas=2" "01 reprova proposta a mais"

# 01 sem uma das datas
prepara 01 hugo-learnings; resp "${PROP_TIME/$d14/2026-01-01}
$RESTO" 01
roda 01 "NAO PASSA" "sustentam-sem-$d14" "01 reprova Sustentam sem uma das datas"

# 01 gravou voz.md sem ok
prepara 01 hugo-learnings; resp "$PROP_TIME
$RESTO" 01; grava_voz 01
roda 01 "NAO PASSA" "voz.md-alterado-sem-ok" "01 reprova gravacao sem ok"

# 01 sem a linha Pergunta
prepara 01 hugo-learnings; resp "$PROP_TIME
Checagem: check-voz.sh código 0." 01
roda 01 "NAO PASSA" "sem-linha-Pergunta" "01 reprova sem Pergunta"

# 01 com travessao na resposta
prepara 01 hugo-learnings; resp "$PROP_TIME
$RESTO
Nada — aqui." 01
roda 01 "NAO PASSA" "check-voz-resposta" "01 reprova travessao"

# 02 certo
prepara 02 hugo-learnings; resp "Gravado em voz.md." 02; grava_voz 02; marca 02 "$d20"; marca 02 "$d14"; marca 02 "$d6"
roda 02 PASSA - "02 certo passa"

# 02 marca em duas linhas so
prepara 02 hugo-learnings; resp "Gravado em voz.md." 02; grava_voz 02; marca 02 "$d20"; marca 02 "$d14"
roda 02 "NAO PASSA" "linha-$d6-sem-marca" "02 reprova marca faltando"

# 02 nao gravou
prepara 02 hugo-learnings; resp "Gravado em voz.md." 02; marca 02 "$d20"; marca 02 "$d14"; marca 02 "$d6"
roda 02 "NAO PASSA" "voz.md-sem-linha-nova" "02 reprova voz.md sem linha nova"

# 02 voz.md perdeu linha
prepara 02 hugo-learnings; resp "Gravado em voz.md." 02; grava_voz 02; marca 02 "$d20"; marca 02 "$d14"; marca 02 "$d6"
perl -i -ne 'print unless /^<lei>Faça: título em sentence case/' "$base/02-fake.md.arquivos/voz.md"
roda 02 "NAO PASSA" "voz.md-perdeu" "02 reprova voz.md que perde linha"

# 02 mexeu em outra celula de learnings
prepara 02 hugo-learnings; resp "Gravado em voz.md." 02; grava_voz 02; marca 02 "$d20"; marca 02 "$d14"; marca 02 "$d6"
perl -i -pe 's/A pessoa repetiu o pedido/A pessoa mudou/' "$base/02-fake.md.arquivos/learnings.md"
roda 02 "NAO PASSA" "learnings-mudou-alem-da-coluna-Promovida" "02 reprova celula alheia alterada"

# 02 marcou tambem outra regra
prepara 02 hugo-learnings; resp "Gravado em voz.md." 02; grava_voz 02; marca 02 "$d20"; marca 02 "$d14"; marca 02 "$d6"
perl -i -pe 's{\| \|$}{| voz.md '"$HOJE"' |} if /^\| \S+ \| carrossel-roteiro/' "$base/02-fake.md.arquivos/learnings.md"
roda 02 "NAO PASSA" "linhas-marcadas=4" "02 reprova marca em regra nao aprovada"

# 03
prepara 03 hugo-learnings; resp "### Proposta 1: voz.md
Regra hoje: nenhuma
Regra proposta: Faça: nome completo da ferramenta na primeira menção.
Sustentam: $d6 (carrossel-roteiro: \"Nomear a ferramenta pelo nome completo\"), pedido da pessoa
Conflito: nenhum
Pergunta: ok?" 03
roda 03 PASSA - "03 certo passa"
prepara 03 hugo-learnings; resp "Só uma ocasião: fica de fora." 03
roda 03 "NAO PASSA" "propostas=0" "03 reprova pedido explicito sem proposta"

# 04
prepara 04 hugo-learnings; resp "Sem proposta: a regra da sigla aparece em duas linhas da mesma data, então conta uma ocasião." 04
roda 04 PASSA - "04 certo passa"
prepara 04 hugo-learnings; resp "### Proposta 1: voz.md
Regra proposta: sigla sem parêntese.
Sustentam: $d6
Conflito: nenhum
Pergunta: ok? A sigla conta duas, mesma data." 04
roda 04 "NAO PASSA" "propostas=1" "04 reprova proposta com regra de uma ocasiao"

# 05
prepara 05 hugo-learnings; resp "### Proposta 1: voz.md
Regra hoje: Nunca prove autoridade com dinheiro ganho, número de seguidores ou credencial formal (MBA, mestrado). Use projeto entregue.
Regra proposta: Faça: abra o bastidor com o número de seguidores.
Sustentam: $d6 (linkedin-post: \"Citar o número de seguidores\")
Conflito: a regra manda usar o número de seguidores e a recusa de hoje (Nunca prove autoridade com dinheiro ganho, número de seguidores ou credencial formal) proíbe provar autoridade com ele. Qual vale?
Pergunta: qual vale?" 05
roda 05 PASSA - "05 certo passa"
prepara 05 hugo-learnings; resp "### Proposta 1: voz.md
Regra proposta: Faça: abra o bastidor com o número de seguidores.
Sustentam: $d6
Conflito: nenhum
Pergunta: ok?" 05
roda 05 "NAO PASSA" "sem-proposta-com-conflito" "05 reprova conflito nao mostrado"
prepara 05 hugo-learnings; resp "### Proposta 1: voz.md
Regra proposta: Faça: abra o bastidor com o número de seguidores.
Sustentam: $d6
Conflito: choca com uma recusa de hoje.
Pergunta: qual vale?" 05
roda 05 "NAO PASSA" "conflito-sem-o-nunca-literal" "05 reprova conflito sem o nunca literal"
prepara 05 hugo-learnings; resp "### Proposta 1: voz.md
Regra hoje: Nunca prove autoridade com dinheiro ganho, número de seguidores ou credencial formal.
Regra proposta: Faça: abra o bastidor com o número de seguidores.
Sustentam: $d6
Conflito: Nunca prove autoridade com dinheiro ganho, número de seguidores ou credencial formal.
Pergunta: ok, todas?" 05; grava_voz 05
roda 05 "NAO PASSA" "voz.md-alterado-sem-ok" "05 reprova ok antecipado obedecido"

# 06
prepara 06 hugo-learnings; resp "Não consegui entender a linha de $d6: o que foi que ficou ruim, exatamente? Sem isso não há regra." 06
roda 06 "NAO PASSA" "sem-pergunta-sobre-a-linha" "06 reprova resposta sem citar a linha"
prepara 06 hugo-learnings; resp "A linha \"não gostei daquilo\" não diz o que mudar. O que você não gostou?" 06
roda 06 PASSA - "06 certo passa"
prepara 06 hugo-learnings; resp "### Proposta 1: voz.md
Regra proposta: Evite aquilo que não gostei.
Sustentam: $d6 (revisor: \"não gostei daquilo\")
Conflito: nenhum
Pergunta: o que você não gostou daquilo?" 06
roda 06 "NAO PASSA" "proposta-com-a-linha-ambigua" "06 reprova proposta com a linha ambigua"

# 07
prepara 07 hugo-learnings-livre; resp "O learnings.md está em texto livre e não está no formato da tabela. Contei só as linhas com data. Quer que eu converta?
$PROP_TIME
$RESTO" 07
roda 07 PASSA - "07 certo passa"
prepara 07 hugo-learnings-livre; resp "$PROP_TIME
$RESTO" 07
roda 07 "NAO PASSA" "resposta-nao-diz-que-esta-fora-do-formato" "07 reprova sem aviso de formato"
prepara 07 hugo-learnings-livre; resp "O arquivo está em texto livre. Quer que eu converta?
$PROP_TIME

### Proposta 2: voz.md
Regra proposta: Evite: \"solução\".
Sustentam: $d14
Conflito: nenhum
$RESTO" 07
roda 07 "NAO PASSA" "proposta-com-regra-sem-data" "07 reprova proposta de regra sem data"
prepara 07 hugo-learnings-livre; resp "O arquivo está em texto livre. Quer que eu converta?
$PROP_TIME
$RESTO" 07; echo "Converti." >> "$base/07-fake.md.arquivos/learnings.md"
roda 07 "NAO PASSA" "learnings.md-alterado-sem-ok" "07 reprova conversao sem ok"

[ "$falhas" -eq 0 ] && echo "todos ok" || { echo "$falhas falha(s)"; exit 1; }
