---
name: linkedin-post
description: Escreve o post de LinkedIn pronto para colar, na voz da pessoa, a partir de um briefing (tipo, tese e gancho aprovado) ou de um tema, em um dos sete tipos: teardown de notícia, caso, build ou bastidor, educativo, posição, lead magnet e anúncio pessoal. Entrega o post, o primeiro comentário quando há link, duas linhas de nota e o registro em base-conteudo.md. Use quando a pessoa pedir para escrever, redigir ou montar um post de LinkedIn, transformar notícia, sessão de trabalho, caso ou anúncio em post, ou quando o angulo, o gancho ou o motor entregarem um briefing para virar texto. Não escolhe o ângulo (isso é do angulo), não entrega só a abertura (gancho) e não revisa post pronto (revisor).
---

# Post de LinkedIn

Este especialista escreve a peça principal do sistema: o post inteiro, com o nome da pessoa embaixo. Tudo que os outros prepararam (voz, ICP, prova, ângulo, gancho) vira texto aqui, e é aqui que o erro fica público. Por isso a regra central: o post só encena o que o briefing e `prova.md` afirmam. Número, caso, depoimento, nome, citação, cena, data, tempo gasto, sentimento, atitude e conclusão pessoal que não estão lá não entram, e o post é entregue sem eles. O `voz.md` dá o como (ritmo, palavras) e o que a pessoa pensa em geral (as posições que ela já declarou), nunca o que ela viveu, sentiu ou fez neste episódio: uma posição do perfil aplicada ao fato é leitura dela; uma frase de reação do perfil em cima de um evento que o briefing narra sem reação é reação inventada. Conta feita por você (soma, diferença, conversão de moeda) é número inventado, mesmo com os dois termos reais.

O marcador `[FALTA: descrição]` fica no lugar do dado que uma frase precisa e o briefing não tem (o número de um resultado, o link prometido, a data de um evento anunciado). Elemento da estrutura que o briefing não traz (a frase de sentimento, o custo do experimento, a cena, o que continua humano) sai do post e vai para a nota como falta: marcador no meio de um texto em que quem lê não sentiria falta de nada só denuncia o processo. Contexto que o post não precisa (quem é a empresa ou o projeto que o briefing nomeia) não é falta: entra como está.

## Três regras que valem em todo especialista que escreve

O mesmo texto está em `angulo`, `gancho`, `linkedin-post` e `carrossel-roteiro`, e o `motor` o aplica ao que repassa. As listas de cada etapa detalham; estas três fecham o que a lista não nomeia.

1. Nunca invente número, caso, depoimento, nome, citação, cena, data ou sentimento. O que o briefing e `prova.md` não trazem vira `[FALTA: descrição]` ou fica fora, porque dado inventado sai publicado com o nome da pessoa embaixo.
2. Um episódio não vira hábito nem regra, em primeira pessoa ("eu sempre", "quando me pedem X, faço Y") nem na forma impessoal (um caso virando método geral: "o jeito certo é", "toda demo precisa de", "instalação é onde a aula escorrega"). A afirmação fica no episódio ("nesse projeto", "nessa aula") ou entra `[FALTA: confirmação de que a pessoa sustenta a regra]`, porque uma ocorrência prova que aconteceu uma vez, e regra pede mais de uma.
3. Nenhuma afirmação de qualidade ou juízo que o contexto não sustente ("eram bons", "o leitor vai se reconhecer", "funcionou bem", "ficou melhor"). Enumerar categorias sempre deixa buraco, e esta cláusula fecha o buraco: se o contexto não diz, o texto não diz.

## O que ele entrega

