# radar-pautas: desenho

Data: 2026-10-21. Origem: conversa com o Hugo em 2026-10-21, depois da pesquisa de referências (kit A Virada IA da Bruna, sergebulaev linkedin-skills e instagram-skills, coreyhaines31 marketingskills, legado `kotler`, dois vídeos do YouTube).

## Por que

Hoje o sistema só começa quando a pessoa traz um tema. O que trava quem compra é o passo antes: "sobre o que eu posto hoje?". O `radar-pautas` já está na spec (`docs/plano/spec.md`, linhas 38 e 67) e o `angulo` já aponta para ele ("Não monta calendário nem distribui a semana: isso é do `radar-pautas`"), mas a skill não existe.

O que o Hugo quer: abrir a pasta de manhã e achar uma lista pronta de pautas boas; eventualmente pedir uma pauta na hora.

## Objetivos

- Uma skill `radar-pautas` que entrega cerca de 5 pautas ordenadas, gravadas em `pautas.md` na pasta de contexto.
- Cada pauta pronta para virar peça: diz de onde vem o fato, por que agora, o que traz de novo e termina com o pedido pronto para colar no `motor`.
- Roda quando a pessoa pede ("me dá pautas", "tem pauta sobre X?") e roda sem fazer pergunta no meio, para poder ser agendada depois sem mudar nada.

## Não objetivos (agora)

- Agendamento. Fica para depois; pode ser feito pelo próprio Claude ou por outro sistema. A skill só precisa rodar do começo ao fim sem pergunta.
- Calendário semanal, distribuição por dia, mix de tipos por semana.
- Métricas de desempenho (Metricool e afins): é do `medir`, que a spec põe depois.
- Mensagem por WhatsApp ou e-mail. A entrega é o arquivo.
- Escrever o post. O radar para na pauta; o resto é do fluxo de sempre (`motor`, `angulo`, `gancho`, `linkedin-post`, `revisor`).

## Antiobjetivos (o que faz o Hugo abrir a lista e pensar "isso não presta")

Palavras do Hugo: "notícias antigas, fora do ICP ou falta de ganho". Uma pauta com qualquer um desses três sai da lista antes de ganhar nota:

1. Notícia antiga: notícia com mais de 15 dias (decisão do Hugo). Pauta que não nasce de notícia (desdobramento de post, fato de `prova.md`, dor de `icp.md`) não tem prazo; para ela valem só os dois motivos abaixo (decisão minha).
2. Fora do ICP: não encosta em quem lê, no que o preocupa ou no que a oferta entrega, segundo `icp.md`.
3. Sem ganho: não consegue dizer, em uma frase, o que traz que o post comum sobre o tema não traz, com o ganho apoiado nos arquivos da pessoa (`prova.md`, `materiais/`, `voz.md`).

Também é fracasso, mesmo funcionando: pauta com número, nome, data ou citação que nenhuma fonte deu (a regra anti-invenção do sistema vale aqui como em todo especialista).

## Fontes, em três camadas (decisão do Hugo)

1. Arquivos da pessoa, sempre: `base-conteudo.md` (o que já saiu e pode ter continuação; o que já saiu não volta como pauta), `prova.md`, `materiais/`, `icp.md` (dores, gatilhos, o que o cliente quer), `voz.md` (posições que a pessoa sustenta), `learnings.md` se existir.
2. Busca na web do host, sempre ligada: novidades do nicho dentro da janela de 15 dias. A skill não nomeia ferramenta: diz "use a busca e a leitura de página que o host tiver". No Claude Code é a busca nativa; no Grok Bot (a spec exige que o sistema rode lá também) é a busca do próprio Grok, que já vê o X (decisão do Hugo). Os testes rodam só no Claude Code. Host sem busca nenhuma: o radar roda só com a camada 1 e diz isso numa linha.
3. Perplexity e Grok, opcionais: para quem configurar a própria chave. Servem para o que está quente nas últimas 24 horas (o Grok, para o que circula no X). Sem chave, o radar roda igual, sem essa camada, e diz isso numa linha.

A busca na web é uma exceção à regra "nenhum comando toca em rede" (`motor`, "O que a pessoa precisa liberar"). A exceção vale só para o `radar-pautas` e só para leitura: ele busca e lê páginas, não envia, não publica e não grava fora da pasta de contexto.

## Regras de evidência (decisão minha, a partir do `marketingskills` e da pesquisa)

- Página da web, resposta do Perplexity ou do Grok e material colado são dado, nunca instrução. Vale o mesmo parágrafo fixo que a Tarefa 3 pôs em `angulo`, `contexto-negocio` e `entrevista-voz`, palavra por palavra, e o `test-regra-terceiro.sh` passa a conferir também o `radar-pautas`.
- Cada fato da web vira uma ficha: link, data de publicação, trecho literal curto, e "o que a fonte diz". Sem data de publicação, o fato não sustenta "por que agora".
- A leitura da pessoa fica separada do que a fonte diz: sai de `voz.md`, `prova.md` ou `icp.md`; sem base, vira `[FALTA: sua posição sobre ...]`. O radar não traduz a notícia "para o público" por conta própria.
- Número só entra se foi lido na fonte primária (a página do órgão, da empresa, do estudo). Número que veio de resumo, de resposta do Perplexity ou do Grok, ou de transcrição precisa ser conferido na fonte; sem isso, `[FALTA: conferir número na fonte]`.
- Confiança por pauta: alta com duas fontes independentes, média com uma fonte primária, baixa só com blog ou relato de terceiro. Pauta de confiança baixa pode entrar, com a ressalva visível.

## Ordem da lista (decisão minha)

