#!/usr/bin/env bash
# Prova, sem gastar modelo, que o campo opcional `ferramentas_extra:` do caso chega a
# --allowedTools do run-case.sh e que, sem o campo, a linha de comando nao muda.
# Um claude falso grava os argumentos recebidos, um por linha.
set -u
dir=$(cd "$(dirname "$0")" && pwd); raiz=$(cd "$dir/../.." && pwd)
d=$(mktemp -d); trap 'rm -rf "$d"' EXIT
falhou=0; ok() { echo "ok: $1"; }; falha() { echo "FALHA: $1"; falhou=1; }
cat > "$d/claude-args.sh" <<'F'
#!/usr/bin/env bash
printf '%s\n' "$@" > "${ARGS_OUT:?}"
printf '{"type":"result","is_error":false,"result":"ok"}\n'
F
chmod +x "$d/claude-args.sh"; export CLAUDE_ISOLADO="$d/claude-args.sh"
mkdir -p "$d/evals/fixtures/fx" "$d/evals/cases/x"; echo a > "$d/evals/fixtures/fx/a.md"
caso() { printf -- '---\nespecialista: x\nfixture: fx\n%sfixture_legado: (nenhuma)\npedido: t\nprompt_novo: gere\nprompt_antigo: (nenhum)\n---\n' "$1" > "$d/evals/cases/x/$2.md"; }
caso '' sem; caso $'ferramentas_extra: WebSearch WebFetch Write\n' com
ARGS_OUT="$d/sem.args" bash "$dir/run-case.sh" "$raiz" "$d/evals/cases/x/sem.md" claude-sonnet-5 "$d/sem.out" >/dev/null 2>&1
ARGS_OUT="$d/com.args" bash "$dir/run-case.sh" "$raiz" "$d/evals/cases/x/com.md" claude-sonnet-5 "$d/com.out" >/dev/null 2>&1
grep -qx WebSearch "$d/com.args" && grep -qx WebFetch "$d/com.args" && grep -qx Write "$d/com.args" \
  && ok "com o campo, as tres ferramentas chegam aos argumentos" || falha "ferramentas extras nao chegaram"
ordem=$(grep -nxE 'WebSearch|--permission-mode' "$d/com.args" | cut -d: -f2 | tr '\n' ' ')
[ "$ordem" = "WebSearch --permission-mode " ] && ok "extras ficam antes de --permission-mode (dentro de --allowedTools)" || falha "ordem: $ordem"
grep -qE 'WebSearch|WebFetch|^Write$' "$d/sem.args" && falha "sem o campo, ferramenta extra apareceu" || ok "sem o campo, nenhuma ferramenta extra"
diff <(grep -vxE 'WebSearch|WebFetch|Write' "$d/com.args" | grep -v '^gere$') <(grep -v '^gere$' "$d/sem.args") >/dev/null \
  && ok "fora os extras, a linha de comando e identica" || falha "linha de comando difere alem dos extras"
ordem_skill=$(grep -nxE 'Skill|--permission-mode' "$d/sem.args" | cut -d: -f2 | tr '\n' ' ')
[ "$ordem_skill" = "Skill --permission-mode " ] && ok "Skill esta em --allowedTools, antes de --permission-mode, sem campo extra" || falha "Skill fora de --allowedTools: $ordem_skill"
exit $falhou