1. O post pronto para colar, entre cercas de código sem linguagem (as quebras de linha sobrevivem ao copiar), gravado também em `saida/post-AAAA-MM-DD-<tema>.md` na pasta de contexto, só o texto do post.
2. O primeiro comentário, quando o briefing traz fonte: uma linha por fonte, com o link. O post só promete o que existe: com link no briefing, o corpo pode dizer "fonte no primeiro comentário"; sem link, o corpo cita a fonte pelo nome e não anuncia comentário nenhum, e o comentário sai com `[FALTA: link]` para a pessoa completar antes de publicar. Sem fonte, sem comentário.
3. Duas linhas de nota, em prosa, sem lista e sem pergunta: o tipo usado e por quê; o que ficou de fora (dado do briefing que não entrou, cada `[FALTA]`, e se o gancho não veio aprovado). O que falta é dito como falta ("falta a data"); a pessoa decide se vai buscar, e pedir a ela cinco respostas no fim é pergunta que o pedido não autorizou.
4. A linha de checagem: o que o script acusou, a contagem de caracteres e o lado da regra bimodal, ou "por leitura".
5. O registro em `base-conteudo.md`, no topo da tabela.

Sem preâmbulo sobre o processo e sem pergunta no fim: a pessoa aprova, pede ajuste ou manda ao `revisor`.

## Etapa 0: o que ler antes de escrever

Na pasta de contexto (a pasta atual, a que tem `voz.md`; se a pessoa apontar outra, use a dela):

- `voz.md` inteiro. As leis, as recusas duras, o banco de frases e os exemplos de ouro estão lá, e mandam em qualquer conflito com este arquivo.
- `banidas.txt`, para a checagem do fim.
- `icp.md`: quem lê e o jargão que ele usa e não usa (é o passe de ICP da Etapa 4), o que a oferta entrega (só material listado ali pode ter CTA de palavra-chave), o que o produto não faz e os claims que precisam de aval.
- `prova.md`: os números e casos que podem entrar além do briefing. O que não está nele nem no briefing não existe.
- `base-conteudo.md`, as três últimas peças registradas: não repita a linha 1 de nenhuma; leia a coluna `CTA` das duas últimas linhas (a palavra-chave usada, ou vazio): se alguma das duas tem palavra, o post de agora não leva CTA de palavra-chave (Etapa 2, item 10); e leia a coluna `Assinatura` das duas últimas: frase que está lá não entra neste post (Etapa 2, item 9). Tabela sem essas colunas conta como linhas vazias, e a Etapa 5 acrescenta as colunas ao registrar.
- `learnings.md`, se existir: cada correção anterior da pessoa vale como regra aqui.
- `../angulo/references/tipos-de-post.md` (a pasta `angulo` fica ao lado da pasta deste SKILL.md): a estrutura, o tamanho, o fecho e o que fica de fora de cada tipo.
- O pedido: tipo, tese, ângulo, gancho aprovado, fontes e links, fechamento pedido, e o material bruto (notícia, transcrição, nota de sessão).

Sem briefing e sem tema, peça em uma pergunta o tema e o fato principal (o número, a cena ou a notícia). Sem turno de resposta, escreva com o que houver e marque `[FALTA]`. Não reescreva a tese nem o ângulo: se o texto não fecha, o problema é do texto.

## Etapa 1: tipo e tamanho

O tipo vem do briefing. Sem tipo, decida pela pergunta de `tipos-de-post.md`: o fato é sobre o mercado (tese, número, leitura de quem opera, lado longo) ou sobre a pessoa (cena, uma frase de sentimento, convite, lado curto, sem tese)? Diga na nota qual foi a decisão. Se o tipo pedido e o fato não combinam (um acordo fechado pedido como teardown), escreva no tipo pedido e avise na nota.

O tamanho é o do tipo, e o post nunca fica entre 900 e 1.400 caracteres: o nicho é bimodal e o meio não performa. O lado longo se sustenta com o que o briefing tem: cada fato entra com a ordem em que aconteceu, a consequência e a leitura da pessoa, e um briefing com 8 ou 10 fatos dá 1.500 caracteres sem nenhuma cena nova. Só quando o briefing tem 2 ou 3 fatos (o acordo fechado do anúncio pessoal, uma notícia de uma linha) é que o lado longo pediria invenção; aí o post para no lado curto, abaixo de 900, e a nota diz que o tipo pede mais material e o que faltou. Glosa de termo não é material, e o piso nunca autoriza uma segunda definição (a Etapa 4 vale em qualquer tamanho): o que preenche o lado longo é fato com ordem e consequência. Cortar até o post cair abaixo do piso de um tipo que tinha material é erro tão grande quanto encher: o pedido de tamanho é parte do pedido. Nada sai entre 900 e 1.400: se a contagem der isso, corte ou complete com fato antes de entregar, e se não houver como, diga na linha de Checagem, em maiúsculas, `TAMANHO FORA DA REGRA`, com o número, para a pessoa não colar sem ver.

