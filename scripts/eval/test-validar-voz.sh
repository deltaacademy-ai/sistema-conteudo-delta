#!/usr/bin/env bash
set -u
# uso: bash scripts/eval/test-validar-voz.sh
# Prova que validar-voz.sh falha alto no teto de caracteres, na estrutura e no banidas.txt
# com oracao, e passa num voz.md minimo correto.
dir=$(cd "$(dirname "$0")" && pwd)
s="$dir/validar-voz.sh"
d=$(mktemp -d); falhou=0
ok() { echo "ok $1"; }
falha() { echo "FALHA $1"; falhou=1; }

blocos="uso prioridade contexto_de_identidade assinatura_de_voz leis_de_escrita leis_de_comunicacao recusas_duras gostos_que_amo gostos_que_detesto banco_de_frases sinais_de_assinatura regras_de_decisao contradicoes_produtivas exemplos_de_ouro nao_inferir instrucao_final"
{ echo "<sobre_mim>"; for b in $blocos; do echo "<$b>"; echo "linha de $b"; echo "</$b>"; done; echo "</sobre_mim>"; } > "$d/ok.md"
printf 'alavancar\nlink na bio\n# grupo: condicional\n' > "$d/banidas-ok.txt"
bash "$s" "$d/ok.md" "$d/banidas-ok.txt" > "$d/saida.txt" && ok "voz.md minimo passa" || { falha "voz.md minimo reprovou"; cat "$d/saida.txt"; }

# teto: mesmo arquivo, teto artificial abaixo do tamanho
TETO_VOZ=100 bash "$s" "$d/ok.md" > "$d/saida.txt" && falha "teto nao disparou" || { grep -q '^TAMANHO:' "$d/saida.txt" && ok "teto dispara com TAMANHO" || { falha "teto disparou sem linha TAMANHO"; cat "$d/saida.txt"; }; }

# teto real: 17.501 caracteres de arquivo estruturado
{ echo "<sobre_mim>"; for b in $blocos; do echo "<$b>"; echo "</$b>"; done; perl -e 'print "x" x 17300, "\n"'; echo "</sobre_mim>"; } > "$d/grande.md"
bash "$s" "$d/grande.md" > "$d/saida.txt" && falha "17.500 nao disparou" || { grep -q '^TAMANHO:' "$d/saida.txt" && ok "arquivo acima de 17.500 reprova" || falha "acima de 17.500 sem TAMANHO"; }

# estrutura: sem o bloco exemplos_de_ouro
grep -v 'exemplos_de_ouro' "$d/ok.md" > "$d/sem-bloco.md"
bash "$s" "$d/sem-bloco.md" > "$d/saida.txt" && falha "bloco ausente passou" || { grep -q 'ESTRUTURA: bloco <exemplos_de_ouro>' "$d/saida.txt" && ok "bloco ausente reprova" || { falha "bloco ausente sem linha ESTRUTURA"; cat "$d/saida.txt"; }; }

# banidas: oracao de 13 palavras
printf 'alavancar\naproximar quem constroi das ferramentas que estao mudando a forma como a gente escreve software\n' > "$d/banidas-ruim.txt"
bash "$s" "$d/ok.md" "$d/banidas-ruim.txt" > "$d/saida.txt" && falha "oracao no banidas passou" || { grep -q '^BANIDAS:' "$d/saida.txt" && ok "oracao no banidas reprova" || falha "oracao sem linha BANIDAS"; }

# banidas: 4 palavras passa, 5 reprova
printf 'ja parou pra pensar\n' > "$d/b4.txt"; printf 'voce ja parou pra pensar\n' > "$d/b5.txt"
bash "$s" "$d/ok.md" "$d/b4.txt" > /dev/null && ok "4 palavras passa" || falha "4 palavras reprovou"
bash "$s" "$d/ok.md" "$d/b5.txt" > /dev/null && falha "5 palavras passou" || ok "5 palavras reprova"

# banidas: palavra funcional, verbo comum, expressao so de funcionais, palavra unica curta
for w in para está estou comenta 'a gente' 'por isso' ia; do
  printf '%s\nalavancar\n' "$w" > "$d/bf.txt"
  bash "$s" "$d/ok.md" "$d/bf.txt" > "$d/saida.txt" && falha "funcional '$w' passou" || { grep -q '^BANIDAS: palavra funcional' "$d/saida.txt" && ok "funcional '$w' reprova" || falha "'$w' reprovou sem linha BANIDAS"; }
done
printf 'link na bio\ncomenta muse\nsinergia\nhype\n' > "$d/bok2.txt"
bash "$s" "$d/ok.md" "$d/bok2.txt" > "$d/saida.txt" && ok "termo com funcional dentro passa (link na bio, comenta muse)" || { falha "termo legitimo reprovou"; cat "$d/saida.txt"; }
printf 'comenta aqui\nsalva esse\nalavancar\n' > "$d/bisca.txt"
bash "$s" "$d/ok.md" "$d/bisca.txt" > "$d/saida.txt" && ok "isca com verbo de plataforma passa (comenta aqui, salva esse)" || { falha "isca de plataforma reprovou"; cat "$d/saida.txt"; }
printf 'aqui agora\nalavancar\n' > "$d/bfun2.txt"
bash "$s" "$d/ok.md" "$d/bfun2.txt" > "$d/saida.txt" && falha "expressao so de funcionais sem verbo de plataforma passou" || ok "expressao so de funcionais sem verbo de plataforma reprova (aqui agora)"

# banidas: so comentario, nenhum termo
printf '# isca de engajamento\n# emoji\n' > "$d/b0.txt"
bash "$s" "$d/ok.md" "$d/b0.txt" > "$d/saida.txt" && falha "banidas sem termo passou" || { grep -q '^BANIDAS: nenhum termo' "$d/saida.txt" && ok "banidas sem termo reprova" || falha "sem termo sem linha BANIDAS"; }

exit $falhou
