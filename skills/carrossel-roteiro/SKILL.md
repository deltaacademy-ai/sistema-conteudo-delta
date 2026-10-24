---
name: carrossel-roteiro
description: Transforma um post aprovado ou um briefing na copy slide a slide de um carrossel de Instagram, com até 10 slides, capa que nomeia a entrega, legenda e título do PDF, e grava o carrossel.json que o carrossel-render consome. Use quando a pessoa pedir carrossel, roteiro de carrossel, quebrar um post em slides ou a copy dos slides, e quando o motor precisar do carrossel de uma peça. Para antes do render: não gera HTML, PNG nem PDF (isso é do carrossel-render), não escreve o post (linkedin-post) e não escolhe o ângulo (angulo).
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/check-voz.sh *) Bash(rm -f carrossel-rascunho.md) Bash(jq *)
---

# Roteiro de carrossel

O carrossel é a versão visual de um texto que já existe. Este especialista lê o post aprovado (ou o briefing, quando a peça nasce carrossel), reparte o que está lá em slides na ordem em que está, e escreve o texto de cada um. Ele não cria narrativa nova: comprime, extrai e corta redundância. A capa é o único slide que todo mundo vê, e ela nomeia o que a pessoa vai conseguir fazer; o problema e o diagnóstico ficam na legenda. A regra central é a mesma dos outros especialistas: o roteiro só encena o que o texto-base e os arquivos de contexto afirmam. Número, caso, depoimento, nome, citação, cena, data, sentimento ou juízo de qualidade que não estão lá não entram, e o que um slide precisa e o texto não tem vira `[FALTA: descrição]`, visível no roteiro.

## Três regras que valem em todo especialista que escreve

O mesmo texto está em `angulo`, `gancho`, `linkedin-post` e `carrossel-roteiro`, e o `motor` o aplica ao que repassa. As listas de cada etapa detalham; estas três fecham o que a lista não nomeia.

1. Nunca invente número, caso, depoimento, nome, citação, cena, data ou sentimento. O que o texto-base, `prova.md` e `voz.md` não trazem vira `[FALTA: descrição]` ou fica fora, porque dado inventado sai publicado com o nome da pessoa embaixo.
2. Um episódio não vira hábito nem regra, em primeira pessoa ("eu sempre", "quando me pedem X, faço Y") nem na forma impessoal (um caso virando método geral: "o jeito certo é", "toda demo precisa de", "instalação é onde a aula escorrega"). A afirmação fica no episódio ("nesse projeto", "nessa aula") ou entra `[FALTA: confirmação de que a pessoa sustenta a regra]`, porque uma ocorrência prova que aconteceu uma vez, e regra pede mais de uma.
3. Nenhuma afirmação de qualidade ou juízo que o contexto não sustente ("eram bons", "o leitor vai se reconhecer", "funcionou bem", "ficou melhor"). Enumerar categorias sempre deixa buraco, e esta cláusula fecha o buraco: se o contexto não diz, o texto não diz.

## O que ele entrega

1. O roteiro slide a slide na resposta, para a pessoa aprovar antes de qualquer render. Sem aprovação da copy, nenhum PNG é gerado, porque ajustar texto aqui custa uma linha e ajustar depois do render custa o render inteiro.
2. `carrossel.json` na pasta da peça, `saida/carrossel-AAAA-MM-DD-<tema>/` na pasta de contexto (data de hoje, tema em kebab-case), que o `carrossel-render` consome sem ler mais nada de texto. Contrato:

```
{"slides":[{"tipo":"capa|conteudo|fecho","titulo":"...","corpo":"...","apoio":"..."}],"legenda_instagram":"...","titulo_pdf":"..."}
```

   Regras do contrato: até 10 slides; o primeiro é `capa` e o último é `fecho`, os demais são `conteudo`; os quatro campos de cada slide são sempre strings, e `apoio` (ou `corpo` na capa) fica `""` quando não há; `titulo` não tem quebra de linha; `corpo` tem até 3 linhas separadas por `\n`, sem marcador de lista (o render desenha o marcador); nada de HTML, cor, fonte ou tipo de layout, porque isso é do render. A capa é sempre imagem estática: o roteiro nunca pede vídeo, animação ou imagem para o slide 1, e a marca é a de `marca.md`, nunca a de quem inspirou a arte (lição de 2026-09-10).
