# Funcoes compartilhadas por reconhecimento.sh e preferencia-voz.sh.
# Uso: dir=$(cd "$(dirname "$0")" && pwd); . "$dir/briefing-lib.sh"
# Espera as variaveis: dir (pasta dos scripts), arq (pasta de artefatos), extrator (modelo).

# extrair_reais <materiais-dir>: grava $arq/textos/real-1..3.txt com o primeiro
# bloco <!-- ai:start --> a <!-- ai:end --> de cada arquivo (ou o arquivo inteiro).
extrair_reais() {
  local mat="$1" n=0 f
  mkdir -p "$arq/textos"
  for f in $(find "$mat" -type f -name '*.md' | LC_ALL=C sort); do
    n=$((n+1)); [ $n -le 3 ] || break
    perl -ne 'if (/<!-- ai:start -->/) { $in=1; next } if (/<!-- ai:end -->/ && $in) { exit } print if $in' "$f" > "$arq/textos/real-$n.txt"
    [ -s "$arq/textos/real-$n.txt" ] || cp "$f" "$arq/textos/real-$n.txt"
  done
  [ "$n" -ge 3 ] || { echo "precisa de 3 materiais, achou $n" >&2; return 1; }
}

# sobreposicao <original> <briefing>: quantas sequencias de 5 palavras do original aparecem no briefing.
sobreposicao() {
  perl -CSD -e '
    sub toks { my $t = lc shift; $t =~ s/[^\p{L}\p{N}\s]/ /g; return grep { length } split /\s+/, $t }
    local $/; open my $o, "<", $ARGV[0]; my @a = toks(<$o>); open my $b, "<", $ARGV[1]; my @c = toks(<$b>);
    my %g; for my $i (0 .. $#a-4) { $g{join " ", @a[$i..$i+4]} = 1 }
    my $hit = 0; for my $i (0 .. $#c-4) { $hit++ if $g{join " ", @c[$i..$i+4]} }
    print "$hit\n"' "$1" "$2"
}

# extrair_briefings: grava $arq/briefings/briefing-1..3.txt a partir dos reais, sem frase do
# original (prompt reconhecimento-briefing.md, modelo $extrator). Se a variavel BRIEFINGS_CACHE
# apontar para uma pasta com os 3 arquivos, copia de la em vez de extrair; se apontar para uma
# pasta sem eles, extrai e guarda la tambem, para as proximas execucoes reutilizarem.
# Define a variavel aviso com as sobreposicoes que sobraram.
extrair_briefings() {
  local i h
  mkdir -p "$arq/briefings"; aviso=""
  if [ -n "${BRIEFINGS_CACHE:-}" ] && [ -s "$BRIEFINGS_CACHE/briefing-1.txt" ] && [ -s "$BRIEFINGS_CACHE/briefing-2.txt" ] && [ -s "$BRIEFINGS_CACHE/briefing-3.txt" ]; then
    cp "$BRIEFINGS_CACHE"/briefing-[123].txt "$arq/briefings/"
    aviso=" briefings do cache $BRIEFINGS_CACHE;"
    return 0
  fi
  _extrair() {
    ( cd "$(mktemp -d)" && "$dir/claude-isolado.sh" --model "$extrator" \
        --append-system-prompt "$(cat "$dir/reconhecimento-briefing.md")" --output-format json "$(cat "$arq/textos/real-$1.txt")" ) \
      | jq -r '.result' | sed '/^```/d' > "$arq/briefings/briefing-$1.txt"
    [ -s "$arq/briefings/briefing-$1.txt" ]
  }
  for i in 1 2 3; do
    _extrair $i || _extrair $i || { echo "extracao do briefing $i falhou" >&2; return 1; }
    h=$(sobreposicao "$arq/textos/real-$i.txt" "$arq/briefings/briefing-$i.txt")
    if [ "$h" -gt 0 ]; then
      _extrair $i || true
      h=$(sobreposicao "$arq/textos/real-$i.txt" "$arq/briefings/briefing-$i.txt")
      [ "$h" -gt 0 ] && aviso="$aviso briefing-$i com $h sequencias de 5 palavras do original;"
    fi
  done
  if [ -n "${BRIEFINGS_CACHE:-}" ]; then mkdir -p "$BRIEFINGS_CACHE"; cp "$arq"/briefings/briefing-[123].txt "$BRIEFINGS_CACHE/"; fi
}
