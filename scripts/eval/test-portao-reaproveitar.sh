#!/usr/bin/env bash
# Confere o portao do reaproveitar (evals/cases/reaproveitar/portao.sh) com saidas falsas, sem modelo:
# usa REAVALIAR e HOJE fixo, e diz se o portao PASSA ou NAO PASSA e por qual achado.
# Cada criterio tem pelo menos um caso negativo: recorte a mais ou a menos, bloco sem campo, Recomendado
# ausente ou de letra que nao existe, briefing ausente, sem a linha Origem, linha 1 da origem repetida,
# numero novo, 50 fora do FALTA, recorte de peca em rascunho, briefing onde nao devia, candidata errada,
# base ou metricas alteradas, peca de saida alterada, arquivo novo.
set -u
raiz=$(cd "$(dirname "$0")/../.." && pwd); cd "$raiz"
portao=evals/cases/reaproveitar/portao.sh
fonte=tst-reap-fonte; saida=tst-reap-saida
base="evals/results/nova/reaproveitar-$fonte"
trap 'rm -rf "evals/results/nova/reaproveitar-$fonte" "evals/results/nova/reaproveitar-$saida"' EXIT
export HOJE=2026-10-22
falhas=0
BR="saida/briefing-$HOJE-relatorio-mensal-automatizado.md"

prepara() { # prepara <caso>: zera a saida falsa de <caso>
  local n="$1-fake"
  rm -rf "$base"; mkdir -p "$base/estado/$n/fixtures/hugo-reaproveitar" "$base/estado/$n/cases/reaproveitar"
  cp -R evals/fixtures/hugo-reaproveitar/. "$base/estado/$n/fixtures/hugo-reaproveitar/"
  cp "evals/cases/reaproveitar/$1.md" "$base/estado/$n/cases/reaproveitar/$1.md"
  mkdir -p "$base/$n.md.arquivos"; cp -R evals/fixtures/hugo-reaproveitar/. "$base/$n.md.arquivos/"
}
resp() { printf '%s\n' "$1" > "$base/$2-fake.md"; }
brief() { printf '%s\n' "$2" > "$base/$1-fake.md.arquivos/$BR"; } # brief <caso> <conteudo>
roda() { # roda <caso> <esperado: PASSA|NAO PASSA> <trecho do achado|-> <descricao>
  local caso="$1" esp="$2" trecho="$3" d="$4" lin
  rm -rf "evals/results/nova/reaproveitar-$saida"
  CASOS="$caso" MODELOS=fake REAVALIAR="$fonte" bash "$portao" "$saida" > /dev/null 2>&1
  lin=$(grep "^$caso-fake" "evals/results/nova/reaproveitar-$saida/_placar.txt" 2>/dev/null)
  if [[ "$lin" != *"| $esp |"* ]]; then echo "FALHA $d: esperado $esp, veio: $lin"; falhas=$((falhas+1)); return; fi
  if [ "$trecho" != "-" ] && [[ "$lin" != *"$trecho"* ]]; then echo "FALHA $d: achado sem '$trecho': $lin"; falhas=$((falhas+1)); return; fi
  echo "ok $d"
}

ORIGEM="Origem: reaproveita 2026-09-22 Caso do relatório mensal automatizado"
BRIEF="Tipo: posição
Tese: Quem assina o relatório decide o que a pessoa confere, e o agente escreve o resto.
Ângulo: Na distribuidora de peças, o dono manteve a conferência humana nos totais de faturamento. O recorte fica na decisão do dono e deixa de fora o antes e depois do tempo.
Leitura da pessoa: [FALTA: leitura da pessoa sobre a conferência do dono]
Funil: meio
Tom: direto, prático
Tipo de gancho: contradição
Formato: post
Tamanho: abaixo de 900, tipo mantido
Fechamento: pergunta genuína
Fontes e links: nenhum link no tema
Material bruto: O dono pediu para manter a conferência humana nos números de faturamento (saida/post-2026-09-22-relatorio-mensal-automatizado.md).
Aval: nada
Falta: [FALTA: leitura da pessoa sobre a conferência do dono]
$ORIGEM"
RESP="### Recorte A
Tipo: posição
O que muda frente à origem: sai o antes e depois do tempo e fica a decisão do dono sobre o que a pessoa confere.
Faltas: a leitura da pessoa sobre a conferência.

