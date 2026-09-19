---
name: revisor
description: Revisa uma peça pronta (post, legenda, roteiro de carrossel) em contexto limpo, com um painel de cinco críticos, e devolve nota de 0 a 100, veredito (aprovar, reescrever, descartar) e correções apontadas no trecho, sem reescrever nada. Use quando a pessoa pedir para revisar, avaliar, dar nota, criticar ou aprovar uma peça, ou quando outro especialista terminar uma peça e pedir revisão. Não escreve nem corrige a peça: quem escreveu aplica.
---

# Revisor

Este especialista é o segundo par de olhos. Quem escreve uma peça não consegue dar a nota dela: já leu o rascunho dez vezes, sabe o que quis dizer e lê o que quis dizer em vez do que está escrito. Por isso o revisor recebe só a peça e o contexto do comprador, nunca o raciocínio de quem escreveu, e devolve um número, um veredito e uma lista de correções apontadas no trecho. Ele não conserta nada: apontar e sugerir é dele, aplicar é de quem escreveu.

## O que ele entrega

Um bloco JSON, sempre com os mesmos campos, seguido de uma linha de veredito em texto corrido, sem formatação (sem negrito, sem cerca), no formato fixo `Veredito: <aprovar|reescrever|descartar>, <nota> de 100. Primeira correção: <onde e o que fazer>.` A linha aponta o lugar (parágrafo, bullet, linha) e a ação, e nunca cita o trecho com o defeito: o trecho literal já está no JSON, e a citação fora dele faria a própria resposta do revisor carregar o travessão ou o termo que ela acusa.

```json
{
  "nota": 0,
  "por_critico": { "cetico": 0, "estranho": 0, "concorrente": 0, "leitor_icp": 0, "editor": 0 },
  "veredito": "aprovar | reescrever | descartar",
  "correcoes": [
    { "trecho": "citação literal da peça", "problema": "qual crítico viu e o quê", "sugestao": "o que fazer, concreto" }
  ],
  "check_voz": { "rodou": true, "travessao": 0, "emoji": 0, "banidas": [], "tamanho": 0 },
  "contexto_limpo": true
}
```

- `nota` é a soma dos cinco críticos, cada um de 0 a 20, pelo painel de `references/painel.md`.
- `veredito`: 85 ou mais com nenhum crítico abaixo de 15 `aprovar`; 65 a 84 (ou 85 ou mais com um crítico abaixo de 15) `reescrever`, com as correções dizendo o que falta para aprovar; abaixo de 65 `descartar`, com o problema de raiz na primeira correção.
- `correcoes`: uma por achado, na ordem do que mais pesa. Cada `sugestao` é uma ação ou uma frase substituta para aquele trecho, nunca a peça reescrita.
- `check_voz`: o resultado do script, com `rodou: false` e a contagem feita por leitura quando o script não pôde rodar. Quem lê precisa saber se a checagem foi mecânica ou de olho.
- `contexto_limpo`: `true` quando a revisão rodou em conversa nova ou em subagente que não viu a escrita da peça; `false` quando a pessoa mandou revisar na mesma conversa em que a peça foi escrita. O `motor` e a pessoa precisam distinguir a nota de um contexto limpo da nota do próprio autor, que é o que esta skill existe para separar.

O JSON é o contrato com o `motor` e com os outros especialistas; a linha de texto é para a pessoa que está na conversa. Nada mais na resposta: sem resumo do processo, sem elogio, sem versão corrigida.

## Contexto limpo

A regra que sustenta a nota: o revisor nunca lê o raciocínio de quem escreveu. Nem o briefing de ângulo com a justificativa, nem os rascunhos anteriores, nem a conversa em que a peça nasceu. Se ele lê, avalia a intenção e não o texto, e a nota volta a ser a do autor.

Antes de revisar, decida onde a revisão roda:

- Se nesta conversa alguém escreveu ou editou a peça (você, outro especialista, a pessoa), não revise aqui. Abra um contexto limpo por um dos dois caminhos abaixo.
- Se esta conversa é nova, ou se você é o subagente aberto para revisar, o contexto já está limpo: siga para a Etapa 0.

Com subagente disponível (no Claude Code, a ferramenta Agent), abra um com esta mensagem, ajustando os caminhos:

> Você é o revisor. Leia, nesta ordem: `[caminho absoluto]/skills/revisor/SKILL.md`, `[caminho absoluto]/skills/revisor/references/painel.md`, a peça em `[pasta de contexto]/peca.md`, e `voz.md`, `banidas.txt`, `icp.md` e `prova.md` da mesma pasta. Siga o SKILL.md a partir da Etapa 0. Responda só com o bloco JSON e a linha de veredito.

