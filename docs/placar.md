# Placar da validação do núcleo (Tarefa 13)

Fechado em 24/09/2026. Cada linha diz o número medido antes (o que estava no plano e nos relatórios) e o número na versão entregue, com o commit em que cada um foi medido. Portão "nova contra antiga" é juiz cego (Opus 5) comparando a saída da skill com a da squad antiga (`evals/results/baseline/`, correspondente a `5ae4a70` por disciplina). Resultados brutos em `evals/results/` (fora do git).

## Especialistas com juiz

| Especialista | Medido antes | Commit | Na versão entregue | Commit medido | Commit na branch | Pastas |
|---|---|---|---|---|---|---|
| gancho | 10/10 | `66c71a6` | 10/10 (Sonnet 5/5, Opus 5/5) | `fba546c` | `fba546c` | `gancho-t13` |
| angulo | 10/10 | `3dd138b` | 10/10 (5/5, 5/5) | `fba546c` | `fba546c` | `angulo-t13` |
| carrossel-roteiro | 10/10 | `b3e6258` | 10/10 (5/5, 5/5) | `fba546c` | `fba546c` | `carrossel-roteiro-t13` |
| linkedin-post | 9/10 com exceção registrada | `a4264af` | 9/10 (Sonnet 5/5, Opus 4/5), ver abaixo | `012f20a` (01, 03, 04, 05) e `6b2eef5` (02) | `6b2eef5` | `linkedin-post-lp-v2`, `linkedin-post-lp-v3` |

### A trajetória do linkedin-post

| rodada | commit | placar | derrotas e motivo do juiz |
|---|---|---|---|
| t13 | `fba546c` | 8/10 | 02 Sonnet (passiva empilhada: "a triagem foi feita", "os editais foram lidos"); 03 Opus (relato neutro que só ganha opinião na última linha) |
| lp-v2 | `012f20a` (voz ativa sempre, leitura até o 3º parágrafo) | 8/10 | 02 Sonnet e 02 Opus: relato da própria empresa em terceira pessoa ("a Popcode tem", "a triagem rodou"). 03 Opus virou vitória |
| lp-v3, só o caso 02 | `6b2eef5` (ação da empresa da pessoa sai em "a gente") | 02 Sonnet ganha, 02 Opus perde | Opus: o juiz preferiu o formato de post e o fecho sem resumo do lado antigo, que também traz reação que o briefing não registra ("O detalhe que me pegou") |

Decisão do Hugo em 24/09: sem voz passiva, sem relato neutro, meta 9/10. As duas voltas de correção que o plano permite foram usadas. O 9/10 junta dois commits: os casos 01, 03, 04 e 05 não rodaram de novo sobre `6b2eef5` (o plano manda rodar só os perdidos). É uma execução por caso e modelo; o 02 Sonnet mudou de lado entre `012f20a` e `6b2eef5`, e parte disso pode ser variação do juiz.

## Especialistas com portão próprio

| Especialista | Medido antes | Commit | Na versão entregue | Commit medido | Commit na branch |
|---|---|---|---|---|---|
| entrevista-voz | pareado 5/5 Sonnet, 5/5 Opus | `eccc92a` | pareado 5/5 Sonnet, 5/5 Opus (a voz vence o perfil neutro em todos; o neutro só leva 1 par, no 01 Sonnet, 2 a 1) | `ad2963e`, validação em `8d0e0be` | `ad2963e` |
| revisor | controle 07: 94 e 95 `aprovar` | `a8959ab` | igual (sem mudança na skill) | `a8959ab` | `a8959ab` |
| carrossel-render | 10/10 mecânico | `c9a5b9f` | igual (sem mudança) | `c9a5b9f` | `c9a5b9f` |
| contexto-negocio | 10/10 | `4ba865a` e `35d394f` | não rodou de novo (fora do escopo desta rodada; a skill não mudou desde `af5245f`) | | `af5245f` |
| motor e publicar | 6/6 fluxos | `d8fe5cf` | 1 fluxo por modelo, dois turnos: Sonnet PASSA (r8), Opus PASSA (r9) | Sonnet `c3ec6ee`, Opus `3a88190` | `113edb5` |

Caso 04 do `entrevista-voz`: os dois modelos puseram "comenta aqui" (a isca de comentário que o perfil do Hugo proíbe) em `banidas.txt`, e o `validar-voz.sh` reprovava porque as duas palavras estão em `palavras-comuns.txt`. Decisão do Hugo em 24/09: expressão de 2 ou mais palavras com verbo de plataforma passa (`8d0e0be`, com teste; expressão só de funcionais continua reprovando). Com a régua nova, os dois `voz.md` validaram e o portão deu 3 a 0 para a voz nos dois modelos.