### Recorte B
Tipo: educativo
O que muda frente à origem: vira um passo a passo para decidir o que a pessoa confere num relatório automatizado.
Faltas: um método que a pessoa use de verdade, com exemplo.

Recomendado: A, porque o fato da decisão do dono já está na peça.
Briefing gravado em $BR.
Checagem: check-voz.sh código 0 no briefing. Resposta conferida na leitura."
RESP3="${RESP/Faltas: a leitura da pessoa sobre a conferência./Faltas: [FALTA: fonte do número de 50 clientes] e a leitura da pessoa.}"

# 01
prepara 01; resp "$RESP" 01; brief 01 "$BRIEF"
roda 01 PASSA - "01 certo passa"
prepara 01; resp "$RESP" 01
roda 01 "NAO PASSA" "briefings-novos=0" "01 reprova sem briefing"
prepara 01; resp "$RESP" 01; brief 01 "$BRIEF"; printf '%s\n' "$BRIEF" > "$base/01-fake.md.arquivos/saida/briefing-$HOJE-outro.md"
roda 01 "NAO PASSA" "briefings-novos=2" "01 reprova dois briefings"
prepara 01; resp "$RESP" 01; brief 01 "${BRIEF/$ORIGEM/Origem: reaproveita}"
roda 01 "NAO PASSA" "briefing-sem-a-linha-Origem" "01 reprova Origem incompleta"
prepara 01; resp "$RESP" 01; brief 01 "${BRIEF/$ORIGEM/}"
roda 01 "NAO PASSA" "briefing-sem-a-linha-Origem" "01 reprova briefing sem Origem"
prepara 01; resp "$RESP" 01; brief 01 "${BRIEF/Funil: meio/Funil: meio
Gancho: O relatório mensal que levava um dia agora sai em minutos}"
roda 01 "NAO PASSA" "repete-a-linha-1-da-origem" "01 reprova linha 1 da origem no briefing"
prepara 01; resp "${RESP/vira um passo a passo/vira \"o dono confere em dez\" e um passo a passo}" 01; brief 01 "$BRIEF"
roda 01 "PASSA" - "01 aceita citar so parte da linha 1 que nao repete a frase"
prepara 01; resp "${RESP/vira um passo a passo/O relatório mensal que levava um dia vira um passo a passo}" 01; brief 01 "$BRIEF"
roda 01 "NAO PASSA" "repete-a-linha-1-da-origem" "01 reprova linha 1 da origem no recorte"
prepara 01; resp "$RESP" 01; brief 01 "${BRIEF/Funil: meio/Funil: meio
Material: Antes o relatório levava um dia. Agora sai em minutos, e o dono confere em dez (peça de 2026-09-22).}"
roda 01 "PASSA" - "01 aceita o fato do fecho da linha 1 no briefing, em frase propria"
prepara 01; resp "${RESP/vira um passo a passo/sai em minutos, e o dono confere em dez, vira um passo a passo}" 01; brief 01 "$BRIEF"
roda 01 "NAO PASSA" "repete-a-linha-1-da-origem" "01 reprova o fecho da linha 1 no recorte"
prepara 01; resp "$RESP" 01; brief 01 "${BRIEF/Funil: meio/Funil: meio
Resultado: 2.468 horas economizadas}"
roda 01 "NAO PASSA" "numero-novo-no-briefing:2.468" "01 reprova numero novo"
prepara 01; resp "$RESP" 01; brief 01 "${BRIEF/Ângulo:/Angulo:}"
roda 01 "NAO PASSA" "briefing-sem-Ângulo" "01 reprova briefing sem campo do angulo"
prepara 01; resp "$(printf '%s\n' "$RESP" | sed 's/^### Recorte B/### Trecho B/')" 01; brief 01 "$BRIEF"
roda 01 "NAO PASSA" "recortes=1" "01 reprova so um recorte"
prepara 01; resp "${RESP/Recomendado: A,/Recomendado: C,}" 01; brief 01 "$BRIEF"
roda 01 "NAO PASSA" "recomendado-nao-e-um-recorte:C" "01 reprova recomendado de letra que nao existe"
prepara 01; resp "${RESP/Recomendado: A, porque o fato da decisão do dono já está na peça./Eu ficaria com o A.}" 01; brief 01 "$BRIEF"
roda 01 "NAO PASSA" "linhas-Recomendado=0" "01 reprova sem Recomendado"
prepara 01; resp "${RESP/O que muda frente à origem: vira/Muda: vira}" 01; brief 01 "$BRIEF"
roda 01 "NAO PASSA" "recorte-B-sem-O-que-muda" "01 reprova bloco sem O que muda"
prepara 01; resp "${RESP/Faltas: um método que a pessoa use de verdade, com exemplo./Nada falta.}" 01; brief 01 "$BRIEF"
roda 01 "NAO PASSA" "recorte-B-sem-Faltas" "01 reprova bloco sem Faltas"
prepara 01; resp "$RESP
Nada — aqui." 01; brief 01 "$BRIEF"
roda 01 "NAO PASSA" "check-voz-resposta" "01 reprova travessao na resposta"
prepara 01; resp "$RESP" 01; brief 01 "$BRIEF
Obs — aqui."
roda 01 "NAO PASSA" "check-voz-briefing" "01 reprova travessao no briefing"
prepara 01; resp "$RESP" 01; brief 01 "$BRIEF"; echo '| 2026-10-22 | x | caso | "g" | rascunho | | | reaproveita |' >> "$base/01-fake.md.arquivos/base-conteudo.md"
roda 01 "NAO PASSA" "base-conteudo.md-alterado" "01 reprova base alterada"
prepara 01; resp "$RESP" 01; brief 01 "$BRIEF"; echo '| 2026-09-22 | x | | | | | | | | | y |' >> "$base/01-fake.md.arquivos/metricas.md"
roda 01 "NAO PASSA" "metricas.md-alterado" "01 reprova metricas alterado"
prepara 01; resp "$RESP" 01; brief 01 "$BRIEF"; echo extra >> "$base/01-fake.md.arquivos/saida/post-2026-09-22-relatorio-mensal-automatizado.md"
roda 01 "NAO PASSA" "peca-de-saida-alterada:post-2026-09-22" "01 reprova peca de origem alterada"
prepara 01; resp "$RESP" 01; brief 01 "$BRIEF"; echo x > "$base/01-fake.md.arquivos/rascunho.md"
roda 01 "NAO PASSA" "arquivo-novo:rascunho.md" "01 reprova rascunho que ficou"
prepara 01; resp "$RESP" 01; brief 01 "$BRIEF"; rm "$base/01-fake.md.arquivos/icp.md"
roda 01 "NAO PASSA" "arquivo-da-fixture-sumiu:icp.md" "01 reprova arquivo da fixture que sumiu"

