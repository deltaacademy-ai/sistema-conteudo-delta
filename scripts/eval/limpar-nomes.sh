#!/usr/bin/env bash
set -euo pipefail
# uso: <texto no stdin> | limpar-nomes.sh
# Tira nome de skill e de plugin do texto que vai ao juiz. Ver limpar-nomes.pl.
dir=$(cd "$(dirname "$0")" && pwd)
exec perl -CSD "$dir/limpar-nomes.pl" "$dir/nomes-de-skill.tsv"
