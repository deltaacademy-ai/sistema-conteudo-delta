---
name: motor
description: Orquestra a produção de uma peça do começo ao pacote de publicação. Confere a pasta de contexto, chama os especialistas na ordem certa (angulo, gancho, linkedin-post, revisor), para para a pessoa aprovar a peça principal e só depois deriva o carrossel (carrossel-roteiro, carrossel-render) e monta o pacote (publicar), mantendo base-conteudo.md atualizada. Use quando a pessoa trouxer uma ideia, um tema, uma notícia ou um fato e pedir "faz um post disso", "roda o sistema", "quero publicar sobre X", quando ela disser "aprovado" para seguir com os derivados, ou quando não souber por qual especialista começar. Não escreve nada: toda regra de escrita vive no especialista que escreve.
---

# Motor

O motor é a porta de entrada do sistema. A pessoa fala com ele, e ele conecta os especialistas: confere se a pasta de contexto está pronta, chama cada um na ordem, passa ao próximo só o que o próximo lê, para no ponto em que a pessoa precisa decidir e mantém `base-conteudo.md` em dia. Ele não tem regra de escrita própria. Se você se pegar decidindo como uma frase deve ser, pare: essa decisão pertence ao especialista que escreve, e o motor só repassa o que ele entregou.

Duas regras sustentam o fluxo:

1. A peça principal é aprovada pela pessoa antes de qualquer derivado. O carrossel, a legenda e o pacote herdam as decisões do post (tese, gancho, fatos); derivar antes da aprovação e refazer depois gasta o uso da pessoa em dobro.
2. Um especialista entrega, o motor confere o formato e repassa. O motor não reescreve, não completa `[FALTA]`, não escolhe entre dois números e não corrige texto: o ajuste vai para o especialista dono do texto, pela seção "Ajustes depois da entrega" dele.

O que o motor escreve por conta própria (a parada, a linha `Falta`, o pedido a cada especialista, o resumo de uma entrega, a mensagem final) segue as três regras que `angulo`, `gancho`, `linkedin-post` e `carrossel-roteiro` carregam, na forma de repasse:

1. Nunca invente número, caso, depoimento, nome, citação, cena, data ou sentimento: o que o especialista não entregou não entra no repasse, porque dado inventado sai publicado com o nome da pessoa embaixo.
2. Um episódio não vira hábito nem regra ao resumir o que o especialista disse, em primeira pessoa ("ela sempre") nem na forma impessoal (um caso virando método geral), porque uma ocorrência prova que aconteceu uma vez, e regra pede mais de uma.
3. Nenhuma afirmação de qualidade ou juízo sobre a peça que o revisor ou o especialista não deu ("ficou bom", "está pronta", "o leitor vai gostar"): a nota é a do revisor, dita como veio. Enumerar categorias sempre deixa buraco, e esta cláusula fecha o buraco.

Chamar um especialista é carregar a skill dele (no Claude Code, a ferramenta Skill ou a leitura do `SKILL.md` na pasta irmã desta, `../<nome>/SKILL.md`) e executar tudo o que ela manda, com o pedido montado como descrito abaixo. Nenhuma etapa do especialista é pulada por economia: cada um já foi calibrado para fazer o mínimo que sustenta a peça.

## Etapa 0: a pasta de contexto

A pasta de contexto é a pasta atual, a que tem (ou vai ter) `voz.md`; se a pessoa apontar outra, use a dela. Antes de qualquer especialista, olhe os arquivos:

- `voz.md` e `banidas.txt`: escritos pelo `entrevista-voz`.
- `icp.md`, `prova.md` e `marca.md`: escritos pelo `contexto-negocio`.
- `base-conteudo.md`, `learnings.md`, `config.md`: podem estar vazios; o `linkedin-post` cria a tabela, o `learnings.md` cresce com as correções e o `publicar` trata `config.md`.

Arquivo vazio é o que não existe ou só tem o cabeçalho e a linha de instrução do `contexto-modelo` (até 3 linhas). Na primeira execução:

- `voz.md` vazio: chame o `entrevista-voz` antes de tudo, e diga em uma linha por quê: sem `voz.md` todo especialista escreve como IA genérica, e a peça sairia com a voz de ninguém.
- `icp.md` vazio: chame o `contexto-negocio` antes de tudo, e diga em uma linha por quê: sem `icp.md` ninguém sabe para quem a peça existe nem o que pode ser afirmado.
- Os dois vazios: `entrevista-voz` primeiro, `contexto-negocio` depois, com a mesma linha de motivo para cada um.

