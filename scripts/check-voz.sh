#!/usr/bin/env bash
# uso: check-voz.sh <arquivo> [banidas.txt]
#
# Acusa travessao (U+2014, U+2013), emoji e, com o segundo argumento, termo da
# lista banida. Saida 1 se acusou algo, 0 se o arquivo esta limpo.
#
# Excecao de citacao, so para termo banido: texto entre aspas (retas, curvas
# ou angulares), linha de blockquote (comeca com ">") e bloco de codigo cercado
# (``` ou ~~~) nao contam como acerto de termo banido. Uma citacao e palavra
# de outro, e o comprador precisa poder citar a copy do proprio site sem a
# checagem disparar (o contexto-negocio manda citar a linha literal da fonte).
# Travessao e emoji nao entram na excecao: dentro ou fora de aspas, sao a
# tipografia do proprio autor. Aspas casam so dentro da mesma linha; aspas
# aninhadas ou sem fechamento nao engolem o resto do arquivo (o que fica fora
# de um par fechado continua sendo texto do autor). Ruling do controlador na
# Tarefa 5: a lista banida com flexoes passou a acusar citacao da copy do
# comprador em 6 arquivos do portao, e o mesmo grep e herdado por todos os
# especialistas.
arq="$1"; ban="${2:-}"; falhou=0
if perl -CSD -ne 'if (/[\x{2014}\x{2013}]/) { print "$.: $_"; $f=1 } END { exit($f?0:1) }' "$arq"; then echo "travessao"; falhou=1; fi
if perl -CSD -ne 'if (/[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}]/) { print "$.: $_"; $f=1 } END { exit($f?0:1) }' "$arq"; then echo "emoji"; falhou=1; fi
if [ -n "$ban" ] && [ -s "$ban" ]; then
  if perl -CSD -e '
    open my $b, "<", $ARGV[0]; my @p = grep { length } map { chomp; s/^\s+|\s+$//g; $_ } grep { !/^#/ } <$b>;
    open my $a, "<", $ARGV[1]; my $f = 0; my $cerca = 0;
    while (my $l = <$a>) {
      my $orig = $l;
      if ($l =~ /^\s*(`{3,}|~{3,})/) { $cerca = !$cerca; next }   # abre ou fecha bloco de codigo
      next if $cerca;                                              # dentro do bloco: citacao
      next if $l =~ /^\s*>/;                                       # blockquote: citacao
      $l =~ s/\x{201C}[^\x{201D}]*\x{201D}/ /g;                    # aspas curvas, fechadas na linha
      $l =~ s/\x{AB}[^\x{BB}]*\x{BB}/ /g;                          # aspas angulares
      $l =~ s/"[^"]*"/ /g;                                         # aspas retas
      for my $w (@p) { if ($l =~ /\b\Q$w\E\b/i) { print "$.: [$w] $orig"; $f = 1 } }
    }
    exit($f ? 0 : 1)' "$ban" "$arq"; then echo "banida"; falhou=1; fi
fi
exit $falhou
