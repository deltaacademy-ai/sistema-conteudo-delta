#!/usr/bin/env bash
set -euo pipefail
# uso: datas-relativas.sh <caso.md> <saida-dir>
#
# Copia o caso e a fixture que ele cita para <saida-dir> (cases/<especialista>/NN.md
# e fixtures/<fixture>/, a convencao de pastas que o run-case.sh espera) e troca
# {HOJE} e {HOJE-N} (N dias antes de hoje, AAAA-MM-DD, calendario local) no
# prompt_novo do caso copiado e em todo arquivo de texto da fixture copiada.
# O campo `fixture` da copia continua sendo o nome da fixture: ele passa a
# apontar para <saida-dir>/fixtures/<fixture>, porque o run-case.sh resolve a
# fixture a partir da pasta do caso. Imprime o caminho do caso copiado.
# O caso e a fixture do repositorio guardam os marcadores e nunca sao alterados.
caso="$1"; saida="$2"
[ -f "$caso" ] || { echo "caso nao existe: $caso" >&2; exit 1; }
raiz=$(cd "$(dirname "$caso")/../.." && pwd)
fx=$(awk -F': ' '$1=="fixture"{sub(/^[^:]*: /,""); print; exit}' "$caso")
[ -n "$fx" ] && [ -d "$raiz/fixtures/$fx" ] || { echo "fixture nao existe: $raiz/fixtures/$fx" >&2; exit 1; }
esp=$(basename "$(dirname "$caso")")
mkdir -p "$saida/cases/$esp" "$saida/fixtures"
rm -rf "$saida/fixtures/$fx"; cp -R "$raiz/fixtures/$fx" "$saida/fixtures/$fx"
copia="$saida/cases/$esp/$(basename "$caso")"
cp "$caso" "$copia"

troca() { # le stdin, troca os marcadores, escreve em stdout
  perl -pe '
    use POSIX qw(strftime mktime);
    s/\{HOJE(?:-(\d+))?\}/ my @t = localtime; strftime("%F", localtime(mktime(0,0,12,$t[3]-($1\/\/0),$t[4],$t[5]))) /ge'
}

perl -pe '
  BEGIN { use POSIX qw(strftime mktime) }
  if (/^prompt_novo: /) { s/\{HOJE(?:-(\d+))?\}/ my @t = localtime; strftime("%F", localtime(mktime(0,0,12,$t[3]-($1\/\/0),$t[4],$t[5]))) /ge }' \
  "$copia" > "$copia.tmp"
mv "$copia.tmp" "$copia"

while IFS= read -r -d '' f; do
  if [ -s "$f" ] && grep -Iq . "$f"; then   # so texto; binario fica como esta
    troca < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  fi
done < <(find "$saida/fixtures/$fx" -type f -print0)
echo "$copia"
