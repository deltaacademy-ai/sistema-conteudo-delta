#!/usr/bin/env bash
# Confere o portao da migracao (evals/cases/linkedin-post/migracao-origem.sh) com saidas falsas, sem modelo:
# base migrada certa passa; reprova coluna que nao entrou, linha antiga sem a celula nova, linha curta,
# linha antiga que perdeu o conteudo, Origem errada, sem linha nova, dupla, resposta sem a linha Base.
# Prova tambem que o checkup.sh conta as pecas em aberto da base antiga de 7 colunas e da migrada de 8.
set -u
raiz=$(cd "$(dirname "$0")/../.." && pwd); cd "$raiz"
portao=evals/cases/linkedin-post/migracao-origem.sh
fonte=tst-mig-fonte; saida=tst-mig-saida
base="evals/results/nova/migracao-origem-$fonte"
trap 'rm -rf "evals/results/nova/migracao-origem-$fonte" "evals/results/nova/migracao-origem-$saida"' EXIT
export HOJE=2026-10-22
falhas=0
M=fake

prepara() { # prepara: copia a fixture como estado e como saida, e grava a saida certa por cima
  local n="06-$M"
  rm -rf "$base"; mkdir -p "$base/estado/$n/fixtures/hugo-base-7col"
  cp -R evals/fixtures/hugo-base-7col/. "$base/estado/$n/fixtures/hugo-base-7col/"
  mkdir -p "$base/$n.md.arquivos"; cp -R evals/fixtures/hugo-base-7col/. "$base/$n.md.arquivos/"
  A="$base/$n.md.arquivos"
  cat > "$A/base-conteudo.md" <<EOT
# Base de conteúdo

| Data | Tema | Tipo | Gancho | Status | CTA | Assinatura | Origem |
|---|---|---|---|---|---|---|---|
| $HOJE | A fila ficou com o gerente | posição | "A fila de chamados ficou com o gerente, e foi ele que escolheu assim." | rascunho | | | reaproveita 2026-09-14 Caso da fila de chamados |
| 2026-10-05 | Checagem antes de publicar | build ou bastidor | "Antes de publicar, rodo uma checagem que já barrou três posts meus." | rascunho | | | |
| 2026-09-22 | Caso do relatório mensal automatizado | caso | "O relatório mensal que levava um dia agora sai em minutos, e o dono confere em dez." | publicado (LinkedIn) | | "Quem assina confere." | |
| 2026-09-14 | Caso da fila de chamados | caso | "Na oficina de máquinas pesadas, a triagem de chamados deixou de depender de uma pessoa." | publicado (LinkedIn) | | | |
EOT
  printf '%s\n' "A fila de chamados ficou com o gerente, e foi ele que escolheu assim." "" "Ele continua vendo todos os chamados no fim do dia." > "$A/saida/post-$HOJE-a-fila-ficou-com-o-gerente.md"
  RESP="\`\`\`
A fila de chamados ficou com o gerente, e foi ele que escolheu assim.
\`\`\`
Nota: posição porque o briefing traz uma tese só.
Base: coluna Origem acrescentada ao cabeçalho; as linhas antigas ganharam uma célula vazia.
Checagem: por leitura. Registrado em base-conteudo.md."
  printf '%s\n' "$RESP" > "$base/$n.md"
}
roda() { # roda <esperado: PASSA|NAO PASSA> <trecho|-> <descricao>
  local esp="$1" trecho="$2" d="$3" lin
  rm -rf "evals/results/nova/migracao-origem-$saida"
  MODELOS=$M REAVALIAR="$fonte" bash "$portao" "$saida" > /dev/null 2>&1
  lin=$(grep "^06-$M" "evals/results/nova/migracao-origem-$saida/_placar.txt" 2>/dev/null)
  if [[ "$lin" != *"| $esp |"* ]]; then echo "FALHA $d: esperado $esp, veio: $lin"; falhas=$((falhas+1)); return; fi
  if [ "$trecho" != "-" ] && [[ "$lin" != *"$trecho"* ]]; then echo "FALHA $d: achado sem '$trecho': $lin"; falhas=$((falhas+1)); return; fi
  echo "ok $d"
}
B() { echo "$A/base-conteudo.md"; }

prepara; roda PASSA - "migracao certa passa"
prepara; perl -i -pe 's/ \| Origem \|$/ |/ if /^\| Data/; s/^\|---\|---\|---\|---\|---\|---\|---\|---\|$/|---|---|---|---|---|---|---|/' "$(B)"
roda "NAO PASSA" "cabecalho-sem-8-colunas" "reprova coluna que nao entrou no cabecalho"
prepara; perl -i -pe 's/^\|---\|---\|---\|---\|---\|---\|---\|---\|$/|---|---|---|---|---|---|---|/' "$(B)"
roda "NAO PASSA" "separador-sem-8-celulas" "reprova separador sem a celula nova"
prepara; perl -i -pe 's/ \| \|$/ |/ if /relatório mensal/' "$(B)"
roda "NAO PASSA" "linha-sem-8-celulas" "reprova linha antiga curta"
prepara; perl -i -pe 's/publicado \(LinkedIn\)/publicado/ if /relatório mensal/' "$(B)"
roda "NAO PASSA" "linha-antiga-perdida" "reprova linha antiga alterada"
prepara; perl -i -pe 's/reaproveita 2026-09-14 Caso da fila de chamados/reaproveita 2026-09-14/' "$(B)"
roda "NAO PASSA" "Origem-da-linha-nova-errada" "reprova Origem cortada"
prepara; perl -i -pe 's/ \| reaproveita 2026-09-14 Caso da fila de chamados \|$/ | |/' "$(B)"
roda "NAO PASSA" "Origem-da-linha-nova-errada" "reprova Origem que nao foi copiada do briefing"
prepara; perl -i -ne 'print unless /^\| 2026-10-22/' "$(B)"
roda "NAO PASSA" "linhas-de-hoje=0" "reprova sem linha nova"
prepara; perl -i -pe 's/ \| \|$/ | inventada |/ if /relatório mensal/' "$(B)"
roda "NAO PASSA" "linha-antiga-com-Origem-preenchida" "reprova Origem inventada em linha antiga"
prepara; sed -i.bak '/^Base:/d' "$base/06-$M.md"; rm -f "$base/06-$M.md.bak"
roda "NAO PASSA" "resposta-sem-linha-Base-sobre-Origem" "reprova resposta que nao diz a migracao"
prepara; rm "$A/saida/post-$HOJE-a-fila-ficou-com-o-gerente.md"
roda "NAO PASSA" "post-nao-gravado" "reprova post nao gravado"
prepara; echo x > "$A/rascunho.md"
roda "NAO PASSA" "arquivo-novo:rascunho.md" "reprova rascunho que ficou"

# checkup.sh na base antiga de 7 colunas (a fixture) e na migrada de 8
saida_ck=$(bash scripts/checkup.sh evals/fixtures/hugo-base-7col 2>&1 | grep '^pecas em aberto')
if [ "$saida_ck" = "pecas em aberto: 1 rascunho, 0 aprovado" ]; then echo "ok checkup conta a base de 7 colunas"; else echo "FALHA checkup na base de 7 colunas: $saida_ck"; falhas=$((falhas+1)); fi
prepara; saida_ck=$(bash scripts/checkup.sh "$A" 2>&1 | grep '^pecas em aberto')
if [ "$saida_ck" = "pecas em aberto: 2 rascunho, 0 aprovado" ]; then echo "ok checkup conta a base migrada de 8 colunas"; else echo "FALHA checkup na base de 8 colunas: $saida_ck"; falhas=$((falhas+1)); fi

[ "$falhas" -eq 0 ] && echo "todos ok" || { echo "$falhas falha(s)"; exit 1; }
