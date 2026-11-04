#!/usr/bin/env bash
# Testa o empacotamento do plugin: validacao do claude, allowed-tools nos frontmatters,
# corpo neutro (sem a variavel do host), INSTALAR.md sem versao no caminho, icone e versao.
set -u
raiz=$(cd "$(dirname "$0")/../.." && pwd)
falhas=0
ok()   { echo "ok    $1"; }
erro() { echo "FALHA $1"; falhas=$((falhas+1)); }

# 1. claude plugin validate
if (cd "$raiz" && claude plugin validate . >/dev/null 2>&1); then ok "claude plugin validate sai com 0"; else erro "claude plugin validate nao saiu com 0"; fi

# 2 e 3. frontmatter e corpo de cada skill cujo corpo cita scripts/. Skill nova que roda
# script falha por padrao ate alguem declarar o allowed-tools ou isenta-la aqui.
# Isentas: rodam check-voz.sh mas ficaram fora do A5 (decisao do controlador, 2026-10-24).
isentas=" angulo contexto-negocio entrevista-voz revisor "
for f in "$raiz"/skills/*/SKILL.md; do
  s=$(basename "$(dirname "$f")")
  fim=$(awk 'NR>1 && /^---$/{print NR; exit}' "$f")
  front=$(sed -n "1,${fim}p" "$f"); corpo=$(sed -n "$((fim+1)),\$p" "$f")
  scripts=$(printf '%s\n' "$corpo" | grep -o 'scripts/[A-Za-z0-9._-]*\.\(sh\|mjs\)' | sort -u)
  [ -z "$scripts" ] && continue
  case "$isentas" in *" $s "*) ok "$s isenta (roda script sem allowed-tools, por decisao)"; continue ;; esac
  linha=$(printf '%s\n' "$front" | grep '^allowed-tools:' || true)
  [ -n "$linha" ] && ok "$s declara allowed-tools" || erro "$s roda script e nao declara allowed-tools"
  for sc in $scripts; do
    case "$sc" in *.mjs) cmd=node ;; *) cmd=bash ;; esac
    case "$linha" in
      *"Bash($cmd "'${CLAUDE_PLUGIN_ROOT}/'"$sc "*) ok "$s libera $cmd $sc" ;;
      *) erro "$s manda rodar $sc e o allowed-tools nao tem Bash($cmd \${CLAUDE_PLUGIN_ROOT}/$sc *)" ;;
    esac
  done
  if printf '%s\n' "$corpo" | grep -q 'CLAUDE_PLUGIN_ROOT'; then erro "$s tem CLAUDE_PLUGIN_ROOT no corpo"; else ok "$s corpo neutro"; fi
done

# 4. INSTALAR.md
if grep -Eq '/[0-9]+\.[0-9]+\.[0-9]+([^0-9.]|$)' "$raiz/INSTALAR.md"; then erro "INSTALAR.md tem numero de versao em caminho"; else ok "INSTALAR.md sem versao em caminho"; fi
if grep -Fq 'claude plugin install sistema-conteudo --marketplace deltaacademy-ai/sistema-conteudo-delta' "$raiz/INSTALAR.md"; then ok "INSTALAR.md traz a instalacao de uma linha"; else erro "INSTALAR.md sem a instalacao de uma linha"; fi

# 5. icone
ic="$raiz/.claude-plugin/icon.png"
if [ -f "$ic" ]; then
  w=$(sips -g pixelWidth "$ic" | awk '/pixelWidth/{print $2}'); h=$(sips -g pixelHeight "$ic" | awk '/pixelHeight/{print $2}')
  if [ "$w" = "$h" ] && [ "${w:-0}" -ge 512 ]; then ok "icone quadrado ${w}px"; else erro "icone ${w}x${h}: precisa ser quadrado e ter 512 px ou mais"; fi
else erro "icone ausente"; fi

# 6. versao diferente da ultima tag
v=$(awk -F'"' '/"version"/{print $4; exit}' "$raiz/.claude-plugin/plugin.json")
tag=$(cd "$raiz" && git tag --list 'sistema-conteudo--v*' --sort=-v:refname | head -1)
if [ -z "$tag" ]; then ok "sem tag anterior (versao $v)"
elif [ "sistema-conteudo--v$v" != "$tag" ]; then ok "versao $v difere da ultima tag $tag"
else erro "versao $v igual a ultima tag $tag"; fi

[ "$falhas" -eq 0 ] && echo "todos ok" || { echo "$falhas falha(s)"; exit 1; }