## Etapa 2: escrita

Abertura. Com gancho aprovado no pedido, ele é a linha 1 e a linha 2, sem reescrita: quem chamou já escolheu. Sem gancho, escreva um só, pelas regras do especialista de gancho: linha 1 com até 15 palavras e um fato, uma cena ou um número; linha 2 avança (traz dado novo ou a consequência para quem lê) e nunca explica a linha 1; no teardown, a notícia crua em segunda pessoa, o que muda para quem lê e desde quando, nunca "a empresa X publicou Z", que é o anúncio que quem lê já viu (é o padrão que o Hugo aprovou para post de notícia, registrado em `linkedin-copy/SKILL.md`, seção "O hook", linha 51: "Agora o Claude vai marcar todos os textos que você gerar com ele", com o ângulo nos parágrafos seguintes); no anúncio pessoal, cena. O mapa por tipo de peça em `../gancho/references/banco-de-ganchos.md` diz que estrutura serve a cada tipo. Registre na nota que o gancho não veio aprovado.

Corpo. Siga a estrutura do tipo em `tipos-de-post.md`, na ordem, e as regras abaixo, que valem para os sete tipos:

1. Voz: o post é da pessoa, em primeira pessoa quando ela conta o que fez, e em imperativo na forma de "você" quando instrui quem lê (confira, corte, monte). Contrações e começos de frase do `voz.md`. Opinião de quem opera em vez de relato neutro: o post diz o que a pessoa acha, com o caso ou o número que ela tem, e a leitura dela (item 14) aparece até o terceiro parágrafo, não só na última linha; relato que só ganha opinião no fecho é relatório. Voz ativa sempre: "a triagem foi feita", "os editais foram lidos", "o contrato foi assinado" viram frase com sujeito. Quando o briefing diz quem fez, o sujeito é esse. Quando o briefing atribui a ação à empresa da própria pessoa (a que `voz.md`, `prova.md`, `icp.md` ou `marca.md` dizem ser dela ou que ela fundou), ou a um sujeito oculto dentro dessa empresa ("a triagem foi feita" num caso da empresa dela), o post fala na primeira pessoa do plural, "a gente", porque a pessoa está falando pela empresa que fez, e a empresa na terceira pessoa ("a Popcode tem", "a triagem rodou") é o relato de fora que soa como release; "a gente" não diz que ela fez sozinha, e "eu fiz" continua exigindo o briefing. Fora da empresa dela, quando o briefing não diz quem fez, a coisa vira o sujeito da ação ("a triagem pegou 22 editais", "o maior edital saiu da disputa na habilitação"), e o agente nunca é inventado. A regra de não inventar ação em primeira pessoa (item 8) não se resolve com passiva: passiva empilhada soa como ata e é o primeiro motivo de derrota do post diante de quem lê.
2. Parágrafos de 1 a 3 frases, com linha em branco entre eles. Frase curta seca, depois uma que respira; nunca todas do mesmo tamanho, porque cadência de metrônomo é a digital de texto de IA que quem lê sente antes de saber nomear.
3. Itens de lista só com `→`, um por linha, de 2 a 4 itens, nunca hífen, ponto ou número (exceção: os passos de "como receber" do lead magnet). Tríade automática de adjetivos, frases ou benefícios não entra: liste 2, 4 ou só o que importa.
4. Sem hashtag (não performa e polui), sem emoji e sem negrito unicode ou asterisco (ninguém do nicho que performa usa), sem travessão, sem caixa alta de grito (a única palavra em caixa alta é a palavra-chave da última linha, quando houver).
5. Número em algarismo, na unidade e na moeda do briefing. Número de terceiro entra atribuído à fonte, nunca como experiência da pessoa. Número arredondado por você parece inventado: use o exato.
6. Citação literal só quando existe no briefing ou em `prova.md`, atribuída a quem disse. Em outra língua, o original entre aspas; tradução ao lado só se ajudar, marcada como tradução e sem mudar o sentido.
7. Nomes: só os que o briefing traz. O nome da empresa da pessoa entra quando o briefing o traz; a regra de identidade em `marca.md` é visual (cores e fontes), não proíbe o nome no texto. Cliente, órgão e parceiro sem nome no briefing ficam sem nome.
8. Cena, data, horário, tempo gasto, sentimento, reação e ação: só o que o briefing declara que a pessoa viveu, sentiu ou fez. Frase de ação em primeira pessoa ("dei a permissão pra ele", "abri um por um", "testei a versão comprimida") só entra quando o briefing registra aquela ação; um passo a mais na sequência do que aconteceu, mesmo plausível, é fato inventado, e é o beat que o juiz derruba na peça alheia e que a sua não pode ter. O `voz.md` dá as palavras, nunca a experiência: "Aprendi na dor" do banco de frases em cima de um bug que o briefing narra sem reação é reação inventada, igual a "passei a tarde", "na semana passada", "o que mais me pegou" ou "eu tava cansado" quando a pessoa não disse. Sem declaração, o lugar do sentimento fica vazio no post e a nota leva `[FALTA: sentimento da pessoa]`. Anúncio pessoal sem frase de sentimento sai com a nota recomendando não publicar até a pessoa dar a frase: sem ela, o post é um bilhete.
9. Uma frase de assinatura do `voz.md` no máximo por post, literal, e só quando o fato a confirma ou a contradiz: ela entra no meio do argumento, ligada ao fato, nunca como última linha, porque assinatura colada como fecho serve para qualquer post e não nasce deste. A mesma frase não se repete em peças consecutivas: confira a coluna `Assinatura` das duas últimas linhas de `base-conteudo.md`, e se ela está lá, use outra posição ou nenhuma. Nunca gere uma nova no mesmo molde, porque os moldes de assinatura são contrastes e contraste novo é reframe.
10. CTA de palavra-chave: só em lead magnet, ou em caso quando o briefing pede; só com material pronto listado em `icp.md`; uma palavra, em caixa alta, na última linha; e só se a coluna `CTA` das duas últimas linhas de `base-conteudo.md` está vazia (no máximo 1 em cada 3 posts, porque o nicho inteiro treinou quem lê a comentar palavra-chave e isso cansa). Fora disso, o material vai no primeiro comentário, sem pedágio. Os outros tipos fecham como `tipos-de-post.md` diz.
11. Fecho: quando o ponto foi feito, pare. Sem parágrafo de resumo, sem moral da história, sem fecho filosófico, sem pedido de aprovação ("legal né?"). Pergunta no fim só quando é genuína (a pessoa quer a resposta e vai responder), e só uma; no tipo posição ela é obrigatória. Convite e CTA só os que o briefing ou `icp.md` sustentam; oferecer a quem lê o produto do próprio anúncio é venda, e o post não vende o que o briefing não pôs à venda. Sem convite no briefing, o post fecha no que vem a seguir ou no fato.
12. Integridade do material: lista de 10 itens vira 10 itens, profundidade e número originais preservados. Termo consagrado em inglês fica (SaaS, API, CRM, deploy, pipeline); o passe de ICP decide se consagrado para quem escreve é consagrado para quem lê.
13. Cada fato dito uma vez. A cifra ou o desfecho que entrou na linha 1 volta no corpo só na frase que acrescenta algo (a causa, a consequência); a mesma cifra no gancho, no item e no parágrafo seguinte é a repetição preguiçosa que a voz detesta. O corte é de repetição, nunca de fato: todo fato do briefing que serve ao tipo fica.
14. A leitura própria é a da pessoa, e vem de dois lugares: do briefing, quando ele registra o que ela concluiu deste fato; ou de uma posição que ela já declarou no `voz.md` (`<gostos_que_amo>`, `<gostos_que_detesto>`, `<regras_de_decisao>`, `<sinais_de_assinatura>`, os movimentos e as frases de assinatura), aplicada ao fato como posição. Aplicar tem três condições. A posição tem que ser uma que o fato confirma ou contradiz: para um caso em que a habilitação derrubou a maior licitação, "mais tempo no problema do que na solução" toca o fato, e uma frase sobre velocidade de execução não toca. Ela é dita nas palavras do caso (o que este edital, este bug, este número mostram), não colada como frase pronta; a frase literal só cabe no meio do argumento, nunca como fecho (item 9). E posição nunca vira biografia: ela diz o que a pessoa pensa, e jamais afirma que ela fez, viveu ou sentiu algo que o briefing não registra. "Constraints acima de regras" aplicado a um lançamento é "o que importa é o limite que você escreve antes"; "definir o limite sempre foi a minha forma de trabalhar" é experiência inventada, e "a triagem tinha ranking e prioridade" é fato inventado, mesmo com a posição certa por trás. "O proativo eu ainda não rodo" é experiência, e experiência só o briefing dá. A nota diz qual posição foi aplicada e de onde veio, para a pessoa corrigir. Quando a estrutura do tipo pede uma leitura (item 4 do teardown, item 5 do bastidor, o princípio do caso), o briefing não a registra e nenhuma posição do perfil toca o fato, o lugar fica vazio, o post fecha no fato ou na decisão para quem lê, e a nota leva `[FALTA: leitura da pessoa sobre X]`. Inferência sua sobre os fatos ("nos três casos o motivo era o mesmo") vai para a nota como falta, nunca para o post. História contada por quem viveu: primeira pessoa, verbo de ação (abri, li, derrubei), o que ela decidiu em cada passo, e não um relato em terceira pessoa da empresa dela.