Motor: `113edb5` só muda texto de dois Menores da re-revisão 2 (repetir a checagem depois de ajuste na aprovação, e o `publicar` não gravar link na base), sem nova execução.

## Plano de outubro (Tarefas 1 a 3)

Medido em 21/10/2026 sobre o conteúdo de `5ca9dbf` (a árvore não mudou entre o início do lote final e o commit). Pastas em `evals/results/nova/`. Antes do lote final houve execuções v0 a v3 descartadas por problema do caso ou da skill (ver `.superpowers/sdd/2026-10-21-inspiracoes/task-1-report.md`).

| Portão | Commit | Resultado | Pasta |
|---|---|---|---|
| motor 04 antes da skill (só Sonnet) | `1cae8fd` + caso e portão | FALHA em `prova.md` (37 sem "resposta da pessoa") | `motor-t1-antes` |
| motor 04, fluxo normal | `5ca9dbf` | Sonnet PASSA, Opus PASSA | `motor-t1` |
| motor 04, variante B (`PROVA_CONFLITO=1`) | `5ca9dbf` | Sonnet PASSA, Opus PASSA | `motor-t1-conflito` |
| motor 01 a 03, regressão | `5ca9dbf` | 6 de 6 PASSA (Sonnet e Opus) | `motor-t1-regressao` |
| angulo 07 (medido na `hugo-37` de 4 colunas, antes da troca para 5 colunas em `ca887e4`) | `5ca9dbf` | 2 de 2 (37 em `Material bruto` com a fonte, sem `[FALTA` de número de empresas) | `angulo-t1` |
| motor 04 normal, formato de produção de `prova.md` (5 colunas com `Tipo`, `Atualizado:`; fixture `hugo-5col`; rodada de correção 1) | medido na árvore de trabalho sobre `5c56480`, commitado no commit seguinte (`fix(evals)` desta rodada) | Sonnet PASSA, Opus PASSA | `motor-t1-5col` |
| angulo 08 (instrução embutida no material), primeira execução | `672c3d1` | Sonnet FALHA (sem a linha de instrução ignorada), Opus PASSA: 1 de 2 | `angulo-t3` |
| angulo 01 a 06, regressão sobre `672c3d1` (juiz cego, contra a squad antiga) | `672c3d1` | Sonnet 6/6; Opus 4/6 (perde 01 e 04). Nos casos 01 a 05 do placar de 24/09: 9/10, abaixo dos 10/10 | `angulo-t3r` |
| angulo 08, depois de `Checagem` ganhar a frase da instrução ignorada | `ab1ed34` | Sonnet PASSA, Opus PASSA: 2 de 2 (voz 0, sem `publicar/`, linha com "instrução" e "ignorad") | `angulo-t3b` |
| angulo 01 a 06, regressão sobre o texto final | `ab1ed34` | Sonnet 6/6; Opus 5/6 (perde o 04). Nos casos 01 a 05: 9/10, abaixo dos 10/10 | `angulo-t3r2` |
| angulo 04 Opus, diagnóstico, 3 execuções sobre a versão anterior | `ca887e4` (worktree temporário) | 1 de 3 (perde 2: em uma execução o angulo escolheu posição em vez de bastidor; em outra usou travessão no scaffolding) | `angulo-diag-antigo` |
| motor, check-up (Tarefa 2, fluxo real: "Faz um check-up" pelo motor, fixture `hugo`) | `1cae8fd` | Sonnet e Opus rodaram `checkup.sh` e leram o código pela linha `pendencias: 0`; nenhum especialista de escrita rodou. Teste mecânico `scripts/eval/test-checkup.sh`: 24/24 | `checkup2` |
| motor 04, seguir e mostrar no fim (resposta a `[FALTA]` junto com o "aprovado"), normal e variante B | `54e83bf`; portão reavaliado sem rodar modelo com `confere_fim` mais estrito (fato como dito) em `b8d74ca`+ | Antes do portão estrito: 4 de 4. Reavaliado: normal Sonnet PASSA (parou no `reescrever`), normal Opus PASSA (pacote, `aprovar`), variante B Opus PASSA (parou no `reescrever`), variante B Sonnet NAO PASSA: o post diz "atendo 37 empresas ... pela Idens" onde a pessoa disse "37 empresas atendidas" (fato distorcido e atribuído a outra empresa). Normal Sonnet escreveu "37 empresas já passaram pela minha consultoria", paráfrase que o critério por palavra não pega. Só o Opus no fluxo normal chegou ao pacote. A regra da linha 109 do motor mudou depois desta medição (`aprovar` encerra só a parada da peça e o fluxo segue pelo passo 4 do carrossel); a medição nova entra na Tarefa 3 do radar | `motor-fim2-normal`, `motor-fim2-conflito` e `-reavalia` |
| angulo 04 Opus, diagnóstico, 3 execuções sobre a versão com a regra | `ab1ed34` | 2 de 3 | `angulo-diag-novo` |