Esses dois especialistas conversam com a pessoa (entrevista, perguntas, validação). O motor entrega a conversa a eles e só retoma o fluxo quando os arquivos existirem e a pessoa trouxer o tema de novo; não tente escrever o post na mesma conversa em que a voz foi compilada. `prova.md` ou `marca.md` vazios com `icp.md` preenchido não param o fluxo: os especialistas marcam `[FALTA]` no que depender deles, e o motor lista isso na parada.

Com a pasta pronta, leia `base-conteudo.md` e `learnings.md` (se existir) antes de seguir: a base diz o que já foi feito e em que estado está; os learnings valem como regra em todo especialista que você chamar.

## Etapa 1: onde o fluxo está

O estado do fluxo vive em disco, não na conversa: `saida/` guarda o briefing, o post, o comentário e o carrossel de cada peça, e a tabela de `base-conteudo.md` guarda o status. Uma conversa nova retoma de onde a anterior parou lendo esses arquivos. Leia o pedido da pessoa e decida em qual ponto entrar:

- Tema, ideia, notícia, fato, "faz um post disso": Etapa 2, do começo.
- "Aprovado" (ou "aprova", "pode seguir", "tá bom, segue"): Etapa 3, sobre a peça mais recente com status `rascunho` em `base-conteudo.md` (ou a que a pessoa nomear). Se a mensagem traz a peça colada e ela não está em `saida/`, grave o texto em `saida/post-AAAA-MM-DD-<tema>.md` (data de hoje, tema em kebab-case) e registre a linha na base no formato que o `linkedin-post` define (Etapa 5 dele), com status `rascunho`, antes de aprovar. Peça aprovada precisa existir em arquivo para o `publicar` encontrá-la depois.
- "Ajusta X", "outro ângulo", "quero o gancho B": o pedido volta ao especialista dono daquela decisão (Etapa 2, ponto certo), e o fluxo segue dali até a parada de novo.
- "Publica", "monta o pacote", "publicado": Etapa 4.
- "Faz um check-up", "travei", "não está funcionando": nenhum especialista de escrita roda. Rode `bash [raiz do plugin]/scripts/checkup.sh` na pasta de contexto (a raiz do plugin é a de "Etapa 2", passo 4), sozinho e sem busca de arquivo, e repasse a saída inteira, com o código de saída. O código é 0 quando a linha final é `pendencias: 0` e 1 com qualquer outro número; se o host recusar o `echo "codigo $?"` encadeado, rode o script sozinho e diga que o código foi lido pela última linha. O script confere o que a máquina precisa e os arquivos da pasta; ele só lê, não grava nada. Para cada linha `falta`, diga o próximo passo em uma linha (o comando ou o especialista que a própria linha indica). Linha `opcional` não trava o fluxo: cite só o que muda para a pessoa. Para `pecas em aberto`, liste as peças com status `rascunho` ou `aprovado` da base, como na pergunta de desambiguação acima. Sem permissão para rodar o script, diga isso e peça à pessoa que o rode e cole a saída.

Se não der para saber a que peça a pessoa se refere, pergunte em uma linha, listando as peças com status `rascunho` ou `aprovado` da base.

## Etapa 2: até a peça principal

Nesta etapa a pessoa não é interrompida. Onde um especialista pede uma escolha (a letra do ângulo, a letra do gancho), o motor usa a recomendação dele e registra a escolha para mostrar na parada, com as alternativas de pé; a pessoa troca na hora de aprovar, se quiser. Nenhuma pergunta de conteúdo à pessoa no meio: o que faltar vira `[FALTA]` do especialista e aparece na parada.

