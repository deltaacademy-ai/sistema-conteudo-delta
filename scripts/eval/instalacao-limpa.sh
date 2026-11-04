#!/usr/bin/env bash
# Teste de instalacao limpa: simula a maquina de quem vai instalar pela primeira vez.
# Tudo roda em HOME temporario ($H). Nao toca no HOME real nem em ~/.claude.
#
# uso: instalacao-limpa.sh
#   MANTER=1        nao apaga $H no fim (para testar a atualizacao depois)
#   COM_CHROMIUM=1  roda o comando de chromium que o check-up imprime (so se ele
#                   instalar dentro de $H); confere "ok chromium" depois
#
# Credencial: o gh guarda o token no Keychain, que um HOME falso nao alcanca. O
# token sai do gh real direto para uma variavel de memoria (GH_TOKEN) e so vale
# para git ls-remote e claude plugin install (variavel nao exportada). Nunca e impresso nem gravado. Toda saida de
# comando passa por mascara antes de aparecer.
# Compativel com o bash 3.2 do macOS.
set -u

dev=$(cd "$(dirname "$0")/../.." && pwd)
real_home="$HOME"
gh_bin=$(command -v gh || true)
falhas=0
pulados=""

mascara() { sed -E 's/(gh[pousr]_|github_pat_|sk-ant-)[A-Za-z0-9_*-]+/[removido]/g; s/(Bearer|token|password)[ =:]+[A-Za-z0-9._-]{16,}/\1 [removido]/g'; }
ok()   { echo "ok    $1"; }
erro() { echo "FALHA $1"; falhas=$((falhas+1)); }
mostra() { mascara < "$1" | sed 's/^/      /' | head -${2:-15}; }

[ -n "$gh_bin" ] || { echo "FALHA gh nao encontrado"; exit 1; }

# Token em memoria, lido com o HOME real. Nada disso vai para arquivo.
tok=$(HOME="$real_home" "$gh_bin" auth token 2>/dev/null || true)
if [ -z "$tok" ]; then echo "FALHA gh real sem login; rode gh auth login no HOME real antes"; exit 1; fi
unset GH_ENTERPRISE_TOKEN GITHUB_TOKEN GITHUB_ENTERPRISE_TOKEN