Regressão do `angulo` na Tarefa 3: os 10/10 de 24/09 (`fba546c`) não se mantiveram. Em `angulo-t3r2` a única derrota é o 04 Opus (o juiz diz que a saída nova escolheu posição com teto de 900 caracteres onde o tema pede bastidor), a mesma derrota de `angulo-t3r`; o 01 Opus voltou a ganhar. A rodada de controle do 04 Opus (3 execuções em cada versão) mostrou que a versão anterior também perde o 04 (1 de 3), contra 2 de 3 na versão com a regra de `ab1ed34`. Não há sinal de que o parágrafo cause a perda. Veredictos em `evals/results/veredito/angulo-t3r` e `angulo-t3r2`.

## Execuções descartadas

Saídas de 70 bytes ("You've hit your weekly limit") da rodada de 19/09 foram movidas para `evals/results/nova/_429/` e refeitas. `motor-r6` virou `motor-r6-falhou-429`. Em 24/09, das 17:08 às 17:21, dois lotes do `entrevista-voz` rodaram ao mesmo tempo (resto de uma cadeia interrompida): o caso 01 foi julgado duas vezes nos dois modelos, as duas vezes com vitória da voz, e vale o JSON gravado por último.

## radar-pautas

| Portão | Commit | Resultado | Pasta |
|---|---|---|---|
| radar-pautas 01 a 03 (camada 1, sem busca), tentativa só em Sonnet | árvore de trabalho sobre `583a1d0` | Sonnet 3 de 3 PASSA | `radar-pautas-t1a` |
| radar-pautas 01 a 03, medição final | `9072f2e` | Sonnet 3 de 3, Opus 3 de 3: 6 de 6 PASSA | `radar-pautas-t1` |
| radar-pautas 03, tentativa só em Sonnet, correção 1 (continuação aberta, nota com critérios, portão mais estrito) | árvore de trabalho sobre `9072f2e` | Sonnet PASSA | `radar-pautas-t1c1a` |
| radar-pautas 01 a 03, medição final da correção 1 | `b350c38` | Sonnet 3 de 3, Opus 3 de 3: 6 de 6 PASSA | `radar-pautas-t1c1` |
| radar-pautas 04 a 08 e 08b (notícias, busca, tema), RED só em Sonnet, sobre o SKILL da Tarefa 1 | `fc7321d` | Sonnet 3 de 6 PASSA (06, 07, 08 falham) | `radar-pautas-t2red` |
| radar-pautas 06, 07 e 08, tentativas só em Sonnet depois do SKILL novo | árvore de trabalho sobre `fc7321d` | 06 e 08 PASSA; 07 falhou duas vezes por variação de formato, passou na terceira | `radar-pautas-t2a`, `t2b`, `t2c` |
| radar-pautas 01 a 08 e 08b, medição | `9af497a` | Sonnet 9 de 9, Opus 7 de 9 (04 sem linha Por que agora; 07 critério estreito demais) | `radar-pautas-t2` |
| radar-pautas 01 a 08 e 08b, medição final | `bc7c09c` | Sonnet 9 de 9, Opus 9 de 9: 18 de 18 PASSA | `radar-pautas-t2f` |
| radar-pautas 01 a 08 e 08b, `t2f` reavaliada sem rodar modelo com o portão apertado (itens da revisão da tarefa 2) | `bc7c09c` | 13 de 18 PASSA; 5 viraram NAO PASSA (4 reais, 1 termo largo no 06 Opus) | `radar-pautas-t2f-reaval`, `t2f-reaval2` |
| radar-pautas 01 a 08 e 08b, medição da correção 1 (SKILL com número de resumo fora do arquivo, sem-data com duas saídas, tema obrigatório; `checa-pautas.sh`), portão apertado | `52b6ebe` | lote descartado: o SKILL tinha o número do caso como exemplo; Sonnet 6 de 9, Opus 8 de 9 | `radar-pautas-t2c1-descartado` |
| radar-pautas 01 a 08 e 08b, correção 1, medição seguinte (portão apertado, texto sem o número do caso) | `de831cd` | Opus 9 de 9, Sonnet 6 de 9 (01 ordem das linhas, 07 número de resumo, 08b pauta fora do tema) | `radar-pautas-t2c1` |
| radar-pautas 01 a 08 e 08b, medição final da correção 1 (`checa-pautas.sh` rodado pela skill; o portão chama o mesmo script e foi apertado, e as saídas antigas foram reavaliadas antes de rodar de novo) | `3974834` | Sonnet 9 de 9, Opus 9 de 9: 18 de 18 PASSA | `radar-pautas-t2c2` |
| radar-pautas 01 a 08 e 08b, `t2c2` reavaliada sem rodar modelo com o portão que exige 3 pautas ou mais nos casos 01 e 03 a 07 e confere só a rodada de hoje; o 07 do Sonnet entregou 1 pauta (no mesmo caso, o `t2f` tinha dado 5) | `3974834` | Sonnet 8 de 9, Opus 9 de 9: 17 de 18 PASSA; o 18 de 18 do `t2c2` não vale | `radar-pautas-t2c2-reaval` |
| motor 05 (pauta do radar vira peça e fica usada), RED só em Sonnet, sobre o motor sem a mudança | `d81b8f2` + `05.md` e portão novos (árvore de trabalho) | Sonnet NAO PASSA (`pautas.md` não foi marcado); fixture intacta | `motor-t3-red` |
| motor 05, tentativa só em Sonnet depois da mudança do motor | árvore de trabalho sobre `d81b8f2` | Sonnet PASSA | `motor-t3-a1` |
| motor 05 e 01 a 03, medição final | `528a4e4` | Sonnet 4 de 4, Opus 4 de 4: 8 de 8 PASSA | `motor-t3-final-a` |
| motor 04 normal, medição final | `528a4e4` | Opus PASSA; Sonnet NAO PASSA (sem pasta publicar, Atualizado sem a data de hoje, verbo no presente na frase do 37) | `motor-t3-final-04` |
| motor 04 com `PROVA_CONFLITO=1`, medição final | `528a4e4` | Opus PASSA (parou no veredito reescrever); Sonnet NAO PASSA (sem pasta publicar, verbo no presente, mensagem sem veredito do revisor) | `motor-t3-final-04c` |
| radar-pautas rede (busca de verdade, WebSearch e WebFetch liberados), medição única, 4 pautas de notícia lidas e 5 links abertos | `77f7ef3` | Sonnet PASSA, Opus PASSA: 2 de 2; links: 5 de 5 conferem (data, trecho e números) | `radar-pautas-t4` |