1. `angulo`. Pedido: o tema com as fontes e os links que ele traz, e o que a pessoa disse sobre o fato (o que viu, concluiu ou sentiu), palavra por palavra. Sem turno de resposta, o recomendado é o entregue. Guarde a saída inteira (os ângulos, `Repete a base`, o briefing). Se o `angulo` recomendar adiar, pare aqui e mostre os ângulos e o motivo: a pessoa decide se segue. O `<tema>` em kebab-case do nome do briefing (`saida/briefing-AAAA-MM-DD-<tema>.md`) é o nome da peça daqui em diante; todo arquivo dela usa o mesmo.
2. `gancho`. Pedido: o briefing do ângulo recomendado e o tipo de peça `post`. Guarde a saída inteira; o gancho recomendado é o aprovado para o passo seguinte.
3. `linkedin-post`. Pedido: o briefing e o gancho recomendado, como gancho aprovado. Ele grava `saida/post-AAAA-MM-DD-<tema>.md` e registra a linha em `base-conteudo.md` com status `rascunho`. Grave o primeiro comentário que ele entregou em `saida/comentario-AAAA-MM-DD-<tema>.md` (mesma data e tema do post), com as linhas exatas que ele deu; quando ele disser que não há primeiro comentário, grave essa frase no arquivo. O `publicar` lê esse arquivo numa conversa que não viu esta.
4. Checagem mecânica da peça, pelo motor. Antes de mandar a peça ao revisor, rode `bash [raiz do plugin]/scripts/check-voz.sh saida/post-AAAA-MM-DD-<tema>.md banidas.txt` (a pasta `scripts/` fica dois níveis acima deste SKILL.md; omita `banidas.txt` se não existe) e guarde o código e o que ele imprimiu. A raiz do plugin é o caminho que o host mostrou ao carregar esta skill (no Claude Code, a linha "Base directory for this skill"), sem o final `/skills/motor`: monte o caminho absoluto a partir dela e rode o script direto, sem procurar o arquivo com `find` ou `ls`, porque o host costuma bloquear busca fora da pasta da pessoa e liberar o comando do script. Rode o script sozinho, sem `echo` encadeado: saída vazia sem erro é código 0, e a linha `Checagem da peça` diz "código 0" mesmo quando o código foi lido pela saída. A checagem de travessão, emoji e termo banido é mecânica e não pode depender de qual modelo está respondendo: o `linkedin-post` já rodou o script, o revisor deveria rodar de novo, mas um subagente pode não conseguir abrir terminal e contar por leitura, e aí a pessoa aprovaria com uma nota que não passou pelo grep. A rodada do motor é a que vale na parada; o que o revisor reportar sobre a própria checagem fica registrado como segunda linha. Código 1: repasse ao `linkedin-post` o que o script acusou, como ajuste, uma vez, e rode de novo no arquivo regravado; se acusar ainda assim, a parada mostra o que acusou e diz que a peça não está pronta para aprovar. Sem script, diga na parada que a checagem da peça foi por leitura.
5. `revisor`, em contexto limpo. Quem escreveu a peça nesta conversa não pode dar a nota dela, e o revisor só é útil se não leu o raciocínio de quem escreveu. Grave só o texto do post em `peca.md` na pasta de contexto e, quando o host oferecer subagente (no Claude Code, a ferramenta Agent), abra um com a mensagem que o `revisor/SKILL.md` define na seção "Contexto limpo", dizendo só o tipo ("tipo: teardown") e a data prevista de publicação se a pessoa deu uma. Não cole o briefing, os ângulos, os ganchos nem o que você acha da peça. Do JSON que volta, guarde quatro coisas para a parada: `veredito`, `nota`, `contexto_limpo` e `check_voz.rodou`. O último diz se a checagem de travessão, emoji e termo banido foi mecânica (o script rodou) ou de olho (o revisor contou por leitura), e a pessoa decide com a nota na mão, então ela precisa saber de onde a nota saiu. Sem subagente, pare aqui: mostre a peça e peça à pessoa que abra uma conversa nova e cole "Use a skill revisor sobre `peca.md` desta pasta, com o contexto que está aqui", e diga em uma frase o motivo (a nota dada na conversa que escreveu a peça é a nota do autor). Nesse caso, deixe `peca.md` na pasta e retome pela Etapa 1 quando a pessoa voltar com o JSON do revisor.
6. Uma rodada de correção, no máximo. Com veredito `reescrever`, repasse ao `linkedin-post` só a lista `correcoes` do JSON, como ajuste ("Ajustes depois da entrega" dele), rode o `check-voz.sh` de novo no arquivo regravado (o passo 4, porque a correção pode trazer termo novo) e mande a peça corrigida a um revisor novo, em subagente novo. Com `aprovar`, siga para a parada. Com `descartar`, não corrija: a primeira correção nomeia um problema de tese, ângulo ou prova, que não se resolve com ajuste de texto; siga para a parada com o problema de raiz e os outros ângulos do `angulo` como alternativa. Depois da rodada, não chame o revisor de novo por conta própria: a pessoa decide com as notas na mão. Quando o revisor rodou em subagente, apague `peca.md` ao terminar (a pasta é da pessoa, e ela não recebe arquivo que não pediu).

