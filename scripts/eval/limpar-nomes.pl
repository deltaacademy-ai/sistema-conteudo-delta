use strict;
use warnings;
use utf8;

# Troca nome de skill e de plugin por um substituto neutro, para o juiz nao
# reconhecer qual sistema gerou cada saida. Tabela em nomes-de-skill.tsv.
# Ordem por tamanho decrescente, para "squad-legado" nao virar "time-legado".
# A capitalizacao inicial do texto original e preservada.

my $tabela = shift @ARGV or die "uso: limpar-nomes.pl <nomes-de-skill.tsv>\n";
open my $t, "<:encoding(UTF-8)", $tabela or die "nao abriu $tabela: $!\n";
my @pares;
while (my $l = <$t>) {
    chomp $l;
    next if $l =~ /^\s*#/ or $l !~ /\S/;
    my ($nome, $novo) = split /\t/, $l, 2;
    next unless defined $novo and length $nome;
    push @pares, [$nome, $novo];
}
close $t;
@pares = sort { length($b->[0]) <=> length($a->[0]) } @pares;

local $/;
my $texto = <STDIN>;
$texto = "" unless defined $texto;
for my $par (@pares) {
    my ($nome, $novo) = @$par;
    $texto =~ s{\b(\Q$nome\E)\b}{
        my $achado = $1;
        my $troca  = $novo;
        $troca = ucfirst($troca) if $achado =~ /^\p{Lu}/;
        $troca;
    }gie;
}
print $texto;