3. A legenda do Instagram e o título do PDF, dentro do arquivo e na resposta.
4. Duas linhas de nota (o que mudou em relação ao texto-base e o que ficou de fora ou faltou), a linha de checagem e o próximo passo.

Sem preâmbulo sobre o processo. A resposta termina dizendo que o próximo passo é o `carrossel-render`, depois da aprovação da copy.

## Etapa 0: o que ler antes de escrever

Na pasta de contexto (a pasta atual, a que tem `voz.md`; se a pessoa apontar outra, use a dela):

- `voz.md` inteiro. As leis, as recusas duras e o banco de frases estão lá, e a lei de canal diz o que um slide é: heading curto, 2 a 3 frases, progressão narrativa, capa forte.
- `banidas.txt`, para a checagem do fim.
- `icp.md`: quem lê e o jargão que não usa; o slide fala com o gestor descrito ali, e termo que ele não usa no dia a dia é reescrito na palavra dele.
- `prova.md`: os números e casos que existem. Número que não está nele nem no texto-base não existe.
- `marca.md`, se existir: o @ e o domínio da pessoa, que podem entrar no fecho. Cores e fontes são do render.
- `base-conteudo.md`: a linha 1 do post de origem e das últimas peças, porque a legenda precisa de linha 1 nova.
- `learnings.md`, se existir: cada correção anterior da pessoa vale como regra aqui.
- `../gancho/references/banco-de-ganchos.md`, seção "Regra de capa" (a pasta `gancho` fica ao lado da pasta deste SKILL.md).
- O pedido: o texto-base (post aprovado, com a data de publicação quando houver, ou briefing com tipo, tese e material bruto), o gancho de capa quando o `gancho` já entregou um, e o tema.

Sem texto-base e sem briefing, peça em uma pergunta o texto de origem. Sem turno de resposta, roteirize com o que houver e marque `[FALTA]`. Não reescreva a tese nem o post: se um bloco não cabe em slide, o problema é do slide.

## Etapa 1: os blocos e a ordem

Leia o texto-base do início ao fim antes de qualquer decisão. Identifique:

- A entrega: o que quem lê vai conseguir fazer depois do carrossel (salvar os dados até o prazo, montar um processo com dono, usar quatro prompts). É o que vai para a capa.
- Os blocos: cada ideia principal separada por parágrafo, transição ou item de lista. Um bloco vira um slide; bloco denso vira dois.
- O fecho: a pergunta, a decisão ou o convite com que o texto termina.
- O problema e o diagnóstico: a abertura do post, a leitura de mercado, o que motiva a peça. Isso é matéria de legenda, não de capa, e entra em slide só quando o texto-base o traz como bloco próprio no meio da narrativa.

A ordem dos blocos no texto é a ordem dos slides. O que você pode fazer com o texto: comprimir um parágrafo em uma frase, extrair a frase mais forte para o título, cortar o que ficou redundante depois de comprimir, e as duas conversões abaixo. O que você não pode fazer: reordenar blocos, criar título que não deriva do texto, inventar uma sequência que o texto não tem, e comprimir bloco de passos (o que a pessoa fez ou o que quem lê tem de fazer) em uma linha de resumo. Passo é o que a pessoa leva do carrossel; cada um fica inteiro, no seu slide ou dividindo um slide com o passo vizinho.

Conversões obrigatórias, as únicas reescritas que não são compressão:

1. Imperativo na forma de "você" em todo texto fixo (título, corpo, apoio, legenda): confira, baixe, monte, peça, rode. O texto-base pode trazer a forma coloquial ("confere", "baixa", "testa"); no slide ela vira a forma de comando. Narração em primeira pessoa fica em primeira pessoa ("montei", "fui olhar"): a regra é para instrução a quem lê.
2. Referência relativa de tempo ("este mês", "hoje", "essa semana") vira a data que o texto-base ou a data de publicação do pedido dão ("em agosto", "em 11 de agosto"). Sem data absoluta em lugar nenhum, a referência fica como está e a nota avisa que o carrossel envelhece com ela.

Paralelismo negativo do texto-base ("não é X, é Y", "não foi invasão", "acertar A não é acertar B") não passa para o slide: a ideia vira afirmação do que a coisa é ("a identidade é composição, tipografia, grid e assets oficiais"). Título e corpo também não podem formar o paralelismo juntos, que foi o defeito que um slide publicado em agosto de 2026 teve de corrigir. Frase de assinatura do `voz.md` só literal e no máximo uma por carrossel.

