---
name: carrossel-render
description: Transforma o carrossel.json aprovado (saída do carrossel-roteiro) nas imagens que a pessoa publica, 01.png a NN.png em 1080x1350 mais carrossel.pdf, tudo do mesmo render, na marca de marca.md e com fontes locais. Use quando a pessoa pedir para renderizar, gerar as imagens, o PDF ou os PNGs de um carrossel, ou quando o motor precisar das artes de uma peça com roteiro aprovado. Não escreve a copy dos slides (isso é do carrossel-roteiro), não inventa cor nem fonte, e não publica.
---

# Render do carrossel

Este especialista é o único do produto que produz imagem. Ele lê um `carrossel.json` já aprovado e a `marca.md` da pessoa, gera a camada de marca (`tokens.css`), monta um HTML com um `.slide` de 1080x1350 por slide, e roda o render que tira um PNG por slide e um PDF de todos, do mesmo HTML. Os PNGs vão para o Instagram; o PDF vai para o carrossel de documento do LinkedIn. A regra que manda em tudo aqui é a mesma dos outros especialistas, aplicada ao visual: nada entra por gosto. Cor e fonte vêm de `marca.md`; o que falta vira padrão declarado na resposta, nunca palpite. E o render não está pronto quando o comando termina: está pronto quando o arquivo foi medido e as imagens foram olhadas.

## O que ele entrega

Na pasta da peça (`saida/carrossel-AAAA-MM-DD-<tema>/`, a mesma onde o `carrossel-roteiro` gravou o `carrossel.json`):

1. `01.png` a `NN.png`, cada um exatamente 1080x1350, um por slide, na ordem do roteiro.
2. `carrossel.pdf`, uma página por slide, do mesmo render e com só as fontes declaradas embutidas.
3. `slides.html`, `tokens.css` e a pasta `fonts/`: a peça abre no navegador sem depender de nada fora da pasta. É o que a pessoa recebe quando o motor de render não roda.
4. `render-relatorio.json`: contagem, medidas, páginas, fontes do PDF, escala aplicada por slide, padrões e avisos.
5. Na resposta: os números conferidos, os padrões que entraram no lugar de item ausente em `marca.md`, os avisos, o que você viu nas imagens, a linha de checagem e o próximo passo.

Sem preâmbulo sobre o processo. Termine dizendo onde estão os arquivos e que o próximo passo é a pessoa publicar (o produto não publica; a legenda está em `carrossel.json`, campo `legenda_instagram`).

## Etapa 0: o que ler antes de renderizar

- `carrossel.json` da peça. Ele precisa existir e a copy precisa estar aprovada pela pessoa; sem aprovação, volte ao `carrossel-roteiro`, porque ajustar texto lá custa uma linha e aqui custa o render inteiro. Não edite o texto dos slides: se um slide não cabe, o problema é do roteiro, e você diz qual slide e quantos caracteres sobram.
- `marca.md` da pasta de contexto (a que tem `voz.md`; o script procura sozinho subindo a partir da pasta da peça). Dele saem as três cores (fundo, destaque, claro), as três fontes (display, texto, rótulo), o @ e o domínio. Cores e fontes marcadas `[FALTA]` contam como ausentes.
- `banidas.txt` da mesma pasta: o script a usa na checagem de voz do `carrossel.json` e do HTML. Sem ela, a checagem cobre só travessão e emoji, e a resposta diz isso.
- `learnings.md`, se existir: correção anterior da pessoa sobre arte, cor, fonte ou capa vale como regra aqui.
- O pedido: a pasta da peça, e qualquer instrução da pessoa sobre a saída (só PNG, só PDF, outra pasta).

Regras de marca que não dependem de leitura:

- A marca é a de `marca.md`, sempre. Quando a copy fala de outra empresa ou de quem inspirou a arte, a identidade continua sendo a da pessoa (lição de 2026-09-10).
- A capa é imagem estática. O slide 1 nunca é vídeo, animação ou imagem gerada; é o PNG deste render.
- Cor ou fonte que `marca.md` não traz não é escolhida por você. O script aplica o padrão de `template/tokens.css` e imprime "padroes aplicados"; você repete isso na resposta, para a pessoa saber que a marca dela ainda não está completa. Se ela quiser a marca certa, o caminho é preencher `marca.md` (especialista `contexto-negocio`), não trocar o valor na mão.
- Fonte é arquivo local. A skill traz Cal Sans, DM Sans e JetBrains Mono em `fonts/` (licença em `fonts/OFL.txt`). Fonte própria da pessoa entra como `.woff2`, `.ttf` ou `.otf` numa pasta `fonts/` ao lado de `marca.md`, com o nome em kebab-case da família e o peso opcional (`minha-fonte.woff2` ou `minha-fonte-400.woff2` e `minha-fonte-700.woff2`). Fonte declarada sem arquivo faz o render falhar de propósito, porque a alternativa (cair em fonte de sistema) produz um arquivo plausível e errado sem avisar (lição de 2026-07-30). Nunca contorne isso apontando para Google Fonts ou para uma fonte do sistema.

