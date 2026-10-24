#!/usr/bin/env bash
# Confere que o formato de learnings.md mora so no consolidar: todo especialista que grava em
# learnings.md aponta para a secao "Formato de learnings.md" e nao descreve colunas proprias; o
# consolidar traz a secao com o cabecalho exato; o modelo da pasta de contexto usa o mesmo cabecalho.
# Sai 1 com cada achado.
set -u
raiz=$(cd "$(dirname "$0")/../.." && pwd)
cab='| Data | Especialista | Regra | Porquê | Como aplicar | Promovida |'
falhas=0
ok()   { echo "ok    $1"; }
erro() { echo "FALHA $1"; falhas=$((falhas+1)); }

c="$raiz/skills/consolidar/SKILL.md"
if [ -f "$c" ]; then
  grep -qx '## Formato de learnings.md' "$c" && ok "consolidar tem a secao Formato de learnings.md" || erro "consolidar sem a secao '## Formato de learnings.md'"
  grep -qxF "$cab" "$c" && ok "consolidar traz o cabecalho da tabela" || erro "consolidar sem o cabecalho da tabela"
else
  erro "skills/consolidar/SKILL.md nao existe"
fi
grep -qxF "$cab" "$raiz/contexto-modelo/learnings.md" && ok "contexto-modelo/learnings.md traz o cabecalho" || erro "contexto-modelo/learnings.md sem o cabecalho da tabela"

achou=0
for f in "$raiz"/skills/*/SKILL.md; do
  s=$(basename "$(dirname "$f")")
  [ "$s" = consolidar ] && continue
  while IFS= read -r linha; do
    achou=$((achou+1))
    case "$linha" in
      *'Formato de learnings.md'*) ok "$s aponta para Formato de learnings.md" ;;
      *) erro "$s grava em learnings.md e nao aponta para 'Formato de learnings.md' do consolidar" ;;
    esac
    case "$linha" in
      *'o porquê e como aplicar'*|*'o motivo dela e como aplicar'*|*'Promovida'*) erro "$s descreve colunas de learnings.md por conta propria" ;;
    esac
  done < <(grep -E '(grave|registre)[^.]*`learnings\.md`' "$f")
done
[ "$achou" -ge 5 ] && ok "achou $achou especialistas que gravam em learnings.md" || erro "esperava ao menos 5 especialistas que gravam em learnings.md, achou $achou"

[ "$falhas" -eq 0 ] && echo "todos ok" || { echo "$falhas falha(s)"; exit 1; }
