#!/usr/bin/env bash
set -u
# uso: validar-voz.sh <voz.md> [banidas.txt]
#
# Checagem mecanica de um voz.md compilado pelo especialista entrevista-voz, e do
# banidas.txt que sai junto. Falha alto (saida 1, uma linha em caixa alta por
# problema) quando:
# - TAMANHO: o voz.md passa de 17.500 caracteres (teto do compilador; cerca de
#   5.000 tokens a 3,5 caracteres por token em portugues com XML). A contagem e
#   em caracteres, com espacos e quebras de linha, nunca em palavras ou bytes:
#   contagem de palavras deixou 8 de 10 arquivos acima do teto na Tarefa 4.
#   TETO_VOZ no ambiente troca o teto (so para teste).
# - ESTRUTURA: nao comeca em <sobre_mim>, nao termina em </sobre_mim>, ou falta
#   algum dos 16 blocos do compilador na ordem.
# - CHECK-VOZ: travessao ou emoji (scripts/check-voz.sh) no voz.md ou no banidas.txt.
# - BANIDAS: linha sem # com mais de 4 palavras. O check-voz.sh casa a linha
#   inteira contra o texto, entao uma oracao nunca dispara e so ocupa o arquivo.
#   Tambem falha quando nao ha nenhuma linha sem #: um banidas.txt so de
#   comentario deixa a checagem mecanica dos outros especialistas sem nada para
#   conferir (regressao vista na rodada 3 da Tarefa 4). E falha em linha feita
#   so de palavra funcional ou verbo comum (lista em palavras-comuns.txt) ou de
#   uma palavra unica com menos de 4 letras: "para", "esta", "comenta" como termo
#   ativo acusariam uso legitimo em quase toda peca (rodada 4 da Tarefa 4).
dir=$(cd "$(dirname "$0")" && pwd)
voz="$1"; ban="${2:-}"; falhou=0; teto="${TETO_VOZ:-17500}"
[ -s "$voz" ] || { echo "ARQUIVO: voz.md vazio ou ausente: $voz"; exit 1; }

n=$(perl -CSD -ne '$n += length; END { print $n + 0 }' "$voz")
if [ "$n" -gt "$teto" ]; then
  echo "TAMANHO: $n caracteres, teto $teto (excede em $((n - teto)))"; falhou=1
else
  echo "tamanho ok: $n caracteres (teto $teto)"
fi

primeira=$(grep -m1 -v '^[[:space:]]*$' "$voz")
ultima=$(grep -v '^[[:space:]]*$' "$voz" | tail -n 1)
[ "$primeira" = "<sobre_mim>" ] || { echo "ESTRUTURA: primeira linha nao e <sobre_mim>: $primeira"; falhou=1; }
[ "$ultima" = "</sobre_mim>" ] || { echo "ESTRUTURA: ultima linha nao e </sobre_mim>: $ultima"; falhou=1; }
blocos="uso prioridade contexto_de_identidade assinatura_de_voz leis_de_escrita leis_de_comunicacao recusas_duras gostos_que_amo gostos_que_detesto banco_de_frases sinais_de_assinatura regras_de_decisao contradicoes_produtivas exemplos_de_ouro nao_inferir instrucao_final"
anterior=0; faltando=0
for b in $blocos; do
  a=$(grep -n -m1 "^<$b>[[:space:]]*$" "$voz" | cut -d: -f1)
  z=$(grep -n -m1 "^</$b>[[:space:]]*$" "$voz" | cut -d: -f1)
  if [ -z "$a" ] || [ -z "$z" ]; then echo "ESTRUTURA: bloco <$b> ausente ou sem fechamento"; falhou=1; faltando=$((faltando + 1)); continue; fi
  [ "$a" -gt "$anterior" ] || { echo "ESTRUTURA: bloco <$b> fora de ordem (linha $a)"; falhou=1; }
  anterior=$z
done
[ "$faltando" -eq 0 ] && echo "estrutura ok: 16 blocos na ordem"

if ! bash "$dir/../check-voz.sh" "$voz" > /dev/null; then echo "CHECK-VOZ: travessao ou emoji em $voz"; falhou=1; fi

if [ -n "$ban" ]; then
  if [ ! -f "$ban" ]; then
    echo "BANIDAS: arquivo ausente: $ban"; falhou=1
  else
    longas=$(grep -v '^[[:space:]]*#' "$ban" | grep -v '^[[:space:]]*$' | awk 'NF > 4')
    if [ -n "$longas" ]; then
      echo "BANIDAS: linha com mais de 4 palavras (termo, nao oracao):"; printf '  %s\n' "$longas" | head -n 20; falhou=1
    fi
    if ! bash "$dir/../check-voz.sh" "$ban" > /dev/null; then echo "CHECK-VOZ: travessao ou emoji em $ban"; falhou=1; fi
    uteis=$(grep -v '^[[:space:]]*#' "$ban" | grep -c -v '^[[:space:]]*$')
    comentario=$(grep -c '^[[:space:]]*#' "$ban")
    if [ "$uteis" -eq 0 ]; then
      echo "BANIDAS: nenhum termo (so comentario): a checagem mecanica dos outros especialistas fica cega"; falhou=1
    fi
    # linha feita so de palavra funcional ou verbo comum (palavras-comuns.txt), salvo expressao
    # de 2+ palavras com verbo de plataforma (isca como "comenta aqui"), ou palavra
    # unica com menos de 4 letras: termo ativo dispara em todo texto, e acusaria uso legitimo
    funcionais=$(perl -CSD -e '
      use utf8;
      sub norm { my $w = lc shift; $w =~ tr/áàâãäéèêëíìîïóòôõöúùûüç/aaaaaeeeeiiiiooooouuuuc/; $w }
      open my $l, "<", $ARGV[0] or die; my (%c, %p); my $plat = 0;
      while (<$l>) { if (/^#/) { $plat = /verbos de plataforma/ ? 1 : 0; next } for (grep { length } split /\s+/) { $c{norm($_)} = 1; $p{norm($_)} = 1 if $plat } }
      open my $b, "<", $ARGV[1] or die;
      while (my $ln = <$b>) { chomp $ln; next if $ln =~ /^\s*#/ || $ln =~ /^\s*$/; my @w = grep { length } split /\s+/, $ln;
        my $todas = 1; $todas = 0 for grep { !$c{norm($_)} } @w;
        # expressao de isca com verbo de plataforma ("comenta aqui") e termo completo, nao funcional solta
        $todas = 0 if @w >= 2 && grep { $p{norm($_)} } @w;
        my $curta = (@w == 1 && length(norm($w[0])) < 4);
        print "$ln\n" if $todas || $curta }' "$dir/palavras-comuns.txt" "$ban")
    if [ -n "$funcionais" ]; then
      echo "BANIDAS: palavra funcional, verbo comum ou palavra unica sem valor distintivo (dispara em uso legitimo):"; printf '  %s\n' "$funcionais" | head -n 20; falhou=1
    fi
    echo "banidas: $uteis termos, $comentario linhas de comentario"
  fi
fi
exit $falhou