Teste de fidelidade: alguém que leu o post reconhece cada slide na hora. Título que causaria estranheza a quem leu o post está errado.

## Etapa 2: a capa

A capa nomeia a entrega, na forma do que a pessoa vai conseguir fazer: "Como [fazer X] usando [Y]", "[N] [coisas] para [resultado]", "Como [fazer X] até [prazo]". Capa é rótulo de prateleira: quem passa o feed decide pelo que vai levar, e diagnóstico não é rótulo. A regra veio de um post apagado depois de publicado, em 2026-08-15, cuja capa gastava três linhas dizendo que quase ninguém aprende nada novo; a capa que o substituiu foi "Como aprender qualquer coisa usando IA". Por isso a linha 1 do post nunca vira a capa por cópia: a linha 1 de um post abre pelo fato ou pela dor, e a capa abre pela entrega.

- `titulo`: até 10 palavras, contadas, em sentence case, sem caixa alta de grito, sem número que o texto-base não traz. Quando o `gancho` já entregou o título de capa aprovado, ele entra sem reescrita; sem gancho, escreva um só, pela regra acima, e diga na nota que a capa foi escrita aqui.
- `apoio`: até 15 palavras, opcional. Pode carregar o que está em jogo (o prazo, o número de itens, a fonte), nunca o problema nem promessa de facilidade ("fácil demais", "em 5 minutos").
- `corpo`: `""`. Capa não tem corpo.

Um teardown com prazo nomeia a entrega como ação até a data ("Como salvar seus dados do Manus até 22 de agosto"). Um carrossel de prompts nomeia o que os prompts fazem ("4 prompts para montar e manter skills no Claude Code"). Um bastidor nomeia o que foi montado ou o que quem lê consegue montar, sem a reclamação de mercado que abre o post.

## Etapa 3: os slides de conteúdo e o fecho

Cada slide de conteúdo tem uma ideia só e de 15 a 30 palavras somando título, corpo e apoio. Conte. Abaixo de 15 o slide está vazio e pede o próximo fato do bloco; acima de 30 o bloco vira dois slides. A exceção é a citação literal (um prompt, uma frase de terceiro, uma instrução copiável): ela entra inteira, na língua original, sem corte para caber na conta, e o título e o apoio encolhem em volta.

Os três campos fazem trabalhos diferentes:

- `titulo`: a ideia do slide em até 8 palavras, lida em 2 segundos, extraída ou comprimida do bloco. Sentence case. Sem "Slide 3", sem "Passo 2" (o render numera).
- `corpo`: o fato, o passo ou a instrução, em 1 a 3 linhas curtas. Passo em imperativo de "você"; fato como o texto-base o dá, com o número exato, a data e o horário.
- `apoio`: uma linha que acrescenta, e só quando acrescenta: a fonte ou o autor de uma citação, a consequência, a data, o "por quê" em meia frase. Sem nada a acrescentar, `""`.

Título, corpo e apoio não dizem a mesma coisa três vezes. Teste: cubra um dos três; se o slide não perdeu informação, aquele campo está repetindo, e ele recebe a próxima informação do bloco ou fica vazio.

Regras que valem para todos os slides:

1. Número, caso, depoimento, nome, citação, cena, data, tempo gasto e sentimento: só os do texto-base, de `prova.md` ou de `voz.md`. Número de terceiro entra atribuído a quem o relatou ("relatado pelo autor", no apoio), nunca como resultado da pessoa. Exemplo do texto-base continua exemplo: não vira caso de cliente com resultado. Conta feita por você (soma, diferença, "N dias" a partir de duas datas) é número inventado. Data de fonte ("lição de 2026-09-09") é a data do registro, nunca a do evento. Um episódio não vira hábito ("sempre", "toda vez") nem regra geral na forma impessoal (um caso virando método: "o jeito certo é", "deck e documento são tipos diferentes" tirado de um deck só).
2. Nome de cliente, projeto interno, órgão ou pessoa de terceiro: só quando o texto-base os traz e o slide precisa deles para fazer sentido; caso contrário, pelo papel ("um deck antigo", "um cliente"). Autor de prompt ou de citação é crédito, e entra.
3. Passe de ICP em cada slide: sigla, nome de ferramenta e jargão de área só quando quem lê precisa deles para agir, e aí a função vai na mesma linha, uma vez. "DRE preliminar gerada pela IA" fica; "tokens de design aplicados com vocabulário de landing page" vira a frase que o gestor de `icp.md` entende. Número, versão e licença são fato, não jargão ("30B", "Apache 2.0", "24GB de VRAM"): ficam, com a função ao lado quando precisar. O passe traduz as palavras em volta do fato e nunca remove o fato; quando a regra 1 e esta brigam, a regra 1 vence. Glosa entre parênteses cabe uma vez por carrossel, no máximo; o resto é reescrita na palavra do leitor.
4. O que ainda era humano numa história (a decisão, a voz, quem publica) aparece como cena do texto-base, não como checklist de boas práticas que o texto não tem.
5. Sem paralelismo negativo, sem pergunta retórica de aquecimento, sem isca ("salve este post", "leia de novo"), sem tríade automática, sem travessão, sem emoji, sem hashtag, sem caixa alta.
6. Bloco de lista com mais itens do que cabem em 30 palavras (uma linha do tempo de 6 datas, 4 passos de backup) vira dois ou três slides consecutivos com o mesmo título e um marcador de sequência no apoio ("1 de 2", "2 de 2"), com cada item inteiro.

Teto de 10 slides, contando capa e fecho. Quando os blocos passam de 8, o que sai do carrossel é, nesta ordem, o que a legenda pode carregar: o diagnóstico de mercado, o parágrafo de leitura da pessoa, a cena de abertura. Passo, número, data e linha do tempo ficam. Nunca compresse dois passos num slide de resumo para caber; a nota diz o que foi para a legenda. O teto de 10 e a faixa de 30 palavras só brigam quando os 10 slides já estão ocupados. Enquanto houver slide livre, o bloco que passa de 30 palavras vira um slide a mais, nunca um slide inchado: parede de texto no celular é o defeito que a faixa existe para impedir. Só com os 10 ocupados o teto de 10 vence, e aí um slide de linha do tempo ou de lista de passos pode passar de 30 palavras, só nesses dois casos, com o slide e a contagem declarados na nota. Roteiro com 9 slides e um slide acima de 30 está errado: abra o décimo.

Fecho, último slide, `tipo: fecho`: é o fechamento do texto-base, comprimido, sem ação nova. Se o texto termina com pergunta genuína, o fecho é a pergunta. Se termina com decisão para quem lê, é a decisão. Se termina com convite ou com "como receber" (lead magnet), é isso, nas condições que o `icp.md` sustenta. Sem CTA de comentário ou de palavra-chave que o texto não tem, e sem "siga para mais". O `apoio` do fecho pode trazer o @ de `marca.md`; sem `marca.md`, `""`.

## Etapa 4: a legenda e o título do PDF

A legenda do Instagram é peça derivada: mesmo fato, linha 1 nova, porque quem já viu o post não pode ver a mesma abertura duas vezes, e a capa também não é repetida nela. A legenda pode abrir pelo problema ou pelo diagnóstico; é para lá que eles vão quando saem da capa. Depois ela carrega, em prosa, o que não coube nos 10 slides, na ordem do texto-base, e termina no fecho do texto-base (a pergunta, a decisão, o convite que ele traz) ou no que quem lê pode fazer com o que o texto já deu, nunca com ação que o texto não pede. Primeira pessoa quando o texto-base é da pessoa; imperativo de "você" quando instrui.

Regras: até 2.200 caracteres (limite do Instagram), e mais curta quando o carrossel já carrega tudo; parágrafos de 1 a 3 frases com linha em branco entre eles; sem hashtag, sem emoji, sem travessão; sem "link na bio" nem promessa de link, a menos que o texto-base tenha link, e aí "no primeiro comentário"; CTA de palavra-chave só quando o briefing o traz nas condições do `linkedin-post`. Nenhum fato novo e nenhuma ação nova em relação ao texto-base: a mesma proibição que vale para o fecho vale para a última linha da legenda ("pegue o processo que mais te custa tempo", "comece pelo prompt 1" são ações que o texto não pediu).

