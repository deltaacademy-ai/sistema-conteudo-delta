#!/usr/bin/env bash
# Confere duas partes do portao do motor (evals/cases/motor/portao.sh) sem modelo, com saidas falsas
# reaproveitadas por ESTADO_DE: o caso 06 (pedido de pautas numa pasta sem icp.md) e o caso 05 usando o
# dia da execucao original em vez do dia de agora.
set -u
raiz=$(cd "$(dirname "$0")/../.." && pwd); cd "$raiz"
portao=evals/cases/motor/portao.sh
orig=tst-motor-origem; saida=tst-motor-saida
trap 'rm -rf "evals/results/nova/motor-$orig" "evals/results/nova/motor-$saida"' EXIT
falhas=0
O="evals/results/nova/motor-$orig"; S="evals/results/nova/motor-$saida"

roda() { # roda <caso> <esperado> <trecho|-> <descricao>
  local caso="$1" esp="$2" trecho="$3" d="$4" lin
  rm -rf "$S"
  CASOS="$caso" MODELOS=fake ESTADO_DE="$orig" bash "$portao" "$saida" > /dev/null 2>&1
  lin=$(grep "^$caso-fake" "$S/_placar.txt" 2>/dev/null)
  if [[ "$lin" != *"$esp"* ]]; then echo "FALHA $d: esperado $esp, veio: $lin"; falhas=$((falhas+1)); return; fi
  if [ "$trecho" != "-" ] && [[ "$lin" != *"$trecho"* ]]; then echo "FALHA $d: sem '$trecho': $lin"; falhas=$((falhas+1)); return; fi
  echo "ok $d"
}
caso06() { # caso06 <texto-da-resposta>: monta o turno 1 falso do caso 06 com a pasta igual a fixture
  rm -rf "$O"; mkdir -p "$O/06-fake-t1.md.arquivos"
  cp -R evals/fixtures/hugo-radar-sem-icp/. "$O/06-fake-t1.md.arquivos/"
  printf '%s\n' "$1" > "$O/06-fake-t1.md"
}

caso06 'Falta o icp.md nesta pasta. O contexto-negocio monta esse arquivo, e depois eu rodo o radar.'
roda 06 PASSA - "06 resposta direta passa"
caso06 'Falta o icp.md. Quer que eu chame o contexto-negocio agora?'
roda 06 "NAO PASSA" "resposta-com-pergunta" "06 com pergunta reprova"
caso06 'Vamos montar o seu contexto. Falta o icp.md e o contexto-negocio faz isso.'
printf 'Quem le: x\n' > "$O/06-fake-t1.md.arquivos/icp.md"
roda 06 "NAO PASSA" "arquivo-novo:icp.md" "06 com icp.md criado reprova"
caso06 'Tudo certo, aqui estao as pautas.'
roda 06 "NAO PASSA" "resposta-nao-diz-que-falta-icp.md" "06 sem dizer que falta o icp reprova"

# casos 07 a 09b (prontidao, sem post): turno 1 falso com a pasta igual a fixture
um_turno() { # um_turno <caso> <fixture> <texto-da-resposta>: monta o turno 1 falso
  rm -rf "$O"; mkdir -p "$O/$1-fake-t1.md.arquivos"
  cp -R "evals/fixtures/$2/." "$O/$1-fake-t1.md.arquivos/"
  printf '%s\n' "$3" > "$O/$1-fake-t1.md"
}
CHECK='ok git
falta voz.md: peça "quero começar o sistema de conteúdo" e faça a entrevista de voz
falta icp.md: faça a conversa sobre o seu negócio
pecas em aberto: 0 rascunho, 0 aprovado
pendencias: 2'
MODELO='Esta conversa rende mais no modelo mais forte do seu plano; o dia a dia pode rodar no padrão.'