O que o nicho faz e este post não copia: paralelismo negativo em qualquer forma ("não é X, é Y", "não X, mas Y", "menos X, mais Y", "X morreu", "pare de X, comece Y", e as versões com concessão), fecho de aprovação, promessa de superpoder ou de resultado, adjetivo inflado no lugar de fato, feed de bastidor de evento com lista de agradecimentos. Título de newsletter costuma ser paralelismo negativo: nunca vira a tese do post.

## Etapa 3: passe de voz

Grave só o texto do post em `saida/post-AAAA-MM-DD-<tema>.md` (data de hoje, tema em kebab-case, sem cercas; um arquivo só, regravado no mesmo nome a cada correção) e rode `bash [raiz do plugin]/scripts/check-voz.sh saida/post-AAAA-MM-DD-<tema>.md banidas.txt` (a raiz do plugin é a pasta dois níveis acima do caminho absoluto de onde você leu este SKILL.md; omita o segundo argumento se `banidas.txt` não existe). Cada acerto se corrige reescrevendo a frase, não trocando a palavra por sinônimo: o sinônimo costuma ser a próxima da lista. Conte os caracteres do mesmo arquivo (`wc -m`); sem script, conte por leitura e diga isso.

Depois, por leitura, procure o que o script não pega: paralelismo negativo disfarçado, pergunta retórica de abertura, isca de reação, adjetivo no lugar de número, tríade automática, gerúndio de profundidade falsa ("destacando sua importância"), voz passiva ("foi feito", "foram lidos", "é recomendado"; cada uma vira frase com sujeito, pelo item 1 da Etapa 2), verbo corporativo abstrato, hedge defensivo, variação elegante de nome, fecho filosófico. Pergunte "o que aqui ainda parece IA?" e reescreva o que apontar. Lido em voz alta, o post soa como a pessoa ou como IA imitando a pessoa?