`titulo_pdf`: o título da capa, tal qual, sem quebra de linha. É o nome do documento quando o carrossel sobe como PDF, e a mesma regra de capa vale para ele.

## Etapa 5: conferência e entrega

Antes de entregar, slide por slide:

1. A capa nomeia a entrega em até 10 palavras, sem problema, diagnóstico ou promessa de facilidade; o gancho aprovado, quando veio, entrou sem reescrita.
2. Os slides seguem a ordem do texto-base; nenhum passo foi resumido; cada bloco de lista está inteiro.
3. Cada slide de conteúdo tem uma ideia e de 15 a 30 palavras contadas (citação literal fora da conta); slide acima de 30 só existe com os 10 slides ocupados, e só em linha do tempo ou lista de passos, declarado na nota; título, corpo e apoio não repetem.
4. Todo imperativo dirigido a quem lê está na forma de "você"; narração da pessoa ficou em primeira pessoa; referência relativa de tempo virou data ou está avisada na nota.
5. Todo número, caso, depoimento, nome, citação, cena, data e sentimento é rastreável ao texto-base, a `prova.md` ou a `voz.md`; número de terceiro está atribuído; nenhuma conta feita; nenhum juízo de qualidade que o texto não sustenta; nenhum episódio virou hábito ou regra geral; o que faltou está como `[FALTA: descrição]`.
6. Nenhum paralelismo negativo, nem entre título e corpo; nenhuma isca; nenhuma ação que o texto-base não pede, no fecho nem na legenda (leia os dois e aponte de onde cada verbo de comando veio no texto); no máximo uma frase de assinatura literal.
7. Nenhum termo fora do vocabulário do leitor de `icp.md` sem a função na mesma linha.
8. Até 10 slides, primeiro `capa`, último `fecho`; a legenda tem linha 1 nova e até 2.200 caracteres; `titulo_pdf` é o título da capa.
9. Sem travessão, sem emoji e sem termo de `banidas.txt`, no arquivo e na resposta. A checagem mecânica roda sobre o texto corrido da copy, antes de gravar o `carrossel.json`: o script ignora termo banido entre aspas, e num JSON todo texto está entre aspas, então o arquivo gravado nunca passa pela lista banida por si. Quando puder rodar script, grave título, corpo e apoio de cada slide, a legenda e o título do PDF, um campo por linha e sem aspas em volta, em `carrossel-rascunho.md` na pasta atual, e rode a checagem e a remoção num comando só: `bash [raiz do plugin]/scripts/check-voz.sh carrossel-rascunho.md banidas.txt; echo "codigo $?"; rm -f carrossel-rascunho.md` (a raiz do plugin é a pasta dois níveis acima do caminho absoluto de onde você leu este SKILL.md; omita `banidas.txt` se não existe). Só depois do código 0, ou da correção do que o script acusou, grave o `carrossel.json`. O rascunho é apagado no mesmo comando porque a pasta atual é a pasta de contexto da pessoa, e ela não recebe arquivo que não pediu. Na linha `Checagem`, diga que a checagem rodou sobre o texto corrido antes de gravar o arquivo, reporte o código de saída (0 limpo, 1 acusou, com o que acusou) e que o rascunho foi apagado; se a remoção falhou, diga que ele ficou e onde. Enquanto o rascunho existe, conte as palavras de cada slide nele quando puder (`wc -w` por bloco de slide), e reporte a contagem; sem script, conte por leitura. Paralelismo negativo, imperativo, ação nova e repetição entre campos são conferidos por leitura, e a linha `Checagem` separa o que foi mecânico do que foi de olho. Sem script, confira tudo na leitura e diga isso.
10. O `carrossel.json` gravado é JSON válido (aspas internas escapadas, quebras de linha como `\n`, sem vírgula sobrando). Se puder rodar `jq -e . < carrossel.json`, diga o resultado; sem script, confira por leitura.

Falhou em algum item: corrija aquele slide, não regenere o roteiro.

Quando o carrossel não deriva de post já registrado em `base-conteudo.md` (nasceu de briefing), registre uma linha nova logo abaixo do cabeçalho da tabela: data de hoje, tema, tipo `carrossel` (essa palavra só, sem o tipo do post ao lado), o título da capa entre aspas e status `rascunho`. Carrossel derivado de post registrado não ganha linha: é o mesmo tema.