H=$(mktemp -d) || { echo "FALHA mktemp"; exit 1; }
case "$H" in /*/tmp.*|/tmp/*|/private/tmp/*|/var/folders/*) ;; *) echo "FALHA H fora do diretorio temporario: $H"; exit 1 ;; esac
[ -d "$H" ] && [ "$H" != "/" ] || { echo "FALHA H invalido"; exit 1; }
log="$H/.log-teste"; mkdir -p "$log"
cleanup() {
  if [ "${MANTER:-0}" = "1" ]; then
    for f in "$log"/*; do [ -f "$f" ] && mascara < "$f" > "$f.m" && mv "$f.m" "$f"; done
    echo "MANTER=1: $H ficou. O script grava ali so o .gitconfig (linha do credential.helper do gh),"
    echo "  o plugin, a pasta conteudo, o cache do npm e os logs em .log-teste (com a mascara aplicada)."
    if grep -rlF "$tok" "$H" >/dev/null 2>&1; then
      echo "  ATENCAO: o token real aparece em arquivos de $H:"
      grep -rlF "$tok" "$H" 2>/dev/null | sed 's/^/    /'
    else
      echo "  varredura: o token real nao aparece em nenhum arquivo de $H"
    fi
    echo "  (arquivos do proprio plugin com ghp_ de exemplo nos casos de teste nao contam)"
    echo "  para apagar: rm -rf \"$H\""
  else
    rm -rf "$H"
    [ -e "$H" ] && echo "FALHA nao consegui apagar $H" || echo "ok    9 $H apagado"
  fi
}
trap cleanup EXIT
trap 'exit 130' INT TERM HUP

# Ambiente do teste: HOME falso, sem agente SSH (a pessoa nova nao tem chave:
# o Claude Code tenta SSH primeiro e cai para HTTPS), sem pasta de config do claude.
export HOME="$H"
unset SSH_AUTH_SOCK CLAUDE_CONFIG_DIR
export GIT_TERMINAL_PROMPT=0
# O gitconfig de sistema da maquina de desenvolvimento chama o osxkeychain, que
# trava sem o Keychain do HOME real. Fora do teste, uma pessoa nova tem o dele.
export GIT_CONFIG_NOSYSTEM=1
# O ssh acha ~/.ssh pelo usuario do sistema (getpwuid), nao pelo $HOME, e -F /dev/null
# nao impede as chaves padrao: IdentityFile=/dev/null e IdentitiesOnly=yes impedem.
# Sem este bloqueio o teste usaria a chave SSH real e nao provaria o caminho HTTPS.
export GIT_SSH_COMMAND='ssh -F /dev/null -o IdentityFile=/dev/null -o IdentityAgent=none -o IdentitiesOnly=yes -o BatchMode=yes -o UserKnownHostsFile=/dev/null'
# Nenhum passo de rede pode travar o teste.
limite() { perl -e 'alarm shift; exec @ARGV' "$@"; }

# 1. credential helper do gh no gitconfig do HOME temporario
git config --global credential.helper "!$gh_bin auth git-credential"
if [ "$(git config --global credential.helper)" = "!$gh_bin auth git-credential" ]; then ok "1 credential helper do gh gravado no HOME temporario"; else erro "1 credential helper nao gravou"; fi

# 2. git ls-remote
if GH_TOKEN="$tok" limite 60 git ls-remote https://github.com/deltaacademy-ai/sistema-conteudo-delta.git HEAD > "$log/lsremote" 2>&1 && grep -qE '^[0-9a-f]{40}[[:space:]]+HEAD$' "$log/lsremote"; then
  ok "2 git ls-remote devolve uma linha com HEAD"
else
  erro "2 git ls-remote sem linha HEAD"; mostra "$log/lsremote"
fi

# 3. claude plugin install
# Limitacao: o Claude Code clona via git e o helper `gh auth git-credential` le o
# GH_TOKEN do ambiente. Por isso este item prova o transporte HTTPS sem SSH, mas nao
# o fluxo `gh auth setup-git` do INSTALAR.md: prova-lo exigiria gravar credencial em $H.
# Esse fluxo so e provado no roteiro da pessoa real.
GH_TOKEN="$tok" limite 240 claude plugin install sistema-conteudo --marketplace deltaacademy-ai/sistema-conteudo-delta > "$log/install" 2>&1 < /dev/null
cod=$?
if [ "$cod" -ne 0 ] && grep -Eqi 'not logged in|/login|please log ?in|sign in|authenticat' "$log/install"; then
  erro "3 login exigido (o item e os seguintes passam para o roteiro da pessoa real)"; mostra "$log/install"
  exit 1
fi
if [ "$cod" -eq 0 ]; then ok "3 claude plugin install saiu com 0"; else erro "3 claude plugin install saiu com $cod"; mostra "$log/install"; fi
remoto=$(git -C "$H/.claude/plugins/marketplaces/sistema-conteudo" remote get-url origin 2>/dev/null | sed -E 's#//[^@/]*@#//[removido]@#')
echo "      transporte do clone do marketplace: ${remoto:-desconhecido}"
case "$remoto" in https://*) ok "3 clone do marketplace caiu para HTTPS sem chave SSH" ;; *) erro "3 clone nao ficou em HTTPS: ${remoto:-sem remoto}" ;; esac

# 4. claude plugin list
limite 60 claude plugin list --json > "$log/list.json" 2>&1 < /dev/null
dir=$(jq -r '.[] | select(.id=="sistema-conteudo@sistema-conteudo" and .enabled==true) | .installPath' "$log/list.json" 2>/dev/null | head -1)
versao=$(jq -r '.[] | select(.id=="sistema-conteudo@sistema-conteudo") | .version' "$log/list.json" 2>/dev/null | head -1)
if [ -n "$dir" ] && [ -d "$dir" ]; then ok "4 plugin list mostra sistema-conteudo@sistema-conteudo habilitado (versao $versao)"; else erro "4 sistema-conteudo nao aparece habilitado"; mostra "$log/list.json"; exit 1; fi
case "$dir" in "$H"/.claude/plugins/*) ok "4 instalado dentro do HOME temporario" ;; *) erro "4 caminho fora de $H"; exit 1 ;; esac

# 5. claude plugin validate na pasta instalada
if claude plugin validate "$dir" > "$log/validate" 2>&1 < /dev/null; then ok "5 claude plugin validate sai com 0 na pasta instalada"; else erro "5 claude plugin validate falhou"; mostra "$log/validate"; fi

# 6. contexto-modelo instalado -> $H/conteudo, git init e commit
modelo="$H/.claude/plugins/marketplaces/sistema-conteudo/contexto-modelo"
if [ -d "$modelo" ] && cp -R "$modelo" "$H/conteudo" && (cd "$H/conteudo" && git init -q && git add -A && git -c user.name=teste -c user.email=teste@example.com commit -q -m inicio); then
  ok "6 contexto-modelo copiado pelo caminho do INSTALAR.md, git init e commit"
else
  erro "6 cp do contexto-modelo, git init ou commit falhou ($modelo)"; exit 1
fi

# 7. check-up da copia instalada, em $H/conteudo
(cd "$H/conteudo" && bash "$dir/scripts/checkup.sh") > "$log/checkup" 2>&1
cod=$?
n=0
grep -q '^falta voz.md' "$log/checkup" || n=1
grep -q '^falta icp.md' "$log/checkup" || n=1
grep -q '^pendencias: 2$' "$log/checkup" || n=1
[ "$cod" -eq 1 ] || n=1
if grep -qF "$dev" "$log/checkup"; then n=1; echo "      a saida cita o repositorio de desenvolvimento ($dev)"; fi
if [ "$n" -eq 0 ]; then ok "7 checkup.sh: falta voz.md, falta icp.md, pendencias: 2, codigo 1, sem caminho do repositorio de desenvolvimento"; else erro "7 checkup.sh fora do esperado (codigo $cod)"; mostra "$log/checkup" 30; fi
echo "      --- saida do checkup.sh ---"; mostra "$log/checkup" 30

# 8. chromium (opcional)
if [ "${COM_CHROMIUM:-0}" = "1" ]; then
  linha=$(grep '^opcional chromium' "$log/checkup" | head -1)
  cmd=$(printf '%s' "$linha" | sed -n 's/.*instale com: //p')
  case "$cmd" in
    "cd \"$H/"*)
      (eval "$cmd") > "$log/chromium" 2>&1 < /dev/null
      (cd "$H/conteudo" && bash "$dir/scripts/checkup.sh") > "$log/checkup2" 2>&1 || true
      if grep -q '^ok chromium' "$log/checkup2"; then ok "8 comando do chromium instalou dentro de \$H e o check-up mostra ok chromium"; else erro "8 apos o comando, o check-up nao mostra ok chromium"; mostra "$log/chromium" 20; fi ;;
    "") if grep -q '^ok chromium' "$log/checkup"; then ok "8 chromium ja estava ok"; else erro "8 sem linha opcional chromium com comando"; fi ;;
    *) erro "8 nao rodei: o comando impresso nao fica dentro de \$H: $cmd" ;;
  esac
else
  echo "pula  8 chromium (use COM_CHROMIUM=1)"
fi

echo
if [ "$falhas" -eq 0 ]; then echo "resultado: itens 1 a 7 ok"; else echo "resultado: $falhas FALHA(s)"; fi
exit $((falhas > 0))