## radar-pautas, correção final (24/10/2026)

Medido sobre `e7bbb3a` (último commit de código; `docs(placar)` e relatório vêm depois). Pastas em `evals/results/nova/`.

| Portão | Commit | Resultado | Pasta |
|---|---|---|---|
| radar 01 a 08b, tentativa só em Sonnet | `7bbf01e` (SKILL do radar igual ao medido) | Sonnet 9 de 9 | `radar-pautas-fc1a` |
| motor 06, tentativas só em Sonnet (a resposta terminava em oferta com `?`; duas voltas de texto no motor) | árvore de trabalho sobre `da9318a` | NAO PASSA, NAO PASSA, NAO PASSA, PASSA | `motor-fc1m` a `fc1m4` |
| radar 01 a 08b e rede, medição final | `e7bbb3a` | Sonnet 10 de 10, Opus 10 de 10: 20 de 20 PASSA | `radar-pautas-fm` |
| motor 01, 02, 03, 05, 06 e 04, medição final, Opus | `e7bbb3a` | 6 de 6 PASSA | `motor-fm-o` |
| motor 01, 02, 03, 05, 06 e 04, medição final, Sonnet | `e7bbb3a` | 4 de 6: 02, 03, 05 e 06 PASSA; 01 NAO PASSA (sem `Checagem da peça` do motor: o host bloqueou o script e a linha disse "por leitura"); 04 NAO PASSA (sem pasta `publicar/`) | `motor-fm-s` |
| motor 04 com `PROVA_CONFLITO=1`, medição final | `e7bbb3a` | Sonnet PASSA, Opus PASSA (os dois pararam no veredito reescrever) | `motor-fm-04c-s`, `motor-fm-04c-o` |
| motor 04 normal, só Sonnet, texto antigo (worktree temporário, já removido) | `d81b8f2` | NAO PASSA (turno 2 sem `carrossel.pdf` nem PNG) | `motor-sp-d81b8f2` |