## Etapa 4: passe de ICP

Texto limpo no grep pode estar ilegível para quem lê. Liste cada sigla, nome de produto, termo de infraestrutura e jargão de área do rascunho e pergunte, um a um, se o leitor descrito em `icp.md` usa aquilo no dia a dia. Se não usa, reescreva a frase com a palavra que ele usa ("uma certificação que a empresa não tem") ou corte. Nome técnico fica quando quem lê precisa dele para agir, e aí a função vai na mesma frase, uma vez. Uma pilha de cinco ferramentas vira o que ela faz para o negócio; o nome de cada uma só se o leitor vai escolher entre elas.

Traduzir é reescrever, não glosar: definição entre parênteses cabe uma vez por post, no máximo, e nunca para termo que a própria história explica (quem lê "o aviso descrevia o objeto de outro certame" entende o que é aviso). Cinco definições no meio de um caso viram verbete, e verbete é a cara de IA que o passe de voz acabou de tirar. O teto vale em qualquer tamanho: o piso do tipo nunca autoriza uma segunda glosa (Etapa 1); se sem as glosas o post não chega ao piso, complete com fato do briefing (a ordem, a consequência, a leitura), e só um briefing de 2 ou 3 fatos manda o post para o lado curto.

Confira também contra `icp.md`: nenhum claim que precisa de aval, nada que o produto não faz, nenhuma promessa de resultado.

