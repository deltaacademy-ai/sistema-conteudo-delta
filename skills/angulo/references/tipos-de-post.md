# Tipos de post

Sete tipos de post de LinkedIn, cada um com a estrutura, a faixa de tamanho, o fecho e o dado sem o qual ele não entra. O `angulo` lê este arquivo para escolher o tipo; o `linkedin-post` lê para escrever. As estruturas vêm do que o Hugo mediu no nicho de IA aplicada a negócio no Brasil (coleta de agosto de 2026 nos perfis de maior alcance) e do que ele aprovou e rejeitou nos próprios posts. Quando o arquivo diz "o nicho faz X", é dado medido, não opinião.

## A primeira pergunta: o fato é sobre o mercado ou sobre a pessoa?

Sobre o mercado (uma notícia, um método, um caso, uma tese) pede tese, número e leitura de quem opera, no lado longo. Sobre a pessoa (um cargo novo, um acordo fechado, um convite, um reconhecimento) pede cena, uma frase de sentimento e convite, no lado curto, sem parágrafo de tese. A regra veio de um anúncio do Hugo em 2026-09-03, escrito por hábito no padrão de teardown, com dois parágrafos de argumento: ele pediu "algo mais simples, entusiasmado e humano", o texto caiu de 1.632 para 893 caracteres e ficou melhor. Tese é o diferencial em post de mercado e é peso morto em post cujo fato é sobre quem escreve, porque cada parágrafo de argumento empurra o texto para o registro de palestra.

## A regra de tamanho

O nicho é bimodal: ou abaixo de 900 caracteres, ou acima de 1.400. O meio (de 900 a 1.400) não performa e não existe na amostra, então nenhum post é entregue nessa faixa. Caracteres contam com espaço e quebra de linha, como o LinkedIn conta (`wc -m` no arquivo do post). Os tetos por tipo vêm dos maiores posts que performaram; acima deles a leitura cai.

O lado longo se sustenta com os fatos do briefing contados inteiros (ordem, consequência, leitura da pessoa); um briefing de 8 ou 10 fatos dá 1.500 caracteres sem cena nova. Só quando o briefing tem 2 ou 3 fatos o lado longo pediria invenção, e aí o post para no lado curto e a nota diz o que faltou. Glosa de termo não é material (uma por post, no máximo, em qualquer tamanho): o piso nunca autoriza uma segunda. Enchimento para chegar a 1.400 e corte até cair abaixo do mínimo do tipo são o mesmo erro: o tamanho é parte do pedido. Nada sai entre 900 e 1.400; se sair, a linha de checagem do post marca `TAMANHO FORA DA REGRA`.

| Tipo | Tamanho | Quando usar | Como fecha |
|---|---|---|---|
| Teardown de notícia | 1.400 a 2.500 | fato externo do dia, lido por quem opera | decisão para quem lê |
| Caso | 1.500 a 2.500 | história real com número e prazo | frase de posicionamento |
| Build ou bastidor | 1.500 a 2.900 | algo que a pessoa montou, com o que quebrou | no conteúdo |
| Educativo | acima de 1.400 | método ou passo a passo que a pessoa usa | o que fazer hoje |
| Posição | abaixo de 900 | uma tese só, defendida com exemplo | pergunta genuína |
| Lead magnet | acima de 1.400 | material pronto para entregar | como receber |
| Anúncio pessoal | abaixo de 900 | o fato é sobre a pessoa | convite |

## 1. Teardown de notícia

Quando: fato externo do dia (lançamento, mudança de regra, aquisição, prazo), lido por quem entrega software para cliente de verdade. É o formato dominante do nicho e o de maior alcance, e é onde a leitura de quem opera ganha da paráfrase de release.

Estrutura:

1. Linha 1: a notícia crua, em segunda pessoa, com quem lê como alvo: o que muda para ele e desde quando. "A empresa X publicou o artigo Y" é o anúncio, e quem lê já viu; o que ainda não viu é a notícia chegando nele. O ângulo fica para o corpo. Padrão aprovado pelo Hugo e registrado em `linkedin-copy/SKILL.md`, seção "O hook", linha 51 ("Agora o Claude vai marcar todos os textos que você gerar com ele").
2. Duas ou três linhas de contexto concreto: datas, valores, quem disse.
3. Bloco de 3 ou 4 itens com `→`, um por linha: o que quebrou ou o que mudou.
4. A leitura própria: o que quem opera vê que o release não diz, com o caso ou o número que a pessoa tem. Aqui é onde o post ganha do resto, e por isso é a leitura dela: a que o briefing registra, ou uma posição que ela já declarou no `voz.md` aplicada ao fato (dita como posição, nunca como experiência deste episódio), com a nota dizendo qual. Sem nenhuma das duas, o item sai, o post vai do bloco direto ao que muda para quem lê, e a nota leva `[FALTA: leitura da pessoa sobre a notícia]`.
5. O que isso muda na operação de quem lê.
6. Fecho em decisão para quem lê (o que conferir, o que cortar, o que perguntar ao fornecedor), nunca moral da história. Pergunta só quando é genuína.

