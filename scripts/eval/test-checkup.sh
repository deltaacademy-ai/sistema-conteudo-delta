#!/usr/bin/env bash
# Testa scripts/checkup.sh: itens obrigatorios (git, voz.md, icp.md), opcionais
# (node, jq, marca.md, pautas.md), contagem de pecas em aberto, codigo de saida e pasta
# de contexto com espaco no nome.
set -u
raiz=$(cd "$(dirname "$0")/../.." && pwd)
s="$raiz/scripts/checkup.sh"
d=$(mktemp -d)
falhas=0
ok()   { echo "ok    $1"; }
erro() { echo "FALHA $1"; falhas=$((falhas+1)); }

# PATH minimo: so os utilitarios que o script usa, com ou sem git, node e jq.
# Os links ficam numa pasta propria; o bash roda por caminho absoluto.
base_utils="awk grep wc sed cat tr head dirname"
mkpath_dir() { # mkpath_dir <pasta> <comando>...
  local dir="$1"; shift; mkdir -p "$dir"
  for c in "$@"; do local p; p=$(command -v "$c") && ln -sf "$p" "$dir/$c"; done
}
mkpath_dir "$d/bin-sem-nodejq" $base_utils git
mkpath_dir "$d/bin-sem-git" $base_utils node jq

roda() { # roda <pasta-de-contexto> [PATH]: grava saida em $d/out e codigo em $d/cod
  local pasta="$1" p="${2:-$PATH}"
  PATH="$p" /bin/bash "$s" "$pasta" > "$d/out" 2>&1; echo $? > "$d/cod"
}
espera_cod()   { [ "$(cat "$d/cod")" = "$2" ] && ok "$1 (codigo $2)" || erro "$1: codigo $(cat "$d/cod"), esperado $2"; }
espera_linha() { grep -q -- "$2" "$d/out" && ok "$1 (linha: $2)" || { erro "$1: linha ausente: $2"; sed 's/^/      | /' "$d/out"; }; }

completa() { rm -rf "$1"; mkdir -p "$1"; cp -R "$raiz/evals/fixtures/hugo/." "$1/"; }

# 1. pasta completa
completa "$d/cheia"
roda "$d/cheia"
espera_cod   "pasta completa" 0
espera_linha "pasta completa" '^pendencias: 0$'
espera_linha "pasta completa" '^ok voz.md'

# 2. voz.md so com o cabecalho do modelo
completa "$d/semvoz"; cp "$raiz/contexto-modelo/voz.md" "$d/semvoz/voz.md"
roda "$d/semvoz"
espera_cod   "voz.md vazio" 1
espera_linha "voz.md vazio" '^falta voz.md'
espera_linha "voz.md vazio" '^pendencias: 1$'

# 3. marca.md ausente e opcional
completa "$d/semmarca"; rm "$d/semmarca/marca.md"
roda "$d/semmarca"
espera_cod   "marca.md ausente" 0
espera_linha "marca.md ausente" '^opcional marca.md'

# 3b. pautas.md: ausente e opcional; com conteudo conta como ok
completa "$d/pautas"; rm -f "$d/pautas/pautas.md"
roda "$d/pautas"
espera_cod   "pautas.md ausente" 0
espera_linha "pautas.md ausente" '^opcional pautas.md'
cp "$raiz/evals/fixtures/hugo-radar-anterior/pautas.md" "$d/pautas/pautas.md"
roda "$d/pautas"
espera_cod   "pautas.md com conteudo" 0
espera_linha "pautas.md com conteudo" '^ok pautas.md'

# 4. sem node e sem jq: opcional, nao falha
roda "$d/cheia" "$d/bin-sem-nodejq"
espera_cod   "sem node e sem jq" 0
espera_linha "sem node e sem jq" '^opcional node'
espera_linha "sem node e sem jq" '^opcional jq'
espera_linha "sem node e sem jq" '^opcional chromium'

# 5. sem git: obrigatorio
roda "$d/cheia" "$d/bin-sem-git"
espera_cod   "sem git" 1
espera_linha "sem git" '^falta git'

# 6. base com duas linhas rascunho e uma publicado (coluna Status por nome, Gancho com | entre aspas)
completa "$d/base"
cat > "$d/base/base-conteudo.md" <<'EOT'
# Base de conteudo

| Data | Tema | Tipo | Gancho | Status | Fonte |
|---|---|---|---|---|---|
| 2026-10-01 | A | teardown | "gancho com | barra" | rascunho | x |
| 2026-10-02 | B | caso | "outro" | rascunho | y |
| 2026-10-03 | C | caso | "terceiro" | publicado | z |
EOT
roda "$d/base"
espera_linha "base com rascunhos" '^pecas em aberto: 2 rascunho, 0 aprovado$'

