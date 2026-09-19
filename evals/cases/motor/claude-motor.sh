#!/usr/bin/env bash
# uso: CLAUDE_ISOLADO=evals/cases/motor/claude-motor.sh scripts/eval/run-case.sh ...
#
# Wrapper do run-case.sh para o portao do motor. O run-case.sh so libera a
# leitura das skills do plugin e o check-voz.sh, o que basta para um
# especialista de texto. O fluxo do motor precisa de mais: o revisor roda em
# subagente (Agent), o carrossel-render chama node com render-carrossel.mjs,
# o carrossel-roteiro valida o JSON com jq, o linkedin-post conta caracteres
# com wc, e o publicar copia PNG e PDF com mkdir e cp. Numa sessao real o
# comprador aprova esses comandos na hora; em `claude -p` nao existe prompt,
# e o comando negado viraria "nao pude rodar". Este wrapper acrescenta so
# essas liberacoes a lista de --allowedTools que o run-case.sh ja monta,
# inserindo-as antes de --permission-mode (a lista e variadica e termina na
# proxima flag), e delega ao claude-isolado.sh, que continua isolando a
# configuracao pessoal do dono da maquina.
#
# Limite conhecido: a liberacao e por prefixo, e comando composto (a cadeia
# `check-voz.sh ...; echo "codigo $?"; rm -f rascunho` que os especialistas
# prescrevem) nao casa com prefixo nenhum quando o host avalia cada parte.
# Em r1 duas execucoes registraram "o comando com echo nao foi autorizado" e
# rodaram o script sozinho, lendo o codigo pela saida. E o mesmo que o
# comprador ve numa sessao real quando recusa o composto; as skills dizem o
# que fazer nesse caso (motor, "O que a pessoa precisa liberar").
dir=$(cd "$(dirname "$0")" && pwd); raiz=$(cd "$dir/../../.." && pwd)
args=(); plugin=""; prev=""
for a in "$@"; do
  [ "$prev" = "--plugin-dir" ] && plugin=$(cd "$a" && pwd)
  if [ "$a" = "--permission-mode" ]; then
    args+=("Agent" "Task"
      "Bash(node $plugin/scripts/render-carrossel.mjs:*)"
      "Bash(jq:*)" "Bash(wc:*)" "Bash(mkdir:*)" "Bash(cp:*)" "Bash(ls:*)" "Bash(cmp:*)" "Bash(rm -f:*)")
  fi
  args+=("$a"); prev="$a"
done
exec "$raiz/scripts/eval/claude-isolado.sh" "${args[@]}"
