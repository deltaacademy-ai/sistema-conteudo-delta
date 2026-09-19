#!/usr/bin/env bash
# Testa scripts/check-voz.sh: travessao, emoji, termo banido e a excecao de
# citacao (aspas, blockquote, bloco de codigo), que vale so para termo banido.
set -u
d=$(mktemp -d)
s=scripts/check-voz.sh
printf 'alavancar\n' > "$d/banidas.txt"
falhas=0
nome() { local n=; for x in "$@"; do case $x in *.md|*.json) n=$x;; esac; done; echo "${n##*/}"; }
espera_ok()    { bash $s "$@" >/dev/null 2>&1 && echo "ok    $(nome "$@")" || { echo "FALHA $(nome "$@") (devia passar)"; falhas=$((falhas+1)); }; }
espera_falha() { bash $s "$@" >/dev/null 2>&1 && { echo "FALHA $(nome "$@") (devia acusar)"; falhas=$((falhas+1)); } || echo "ok    $(nome "$@")"; }
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
# modo --json: as aspas da sintaxe nao sao citacao. Termo banido dentro de um valor acusa,
# com o caminho do valor (indice a partir de 1) no lugar do numero da linha
printf '{"slides":[{"tipo":"capa","titulo":"Capa"},{"tipo":"conteudo","corpo":"vamos alavancar isso\\nsegunda linha"}]}\n' > "$d/ban.json"
espera_falha --json "$d/ban.json" "$d/banidas.txt"
bash $s --json "$d/ban.json" "$d/banidas.txt" | grep -q '^slides\[2\].corpo: \[alavancar\]' && echo "ok    json acusa com o caminho slides[2].corpo" || { echo "FALHA json: caminho do acerto"; falhas=$((falhas+1)); }
# o mesmo termo dentro de citacao marcada no proprio valor passa (aspas retas escapadas e curvas)
printf '{"slides":[{"corpo":"o site diz \\"vamos alavancar seu negocio\\" e pronto"}]}\n' > "$d/cit.json";       espera_ok --json "$d/cit.json" "$d/banidas.txt"
printf '{"slides":[{"corpo":"o site diz \xe2\x80\x9cvamos alavancar\xe2\x80\x9d e pronto"}]}\n' > "$d/cit2.json"; espera_ok --json "$d/cit2.json" "$d/banidas.txt"
# citacao fechada nao mascara o termo fora dela
printf '{"corpo":"o site diz \\"crescer\\" e eu quero alavancar"}\n' > "$d/cit-fora.json";                      espera_falha --json "$d/cit-fora.json" "$d/banidas.txt"
# travessao e emoji dentro de valor acusam, com ou sem lista, e mesmo entre aspas
printf '{"titulo":"IA \xe2\x80\x94 acelera"}\n' > "$d/trav.json";                        espera_falha --json "$d/trav.json"
printf '{"titulo":"cita \\"IA \xe2\x80\x94 acelera\\" aqui"}\n' > "$d/trav-cit.json";    espera_falha --json "$d/trav-cit.json" "$d/banidas.txt"
printf '{"titulo":"foguete \xf0\x9f\x9a\x80"}\n' > "$d/emoji.json";                     espera_falha --json "$d/emoji.json"
# termo banido na chave nao vira acerto do valor limpo (o rotulo do caminho fica fora da conferencia)
printf '{"alavancar":[{"corpo":"texto limpo"}]}\n' > "$d/chave.json";                   espera_ok --json "$d/chave.json" "$d/banidas.txt"
# modo texto com CHECK_VOZ_PREFIXO=1: o rotulo antes do TAB sai da conferencia, o texto depois entra
printf 'slide alavancar\ttexto limpo\n' > "$d/prefixo-ok.txt"
CHECK_VOZ_PREFIXO=1 bash $s "$d/prefixo-ok.txt" "$d/banidas.txt" >/dev/null && echo "ok    prefixo-ok.txt" || { echo "FALHA prefixo-ok.txt (devia passar)"; falhas=$((falhas+1)); }
printf 'slide 2\tquero alavancar\n' > "$d/prefixo-ban.txt"
CHECK_VOZ_PREFIXO=1 bash $s "$d/prefixo-ban.txt" "$d/banidas.txt" >/dev/null && { echo "FALHA prefixo-ban.txt (devia acusar)"; falhas=$((falhas+1)); } || echo "ok    prefixo-ban.txt"
# sem lista, json limpo passa; json invalido acusa
printf '{"slides":[{"titulo":"Texto limpo, com \\"aspas\\" e acento: ação"}]}\n' > "$d/limpo.json"; espera_ok --json "$d/limpo.json"
printf '{"slides":[\n' > "$d/quebrado.json";                                            espera_falha --json "$d/quebrado.json"
[ "$falhas" -eq 0 ] && echo "todos os testes passaram" || { echo "$falhas teste(s) falharam"; exit 1; }
