#!/usr/bin/env bash
# uso: check-voz.sh <arquivo> [banidas.txt]
#      check-voz.sh --json <arquivo.json> [banidas.txt]
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
#
# Modo --json (ruling do controlador na Tarefa 11): num JSON todo valor esta
# entre aspas, e a excecao de citacao deixava passar qualquer termo. Nesse modo
# o script extrai os valores de texto (recursivamente, com o caminho de cada
# um, indice de lista a partir de 1) e confere cada um como prosa comum: as
# aspas da sintaxe JSON nao contam, e a excecao vale so para citacao marcada
# dentro do valor (trecho entre aspas no proprio texto). O acerto sai com o
# caminho no lugar do numero da linha, por exemplo "slides[3].corpo: [termo] ...".
modo=texto
if [ "${1:-}" = "--json" ]; then modo=json; shift; fi
arq="${1:-}"; ban="${2:-}"
if [ -z "$arq" ] || [ ! -f "$arq" ]; then echo "uso: check-voz.sh [--json] <arquivo> [banidas.txt]"; exit 1; fi

# Com CHECK_VOZ_PREFIXO=1 no ambiente, cada linha e "rotulo<TAB>texto": o rotulo (caminho no JSON,
# numero do slide no texto renderizado) sai na mensagem mas nao entra na conferencia, senao termo
# banido numa chave viraria acerto atribuido a um valor limpo.
checar() {
  local arq="$1" ban="$2" falhou=0
  if perl -CSD -ne 'my $t = $_; $t =~ s/^[^\t]*\t// if $ENV{CHECK_VOZ_PREFIXO}; if ($t =~ /[\x{2014}\x{2013}]/) { print "$.: $_"; $f=1 } END { exit($f?0:1) }' "$arq"; then echo "travessao"; falhou=1; fi
  if perl -CSD -ne 'my $t = $_; $t =~ s/^[^\t]*\t// if $ENV{CHECK_VOZ_PREFIXO}; if ($t =~ /[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}]/) { print "$.: $_"; $f=1 } END { exit($f?0:1) }' "$arq"; then echo "emoji"; falhou=1; fi
  if [ -n "$ban" ] && [ -s "$ban" ]; then
    if perl -CSD -e '
      open my $b, "<", $ARGV[0]; my @p = grep { length } map { chomp; s/^\s+|\s+$//g; $_ } grep { !/^#/ } <$b>;
      open my $a, "<", $ARGV[1]; my $f = 0; my $cerca = 0;
      while (my $l = <$a>) {
        my $orig = $l;
        $l =~ s/^[^\t]*\t// if $ENV{CHECK_VOZ_PREFIXO};                # rotulo nao e texto
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
  return $falhou
}

if [ "$modo" = texto ]; then
  checar "$arq" "$ban"; exit $?
fi

# Modo json: extrai os valores de texto para um arquivo temporario, um valor por
# linha (valor com quebra de linha vira uma linha por trecho), cada linha com o
# caminho na frente. A excecao de aspas do checador entao so enxerga as aspas que
# estao dentro do proprio texto, nunca as da sintaxe.
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
if ! perl -MJSON::PP -e '
  binmode STDOUT, ":utf8";
  local $/; my $bruto = <STDIN>;
  my $j = eval { JSON::PP->new->utf8->decode($bruto) };
  if ($@) { print STDERR "json invalido\n"; exit 2 }
  sub anda {
    my ($v, $cam) = @_;
    if (ref $v eq "HASH")  { anda($v->{$_}, $cam eq "" ? $_ : "$cam.$_") for sort keys %$v }
    elsif (ref $v eq "ARRAY") { anda($v->[$_], $cam . "[" . ($_ + 1) . "]") for 0 .. $#$v }
    elsif (defined $v && !ref $v) { print "$cam\t$_\n" for split /\r?\n/, $v }
  }
  anda($j, "");' < "$arq" > "$tmp"; then echo "json invalido: $arq"; exit 1; fi
CHECK_VOZ_PREFIXO=1 checar "$tmp" "$ban" | sed -E -e 's/^[0-9]+: (\[[^]]*\] )([^\t]*)\t/\2: \1/' -e 's/^[0-9]+: ([^\t]*)\t/\1: /'
exit "${PIPESTATUS[0]}"
