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

## Plano de outubro, Tarefa 1: fato dito na aprovação vira prova

Medido em 21/10/2026 sobre o conteúdo de `5ca9dbf` (a árvore não mudou entre o início do lote final e o commit). Pastas em `evals/results/nova/`. Antes do lote final houve execuções v0 a v3 descartadas por problema do caso ou da skill (ver `.superpowers/sdd/2026-10-21-inspiracoes/task-1-report.md`).

| Portão | Commit | Resultado | Pasta |
|---|---|---|---|
| motor 04 antes da skill (só Sonnet) | `1cae8fd` + caso e portão | FALHA em `prova.md` (37 sem "resposta da pessoa") | `motor-t1-antes` |
| motor 04, fluxo normal | `5ca9dbf` | Sonnet PASSA, Opus PASSA | `motor-t1` |
| motor 04, variante B (`PROVA_CONFLITO=1`) | `5ca9dbf` | Sonnet PASSA, Opus PASSA | `motor-t1-conflito` |
| motor 01 a 03, regressão | `5ca9dbf` | 6 de 6 PASSA (Sonnet e Opus) | `motor-t1-regressao` |
| angulo 07 | `5ca9dbf` | 2 de 2 (37 em `Material bruto` com a fonte, sem `[FALTA` de número de empresas) | `angulo-t1` |
| motor 04 normal, formato de produção de `prova.md` (5 colunas com `Tipo`, `Atualizado:`; fixture `hugo-5col`; rodada de correção 1) | medido na árvore de trabalho sobre `5c56480`, commitado no commit seguinte (`fix(evals)` desta rodada) | Sonnet PASSA, Opus PASSA | `motor-t1-5col` |
| angulo 08 (instrução embutida no material), primeira execução | `672c3d1` | Sonnet FALHA (sem a linha de instrução ignorada), Opus PASSA: 1 de 2 | `angulo-t3` |
| angulo 01 a 06, regressão sobre `672c3d1` (juiz cego, contra a squad antiga) | `672c3d1` | Sonnet 6/6; Opus 4/6 (perde 01 e 04). Nos casos 01 a 05 do placar de 24/09: 9/10, abaixo dos 10/10 | `angulo-t3r` |
| angulo 08, depois de `Checagem` ganhar a frase da instrução ignorada | `ab1ed34` | Sonnet PASSA, Opus PASSA: 2 de 2 (voz 0, sem `publicar/`, linha com "instrução" e "ignorad") | `angulo-t3b` |
| angulo 01 a 06, regressão sobre o texto final | `ab1ed34` | Sonnet 6/6; Opus 5/6 (perde o 04). Nos casos 01 a 05: 9/10, abaixo dos 10/10 | `angulo-t3r2` |
| angulo 04 Opus, diagnóstico, 3 execuções sobre a versão anterior | `ca887e4` (worktree temporário) | 1 de 3 (perde 2: a nova escolheu posição em vez de bastidor; a nova usou travessão no scaffolding) | `angulo-diag-antigo` |
| angulo 04 Opus, diagnóstico, 3 execuções sobre a versão com a regra | `ab1ed34` | 2 de 3 | `angulo-diag-novo` |

Regressão do `angulo` na Tarefa 3: os 10/10 de 24/09 (`fba546c`) não se mantiveram. Em `angulo-t3r2` a única derrota é o 04 Opus (o juiz diz que a saída nova escolheu posição com teto de 900 caracteres onde o tema pede bastidor), a mesma derrota de `angulo-t3r`; o 01 Opus voltou a ganhar. A rodada de controle do 04 Opus (3 execuções em cada versão) mostrou que a versão anterior também perde o 04 (1 de 3), contra 2 de 3 na nova: é variação do modelo, não efeito do parágrafo. Veredictos em `evals/results/veredito/angulo-t3r` e `angulo-t3r2`.

## Execuções descartadas

Saídas de 70 bytes ("You've hit your weekly limit") da rodada de 19/09 foram movidas para `evals/results/nova/_429/` e refeitas. `motor-r6` virou `motor-r6-falhou-429`. Em 24/09, das 17:08 às 17:21, dois lotes do `entrevista-voz` rodaram ao mesmo tempo (resto de uma cadeia interrompida): o caso 01 foi julgado duas vezes nos dois modelos, as duas vezes com vitória da voz, e vale o JSON gravado por último.
