# Casos de avaliação

Cada caso é um arquivo `evals/cases/<especialista>/NN.md` com frontmatter e corpo.

Frontmatter (um campo por linha, no formato `campo: valor`):

- `especialista`: nome do especialista avaliado.
- `fixture`: caminho relativo a `evals/fixtures/`, com o contexto no formato novo.
- `fixture_legado`: caminho relativo a `evals/fixtures/`, com o contexto no formato da squad antiga.
- `prompt_novo`: pedido enviado ao especialista da squad nova.
- `prompt_antigo`: pedido equivalente enviado à squad antiga.
- `pedido`: o mesmo pedido de negócio em forma neutra, sem nome de skill, de plugin nem de arquivo de fixture. É o único pedido que o juiz enxerga.

Corpo: a rubrica específica do caso, lida pelo juiz junto com o contexto do autor.

Regras de paridade (o portão só vale se os dois lados receberem a mesma coisa):

- `prompt_novo` e `prompt_antigo` carregam os mesmos fatos de negócio, a mesma peça pedida e a mesma restrição de forma (inclusive faixa de tamanho). A diferença fica só no que é mecânica de cada squad (qual skill chamar, qual etapa, quais campos de formulário).
- As faixas de tamanho seguem `.superpowers/sdd/plano/task-7-brief.md`: teardown 1.400 a 2.500, caso 1.500 a 2.500, build ou bastidor 1.500 a 2.900, educativo acima de 1.400, posição abaixo de 900, lead magnet acima de 1.400, anúncio pessoal abaixo de 900. Rubrica não cobra tamanho que o prompt não declarou.
- O juiz recebe `pedido` mais a rubrica, nunca `prompt_novo` nem `prompt_antigo`.

Uso:

- `scripts/eval/run-case.sh <plugin-dir> <caso.md> <modelo> <saida.md> [novo|antigo]` gera uma saída.
- `scripts/eval/judge.sh <caso.md> <saida-nova> <saida-antiga> <veredito.json> <fixture-dir>` compara as duas saídas em contexto limpo e embaralhado, e grava o veredito.
- `scripts/eval/judge-msg.sh` monta a mensagem do juiz (contexto, `pedido`, rubrica e as duas saídas) e imprime no stdout, sem gastar modelo.
- `scripts/eval/coletar-saida.sh <saida.md> <fixture-dir>` junta à mensagem final os arquivos que a execução gravou (`saida/**` e qualquer arquivo novo ou alterado em relação à fixture), rotulados pelo nome.
- `scripts/eval/limpar-nomes.sh` troca nome de skill e de plugin por termo neutro nos dois lados, pela tabela `scripts/eval/nomes-de-skill.tsv`.
- `bash scripts/eval/test-judge-cego.sh` prova que a mensagem do juiz não carrega nome de skill, nem os prompts do caso, e que os arquivos gravados chegam aos dois lados.
