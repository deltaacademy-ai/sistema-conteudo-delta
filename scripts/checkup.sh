#!/usr/bin/env bash
# uso: checkup.sh [pasta-de-contexto]   (padrao: a pasta atual)
#
# Check-up da instalacao e da pasta de contexto. Uma linha por item:
#   ok <item>
#   falta <item>: <o que fazer>       (obrigatorio; conta como pendencia)
#   opcional <item>: <o que fazer>    (o sistema funciona sem, com limite)
#   andamento <item>: <o que fazer>   (aviso de trabalho comecado; nao conta como pendencia)
# Depois, as pecas em aberto da base e a contagem de pendencias:
#   pecas em aberto: <N> rascunho, <M> aprovado
#   pendencias: <K>
# Saida 0 com K = 0, 1 com K > 0.
#
# Arquivo vazio e o que nao existe ou tem ate 3 linhas (o cabecalho e a linha
# de instrucao do contexto-modelo), a mesma regra do motor, Etapa 0.
# Nenhum comando toca em rede nem sai da pasta de contexto e da raiz do plugin.
# Compativel com o bash 3.2 do macOS.
pasta="${1:-.}"
raiz=$(cd "$(dirname "$0")/.." && pwd)
pend=0

ok()       { echo "ok $1"; }
falta()    { echo "falta $1: $2"; pend=$((pend+1)); }
opcional() { echo "opcional $1: $2"; }
andamento() { echo "andamento $1: $2"; }

vazio() { # vazio <arquivo>: verdadeiro se ausente ou com ate 3 linhas
  [ ! -f "$1" ] || [ "$(grep -c '' < "$1")" -le 3 ]
}

# Obrigatorios
if command -v git >/dev/null 2>&1; then ok git
else falta git "instale com: brew install git gh"; fi

if vazio "$pasta/voz.md"; then falta voz.md "peça \"quero começar o sistema de conteúdo\" e faça a entrevista de voz (especialista entrevista-voz)"
else ok voz.md; fi

# Entrevista comecada e nao compilada: voz-bruta.md com respostas (mais de 3 linhas)
# e voz.md ainda vazio.
if vazio "$pasta/voz.md" && [ -f "$pasta/voz-bruta.md" ] && ! vazio "$pasta/voz-bruta.md"; then
  andamento entrevista-voz "voz-bruta.md tem respostas e voz.md está vazio; peça \"quero começar o sistema de conteúdo\" para retomar"
fi

if vazio "$pasta/icp.md"; then falta icp.md "faça a conversa sobre o seu negócio (especialista contexto-negocio)"
else ok icp.md; fi

# Opcionais
if command -v node >/dev/null 2>&1; then
  ok node
  if (cd "$raiz" && node -e 'const p=require("playwright");process.exit(require("fs").existsSync(p.chromium.executablePath())?0:1)' >/dev/null 2>&1); then
    ok chromium
  else
    opcional chromium "sem ele o carrossel sai em HTML; instale com: cd \"$raiz\" && npm install && npx playwright install chromium"
  fi
else
  opcional node "sem ele o carrossel sai em HTML; instale com: brew install node"
  opcional chromium "instale o node primeiro (brew install node), depois: npx playwright install chromium"
fi

if command -v jq >/dev/null 2>&1; then ok jq
else opcional jq "sem ele o JSON do carrossel é conferido por leitura; instale com: brew install jq"; fi

if vazio "$pasta/prova.md"; then opcional prova.md "sem ele a peça marca [FALTA] onde precisaria de prova; preenche com o especialista contexto-negocio"
else ok prova.md; fi

if vazio "$pasta/marca.md"; then opcional marca.md "sem ele o carrossel usa a identidade padrão; preenche com o especialista contexto-negocio"
else ok marca.md; fi

if vazio "$pasta/banidas.txt"; then opcional banidas.txt "sem ele a checagem de termo proibido não roda; o especialista entrevista-voz gera"
else ok banidas.txt; fi

if vazio "$pasta/pautas.md"; then opcional pautas.md "sem ele não há lista de pautas; peça \"me dá pautas\" e o especialista radar-pautas grava"
else ok pautas.md; fi

# Pecas em aberto: coluna Status achada pelo nome no cabecalho; trechos entre
# aspas (o Gancho) saem antes de dividir a linha, porque podem conter "|".
contagem=$(awk -F'|' '
  /^\|/ {
    linha = $0; gsub(/"[^"]*"/, "", linha)
    n = split(linha, c, "|")
    if (!col) {
      for (i = 1; i <= n; i++) { t = c[i]; gsub(/^[ \t]+|[ \t]+$/, "", t); if (tolower(t) == "status") col = i }
      next
    }
    if (linha ~ /^\|[ \t:-]*\|[ \t:|-]*$/) next
    t = c[col]; gsub(/^[ \t]+|[ \t]+$/, "", t); t = tolower(t)
    if (t ~ /^rascunho/) r++
    else if (t ~ /^aprovado/) a++
  }
  END { printf "%d %d", r, a }
' "$pasta/base-conteudo.md" 2>/dev/null)
[ -n "$contagem" ] || contagem="0 0"
echo "pecas em aberto: ${contagem% *} rascunho, ${contagem#* } aprovado"

echo "pendencias: $pend"
[ "$pend" -eq 0 ]