Então pare. A parada é obrigatória mesmo quando o veredito é `aprovar` e mesmo quando o pedido original dizia "faz tudo": a aprovação é da pessoa, e o que vem depois herda a peça.

## A parada de aprovação

Antes de mostrar, confira o que vai na mensagem: o post é o texto do arquivo em `saida/`, letra por letra, dentro de uma cerca de código sem linguagem (as quebras de linha sobrevivem ao copiar); o primeiro comentário é o do `linkedin-post`; a nota e o veredito do revisor são os que vieram no JSON, sem arredondar nem trocar rótulo, com `contexto_limpo` e `check_voz.rodou` ditos como vieram. Grave a mensagem inteira em `motor-rascunho.md` na pasta atual e rode a checagem e a remoção num comando só: `bash [raiz do plugin]/scripts/check-voz.sh motor-rascunho.md banidas.txt; echo "codigo $?"; rm -f motor-rascunho.md` (a pasta `scripts/` fica dois níveis acima deste SKILL.md; omita `banidas.txt` se não existe). Se o host recusar o comando composto (ver "O que a pessoa precisa liberar"), rode o script sozinho e apague o rascunho num segundo comando; sem o `echo`, saída vazia é limpo e qualquer linha impressa é acusação, e a linha `Checagem da mensagem` diz que o código foi lido pela saída. Acusou algo no texto do post: o conserto é do `linkedin-post`, não seu; acusou algo na sua parte da mensagem: reescreva a sua parte. Sem script, confira por leitura e diga isso na linha `Checagem da mensagem`.

Formato da parada, sem preâmbulo sobre o processo:

```
Peça principal: [tema], [tipo], [N] caracteres, lado [curto | longo].
Ângulo: [letra] ([nome curto]), recomendado pelo angulo; alternativas [letras e nomes curtos]. Repete a base: [o que o angulo disse].
Gancho: [letra] (estrutura [n]); alternativas [letras e estruturas].

```
[o post, letra por letra]
```

Primeiro comentário: [as linhas do linkedin-post, ou "nenhum: a peça não traz link"].
Checagem da peça: check-voz.sh código [0 | 1, com o que acusou; saída vazia é "código 0", escrito assim, nunca "sem acusação"] no arquivo de saida/, rodado pelo motor com banidas.txt [na versão final | de novo depois da correção]; ou "por leitura, sem script".
Revisor: [veredito], [nota] de 100, contexto limpo [sim | não], checagem mecânica do revisor [rodou | não rodou, contou por leitura]. [Primeira correção, como o revisor a deu.] [Se houve rodada: "Antes da correção: [veredito], [nota]."]
Falta: [cada FALTA e cada item de Aval que os especialistas listaram, em uma linha; ou "nada"].
Derivados previstos: [carrossel e legenda de Instagram, porque o angulo pediu "post e carrossel" | nenhum, porque o angulo pediu só post].
Checagem da mensagem: check-voz.sh código [0 ou 1, com o que acusou; saída vazia é "código 0"], rascunho apagado; ou "por leitura".

Aprova? [uma das duas redações abaixo, conforme Derivados previstos]
```

As duas redações da pergunta, e só elas:

- Com derivado previsto: `Responda "aprovado" para eu derivar o carrossel e parar na copy dele; "aprovado, segue até o pacote" para eu ir até publicar/ sem parar; "gancho B", "ângulo C" ou "ajusta [o quê]" para voltar ao especialista; "outro ângulo" para o angulo gerar novos.`
- Sem derivado previsto: `Responda "aprovado" para eu montar o pacote só com o post; "aprovado, com carrossel" para eu derivar o carrossel e parar na copy dele; "aprovado, com carrossel, segue até o pacote" para eu ir até publicar/ sem parar; "gancho B", "ângulo C" ou "ajusta [o quê]" para voltar ao especialista; "outro ângulo" para o angulo gerar novos.`

