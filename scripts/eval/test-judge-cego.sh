#!/usr/bin/env bash
set -u
# uso: bash scripts/eval/test-judge-cego.sh
# Prova que a mensagem que vai ao juiz nao carrega nome de skill nem de plugin,
# nem os prompts do caso (que dizem qual plugin rodou), e que os arquivos
# gravados pela execucao chegam ao juiz.
dir=$(cd "$(dirname "$0")" && pwd)
raiz=$(cd "$dir/../.." && pwd)
falhou=0
ok() { echo "ok $1"; }
falha() { echo "FALHA $1"; falhou=1; }

d=$(mktemp -d)
fxn="$d/fx-nova"; fxa="$d/fx-antiga"
mkdir -p "$fxn" "$fxa"
printf 'Voz do autor: frase curta, sem travessao.\n' > "$fxn/voz.md"
printf 'ICP: gestor que decide.\n' > "$fxn/icp.md"
printf 'material fixo\n' > "$fxn/base.md"
printf 'material fixo\n' > "$fxa/base.md"

caso="$d/01.md"
cat > "$caso" <<'CASO'
---
especialista: gancho
fixture: fx-nova
fixture_legado: fx-antiga
pedido: Tarefa: criar duas aberturas de post de LinkedIn a partir do briefing abaixo.
prompt_novo: Use a skill gancho do plugin sistema-conteudo para criar as aberturas.
prompt_antigo: Use a skill hormozi do plugin squad-legado no modo A.
---

- Linha 1 com ate 15 palavras.
- Sem paralelismo negativo.
CASO

nova="$d/nova.md"; antiga="$d/antiga.md"
printf 'Gancho 1 gerado pela skill gancho do plugin sistema-conteudo.\nO conteudo final esta nos arquivos gravados.\n' > "$nova"
printf 'Etapa B do Kotler, modo A do Hormozi, squad-legado. Da Vinci nao rodou.\n' > "$antiga"
mkdir -p "$nova.arquivos/saida" "$antiga.arquivos"
printf 'material fixo\n' > "$nova.arquivos/base.md"
printf 'ENTREGAVEL NOVO NO ARQUIVO\n' > "$nova.arquivos/saida/voz.md"
printf 'material fixo\n' > "$antiga.arquivos/base.md"
printf 'ENTREGAVEL ANTIGO NO ARQUIVO\n' > "$antiga.arquivos/briefing.md"

msg=$(bash "$dir/judge-msg.sh" "$caso" "$fxn" "$nova" "$fxn" "$antiga" "$fxa") || { echo "FALHA judge-msg nao rodou"; exit 1; }

# 1. nenhum nome de skill ou de plugin sobrevive
nomes=$(awk -F'\t' '!/^[ \t]*#/ && NF>=2 {print $1}' "$dir/nomes-de-skill.tsv")
achados=""
while IFS= read -r n; do
  [ -n "$n" ] || continue
  if printf '%s' "$msg" | grep -qiE "(^|[^[:alnum:]_-])$n([^[:alnum:]_-]|$)"; then achados="$achados $n"; fi
done <<< "$nomes"
[ -z "$achados" ] && ok "sem nome de skill na mensagem do juiz" || falha "nome de skill vazou:$achados"

# 2. os prompts do caso nao vao ao juiz
printf '%s' "$msg" | grep -qE 'prompt_novo|prompt_antigo|^especialista:|^fixture' && falha "frontmatter do caso vazou" || ok "sem prompt nem frontmatter do caso na mensagem do juiz"

# 3. o pedido neutro e a rubrica chegam
printf '%s' "$msg" | grep -q 'criar duas aberturas' && ok "pedido neutro presente" || falha "pedido neutro ausente"
printf '%s' "$msg" | grep -q 'Linha 1 com ate 15 palavras' && ok "rubrica presente" || falha "rubrica ausente"

# 4. os arquivos gravados pela execucao chegam, dos dois lados
printf '%s' "$msg" | grep -q 'ENTREGAVEL NOVO NO ARQUIVO' && ok "arquivo do lado novo coletado" || falha "arquivo do lado novo ausente"
printf '%s' "$msg" | grep -q 'ENTREGAVEL ANTIGO NO ARQUIVO' && ok "arquivo do lado antigo coletado" || falha "arquivo do lado antigo ausente"

# 5. arquivo identico a fixture nao e repetido
[ "$(printf '%s' "$msg" | grep -c 'material fixo')" -eq 0 ] && ok "arquivo inalterado da fixture nao repetido" || falha "arquivo inalterado repetido"

# 6. todo caso com baseline tem campo pedido, e nenhum pedido tem nome de skill
for c in "$raiz"/evals/cases/*/0?.md; do
  case "$c" in *_fumaca*|*_setup-legado*) continue;; esac
  p=$(awk -F': ' '$1=="pedido"{sub(/^pedido: /,""); print; exit}' "$c")
  [ -n "$p" ] || falha "caso sem pedido: $c"
done
[ "$falhou" -eq 0 ] && ok "todo caso tem campo pedido"
exit $falhou