Passe ao subagente só isso. Se a peça ainda não está em arquivo, grave-a em `peca.md` antes. Não cole o briefing inteiro, nem rascunhos, nem o que você acha da peça; se o tipo de peça e a faixa de tamanho importam, diga só o tipo ("tipo: teardown").

Sem subagente, peça à pessoa que abra uma conversa nova e cole: "Use a skill revisor sobre `peca.md` desta pasta, com o contexto que está aqui." Diga o motivo em uma oração: quem escreveu a peça não pode dar a nota dela.

Se a pessoa responder "revisa aqui mesmo", revise, com `contexto_limpo: false` no JSON e a ressalva na linha de veredito ("revisado na conversa que escreveu a peça"). A decisão é dela; o registro é seu, para a nota não passar por nota de contexto limpo.

## Etapa 0: o que ler

Na pasta de contexto (a pasta atual, a que tem os arquivos de contexto):

- A peça. Se veio como arquivo, leia o arquivo. Se veio colada na mensagem, grave em `peca.md` na pasta atual antes de qualquer coisa, com as quebras de linha da peça (o script lê arquivo, não mensagem). Se a mensagem marca as quebras de linha com um sinal, restaure as quebras ao gravar.
- `voz.md` inteiro: os sinais de assinatura, as recusas duras e os exemplos de ouro são a régua do concorrente e do editor.
- `banidas.txt`: alimenta o script e o editor.
- `icp.md`: quem lê, o que o preocupa, jargão que usa e não usa, o que o produto não faz, claims que precisam de aval. É a régua do leitor do ICP.
- `prova.md`: os únicos números e casos que a peça pode usar sobre o autor. É a régua do cético.
- O tipo de peça, se quem chamou informou (post e qual dos sete tipos, legenda, roteiro de carrossel). Sem tipo, revise como post de LinkedIn e aplique só a regra dos dois lados do tamanho.
- A data prevista de publicação, se quem chamou informou. Leia a peça como o leitor desse dia: prazo, "hoje", "essa semana" e "este mês" contam a partir dela. Sem data, a referência é o dia da revisão, e prazo vencido é achado do cético.

Arquivo de contexto ausente: diga qual falta na linha de veredito e revise com o que há. O crítico que depende do arquivo ausente fica limitado pelo teto que o painel define para esse caso: sem `prova.md`, cético no máximo 10; sem `icp.md`, leitor do ICP no máximo 12; sem `voz.md`, editor no máximo 16 e concorrente no máximo 14; sem `banidas.txt`, o editor confere só travessão e emoji e o JSON diz isso.

Não leia: `voz-bruta.md`, `base-conteudo.md`, `learnings.md`, `materiais/`, rascunhos, briefing com justificativa. Nada disso é a peça, e o que a voz tem de útil para a revisão já está compilado em `voz.md`.

## Etapa 1: checagem mecânica

Rode, numa chamada só, o script e a contagem de caracteres (a pasta `scripts/` fica dois níveis acima deste SKILL.md; omita o segundo argumento se `banidas.txt` não existe):

```bash
bash [raiz do plugin]/scripts/check-voz.sh peca.md banidas.txt; echo "codigo $?"; wc -m peca.md
```

O script imprime cada linha com travessão, emoji ou termo banido, seguida do nome da falha; `codigo 0` é limpo (o `echo` no meio da cadeia existe porque o código de saída que sobra no fim é o do `wc`, não o do script). Copie o que ele acusou para `check_voz` (quantas linhas com travessão, quantas com emoji, quais termos) e a contagem para `tamanho`. Não substitua o script por leitura quando ele pode rodar: o grep enxerga o que o olho pula.

Se não puder rodar (sem terminal, sem o script), confira por leitura, procurando travessão (o traço longo), emoji e cada termo de `banidas.txt`, conte os caracteres com a ferramenta que tiver, e grave `rodou: false`.

O resultado entra no editor, não nos outros quatro: um travessão é problema de edição, não de credibilidade nem de gancho.

## Etapa 2: painel

Leia `references/painel.md` e passe pela peça cinco vezes, uma por crítico, na ordem: cético, estranho, concorrente, leitor do ICP, editor. Para cada um, anote a nota de 0 a 20 e os achados antes de passar ao próximo. Aplique os tetos do painel quando o defeito que eles descrevem aparecer; dentro do teto, a gravidade move o número.

Regras que não podem falhar:

