#!/usr/bin/env bash
# Testa scripts/check-voz.sh: travessao, emoji, termo banido e a excecao de
# citacao (aspas, blockquote, bloco de codigo), que vale so para termo banido.
set -u
d=$(mktemp -d)
s=scripts/check-voz.sh
printf 'alavancar\n' > "$d/banidas.txt"
falhas=0
espera_ok()    { bash $s "$@" >/dev/null && echo "ok    $1" || { echo "FALHA $1 (devia passar)"; falhas=$((falhas+1)); }; }
espera_falha() { bash $s "$@" >/dev/null && { echo "FALHA $1 (devia acusar)"; falhas=$((falhas+1)); } || echo "ok    $1"; }
# basicos
printf 'texto limpo, sem nada.\n' > "$d/limpo.md";                 espera_ok "$d/limpo.md" "$d/banidas.txt"
printf 'texto com travess\xe2\x80\x94o\n' > "$d/trav.md";         espera_falha "$d/trav.md"
printf 'vamos alavancar isso\n' > "$d/ban.md";                     espera_falha "$d/ban.md" "$d/banidas.txt"
# termo banido dentro de aspas passa; o mesmo termo fora acusa
printf 'o site diz "vamos alavancar seu negocio" e pronto\n' > "$d/aspas.md";             espera_ok "$d/aspas.md" "$d/banidas.txt"
printf 'o site diz \xe2\x80\x9cvamos alavancar\xe2\x80\x9d e pronto\n' > "$d/curvas.md"; espera_ok "$d/curvas.md" "$d/banidas.txt"
printf 'o site diz "vamos crescer" e eu quero alavancar\n' > "$d/fora.md";                 espera_falha "$d/fora.md" "$d/banidas.txt"
# travessao dentro de aspas continua acusando (a excecao nao cobre tipografia)
printf 'o site diz "IA \xe2\x80\x94 acelera" e pronto\n' > "$d/trav-aspas.md";           espera_falha "$d/trav-aspas.md" "$d/banidas.txt"
printf '> IA \xe2\x80\x94 acelera\n' > "$d/trav-bq.md";                                  espera_falha "$d/trav-bq.md" "$d/banidas.txt"
# aspas aninhadas: o par externo fechado mascara tudo dentro
printf 'ele disse \xe2\x80\x9cno site esta "alavancar" e tal\xe2\x80\x9d hoje\n' > "$d/aninhada.md"; espera_ok "$d/aninhada.md" "$d/banidas.txt"
# aspas sem fechamento nao engolem o resto: o termo na linha seguinte acusa, e so ele
printf 'ele abriu "aspas e nao fechou\ntexto do autor\nquero alavancar aqui\n' > "$d/aberta.md"
espera_falha "$d/aberta.md" "$d/banidas.txt"
n=$(bash $s "$d/aberta.md" "$d/banidas.txt" | grep -c '^3: ')
[ "$n" -eq 1 ] && echo "ok    aberta acusa a linha 3" || { echo "FALHA aberta: linha 3 nao acusada"; falhas=$((falhas+1)); }
# aspas sem fechamento na propria linha: o termo depois dela nao esta entre aspas fechadas, acusa
printf 'ele abriu "alavancar e nao fechou\n' > "$d/aberta2.md";  espera_falha "$d/aberta2.md" "$d/banidas.txt"
# blockquote de varias linhas passa; a linha normal depois dele acusa
printf '> primeira linha citada, alavancar\n> segunda linha citada, alavancar\n' > "$d/bq.md";  espera_ok "$d/bq.md" "$d/banidas.txt"
printf '> citado: alavancar\n\ndepois eu quero alavancar\n' > "$d/bq-depois.md";              espera_falha "$d/bq-depois.md" "$d/banidas.txt"
# bloco de codigo cercado passa; depois do fechamento acusa
printf 'antes\n```\nvamos alavancar\n```\ndepois limpo\n' > "$d/cerca.md";                     espera_ok "$d/cerca.md" "$d/banidas.txt"
printf '```\nvamos alavancar\n```\ndepois alavancar\n' > "$d/cerca-depois.md";                espera_falha "$d/cerca-depois.md" "$d/banidas.txt"
# emoji dentro de blockquote continua acusando
printf '> foguete \xf0\x9f\x9a\x80 citado\n' > "$d/emoji-bq.md";                              espera_falha "$d/emoji-bq.md"
[ "$falhas" -eq 0 ] && echo "todos os testes passaram" || { echo "$falhas teste(s) falharam"; exit 1; }