Tamanho: 1.400 a 2.500 caracteres.

Fecho: decisão para quem lê. Fonte citada pelo nome no corpo; link no primeiro comentário quando o briefing o traz, e só então o post o anuncia.

Exige: fato com data e fonte no briefing. Número de terceiro entra atribuído à fonte, nunca como experiência da pessoa. A experiência própria fica no que o briefing dá.

Fica de fora: o título da fonte como tese do post (título de newsletter costuma ser paralelismo negativo), adjetivo de urgência, geopolítica como conclusão (deixa quem lê sem nada para fazer).

## 2. Caso

Quando: uma história real com problema, o que foi feito, o que mudou e número. É o formato de maior densidade de conteúdo da amostra e exige história verificável.

Estrutura:

1. Linha 1: o resultado ou o número da história.
2. A história em 4 a 6 parágrafos curtos, em primeira pessoa e na ordem em que aconteceu, com data e número: a situação, o que a pessoa fez, o que mudou. O número da linha 1 não volta no corpo. Sem IA nem oferta no meio, e sem glossário: o termo de área que a história não explica sozinha é reescrito na palavra de quem lê.
3. O princípio que a história prova, nomeado numa frase: o que o briefing registra que a pessoa concluiu, ou uma posição declarada no `voz.md` que o caso confirma, dita como posição e nomeada na nota.
4. Onde a oferta ou a IA entram hoje nesse mesmo problema, só quando o briefing pede; sem pedido, o post fecha no princípio.

Tamanho: 1.500 a 2.500 caracteres.

Fecho: frase de posicionamento. CTA de palavra-chave só quando o briefing pede e o material existe.

Exige: caso em `prova.md` (com número, prazo e permissão de uso) ou no briefing. Sem número e prazo, o caso não é caso: vira bastidor ou posição.

Fica de fora: nome de cliente, órgão ou parceiro que o briefing não traz; resultado que a história não teve ("ganhamos", "fechou") quando a fonte não diz; a lição virando promessa de venda.

## 3. Build ou bastidor

Quando: algo que a pessoa montou, testou ou operou, com o que quebrou junto. É a brecha mais aberta do nicho: todo mundo cita caso, quase ninguém abre um.

Estrutura:

1. Linha 1: a cena ou a dor que motivou, ou o resultado com número.
2. As peças do sistema, listadas e traduzidas para quem lê (nome de ferramenta fica quando quem lê precisa dele para agir).
3. O que rolou, afirmado, com número quando o briefing traz.
4. O que não funcionou. Obrigatório, como parte da história e nunca como nota de rodapé: é o que separa bastidor de vitrine.
5. O que continua sendo trabalho humano: o que o briefing diz que ficou com a pessoa, ou uma posição do `voz.md` sobre o que a máquina não decide, aplicada ao que quebrou e nomeada na nota; sem nenhuma das duas, o item sai e a nota registra a falta. Reação ao que quebrou ("aprendi", "me pegou") só a que o briefing declara.
6. O custo real do experimento (tempo, dinheiro), só se o briefing dá; sem o dado, o item sai e a nota registra.

Tamanho: 1.500 a 2.900 caracteres.

Fecho: no conteúdo, no que quem lê consegue fazer com isso. Sem CTA de palavra-chave. Pergunta só quando é genuína.

Exige: experimento que a pessoa fez de verdade, com o que falhou registrado no briefing. "Eu rodei X" só vale se ela rodou X.

Fica de fora: tempo gasto, prazo, número de usuários ou resultado que o briefing não dá; sentimento que a pessoa não declarou; tutorial de stack.

## 4. Educativo

Quando: um método, um framework ou um passo a passo que a pessoa usa de verdade e que quem lê consegue aplicar hoje.

Estrutura:

1. Linha 1: o que quem lê vai conseguir fazer, ou o erro que ele comete hoje, dito como fato.
2. O método inteiro: passos ou itens com `→`, cada um com o exemplo concreto. Lista de 10 vira 10 no post; cortar para "os 3 principais" muda o conteúdo.
3. Onde o método quebra ou não serve: a limitação junto do avanço.
4. O que fazer hoje, em imperativo na forma de "você".

Tamanho: acima de 1.400 caracteres (sem teto fixo; utilidade decide, parou de ser útil, parou de escrever).

