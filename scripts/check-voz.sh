#!/usr/bin/env bash
# uso: check-voz.sh <arquivo> [banidas.txt]
arq="$1"; ban="${2:-}"; falhou=0
if perl -CSD -ne 'if (/[\x{2014}\x{2013}]/) { print "$.: $_"; $f=1 } END { exit($f?0:1) }' "$arq"; then echo "travessao"; falhou=1; fi
if perl -CSD -ne 'if (/[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}]/) { print "$.: $_"; $f=1 } END { exit($f?0:1) }' "$arq"; then echo "emoji"; falhou=1; fi
if [ -n "$ban" ] && [ -s "$ban" ]; then
  if perl -CSD -e '
    open my $b, "<", $ARGV[0]; my @p = grep { length } map { chomp; s/^\s+|\s+$//g; $_ } grep { !/^#/ } <$b>;
    open my $a, "<", $ARGV[1]; my $f = 0;
    while (my $l = <$a>) { for my $w (@p) { if ($l =~ /\b\Q$w\E\b/i) { print "$.: [$w] $l"; $f = 1 } } }
    exit($f ? 0 : 1)' "$ban" "$arq"; then echo "banida"; falhou=1; fi
fi
exit $falhou