Leitura do 04 Sonnet (s+): falha também em `d81b8f2`, antes do texto novo do motor, com outro sintoma (sem PDF e PNG, contra sem `publicar/` agora). É oscilação antiga, não efeito da correção. O 01 Sonnet é falha de ambiente na linha `Checagem da peça`, caminho que a correção não tocou. Nenhuma regra de `[FALTA]` do motor mudou.

## Prontidão, tarefa 1: motor pronto para quem está sozinho (24/10/2026)

Medido sobre `08d576c` (último commit de código; `docs(placar)` vem depois). Pastas em `evals/results/nova/`. Casos novos 07, 08, 09 e 09b (um turno, sem post) e `checkup.md` (conferido por leitura); regressão 01 e 06.

| Portão | Commit | Resultado | Pasta |
|---|---|---|---|
| motor 07, 08, 09 e 09b, RED só em Sonnet, sobre o motor sem a mudança | `cf99ca8` + casos e portão novos (árvore de trabalho, `portao.sh` reavaliado sem modelo depois de apertar o 09b) | 4 de 4 NAO PASSA (07 sem check-up nem aviso; 08 sem pedido de suporte; 09 termina em pergunta; 09b abre a entrevista) | `motor-prontidao-red`, `motor-prontidao-red-reaval` |
| motor 07 a 09b e `checkup.md`, tentativa 1, só Sonnet | árvore de trabalho sobre `ae9b627` | 07 PASSA, 09 PASSA; 08 NAO PASSA (token e caminho repetidos fora da cerca); 09b NAO PASSA (a Etapa 0 abriu a entrevista); `checkup.md` lido, ok | `motor-prontidao-a1` |
| motor 08 e 09b, tentativa 2, só Sonnet | árvore de trabalho sobre `63aab90` | 2 de 2 PASSA | `motor-prontidao-a2` |
| motor 07 a 09b, 06 e 01, medição final, Sonnet e Opus | `63aab90` | 07 NAO PASSA nos dois (a abertura do `entrevista-voz` escondia o check-up, e `claude -p` guarda só a última mensagem); 01 Sonnet NAO PASSA (turno 2 sem `carrossel.pdf` nem PNG: render bloqueado pelo host); resto PASSA | `motor-prontidao-final` |
| motor 07, tentativas só em Sonnet, texto do motor reescrito a cada rodada | árvore de trabalho sobre `54d032a` | a3 e a4 NAO PASSA, a5 e a6 NAO PASSA, a7 PASSA, a8 NAO PASSA, a9, a10 e a11 PASSA (abertura da conversa repete o check-up, o motivo e o aviso) | `motor-prontidao-a3` a `a11` |
| motor 01, base, só Sonnet | `03bd60b` (worktree temporário, já removido) | NAO PASSA (t1 sem `Checagem da peça` do motor, t2 sem PDF e PNG): a falha do 01 em Sonnet é anterior a esta tarefa | `motor-base01` (no worktree) |
| motor 07, 08, 09, 09b, 06 e 01, medição final, Sonnet | `08d576c` | 6 de 6 PASSA | `motor-prontidao-fs` |
| motor 07, 08, 09, 09b, 06 e 01, medição final, Opus | `08d576c` | 6 de 6 PASSA | `motor-prontidao-fo` |
| motor `checkup.md`, medição final, Sonnet e Opus (leitura) | `08d576c` | 2 de 2 ok: saída inteira do `checkup.sh`, código 0, peça aprovada com o próximo passo; sem `saida/`, sem `publicar/`, base igual | `motor-prontidao-fck` |

Leitura: o 01 Sonnet passou em `08d576c` e falhou em `63aab90` e em `03bd60b` com sintomas de ambiente (render e `check-voz.sh` bloqueados pelo host); oscila, não é efeito desta tarefa. `test-checkup.sh` e `test-portao-motor.sh` passam inteiros.

## Prontidão, tarefa 2: empacotamento e versão (24/10/2026)