## Etapa 1: rodar o render

O script fica na raiz do plugin, dois níveis acima deste SKILL.md. Rode a partir da raiz do plugin ou com caminhos absolutos:

```bash
node [raiz do plugin]/scripts/render-carrossel.mjs <pasta-da-peca>/carrossel.json
```

Opções: `<pasta-de-saida>` como segundo argumento quando a pessoa quiser os arquivos em outro lugar; `--marca <marca.md>` quando o arquivo não estiver acima da pasta da peça; `--banidas <banidas.txt>` quando a lista não estiver ao lado de `marca.md`; `--fontes <pasta>` para uma pasta extra de fontes; `--so-html` para gerar HTML e tokens sem renderizar.

O que o script faz, nessa ordem, e o que ele recusa:

1. Valida o `carrossel.json`: até 10 slides, primeiro `capa`, último `fecho`, quatro campos string por slide. Erro aqui é erro de roteiro: devolva ao `carrossel-roteiro` com a mensagem.
2. Confere a voz do `carrossel.json` com `check-voz.sh --json` e a `banidas.txt` da pessoa (a que está ao lado de `marca.md`): travessão, emoji e termo banido em qualquer valor de texto, slide a slide. Num JSON todo valor está entre aspas, e a checagem comum tratava tudo como citação; o modo `--json` lê os valores como prosa e só exime citação marcada dentro do próprio texto (trecho entre aspas na frase). Um acerto para o render antes de qualquer imagem, com o termo e o caminho do slide na mensagem (`slides[3].corpo: [termo] ...`), porque imagem publicada custa mais para corrigir que uma linha de texto. O conserto é no roteiro, nunca aqui. Sem `banidas.txt`, o script diz que conferiu só travessão e emoji.
3. Lê `marca.md`, monta `tokens.css` e copia os arquivos de fonte para `fonts/` dentro da pasta da peça. Recusa contraste entre fundo e claro abaixo de 4.5:1 (o texto não daria para ler) e fonte sem arquivo. Avisa destaque com contraste abaixo de 3:1.
4. Monta `slides.html` a partir de `template/slide.html`: um `.slide` por entrada, com o texto escapado, o marcador de linha desenhado pelo CSS (o roteiro manda `corpo` sem marcador), o @ no topo, o domínio no rodapé e a barra de progresso. Roda `check-voz.sh` de novo no HTML gerado, com a mesma lista, e para se acusar: é a prova de que o que vai para a imagem passou, não só o que entrou.
5. Abre no Chromium do Playwright em 1080x1350, força o carregamento de cada `@font-face` e para se alguma não carregou. Reduz `--escala` por slide, em passos de 5% até 60%, quando o texto não cabe no miolo; slide que não coube nem assim é falha, com o número do slide na mensagem.
6. Tira o PNG de cada `.slide` e o PDF da página inteira, com `@page` de 1080x1350 e fundo impresso.
7. Confere o artefato, não o processo: conta os PNGs contra os slides, lê largura e altura de cada PNG no cabeçalho do arquivo, conta as páginas do PDF, extrai a lista de `/BaseFont` do PDF e compara com as famílias declaradas. Qualquer fonte a mais ou a menos é falha.

Saída 0 é "conferido, falta olhar". Saída 1 é falha com a razão na primeira linha que começa com `FALHA:`. Saída 2 é ausência de Node, Playwright ou Chromium: o HTML ficou pronto e a Etapa 3 muda.

## Etapa 2: olhar as imagens

Texto presente no HTML não é texto legível (lição de 2026-09-09), e o script só prova contagem, medida e fonte. Antes de declarar pronto, abra com a ferramenta de leitura de imagem pelo menos três PNGs: a capa e os dois slides de conteúdo com mais texto (o `render-relatorio.json` mostra a escala; slide com escala abaixo de 1.00 é o primeiro a olhar). Em cada um, confira:

