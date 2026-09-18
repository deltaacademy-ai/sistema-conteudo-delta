#!/usr/bin/env perl
# uso: flexionar-banidas.pl <banidas.txt> > <banidas-novo.txt>
#
# Acrescenta, logo abaixo de cada termo de uma palavra so, as flexoes comuns
# dele, uma por linha, como manda a regra de flexoes do compilador
# (skills/entrevista-voz/references/compilador.md, "Flexoes, uma por linha").
# Motivo: check-voz.sh casa o termo inteiro, sem radical, entao "destravar" na
# lista deixa "destravam" passar (caso real da Tarefa 5). Radical no casador
# acusaria uso legitimo ("destrav" pegaria "destravado" num relato), por isso
# a lista e que carrega as formas.
#
# O que gera:
# - verbo (palavra unica em -ar, -er, -ir, fora da lista de excecoes abaixo):
#   3a do singular e do plural do presente, gerundio, 3a do singular do
#   preterito, participio nos dois generos e numeros (as formas do exemplo do
#   compilador). A 1a do singular fica de fora de proposito: "gabarito" e
#   "fomento" sao substantivos comuns e acusariam uso legitimo. Verbos em -ear
#   recebem o -ei- do presente (desbloqueia, desbloqueiam).
# - adverbio, conjuncao e palavra em -mente: nada (invariaveis).
# - adjetivo em -o (fora -ao): feminino e os dois plurais. Em -dor, -tor, -sor:
#   feminino em -ora e os dois plurais.
# - outras palavras unicas: so o plural (-ao para -oes, -m para -ns, -r/-z/-s
#   para -es, -al/-el/-ol/-ul para -ais/-eis/-ois/-uis, -il para -is, -vel para
#   -veis, vogal para +s).
# - deixa como esta: comentario, linha vazia, expressao de mais de uma palavra,
#   termo com hifen (ingles, ex.: data-driven) e termo sem regra (ex.: turnkey).
# Idempotente: forma que ja existe no arquivo (sem distinguir caixa) nao entra
# de novo. Imprime no stderr a contagem de termos antes e depois.
use strict; use warnings; use utf8;
use open qw(:std :encoding(UTF-8));

my $arq = shift or die "uso: flexionar-banidas.pl <banidas.txt>\n";
open my $f, '<', $arq or die "$arq: $!\n";
my @linhas = <$f>; close $f; chomp @linhas;

# palavras em -ar/-er/-ir que nao sao verbo (recebem so o plural em -es)
my %nao_verbo = map { $_ => 1 } qw(pilar lugar exemplar singular regular particular popular similar familiar celular escolar militar solar polar auxiliar elementar espetacular poder prazer mulher colher saber dever mister porvir lazer parecer);
# palavras invariaveis: adverbio e conjuncao nao flexionam
my %invariavel = map { $_ => 1 } qw(ademais outrossim destarte assim);

my %tem; for (@linhas) { next if /^\s*#/ || /^\s*$/; my $t = lc $_; $t =~ s/^\s+|\s+$//g; $tem{$t} = 1 }
my $antes = scalar keys %tem;

sub flexoes {
  my $w = shift; my @f;
  return () if $w =~ /-/ || $w =~ /\s/ || $invariavel{$w} || $w =~ /mente$/;
  if ($w =~ /(ar|er|ir)$/ && !$nao_verbo{$w}) {
    my ($raiz, $tema) = ($w =~ /^(.*)([aei])r$/);
    my $ear = ($w =~ /ear$/);
    my $r1 = $ear ? "${raiz}i" : $raiz;           # radical do presente (desbloquei-)
    my $v3 = $tema eq 'a' ? 'a' : 'e';             # 3a sing presente
    my $v3p = $tema eq 'a' ? 'am' : 'em';          # 3a plural presente
    my $ger = { a => 'ando', e => 'endo', i => 'indo' }->{$tema};
    my $pret = { a => 'ou', e => 'eu', i => 'iu' }->{$tema};
    my $part = $tema eq 'a' ? 'ad' : 'id';
    push @f, "$r1$v3", "$r1$v3p", "$raiz$ger", "$raiz$pret",
             "$raiz${part}o", "$raiz${part}a", "$raiz${part}os", "$raiz${part}as";
    return @f;
  }
  if ($w =~ /ão$/) { (my $p = $w) =~ s/ão$/ões/; return ($p) }
  if ($w =~ /o$/) { (my $b = $w) =~ s/o$//; return ("${b}a", "${b}os", "${b}as") }
  if ($w =~ /(d|t|s)or$/) { return ("${w}a", "${w}es", "${w}as") }
  if ($w =~ /m$/) { (my $p = $w) =~ s/m$/ns/; return ($p) }
  if ($w =~ /[rz]$/) { return ("${w}es") }
  if ($w =~ /vel$/) { (my $p = $w) =~ s/vel$/veis/; return ($p) }
  if ($w =~ /al$/) { (my $p = $w) =~ s/al$/ais/; return ($p) }
  if ($w =~ /el$/) { (my $p = $w) =~ s/el$/éis/; return ($p) }
  if ($w =~ /ol$/) { (my $p = $w) =~ s/ol$/óis/; return ($p) }
  if ($w =~ /ul$/) { (my $p = $w) =~ s/ul$/uis/; return ($p) }
  if ($w =~ /il$/) { (my $p = $w) =~ s/il$/is/; return ($p) }
  if ($w =~ /s$/) { return () }                    # ja plural ou invariavel
  if ($w =~ /[aeiouáéíóúâêôãõ]$/) { return ("${w}s") }
  return ();
}

# Idempotencia: uma linha que ja e flexao de outro termo do arquivo (ex.:
# "alavanca", gerada de "alavancar" numa passada anterior) nao vira base de
# novas formas, senao cada passada acrescentaria mais uma camada.
my %derivada;
for my $t (keys %tem) { next if $t =~ /\s/; $derivada{$_} = 1 for flexoes($t) }

my $depois = $antes;
for my $l (@linhas) {
  print "$l\n";
  next if $l =~ /^\s*#/ || $l =~ /^\s*$/;
  (my $t = lc $l) =~ s/^\s+|\s+$//g;
  next if $t =~ /\s/ || $derivada{$t};
  for my $fx (flexoes($t)) {
    next if $tem{$fx}; $tem{$fx} = 1; $depois++;
    print "$fx\n";
  }
}
print STDERR "termos antes: $antes, depois: $depois\n";