# 02
RESP02="Reaproveitar: nada gravado. A peça \"Checagem antes de publicar\" está como rascunho, e só peça publicada entra.
Checagem: nenhum arquivo mudou. Resposta conferida na leitura."
prepara 02; resp "$RESP02" 02
roda 02 PASSA - "02 certo passa"
prepara 02; resp "$RESP02" 02; brief 02 "$BRIEF"
roda 02 "NAO PASSA" "briefing-gravado-sem-dever" "02 reprova briefing de peca em rascunho"
prepara 02; resp "$RESP02
$RESP" 02
roda 02 "NAO PASSA" "recorte-de-peca-em-rascunho" "02 reprova recorte de rascunho"
prepara 02; resp "Reaproveitar: nada gravado. Não consegui montar o recorte." 02
roda 02 "NAO PASSA" "resposta-nao-diz-que-so-peca-publicada-entra" "02 reprova resposta sem a regra"
prepara 02; resp "Reaproveitar: nada gravado. Só peça publicada entra." 02
roda 02 "NAO PASSA" "resposta-nao-cita-o-status" "02 reprova resposta sem o status"

# 03
prepara 03; resp "$RESP3" 03; brief 03 "$BRIEF"
roda 03 PASSA - "03 certo passa (FALTA na resposta)"
prepara 03; resp "$RESP" 03; brief 03 "${BRIEF/Falta: \[FALTA: leitura/Falta: [FALTA: fonte do número de 50 clientes]. [FALTA: leitura}"
roda 03 PASSA - "03 aceita o FALTA so no briefing"
prepara 03; resp "$RESP3" 03; brief 03 "${BRIEF/Material bruto: O dono/Material bruto: Agora são 50 clientes. O dono}"
roda 03 "NAO PASSA" "50-no-briefing-fora-de-FALTA" "03 reprova 50 como fato no briefing"
prepara 03; resp "$RESP" 03; brief 03 "$BRIEF"
roda 03 "NAO PASSA" "sem-FALTA-sobre-o-numero" "03 reprova sumir com o numero sem avisar"
prepara 03; resp "$RESP3" 03; brief 03 "${BRIEF/Tese: Quem/Tese: Com cinquenta clientes, quem}"
roda 03 "NAO PASSA" "50-no-briefing-fora-de-FALTA" "03 reprova cinquenta por extenso"