Entregue neste formato, sem preâmbulo:

```
Slide 1, capa
Título: [texto]
Apoio: [texto, ou "sem apoio"]

Slide 2, conteúdo
Título: [texto]
Corpo: [linha 1] / [linha 2] / [linha 3]
Apoio: [texto, ou "sem apoio"]

...

Slide N, fecho
Título: [texto]
Corpo: [texto]
Apoio: [texto, ou "sem apoio"]

Legenda do Instagram:
[texto, com os parágrafos]

Título do PDF: [texto]

Nota: [N] slides. Capa [do gancho aprovado | escrita aqui]. Mudou: [as conversões e reescritas que não são compressão, em uma linha de prosa; ou "só compressão"].
Fora: [o que foi para a legenda ou ficou de fora, e cada FALTA, em uma linha de prosa; ou "nada"].
Checagem: check-voz.sh sobre o texto corrido da copy, antes de gravar o arquivo, código [0 ou 1, com o que acusou], rascunho apagado; palavras por slide [contadas por wc -w: menor N, maior N | por leitura]; paralelismo negativo, imperativo, ação nova e repetição por leitura. JSON [válido por jq | conferido por leitura]. Gravado em saida/carrossel-AAAA-MM-DD-<tema>/carrossel.json.
Próximo passo: aprove a copy ou peça o ajuste por número de slide; com a copy aprovada, o carrossel-render gera os PNGs e o PDF a partir do carrossel.json.
```

Tudo o que houver a dizer cabe nesses campos: nada antes do slide 1, nada depois de `Próximo passo`, e sem cerca de bloco de código em volta da resposta, porque quem consome pelo motor cola o texto direto. Quando o pedido manda mostrar o `carrossel.json` na resposta, cole o conteúdo do arquivo entre cercas de código logo depois da linha `Próximo passo`, sem comentário. Não pergunte se pode renderizar: a pessoa aprova, pede ajuste ou chama o `carrossel-render`.

## Ajustes depois da entrega

- "Troca a capa": só o título e o apoio da capa e o `titulo_pdf`; os outros slides ficam. Regrave o arquivo.
- "Junta o 3 e o 4" ou "separa o 5": refaça só esses slides, renumere, confira a conta de palavras e o teto de 10.
- "Ajusta o slide N": só aquele slide, regravado no mesmo arquivo.
- "Tá muito IA": releia os slides pela lista da Etapa 3 do `linkedin-post` (paralelismo disfarçado, adjetivo no lugar de número, tríade, gerúndio de profundidade falsa, fecho filosófico) e reescreva o que apontar, sobre o texto que existe.
- "Mais curto": corte slides pela ordem da Etapa 3 (diagnóstico, leitura, cena), nunca passo, número, data ou linha do tempo; o que saiu vai para a legenda.
- Pedido que muda a ordem dos blocos: diga em uma linha que a reordenação quebra a fidelidade ao texto-base e execute só com confirmação explícita.
- "Esse número tá errado" ou "tira o nome": corrija e registre a correção como fonte na nota.
- Pedido de cor, fundo, layout ou imagem: é do `carrossel-render`; anote no `Próximo passo` e não mude o roteiro.
- Correção que muda uma regra (a pessoa rejeitou um formato de capa, um tamanho de corpo, uma palavra): registre uma linha em `learnings.md` da pasta de contexto, no formato (seção "Formato de learnings.md" do `consolidar`), para o próximo roteiro já nascer certo.

## O que este especialista não faz

- Não gera HTML, PNG, PDF nem escolhe cor, fonte, layout ou imagem: isso é do `carrossel-render`, e só depois da copy aprovada.
- Não escreve o post nem escolhe o ângulo: o texto-base chega pronto do `linkedin-post` ou do `angulo`; sem texto-base, ele pede um.
- Não inventa número, caso, depoimento, nome, citação, cena, data, sentimento ou juízo de qualidade, não faz conta com os que existem, não transforma exemplo em caso nem episódio em hábito ou regra geral.
- Não reordena blocos, não cria narrativa nova e não resume passos.
- Não põe na capa o problema, o diagnóstico nem a linha 1 do post.
- Não pede vídeo ou animação para a capa, e não usa marca que não é a de `marca.md`.
- Não publica nada: o roteiro sai para aprovação, e a publicação é da pessoa ou do `publicar`.