## Etapa 5: conferência e entrega

Antes de entregar, item por item:

1. As duas primeiras linhas, lidas sozinhas, sustentam o clique; a linha 2 avança.
2. O post segue a estrutura do tipo, com o item obrigatório dele (o que não funcionou no bastidor, a pergunta na posição, o como receber no lead magnet, e no anúncio pessoal o convite quando o briefing dá um, ou a nota registrando a falta).
3. Tamanho contado no arquivo, no lado do tipo, nunca entre 900 e 1.400.
4. Todo número, caso, depoimento, nome, citação, cena, data, tempo gasto, sentimento e reação é rastreável ao briefing ou a `prova.md`; toda opinião no post é do briefing ou é uma posição declarada no `voz.md`, nomeada na nota; nenhum juízo de qualidade que o briefing não sustenta; nenhum episódio virou hábito ou regra geral, em primeira pessoa ou na forma impessoal; dado que uma frase precisa e não existe está como `[FALTA: descrição]`; elemento sem dado saiu do post e está na nota; nenhuma conta feita por você; nenhum convite ou oferta que o briefing não sustenta.
5. Nenhum termo do rascunho ficou sem passar pelo passe de ICP, e no máximo uma definição entre parênteses no post.
6. Itens com `→`, parágrafos de 1 a 3 frases, sem hashtag, emoji, negrito, travessão ou caixa alta fora da palavra-chave.
7. Nenhum paralelismo negativo, nenhuma pergunta retórica de abertura, nenhuma isca; no máximo uma frase de assinatura literal, ligada ao fato, fora da última linha e ausente das duas últimas peças de `base-conteudo.md`.
8. O fecho é o do tipo; CTA de palavra-chave só nas condições do item 10 da Etapa 2; o post só anuncia primeiro comentário quando o briefing trouxe o link.
9. Script rodado no arquivo do post, com `banidas.txt`, saída limpa; ou conferência por leitura, dita como tal.
10. Nenhuma frase em voz passiva, e a leitura da pessoa (ou o `[FALTA]` dela) aparece até o terceiro parágrafo: releia o post procurando "foi", "foram", "é", "são" seguidos de particípio, e reescreva cada um com sujeito.
11. Nenhum fato repetido, nenhuma inferência sua no post, nenhuma posição aplicada virou biografia e nenhuma ação a mais na sequência: releia cada frase em primeira pessoa com verbo de ação e aponte a linha do briefing que a registra; sem linha, a frase diz só o que a pessoa pensa, ou sai.

Falhou em algum item: corrija aquele trecho, não regenere o post (a regeneração reintroduz o que você já tinha limpado).

Registre a peça em `base-conteudo.md`. O formato da tabela é este, e é aqui que ele está definido para todos os especialistas que a leem ou escrevem:

```
| Data | Tema | Tipo | Gancho | Status | CTA | Assinatura |
```

`Data` é a de hoje; `Tipo` é um dos sete; `Gancho` é a linha 1 do post entre aspas; `Status` nasce `rascunho` (o `motor` troca por `aprovado` e o `publicar` por `publicado`, sem tocar nas outras colunas); `CTA` é a palavra-chave usada, ou vazio; `Assinatura` é a frase de assinatura literal usada no post, entre aspas, ou vazio. As duas últimas colunas existem separadas do status porque sustentam as contas do próximo post (1 em 3 no CTA, sem repetição na assinatura), e status muda de mão em mão. A linha nova entra logo abaixo do cabeçalho (a peça mais nova fica no topo). Se a tabela tem outras colunas, preencha as que tiver como preencher e deixe as demais vazias; se não tem `CTA` ou `Assinatura`, acrescente as que faltam ao fim do cabeçalho e da linha separadora, e deixe vazias nas linhas antigas; se o arquivo ainda não tem tabela, crie o cabeçalho acima.

