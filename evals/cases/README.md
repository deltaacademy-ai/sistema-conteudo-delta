# Casos de avaliação

Cada caso é um arquivo `evals/cases/<especialista>/NN.md` com frontmatter e corpo.

Frontmatter (um campo por linha, no formato `campo: valor`):

- `especialista`: nome do especialista avaliado.
- `fixture`: caminho relativo a `evals/fixtures/`, com o contexto no formato novo.
- `fixture_legado`: caminho relativo a `evals/fixtures/`, com o contexto no formato da squad antiga.
- `prompt_novo`: pedido enviado ao especialista da squad nova.
- `prompt_antigo`: pedido equivalente enviado à squad antiga.

Corpo: a rubrica específica do caso, lida pelo juiz junto com o contexto do autor.

Uso:

- `scripts/eval/run-case.sh <plugin-dir> <caso.md> <modelo> <saida.md> [novo|antigo]` gera uma saída.
- `scripts/eval/judge.sh <caso.md> <saida-nova> <saida-antiga> <veredito.json> <fixture-dir>` compara as duas saídas em contexto limpo e embaralhado, e grava o veredito.