# 6b. cabecalho com outras colunas (Status fora da posicao 5)
cat > "$d/base/base-conteudo.md" <<'EOT'
| Data | Tema | Status | Fonte | Tipo |
|---|---|---|---|---|
| 2026-10-01 | A | aprovado | x | caso |
| 2026-10-02 | B | rascunho | y | caso |
EOT
roda "$d/base"
espera_linha "Status por nome do cabecalho" '^pecas em aberto: 1 rascunho, 1 aprovado$'

# 6c. so cabecalho: 0 e 0, sem falhar
cat > "$d/base/base-conteudo.md" <<'EOT'
| Data | Tema | Tipo | Gancho | Status | Fonte |
|---|---|---|---|---|---|
EOT
roda "$d/base"
espera_cod   "base so com cabecalho" 0
espera_linha "base so com cabecalho" '^pecas em aberto: 0 rascunho, 0 aprovado$'

# 6d. base antiga de 7 colunas (sem Origem) e base nova de 8 (com Origem): Status achado pelo nome
cat > "$d/base/base-conteudo.md" <<'EOT'
| Data | Tema | Tipo | Gancho | Status | CTA | Assinatura |
|---|---|---|---|---|---|---|
| 2026-10-01 | A | teardown | "gancho com | barra" | rascunho | | |
| 2026-10-02 | B | caso | "outro" | aprovado | | "frase" |
| 2026-10-03 | C | caso | "terceiro" | publicado | | |
EOT
roda "$d/base"
espera_linha "base de 7 colunas" '^pecas em aberto: 1 rascunho, 1 aprovado$'
cat > "$d/base/base-conteudo.md" <<'EOT'
| Data | Tema | Tipo | Gancho | Status | CTA | Assinatura | Origem |
|---|---|---|---|---|---|---|---|
| 2026-10-01 | A | teardown | "gancho com | barra" | rascunho | | | reaproveita 2026-09-22 Caso do relatorio |
| 2026-10-02 | B | caso | "outro" | aprovado | | "frase" | |
| 2026-10-03 | C | caso | "terceiro" | publicado | | | |
EOT
roda "$d/base"
espera_linha "base de 8 colunas" '^pecas em aberto: 1 rascunho, 1 aprovado$'

# 7. base ausente
completa "$d/semb"; rm "$d/semb/base-conteudo.md"
roda "$d/semb"
espera_cod   "base ausente" 0
espera_linha "base ausente" '^pecas em aberto: 0 rascunho, 0 aprovado$'

# 8. pasta com espaco no nome
completa "$d/pasta com espaco"
roda "$d/pasta com espaco"
espera_cod   "pasta com espaco" 0
espera_linha "pasta com espaco" '^pendencias: 0$'
espera_linha "pasta com espaco" '^ok icp.md'

# 9. pasta padrao e a atual
( cd "$d/cheia" && /bin/bash "$s" > "$d/out" 2>&1; echo $? > "$d/cod" )
espera_cod   "pasta atual por padrao" 0

# 10. entrevista em andamento: voz-bruta.md com respostas e voz.md vazio. A linha
# `andamento` avisa e nao conta como pendencia (as duas pendencias sao voz.md e icp.md)
modelo() { rm -rf "$1"; mkdir -p "$1"; cp -R "$raiz/contexto-modelo/." "$1/"; }
modelo "$d/andamento"
printf '# Voz bruta\n\nResposta 1\nResposta 2\nResposta 3\n' > "$d/andamento/voz-bruta.md"
roda "$d/andamento"
espera_linha "entrevista em andamento" '^andamento entrevista-voz: '
espera_linha "entrevista em andamento" '^falta voz.md'
espera_linha "entrevista em andamento" '^pendencias: 2$'

# 11. voz-bruta.md do modelo: nenhuma linha andamento
modelo "$d/modelo"
roda "$d/modelo"
grep -q '^andamento' "$d/out" && { erro "voz-bruta.md do modelo: linha andamento inesperada"; } || ok "voz-bruta.md do modelo (sem linha andamento)"

# 12. pasta recem-copiada do contexto-modelo: base sem tabela conta 0 e 0, sem erro no stderr
roda "$d/modelo"
espera_linha "pasta do contexto-modelo" '^pecas em aberto: 0 rascunho, 0 aprovado$'
grep -qi 'awk' "$d/out" && erro "pasta do contexto-modelo: erro do awk na saida" || ok "pasta do contexto-modelo (sem erro do awk)"

# 13. voz.md preenchido: o aviso de andamento nao aparece mesmo com voz-bruta.md cheia
completa "$d/pronta"; printf '# Voz bruta\n\na\nb\nc\nd\n' > "$d/pronta/voz-bruta.md"
roda "$d/pronta"
grep -q '^andamento' "$d/out" && erro "voz.md preenchido: linha andamento inesperada" || ok "voz.md preenchido (sem linha andamento)"

rm -rf "$d"
[ "$falhas" -eq 0 ] && { echo "todos passaram"; exit 0; } || { echo "$falhas falha(s)"; exit 1; }