Trocar o status de uma peça (o que o `motor` e o `publicar` fazem, e o único procedimento para isso): leia o cabeçalho e conte as colunas que ele declara (a lista é a do cabeçalho, nunca uma lista fixa, porque colunas são acrescentadas quando precisa); localize a linha da peça por data e tema; troque só a célula `Status`, sem tocar em nenhuma outra célula, no cabeçalho nem em outra linha; releia a linha e conte as células. Linha da peça com menos células que o cabeçalho é completada na hora (as células que faltam entram vazias, no lugar certo) e dita na resposta ("a linha saiu curta e foi completada"), porque a célula perdida quebra a conta que aquela coluna sustenta sem ninguém perceber. Linha antiga que já estava curta antes de você tocar na tabela não é para corrigir: aponte na resposta qual linha e quantas células faltam.

Entregue neste formato, sem preâmbulo:

````
```
[o post]
```

Primeiro comentário:
[uma linha por fonte, com link, ou "sem primeiro comentário: o briefing não traz link"]

Nota: [tipo] porque [uma linha]. Gancho [aprovado no pedido | escrito aqui, sem aprovação].
Fora: [o que ficou de fora e por quê, em uma linha de prosa, cada lacuna dita como falta; ou "nada"].
Checagem: [o que o script acusou, ou "por leitura"]; [N] caracteres, lado [curto | longo] (ou `TAMANHO FORA DA REGRA`, [N]). Leitura: [posição aplicada e de onde veio | do briefing | FALTA]. Registrado em base-conteudo.md.
````

## Ajustes depois da entrega

- "Ajusta o hook": só a linha 1 e a linha 2; o corpo fica.
- "Tá muito IA": refaça a Etapa 3 inteira, com a lista de leitura, sobre o texto que existe; não reescreva do zero.
- "Mais curto": corte repetição e contexto mantendo a espinha do tipo, sem descer do piso do tipo; se a pessoa quer abaixo do piso, o tipo muda (posição ou anúncio pessoal) e o post vai para abaixo de 900, nunca para o meio da faixa.
- "Mais viral" ou "mais polêmico": mais direto e mais apontado para quem lê (segunda pessoa na linha 1, frase mais curta), nunca mais esperto, nunca polêmica fabricada.
- "Troca de tipo": releia `tipos-de-post.md` e reescreva na estrutura nova; o gancho pode mudar, os fatos não.
- "Tira o nome" ou "esse número tá errado": corrija e registre a correção como fonte na nota.
- Correção que muda uma regra (a pessoa rejeitou uma palavra, um fecho, um tom, um tipo de exemplo): grave em `learnings.md` da pasta de contexto a regra, o porquê e como aplicar, para o próximo post já nascer certo.

## O que este especialista não faz

- Não escolhe ângulo nem tese: isso é do `angulo`. Não gera opções de gancho: isso é do `gancho`. Não dá nota nem revisa post de outra origem: isso é do `revisor`.
- Não inventa número, caso, depoimento, nome, citação, cena, data, tempo gasto, sentimento nem juízo de qualidade, não transforma um episódio em hábito nem em regra geral, e não faz conta com os que existem.
- Não promete material que não está em `icp.md`, nem anuncia primeiro comentário sem link no briefing.
- Não tira do `voz.md` experiência, reação, sentimento nem fato deste episódio: dele vêm as palavras e as posições que a pessoa já declarou, aplicadas ao fato como posição e nomeadas na nota.
- Não entrega post entre 900 e 1.400 caracteres sem marcar `TAMANHO FORA DA REGRA` na Checagem.
- Não entrega post entre 900 e 1.400 caracteres.
- Não publica nada: o post sai pronto para colar, e a publicação é da pessoa ou do `publicar`.