- Dá para ler tudo, com contraste, sem texto cortado na borda nem sobreposto à barra de progresso.
- A fonte é a declarada (Cal Sans tem o "a" de andar único e o "t" curto; fonte de sistema no lugar dela aparece como Helvetica ou Arial).
- Título sem palavra órfã na última linha e sem quebra no meio de número ou sigla.
- O @ e o domínio são os de `marca.md`, e as cores são as de `marca.md`.

Se algo estiver errado, o conserto é no lugar certo: cor e fonte em `marca.md`; texto em `carrossel.json` via `carrossel-roteiro`; layout em `template/slide.html` só se a pessoa pedir mudança de template, e aí o portão roda de novo. Corrija e renderize de novo; não entregue com ressalva o que dá para consertar.

A checagem de voz já rodou dentro do script, duas vezes (no `carrossel.json` em modo `--json` e no `slides.html`), com a `banidas.txt` da pessoa; as linhas `voz:` da saída dizem o que foi conferido e com qual lista. Repita na resposta o que elas disseram. Se o script parou com `FALHA: ... acusou na checagem de voz`, o termo e o slide estão na mensagem: o conserto é no `carrossel.json` via `carrossel-roteiro`, e você não renderiza até a lista sair limpa. Se rodou sem `banidas.txt`, diga isso: a pessoa precisa saber que o termo banido dela não foi conferido.

## Etapa 3: quando o render não roda

Se o script sair com código 2 (sem Node, Playwright ou Chromium), não fique em silêncio nem finja que renderizou. Entregue `slides.html`, `tokens.css` e `fonts/` (o script já os gravou) e diga à pessoa, em três linhas, como exportar sem o script:

1. Instalar o motor uma vez, na raiz do plugin: `npm i playwright && npx playwright install chromium`, e rodar o comando de novo. É o caminho que produz os arquivos conferidos.
2. Sem instalar nada: abrir `slides.html` no Chrome, imprimir em PDF com tamanho de página personalizado de 1080 por 1350 px (11,25 por 14,06 polegadas), margens zero e "gráficos de fundo" ligado. Isso dá o `carrossel.pdf`.
3. Para os PNGs sem o script: exportar cada página do PDF como imagem em 1080x1350, ou capturar cada slide no navegador em zoom 100%.

Nesse caso a resposta diz que os arquivos não foram conferidos por script e que a pessoa precisa olhar cada slide antes de publicar.

## Contrato do template e dos tokens

`template/tokens.css` é a única camada de marca: três cores (`--fundo`, `--destaque`, `--claro`) e três fontes (`--fonte-display`, `--fonte-texto`, `--fonte-mono`), mais um `@font-face` por arquivo de fonte, todos com caminho relativo `fonts/…`. Tons suaves, linhas e brilho derivam por `color-mix()` dentro de `template/slide.html`; nenhum hex vive no template. Trocar de marca é trocar `marca.md`.

`template/slide.html` traz o CSS e três `<template>` (`capa`, `conteudo`, `fecho`) com os campos `{{titulo}}`, `{{apoio}}`, `{{corpo_linhas}}`, `{{handle}}`, `{{dominio}}`, `{{pagina}}` e `{{avanco}}`. Cada `.slide` mede 1080x1350, quebra página no PDF e tem `--escala` própria. Alinhamento à esquerda, margem de 80px, título em display, corpo em texto com marcador de linha na cor de destaque, apoio em mono, barra de progresso no rodapé. Mudança de layout é mudança de template, e o portão (`evals/cases/carrossel-render/portao.sh`) precisa passar de novo depois dela.

## Etapa 4: conferência e resposta

Antes de responder, confira:

1. O script terminou em `ok` e você abriu pelo menos três PNGs e leu o texto neles.
2. A resposta traz os números do relatório (slides, PNGs e medida, páginas e fontes do PDF, escala por slide) e o que você viu nas imagens, em uma linha cada.
3. Os padrões aplicados e os avisos do script aparecem na resposta, palavra por palavra, se houve algum.
4. As linhas `voz:` do script (o `carrossel.json` em modo `--json` e o `slides.html`, com a `banidas.txt` da pessoa) estão na resposta, com o que foi conferido e o resultado. Se o script não pôde rodar, rode `bash [raiz do plugin]/scripts/check-voz.sh --json <pasta-da-peca>/carrossel.json banidas.txt` à mão; se nem isso, diga que a conferência foi por leitura.
5. A capa é PNG estático, a marca é a de `marca.md`, e nenhum texto de slide foi alterado por você.

Quando a peça for de terceiro (o comprador é quem publica), feche com onde estão os arquivos e a legenda pronta em `carrossel.json`; a publicação é manual e é dele.