Fecho: o que fazer hoje, ou frase de posicionamento. Sem CTA de palavra-chave: método que pede pedágio de comentário é lead magnet, e aí o material precisa existir.

Exige: método que a pessoa usa, com exemplo real. Adaptação para o contexto brasileiro é permitida no exemplo, nunca no número: valor em outra moeda fica na moeda original, porque conversão é conta.

Fica de fora: passo genérico de mercado que a pessoa não pratica, promessa de resultado.

## 5. Posição

Quando: uma tese só, que a pessoa sustenta de verdade, defendida com exemplo concreto. Único tipo que pode não ter produto nem material atrás.

Estrutura:

1. Linha 1: a tese, dita como afirmação positiva.
2. Três a cinco parágrafos defendendo, com o exemplo real (o que aconteceu, o que a pessoa decidiu) e a leitura que vale fora do caso específico.
3. Pergunta genuína: a pessoa quer a resposta e vai responder quem comentar.

Tamanho: abaixo de 900 caracteres.

Fecho: a pergunta genuína. É o único tipo que termina em pergunta por regra.

Exige: posição que aparece em `voz.md` ou no briefing, com exemplo real. Sem exemplo, a tese vira opinião solta e não entra.

Fica de fora: paralelismo negativo na tese ("não é X, é Y"), polêmica fabricada, nome de cliente, jargão de área sem tradução (a posição vale para quem lê fora daquela área).

## 6. Lead magnet

Quando: existe um material pronto para entregar (planilha, guia, prompt, diagnóstico, aula), registrado em `icp.md`, e o objetivo é comentário que vira contato.

Estrutura:

1. Linha 1: o material como coisa que a pessoa fez e que produz um resultado concreto, com número se o briefing traz (horas gastas, itens, onde rodou).
2. O que quem lê recebe, em itens com `→`.
3. O que ele consegue fazer com isso, uma frase por item que importa, sem adjetivo.
4. Como receber: comentar a palavra-chave e mandar conexão (sem conexão, a mensagem não chega). A palavra-chave é uma só, em caixa alta, na última linha.

Tamanho: acima de 1.400 caracteres.

Fecho: a instrução de como receber. É o único tipo em que o CTA de palavra-chave é o padrão, e mesmo assim entra no máximo em 1 de cada 3 posts (o nicho inteiro treinou quem lê a comentar palavra-chave, e isso cansa); a alternativa é o link no primeiro comentário, sem pedágio, que custa alcance e compra posicionamento.

Exige: material pronto, listado em `icp.md` ("O que a oferta entrega"). Material em construção não vira lead magnet: prometer o que não está feito é a promessa que a voz recusa.

Fica de fora: número de resultado sem fonte, "de graça" repetido, lista de benefícios com adjetivo no lugar de fato.

## 7. Anúncio pessoal

Quando: o fato é sobre a pessoa (cargo, acordo, prêmio, evento em que ela vai estar, programa em que entrou). Quem lê quer a reação humana, e tese aqui é peso morto.

Estrutura:

1. Linha 1: cena ou memória concreta, com lugar, hora ou objeto, ou o fato dito com o sentimento junto.
2. O fato, numa frase: o que aconteceu e o que muda.
3. Uma frase de sentimento, específica, que só a pessoa diria. Uma, não um parágrafo, e só quando ela a declarou no briefing (o `voz.md` não é fonte de sentimento sobre este fato): sem declaração, o post segue sem a frase, a nota leva `[FALTA: sentimento da pessoa]` e recomenda não publicar antes de a pessoa dar a frase, porque anúncio sem reação é bilhete.
4. O que segue (o que ela vai fazer, quando, onde), só o que o briefing confirma.
5. Convite: o que quem lê pode fazer (chamar, aparecer, levar para a cidade dele), só o que o briefing sustenta. Sem convite no briefing, o post fecha no que vem a seguir.
6. Agradecimento nominal em uma linha, só com os nomes que o briefing traz.

Tamanho: abaixo de 900 caracteres.

Fecho: o convite que o briefing dá, ou o que vem a seguir. Sem CTA de palavra-chave. Oferecer a quem lê o mesmo produto do anúncio (o treinamento, a mentoria, a vaga) é venda, e anúncio não é venda.

Exige: fato confirmado. Cena de sala, data, cidade, turma ou número de participantes que o briefing não dá ficam fora; só a data de um evento anunciado sem data vira `[FALTA: data]`, porque a frase do evento precisa dela.

Fica de fora: todo parágrafo que começa a explicar por que aquilo importa (é a tese voltando), o que a pessoa vai ensinar em detalhe, oferta do produto a quem lê, foto de palco com lista de agradecimentos, regionalismo forçado.