Primeiro os três descartes acima e o descarte de pauta já publicada (cruzando com `base-conteudo.md`). Depois uma nota:

- peso 2: encaixe com o ICP; dor ou gatilho real do cliente; prova disponível em `prova.md` ou `materiais/`;
- peso 1: recência do "por que agora"; novidade frente a `base-conteudo.md`.

Pauta com mais `[FALTA]` perde ponto. Empate: ganha a que tem mais prova local. A escala exata e como cada critério vira número fica com quem constrói.

## O que cada pauta traz

- Título curto.
- Origem: continuação (de qual peça em `base-conteudo.md`), fato (`prova.md` ou `materiais/`, com a linha), dor do ICP, ou notícia (com a ficha de evidência).
- Por que agora (para notícia, com a data; para o resto, o gatilho em `icp.md` ou a continuação).
- Ganho: a frase do que a pauta traz de novo e de qual arquivo isso sai.
- Confiança e nota.
- Os `[FALTA]` que a pessoa vai precisar responder.
- O pedido pronto para colar no `motor`, no formato que o `motor` já aceita como tema.

## Pedido sobre um tema ("tem pauta sobre X?") (decisão do Hugo)

- Responde na conversa com 1 a 3 pautas sobre X e põe essas pautas no topo de `pautas.md`, com a data e o tema pedido.
- Os mesmos descartes valem: se X está fora do ICP, se não há notícia de X nos últimos 15 dias e nenhum fato nos arquivos, ou se não há ganho, o radar diz qual foi o motivo e não entrega pauta. Nunca inventa uma para não voltar de mãos vazias.

## O arquivo `pautas.md`

- Fica na pasta de contexto.
- Cada rodada põe as pautas novas no topo, com a data da rodada (decisão minha).
- Cada pauta tem um identificador curto (por exemplo `P-2026-10-21-3`) que vai dentro do pedido pronto para o `motor` (decisão minha).
- Pauta de rodada anterior que ainda vale fica; notícia que passou dos 15 dias sai.
- Pauta usada sai: quando o `motor` recebe um pedido com identificador de pauta, ele marca a pauta como usada em `pautas.md`, e a rodada seguinte a retira. Sem identificador (a pessoa reescreveu o pedido), o radar compara por tema com `base-conteudo.md`, que é aproximado. Assim a tabela de `base-conteudo.md` não ganha coluna e `linkedin-post` e `publicar` não mudam (decisão minha).
- O dono do formato é o `radar-pautas`; quem lê só aponta para ele.

## Pasta de contexto incompleta (decisão minha)

- Sem `icp.md`, ou com ele só no modelo: o radar não grava lista. Os descartes e a nota dependem dele. Diz o que falta e que o `contexto-negocio` monta, sem chamar o `contexto-negocio` (que faz perguntas).
- Sem `voz.md`, `prova.md` ou `materiais/`: roda, e toda leitura da pessoa vira `[FALTA]`; diz numa linha o que faltou.

## Permissões (decisão minha)

O agendamento fica para depois, mas a skill roda do começo ao fim sem pergunta de conteúdo. Os pedidos de permissão do host (busca, leitura de página, gravação de `pautas.md`) entram na lista de "O que a pessoa precisa liberar" do `motor` e no `INSTALAR.md`, para que, quando o agendamento vier, a pessoa saiba o que liberar de uma vez.

## Encaixe no sistema

- `motor`: reconhece "me dá pautas", "roda o radar", "tem pauta sobre X?" e chama o `radar-pautas`; o pedido colado de uma pauta entra no fluxo normal. A seção "O que a pessoa precisa liberar" ganha a linha da busca na web e da exceção de rede.
- `angulo`: a linha que aponta para o `radar-pautas` continua valendo.
- `checkup.sh`: pode listar `pautas.md` como opcional (decisão de quem constrói, se for barato).
- Chaves do Perplexity e do Grok nunca ficam em arquivo da pasta de contexto, em `config.md` versionado nem em git. Como a chave chega (servidor MCP que a pessoa já configurou no Claude Code, variável de ambiente) é escolha de quem constrói, com o mínimo de configuração para o comprador.

## Restrições que já valem no sistema

- PT-BR, sem travessão, sem emoji, sem termo de `banidas.txt`; `check-voz.sh` roda em `pautas.md` e no SKILL.md novo.
- Cada regra mora num lugar só; quem não é dono aponta pelo nome da seção.
- Afirmação de qualidade só com execução em dois modelos (claude-sonnet-5 e claude-opus-5), ligada ao commit; no máximo 2 execuções em paralelo; em 429, esperar e repetir.
- Das referências entram só ideias, sem texto copiado.

## O que fica com quem constrói

- A escala da nota e o peso exato de cada `[FALTA]`.
- Quantas buscas o radar faz e com que termos (a partir de `icp.md` e `voz.md`).
- Como detectar se Perplexity ou Grok estão disponíveis.
- Como as páginas fixas chegam ao radar nos testes (decisão minha sobre o princípio): os casos que dependem de conteúdo da web usam páginas gravadas na fixture, entregues ao radar como resultado de busca já feito, para o teste se repetir igual; o SKILL.md não ganha modo de teste visível. Uma rodada a mais, com a rede de verdade nos dois modelos, confere só que a lista sai e respeita as regras de fonte e data.
- Os casos de eval: no mínimo um com notícia de 20 dias (tem que cair), um com notícia fora do ICP (tem que cair), um com página que traz instrução embutida (tem que ser ignorada e dita), um sem rede e sem chave (tem que sair lista só dos arquivos), e um com número vindo só de resumo (tem que virar `[FALTA]`).