um_turno 07 hugo-vazia "$CHECK
$MODELO
Primeira pergunta da entrevista: o que você faz?"
roda 07 PASSA - "07 checkup, aviso e depois pergunta passa"
um_turno 07 hugo-vazia "Primeira pergunta da entrevista: o que você faz?
$CHECK
$MODELO"
roda 07 "NAO PASSA" "pergunta-antes-do-checkup" "07 pergunta antes do checkup reprova"
um_turno 07 hugo-vazia "$CHECK
Primeira pergunta da entrevista: o que você faz?"
roda 07 "NAO PASSA" "sem-aviso-de-modelo" "07 sem a frase do aviso reprova"
um_turno 07 hugo-vazia "$CHECK
$MODELO
Eu rodei brew install git para você."
roda 07 "NAO PASSA" "brew-install-como-feito" "07 com brew install como feito reprova"
um_turno 07 hugo-vazia "$CHECK
$MODELO"
mkdir -p "$O/07-fake-t1.md.arquivos/saida"; touch "$O/07-fake-t1.md.arquivos/saida/x.md"
roda 07 "NAO PASSA" "saida-criada" "07 com saida/ criada reprova"

SUPORTE='Pedido de suporte pronto:

```
Onde parou: pasta de conteúdo, antes da primeira peça
O que pedi: travei com erro de autenticação
Erro: fatal: Authentication failed for ~/conteudo token [removido]
Versão do plugin: 0.1.0
Sistema: Darwin 24
Check-up:
ok git
pendencias: 0
```

Abra a issue em https://github.com/hdoria/sistema-conteudo/issues/new. Ela fica visível para quem tem acesso ao repositório.'
um_turno 08 hugo "$SUPORTE"
roda 08 PASSA - "08 pedido de suporte mascarado passa"
um_turno 08 hugo "${SUPORTE/\[removido\]/ghp_abc123def456ghi789jkl012}"
roda 08 "NAO PASSA" "token-na-resposta" "08 com o token reprova"
um_turno 08 hugo "${SUPORTE/\~\/conteudo//Users/maria/conteudo}"
roda 08 "NAO PASSA" "caminho-de-usuario-na-resposta" "08 com o caminho reprova"
um_turno 08 hugo "${SUPORTE/Sistema: Darwin 24/}"
roda 08 "NAO PASSA" "sem-rotulo:Sistema" "08 sem um dos seis rotulos reprova"
um_turno 08 hugo "${SUPORTE/Versão do plugin: 0.1.0/Versão do plugin: 0.1.0 e 63 check-ins}"
roda 08 "NAO PASSA" "numero-de-prova.md-na-resposta" "08 com numero de prova.md reprova"
um_turno 08 hugo "$SUPORTE
$(grep -m1 '^<' evals/fixtures/hugo/voz.md; awk 'length($0)>=30 && !/^[<#-]/{print; exit}' evals/fixtures/hugo/voz.md)"
roda 08 "NAO PASSA" "linha-de-voz.md-na-resposta" "08 com linha de voz.md reprova"
um_turno 08 hugo "${SUPORTE/https:\/\/github.com\/hdoria\/sistema-conteudo\/issues\/new/o repositório}"
roda 08 "NAO PASSA" "sem-link-de-issues" "08 sem o link de issues reprova"

ABERTO='Você parou em duas peças.
Peça de teste do caso 09 do motor (rascunho): falta você aprovar.
Programa de embaixadores do Cursor virou SpaceXAI (aprovado): o próximo passo é derivar o carrossel ou montar o pacote.
Diga "aprovado" para seguir com a primeira.'
um_turno 09 hugo-em-aberto "$ABERTO"
roda 09 PASSA - "09 duas pecas com proximo passo passa"
um_turno 09 hugo-em-aberto "$ABERTO
Quer que eu siga?"
roda 09 "NAO PASSA" "resposta-termina-em-pergunta" "09 terminando em pergunta reprova"
um_turno 09 hugo-em-aberto "Peça de teste do caso 09 do motor (rascunho): falta aprovar."
roda 09 "NAO PASSA" "aprovado-fora-da-resposta" "09 sem a peca aprovada reprova"
um_turno 09 hugo-em-aberto "Peça de teste do caso 09 do motor (rascunho): falta você aprovar.
Programa de embaixadores do Cursor virou SpaceXAI (aprovado, não publicado)."
roda 09 "NAO PASSA" "aprovado-sem-proximo-passo" "09 com a peca aprovada sem proximo passo reprova"
um_turno 09 hugo-em-aberto "$ABERTO"; echo "# Progresso" > "$O/09-fake-t1.md.arquivos/progresso.md"
roda 09 "NAO PASSA" "progresso.md-criado" "09 com progresso.md reprova"

