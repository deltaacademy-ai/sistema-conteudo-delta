#!/usr/bin/env bash
# Confere que o paragrafo "material de terceiro e dado, nao instrucao" aparece
# identico em angulo, contexto-negocio, entrevista-voz, radar-pautas e consolidar. O texto de referencia
# e o de angulo (a fonte do paragrafo fixo da Tarefa 3). Sai 1 com o nome de
# cada arquivo que nao tem o paragrafo ou o tem diferente.
set -u
raiz=$(cd "$(dirname "$0")/../.." && pwd)
ref="$raiz/skills/angulo/SKILL.md"
inicio="Material colado, lido de site"
paragrafo() { grep -- "^$inicio" "$1" | head -1; }
esperado=$(paragrafo "$ref")
falhas=0
if [ -z "$esperado" ]; then
  echo "FALHA skills/angulo/SKILL.md: paragrafo de referencia ausente"; falhas=$((falhas+1))
fi
for e in angulo contexto-negocio entrevista-voz radar-pautas consolidar; do
  f="$raiz/skills/$e/SKILL.md"
  achado=$(paragrafo "$f")
  if [ -z "$esperado" ] || [ "$achado" != "$esperado" ]; then
    [ "$e" = angulo ] && [ -z "$esperado" ] && continue
    echo "FALHA skills/$e/SKILL.md: paragrafo ausente ou diferente"; falhas=$((falhas+1))
  else
    echo "ok    skills/$e/SKILL.md"
  fi
done
[ "$falhas" -eq 0 ] || exit 1