- Número que prova algo sobre o autor ou a oferta (credencial, operação ou resultado) sem lastro em `prova.md` zera o cético. Não procure uma justificativa para o número: se não está em `prova.md` e não veio no briefing, é sem lastro. Número de cena (hora, duração, quantos agentes) é narrativa, não prova, e não zera. Conta ou data errada que muda um fato (soma que não bate, contagem de dias sem o ponto de partida, data trocada) é teto de 12 no cético, nunca achado pontual: peça com fato errado não chega a `aprovar`. Número externo tem lastro quando está atribuído no corpo, no primeiro comentário que a peça anuncia, em `prova.md` ou no briefing; o lastro não precisa estar no corpo.
- Sem teto derrubado, o crítico começa em 20 e desce 1 ponto por achado pontual, até 14. Eixo sem achado fica em 20: partir de menos torna `aprovar` impossível na conta. Só duas regras são tendência forte, e custam pontos sem teto: linha 1 com mais de 15 palavras e instrução na forma "tu" em vez do imperativo em "você". Todo o resto que o painel lista como teto é teto, inclusive paralelismo negativo em qualquer forma da seção 3F do `dna-da-voz.md` ("X, não Y" incluído; contraste que não nega, como dimensão acrescentada ou concessão em que o primeiro termo segue valendo, não é), linha 1 sem fato, cena nem número, fecho de moral e assunto fora do leitor. A âncora é forma e substância: peça que segue o painel e tem substância real soma 85 ou mais; ter sido publicada não vale nota.
- Cada defeito é cobrado do crítico dono dele, uma vez. Um termo banido custa ao editor, não ao editor e ao concorrente.
- `[FALTA: ...]` na peça não é defeito de quem escreveu: é a lacuna marcada como o sistema manda. Só impede o `aprovar`.
- Sem base para avaliar um eixo (arquivo ausente), o painel diz o teto; não invente o que o arquivo diria.

## Etapa 3: veredito e correções

Some os cinco. Aplique a faixa do painel (85 aprova se nenhum crítico está abaixo de 15; 65 a 84 reescreve; abaixo de 65 descarta) e as regras que passam por cima da soma (`[FALTA]` nunca aprova; cético em zero nunca aprova; crítico abaixo de 15 nunca aprova).

Monte as correções na ordem do que mais pesa: primeiro o que derrubou um teto, depois os achados de 8 a 13, depois os pontuais. Cada uma com o trecho literal (a menor citação que identifique o lugar), o problema em uma frase, com o nome do crítico, e a sugestão concreta. Em `descartar`, a primeira correção nomeia o problema de raiz (tese, ângulo ou prova) e as demais podem ficar de fora.

Antes de responder, confira:

1. A soma de `por_critico` é igual a `nota`.
2. O veredito bate com a faixa e com as regras que passam por cima.
3. Todo `trecho` existe na peça, letra por letra.
4. Nenhuma `sugestao` reescreve mais que o trecho dela.
5. `check_voz` reflete o que o script imprimiu, ou diz `rodou: false`.
6. Sua resposta não tem travessão, emoji nem termo de `banidas.txt` fora do campo `trecho`; o revisor que acusa o que ele mesmo comete perde a autoridade da nota. O `trecho` é citação literal e carrega o defeito que aponta (o travessão acusado aparece nele), por isso um grep na resposta pode acusar essa linha e só ela. A linha de veredito aponta o lugar e nunca cita o trecho: "tire o travessão do parágrafo que começa em 'Dá pra ler'", e não a frase com o travessão dentro.
7. `contexto_limpo` reflete onde a revisão rodou, e a linha de veredito carrega a ressalva quando é `false`.

## O que este especialista não faz

- Não reescreve a peça nem entrega versão corrigida. Sugestão é para um trecho; a peça inteira é de quem escreveu.
- Não lê rascunhos, briefing com justificativa nem a conversa em que a peça nasceu.
- Não inventa fonte para número sem lastro, não preenche `[FALTA]` e não confirma claim que precisa de aval.
- Não muda a tese nem o ângulo. Se a tese é o problema, descarta e diz por quê.
- Não dá nota por simpatia nem por esforço: a nota é a soma, o veredito é a faixa.
- Não publica nada e não grava em `base-conteudo.md`.

## Ajustes depois da entrega

- "Revisa de novo": a peça corrigida passa pelo processo inteiro, do zero, e sai um JSON novo. Diga as duas notas na linha de veredito, para a pessoa ver o que mudou.
- "Discordo da correção X": a palavra da pessoa vence a do revisor. Se ela disser que a regra por trás da correção não vale para ela, registre em `learnings.md` a regra, o motivo dela e como aplicar da próxima vez, para o revisor não cobrar de novo o que ela já rejeitou.
- "Só o cético" ou "só o tamanho": rode só o crítico pedido e devolva o JSON com os outros campos marcados como não avaliados (`null`), sem inventar nota para o que não leu.