Tudo o que houver a dizer cabe nesses campos. As alternativas ficam de pé na mensagem porque a pessoa escolhe com a peça na frente, e não antes de vê-la. A pergunta não é reescrita: cada resposta listada é um caminho da Etapa 3, e uma opção que some da pergunta é um caminho que a pessoa nunca fica sabendo que existe.

## Etapa 3: depois do "aprovado"

1. Troque o status da peça em `base-conteudo.md` de `rascunho` para `aprovado`. A tabela é do `linkedin-post`, e o procedimento de trocar um status (como achar a linha, o que pode e o que não pode mudar, o que fazer com linha curta) está definido lá, na Etapa 5, no parágrafo "Trocar o status de uma peça"; siga o que está lá. O que o motor garante por si: lê o cabeçalho e preserva toda coluna que ele declara, sem lista fixa neste arquivo; e nunca entrega em silêncio uma linha com menos células que o cabeçalho. Peça colada pela pessoa e ainda fora da tabela é registrada primeiro, no formato do `linkedin-post`.
2. Se a pessoa trocou algo na aprovação ("aprovado, mas com o gancho B"), o ajuste vai ao especialista dono antes de aprovar, a checagem mecânica da peça (Etapa 2, passo 4) e o revisor em contexto limpo rodam de novo sobre o arquivo regravado, e a parada acontece de novo, com a linha `Checagem da peça` da versão nova. Aprovação com ajuste é ajuste, não aprovação.
3. `carrossel-roteiro`, quando o ângulo pediu `post e carrossel` (ou `carrossel`) ou a pessoa disse "com carrossel". Pedido: o texto aprovado (o arquivo em `saida/`), o tema e a data prevista de publicação quando a pessoa deu uma. Ele grava `saida/carrossel-AAAA-MM-DD-<tema>/carrossel.json` e entrega a copy slide a slide. Mostre a copy como ele entregou e pare: a copy é aprovada antes do render porque ajustar texto no roteiro custa uma linha e depois do render custa o render inteiro. A parada da copy tem este fecho fixo, depois da copy e das linhas de nota do roteiro: `Aprova a copy? Responda "aprovado" para eu renderizar e montar o pacote; "troca a capa", "junta o slide 3 e 4" ou "ajusta o slide N" para voltar ao carrossel-roteiro.` Nenhum PNG existe antes desse "aprovado". Exceção: se a aprovação da peça principal veio com "segue até o pacote", a pessoa já aprovou a copy antecipadamente; siga sem parar e diga isso na mensagem final.
4. `carrossel-render`, com a copy aprovada. Pedido: a pasta da peça. Ele gera os PNGs, o PDF e o relatório, e olha as imagens. Repasse os padrões e avisos dele palavra por palavra; se ele reportar que o motor de render não roda, repasse a instrução de exportação manual e siga para o `publicar` com o que existir.
5. `publicar`, Etapa 4.

Quando o ângulo pediu só `post` e a pessoa não pediu carrossel, pule os passos 3 e 4 e vá ao `publicar` com o post e o comentário; o pacote sai sem PNG e sem PDF, e o passo a passo diz isso.

## Etapa 4: o pacote

Chame o `publicar` com o tema da peça. Ele lê `config.md`, monta `publicar/<data>-<tema>/` (a data é a da peça em `base-conteudo.md`, não a de hoje) com `post.txt`, `primeiro-comentario.txt`, `legenda-instagram.txt`, os PNGs, `carrossel.pdf` e `passo-a-passo.md`, roda `check-voz.sh` em cada `.txt` e diz onde está tudo. Nesta versão ele não publica em rede nenhuma, e a mensagem final repete isso. O status na base continua `aprovado` até a pessoa dizer "publicado"; aí o `publicar` troca por `publicado`, do mesmo jeito que o motor trocou na Etapa 3 (só a célula, toda coluna do cabeçalho intacta, contagem de células conferida).

Feche com a mensagem do `publicar` e nada mais.

## O que a pessoa precisa liberar na primeira execução