# 04
RESP4="${RESP/Tipo: educativo/Tipo: carrossel}"
RESP4="${RESP4/Recomendado: A, porque o fato da decisão do dono já está na peça./Recomendado: B, porque o pedido foi carrossel.}"
BRIEF4="${BRIEF/Formato: post/Formato: carrossel}"
prepara 04; resp "$RESP4" 04; brief 04 "$BRIEF4"
roda 04 PASSA - "04 certo passa"
prepara 04; resp "$RESP" 04; brief 04 "$BRIEF4"
roda 04 "NAO PASSA" "recorte-recomendado-sem-Tipo-carrossel" "04 reprova recomendado que nao e carrossel"
prepara 04; resp "$RESP4" 04; brief 04 "$BRIEF"
roda 04 "NAO PASSA" "briefing-sem-Formato-carrossel" "04 reprova briefing em formato post"

# 05
RESP5="Candidata 1: 2026-09-14 Caso da fila de chamados. 1.780 impressões, colado pela pessoa em 2026-09-24 (acima da média das duas medidas).
Candidata 2: 2026-09-22 Caso do relatório mensal automatizado. 940 impressões, colado pela pessoa em 2026-09-29.
A peça \"Checagem antes de publicar\" é rascunho e não entra.
Diga qual delas você quer reaproveitar.
Checagem: nenhum arquivo mudou. Resposta conferida na leitura."
prepara 05; resp "$RESP5" 05
roda 05 PASSA - "05 certo passa"
prepara 05; resp "$RESP5" 05; brief 05 "$BRIEF"
roda 05 "NAO PASSA" "briefing-gravado-sem-dever" "05 reprova briefing numa pergunta de sugestao"
prepara 05; resp "Candidata 1: 2026-09-22 Caso do relatório mensal automatizado. 940 impressões, colado pela pessoa em 2026-09-29.
Candidata 2: 2026-09-14 Caso da fila de chamados. 1.780 impressões, colado pela pessoa em 2026-09-24." 05
roda 05 "NAO PASSA" "primeira-candidata-nao-e-a-fila" "05 reprova a ordem trocada"
prepara 05; resp "${RESP5/ colado pela pessoa em 2026-09-24/}" 05
roda 05 "NAO PASSA" "primeira-candidata-sem-a-fonte" "05 reprova candidata sem a fonte"
prepara 05; resp "${RESP5/1.780 impressões/muitas impressões}" 05
roda 05 "NAO PASSA" "primeira-candidata-sem-1.780" "05 reprova candidata sem o numero"
prepara 05; resp "$RESP5
Candidata 3: 2026-10-05 Checagem antes de publicar." 05
roda 05 "NAO PASSA" "candidata-em-rascunho" "05 reprova rascunho como candidata"
prepara 05; resp "$RESP5
$RESP" 05
roda 05 "NAO PASSA" "recorte-em-pergunta-de-sugestao" "05 reprova recorte numa pergunta de sugestao"
prepara 05; resp "Reaproveitar: não achei peça medida." 05
roda 05 "NAO PASSA" "sem-linha-Candidata" "05 reprova resposta sem candidata"

[ "$falhas" -eq 0 ] && echo "todos ok" || { echo "$falhas falha(s)"; exit 1; }