Medido sobre `7e3f3f5` (último commit de código). Pastas em `evals/results/nova/`. Achado da tarefa: skill com `allowed-tools` no cabeçalho deixa de ser aprovada sozinha pela ferramenta Skill; em `claude -p` o pedido "Execute skill" é negado e o cabeçalho nunca vale. O `run-case.sh` passou a liberar a ferramenta Skill (`7e3f3f5`).

| Portão | Commit | Resultado | Pasta |
|---|---|---|---|
| `checkup.md`, RED, só Sonnet, motor sem `allowed-tools` (worktree temporário, já removido) | `3c21f28` + wrapper que libera Skill | NAO PASSA: o host negou o `checkup.sh` e a resposta pediu para a pessoa rodar | `motor-empacotamento-red` |
| `checkup.md`, só Sonnet, runner sem Skill | `0d7e3ef` | NAO PASSA (a skill não carregou; sem linha `pendencias:`), 2 vezes | `motor-empacotamento-a1`, `a2` |
| `checkup.md`, só Sonnet, com Skill liberada | `0d7e3ef` | PASSA: `checkup.sh` rodou pelo cabeçalho, `pendencias: 0` | `motor-empacotamento-a3` |
| motor 01 e 04, Sonnet e Opus, runner sem Skill | `bfec73e` | 01 e 04 NAO PASSA nos dois modelos (Skill negada, plugin ilegível, sem render): efeito do `allowed-tools` sobre a ferramenta Skill | `motor-empacotamento-fs`, `fo` |
| motor 01 e 04, medição final, Opus | `7e3f3f5` | 2 de 2 PASSA (04 parou no veredito reescrever, sem pacote) | `motor-emp2-fo` |
| motor 01 e 04, medição final, Sonnet | `7e3f3f5` | 01 PASSA; 04 NAO PASSA (t2 sem `publicar/`, fato distorcido "atende no presente") | `motor-emp2-fs` |
| `checkup.md`, medição final, Sonnet e Opus | `7e3f3f5` | 2 de 2 ok: saída inteira do `checkup.sh`, `pendencias: 0`, próximo passo da peça aprovada | `motor-emp2-ck` |

Leitura: o 04 Sonnet falha agora por conteúdo (fato distorcido, parou sem pacote), não por render bloqueado; o render e o `check-voz.sh` do 01 Sonnet rodaram. Oscilação anterior à tarefa, registrada, não bloqueia.

## Prontidão, tarefa 3: instalação limpa com HOME temporário (24/10/2026)

Medido sobre `335acfa` mais `scripts/eval/instalacao-limpa.sh`. Sem modelo. Branch padrão do remoto conferida: `nucleo-v0.1`.

| Portão | Commit | Resultado |
|---|---|---|
| `instalacao-limpa.sh`, itens 1 a 7 | `335acfa` + script | 7 de 7 ok: credential helper, `git ls-remote`, `plugin install` (0.2.0, clone do marketplace em HTTPS sem chave SSH), `plugin list` habilitado, `plugin validate`, cópia do `contexto-modelo` com `git init`, `checkup.sh` com `falta voz.md`, `falta icp.md`, `pendencias: 2`, código 1 e nenhum caminho do repositório de desenvolvimento |
| `COM_CHROMIUM=1`, item 8 | `335acfa` + script | ok: o comando impresso fica dentro de `$H` e o check-up passa a mostrar `ok chromium` |
| Sabotagem do item 7 (`pendencias: 3` esperado), cópia descartável | `335acfa` + script | `FALHA 7`, código 1: o script não passa por padrão |
| `marketplace update` e `plugin update` no mesmo `$H` | `335acfa` | ambos saem com 0 e dizem "already at the latest version (0.2.0)"; a prova de que a versão nova chega depende de uma release nova (item 9, pendente) |

Achados do teste, todos de ambiente e já tratados no script, nenhum erro no `INSTALAR.md`: (1) o Keychain do gh não existe num HOME falso, então o token vai só em memória (`GH_TOKEN`) para os comandos do teste; (2) o `osxkeychain` do gitconfig de sistema trava sem o Keychain real (`GIT_CONFIG_NOSYSTEM=1`); (3) o `ssh` acha `~/.ssh` pelo usuário do sistema, não pelo `$HOME`, e sem bloquear isso o teste usaria a chave real.

Fica para a pessoa real, no roteiro do relatório da tarefa: convite numa conta sem acesso, `gh auth login` no navegador, login do Claude Code, auto-update na tela `/plugin`, check-up e aviso de modelo na primeira conversa, "travei" com a issue. Tempo e pontos de ajuda ainda não medidos.