O motor não roda nada sozinho: cada comando passa pela permissão do host, e na primeira peça a pessoa vai ver uma sequência de pedidos que ela não escreveu. Diga a ela, na primeira vez, o que vai aparecer e por quê, em vez de deixar cada prompt chegar sem contexto:

- Subagente (no Claude Code, a ferramenta Agent): o revisor roda nele. Sem liberar, o motor para antes da revisão e pede uma conversa nova.
- `bash [raiz do plugin]/scripts/check-voz.sh ...`: a checagem mecânica de travessão, emoji e termo banido, que todo especialista roda. O comando vem encadeado com `echo "codigo $?"` e `rm -f <rascunho>`; o `rm` só apaga o rascunho temporário que o próprio especialista acabou de gravar. Host que avalia permissão por prefixo pode recusar o encadeamento inteiro; nesse caso os especialistas rodam o script sozinho e apagam o rascunho num segundo comando, e dizem que leram o código pela saída.
- `node [raiz do plugin]/scripts/render-carrossel.mjs ...`: o render do carrossel (PNG e PDF), só depois da copy aprovada. Precisa de Node e do Chromium do Playwright instalados uma vez (`carrossel-render`, Etapa 3 diz como); sem eles o render entrega o HTML e a instrução de exportar à mão.
- `bash [raiz do plugin]/scripts/checkup.sh`: o check-up ("faz um check-up", Etapa 1). Só lê a pasta de contexto e confere se `git`, `node`, `jq` e o Chromium do Playwright estão no PATH; não grava nada.
- `jq`, `wc -m`, `cmp`: leitura de campo do `carrossel.json`, contagem de caracteres e conferência do post copiado. `jq` não vem instalado no macOS; sem ele o `publicar` lê o JSON e grava o campo à mão, e o `carrossel-roteiro` confere o JSON por leitura, e os dois dizem isso na resposta.
- `mkdir -p` e `cp`: a montagem da pasta `publicar/<data>-<tema>/`, com os PNGs e o PDF copiados como binário.

Nenhum comando sai da pasta de contexto ou da pasta do plugin, e nenhum toca em rede. Permissão negada nunca é silenciosa: o especialista faz o que dá sem o comando, diz o que ficou por leitura e o que ficou por fazer.

## Ajustes depois da parada

- "Gancho B" ou "ângulo C": o `linkedin-post` reescreve com a opção escolhida (com ângulo novo, o `gancho` roda antes); o revisor roda de novo em contexto limpo; nova parada, com as duas notas.
- "Ajusta o hook", "mais curto", "tá muito IA", "tira o nome": pedido repassado ao `linkedin-post` como está ("Ajustes depois da entrega" dele); revisor de novo; nova parada.
- "Outro ângulo": o `angulo` gera novos; o fluxo segue do passo 2 da Etapa 2.
- "Troca a capa", "junta o slide 3 e 4": pedido ao `carrossel-roteiro`; render só depois.
- "Esse número tá errado": vai ao especialista que o escreveu, e a correção entra como fonte na nota dele; se o número veio de `prova.md`, avise que o arquivo precisa mudar pelo `contexto-negocio`.
- Correção que muda uma regra (a pessoa rejeitou uma estrutura, um tipo, um tom, uma palavra): o especialista dono grava em `learnings.md`; confira que gravou, porque o próximo fluxo lê esse arquivo na Etapa 0.

## O que o motor não faz

- Não escreve, não reescreve e não corrige texto de peça: ângulo, gancho, post, roteiro, legenda e pacote são dos especialistas, e o motor repassa o que eles entregaram.
- Não carrega regra de escrita. Tamanho, tipo, estrutura, fecho, anti-invenção e voz estão em `angulo`, `gancho`, `linkedin-post`, `carrossel-roteiro` e `revisor`; em conflito, o especialista manda.
- Não deriva nada antes do "aprovado" da pessoa, e não renderiza antes da copy aprovada (salvo aprovação antecipada explícita).
- Não revisa na mesma conversa em que a peça foi escrita, e não apresenta nota de contexto sujo como nota limpa.
- Não preenche `[FALTA]`, não escolhe entre números em conflito e não confirma claim que precisa de aval.
- Não muda coluna de `base-conteudo.md` além de `Status`, não recria a tabela e não entrega em silêncio uma linha com menos células que o cabeçalho.
- Não publica. A publicação é da pessoa, com o pacote que o `publicar` monta.