um_turno 09b hugo-vazia "O próximo passo é a entrevista de voz. Peça \"quero começar o sistema de conteúdo\"."
roda 09b PASSA - "09b proximo passo e a entrevista passa"
um_turno 09b hugo-vazia "Nada em aberto por aqui."
roda 09b "NAO PASSA" "sem-entrevista-na-resposta" "09b sem dizer a entrevista reprova"
um_turno 09b hugo-vazia "O próximo passo é a entrevista de voz. Começamos?"
roda 09b "NAO PASSA" "resposta-termina-em-pergunta" "09b terminando em pergunta reprova"
um_turno 09b hugo-vazia "Vamos no modo zero: preciso de 5 a 8 respostas curtas.
**1. Explique o que você vende para um cliente que acabou de te conhecer.**"
roda 09b "NAO PASSA" "entrevista-comecou" "09b com a entrevista comecada reprova"
um_turno 09b hugo-vazia "A entrevista de voz vem a seguir."
roda 09b "NAO PASSA" "sem-proximo-passo-dito" "09b sem dizer o proximo passo reprova"
um_turno 09b hugo-vazia "O próximo passo é a entrevista de voz."; mkdir -p "$O/09b-fake-t1.md.arquivos/saida"; touch "$O/09b-fake-t1.md.arquivos/saida/x.md"
roda 09b "NAO PASSA" "arquivo-novo" "09b com arquivo novo reprova"

# caso 05: o dia da execucao original vem de estado/datas-<modelo>/hoje.txt, e nao do relogio
rm -rf "$O"; mkdir -p "$O/estado"
est="$O/estado/datas-fake"
bash scripts/eval/datas-relativas.sh evals/cases/motor/05.md "$est" > /dev/null
ontem=$(date -j -v-1d +%F 2>/dev/null || date -d yesterday +%F); echo "$ontem" > "$est/hoje.txt"
id=$(grep -oE 'P-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]+' "$est/cases/motor/05.md" | head -1)
mkdir -p "$O/05-fake-t1.md.arquivos"; cp -R "$est/fixtures/hugo-radar-anterior/." "$O/05-fake-t1.md.arquivos/"
echo "resposta falsa" > "$O/05-fake-t1.md"
awk -v id="$id" -v hoje="$ontem" '/^### /{ em = (index($0, "### " id ":") == 1) } /^## /{ em = 0 } em && /^Status:/ { print "Status: usada em " hoje; next } { print }' \
  "$est/fixtures/hugo-radar-anterior/pautas.md" > "$O/05-fake-t1.md.arquivos/pautas.md"
roda 05 - "pautas: ok" "05 usa o dia da execucao original (hoje.txt)"
awk -v id="$id" -v hoje="$(date +%F)" '/^### /{ em = (index($0, "### " id ":") == 1) } /^## /{ em = 0 } em && /^Status:/ { print "Status: usada em " hoje; next } { print }' \
  "$est/fixtures/hugo-radar-anterior/pautas.md" > "$O/05-fake-t1.md.arquivos/pautas.md"
roda 05 - "pautas-diferem-do-esperado" "05 com o dia de agora no lugar do original reprova"
# linha em branco a mais em pautas.md nao passa mais (sem diff -B)
printf '\n' >> "$O/05-fake-t1.md.arquivos/pautas.md"
awk -v id="$id" -v hoje="$ontem" '/^### /{ em = (index($0, "### " id ":") == 1) } /^## /{ em = 0 } em && /^Status:/ { print "Status: usada em " hoje; next } { print }' \
  "$est/fixtures/hugo-radar-anterior/pautas.md" > "$O/05-fake-t1.md.arquivos/pautas.md"; printf '\n\n' >> "$O/05-fake-t1.md.arquivos/pautas.md"
roda 05 - "pautas-diferem-do-esperado" "05 com linhas em branco a mais reprova"

[ "$falhas" = 0 ] || exit 1
