---
name: publicar
description: Monta o pacote de publicação de uma peça aprovada, no modo que config.md define. Nesta versão só existe o modo manual, e é ele que roda quando o arquivo não diz outra coisa: cria publicar/<data>-<tema>/ com post.txt, primeiro-comentario.txt, legenda-instagram.txt, os PNGs e o PDF do carrossel e um passo a passo para a pessoa publicar à mão no LinkedIn e no Instagram. Nunca chama API de rede social. Use quando a pessoa pedir para publicar, montar o pacote, preparar a publicação ou "deixa pronto pra postar", quando o motor chegar ao fim dos derivados, ou quando ela disser "publicado" para marcar a peça na base.
---

# Publicar

Este especialista é o último da fila. Ele pega o que os outros gravaram em `saida/` e monta, numa pasta só, tudo o que a pessoa precisa para publicar sem procurar arquivo. Ele não escreve, não reescreve e não corrige texto: o que entra em `post.txt` é o post aprovado letra por letra, e o que entra em `legenda-instagram.txt` é a legenda que o `carrossel-roteiro` gravou. Se um texto está errado, o conserto é do especialista que o escreveu.

Nesta versão nada é publicado por ele. O modo `manual` monta o pacote e o passo a passo; a publicação é feita pela pessoa, no navegador ou no celular. Nenhuma chamada a API do LinkedIn, do Instagram ou de ferramenta de agendamento acontece aqui, e a mensagem final repete isso, para ninguém esperar que a peça tenha ido ao ar.

## O que ele entrega

Em `publicar/<data>-<tema>/` na pasta de contexto (a pasta atual, a que tem `voz.md`; se a pessoa apontar outra, use a dela), onde `<data>` e `<tema>` são os da peça em `base-conteudo.md` e em `saida/` (a data em que a peça foi escrita, não a de hoje):

1. `post.txt`: o texto do post, tal qual está em `saida/post-<data>-<tema>.md`, sem cercas, sem título, com as quebras de linha originais.
2. `primeiro-comentario.txt`: as linhas de `saida/comentario-<data>-<tema>.md` (uma por fonte, com o link). Quando o arquivo diz que não há primeiro comentário, o `.txt` traz essa frase, e o passo a passo manda pular o comentário.
3. `legenda-instagram.txt`: o campo `legenda_instagram` de `saida/carrossel-<data>-<tema>/carrossel.json`, com as quebras de linha restauradas.
4. `01.png` a `NN.png`: cópia dos PNGs da pasta do carrossel, na mesma ordem e com o mesmo nome.
5. `carrossel.pdf`: cópia do PDF da pasta do carrossel.
6. `passo-a-passo.md`: a ordem de publicação em cada rede, com o nome do arquivo em cada passo.

Na resposta: o modo lido de `config.md`, a lista dos arquivos com tamanho ou contagem, o resultado do `check-voz.sh` em cada `.txt`, o que faltou, e a frase de que nada foi publicado.

## Etapa 0: o modo

Leia `config.md` na pasta de contexto e procure a linha `destino_publicacao:`.

- `manual`: siga.
- Arquivo ausente, linha ausente ou valor vazio: trate como `manual` e diga isso na resposta em uma linha.
- Qualquer outro valor (um nome de ferramenta, `api`, `automatico`): diga que esta versão só tem o modo manual, monte o pacote manual do mesmo jeito e não tente conectar a nada. A pessoa fica sabendo que o valor do arquivo ainda não faz nada.

## Etapa 1: o que existe da peça

Localize a peça pelo tema que a pessoa deu ou pela linha mais recente com status `aprovado` em `base-conteudo.md`. Peça com status `rascunho` não entra no pacote: avise que ela ainda não foi aprovada e pare; a aprovação é dada ao `motor`, e o pacote de um rascunho vira post publicado sem revisão.

Depois olhe `saida/`:

- `post-<data>-<tema>.md`: obrigatório. Sem ele, pare e diga o que falta; não monte `post.txt` a partir de mensagem antiga nem de memória.
- `comentario-<data>-<tema>.md`: quando não existe, `primeiro-comentario.txt` recebe a frase "Sem primeiro comentário: a peça não traz link." e a resposta diz que o arquivo não existia.
- `carrossel-<data>-<tema>/carrossel.json`, com os PNGs e `carrossel.pdf` ao lado: quando a pasta não existe, o pacote sai sem `legenda-instagram.txt`, sem PNG e sem PDF, e o passo a passo cobre só o LinkedIn. Quando o `carrossel.json` existe mas os PNGs ou o PDF não, o carrossel ainda não foi renderizado: diga que o `carrossel-render` precisa rodar antes, monte o que der (post, comentário, legenda) e liste o que faltou.

Nada é gerado aqui para tapar buraco: arquivo que falta é dito como falta.

## Etapa 2: montar a pasta

Crie `publicar/<data>-<tema>/` e copie cada arquivo pelo caminho, sem reescrever o conteúdo. Quando puder rodar comandos, use cópia de arquivo (`mkdir -p` e `cp`) para os PNGs e o PDF, que são binários, e para o post e o comentário, que precisam ficar letra por letra; para a legenda, extraia o campo do JSON (`jq -r .legenda_instagram`) e grave o resultado. Sem comandos, leia cada arquivo de texto e grave o `.txt` com o mesmo conteúdo, e diga na resposta que os PNGs e o PDF não puderam ser copiados e onde estão.

Escreva `passo-a-passo.md` com esta estrutura, adaptada ao que existe no pacote:

```markdown
# Passo a passo: [tema]

Nada foi publicado. Esta pasta tem tudo o que você precisa para publicar à mão.

## LinkedIn

1. Abra o LinkedIn e comece um post novo.
2. Cole o conteúdo de `post.txt`, sem mudar nada. Confira as quebras de linha: cada parágrafo separado por linha em branco.
3. Publique.
4. Logo depois de publicar, abra o post e cole `primeiro-comentario.txt` como o primeiro comentário. [Se o arquivo diz que não há comentário: pule este passo.]
5. [Se existe carrossel.pdf:] Para a versão em carrossel de documento, faça outro post, anexe `carrossel.pdf` como documento e cole `legenda-instagram.txt` como texto, ou uma versão dela. Publique num dia diferente do post de texto, para a mesma peça não aparecer duas vezes no mesmo feed.

## Instagram

1. Abra o Instagram e comece uma publicação de várias fotos.
2. Selecione `01.png` até `NN.png`, nessa ordem. A capa é o `01.png`.
3. Cole `legenda-instagram.txt` como legenda.
4. Publique. [Se o primeiro comentário traz link: o Instagram não abre link em comentário; deixe a fonte nomeada na legenda, como ela já está.]

## Depois de publicar

Volte aqui e diga "publicado": a peça muda para `publicado` em base-conteudo.md.
```

Substitua `NN` pelo número real de slides, tire os passos entre colchetes que não se aplicam e não acrescente instrução que o pacote não sustenta (sem "melhor horário", sem "hashtags sugeridas": o post não usa hashtag e o horário é decisão da pessoa).

## Etapa 3: conferência

Antes de responder:

1. Conte os arquivos da pasta e compare com o que a Etapa 1 encontrou: todo PNG da pasta do carrossel está no pacote, com o mesmo nome; o PDF está; os três `.txt` estão (ou o que faltou está dito).
2. `post.txt` é idêntico ao arquivo de origem. Quando puder rodar comandos, `cmp` os dois; sem comandos, releia os dois e diga que a conferência foi por leitura.
3. Rode `bash [raiz do plugin]/scripts/check-voz.sh <arquivo> banidas.txt` em cada `.txt` do pacote (a pasta `scripts/` fica dois níveis acima deste SKILL.md; omita `banidas.txt` se não existe) e reporte o código de saída de cada um. Se algum acusar algo, o pacote fica montado, mas a resposta diz qual arquivo e o que acusou, e aponta o especialista dono (`linkedin-post` para o post e o comentário, `carrossel-roteiro` para a legenda): você não corrige texto. Sem script, confira por leitura e diga isso.
4. `passo-a-passo.md` cita só arquivos que existem na pasta.
5. Nenhuma chamada a rede social foi feita, e a resposta diz isso.

## Etapa 4: o status

Quando a pessoa disser "publicado" (com ou sem a rede e o link), leia o cabeçalho da tabela em `base-conteudo.md` e conte as colunas que ele declara; localize a linha da peça e troque só a célula `Status` de `aprovado` para `publicado`. Nenhuma outra célula muda, o cabeçalho não muda, e toda coluna que o cabeçalho declara fica com o valor que tinha. A lista de colunas é a do cabeçalho, nunca uma lista fixa deste arquivo: o `linkedin-post` grava colunas de controle (hoje `CTA`, que sustenta a conta de 1 em 3 posts, e `Assinatura`, que impede a mesma frase de assinatura em peças seguidas) e pode gravar outras, e uma célula perdida na troca de status quebra a regra daquela coluna sem ninguém perceber. Depois de gravar, releia a linha e conte as células: se ela tem menos células que o cabeçalho, corrija na hora (complete com as células que faltam, vazias, no lugar certo) e diga na resposta que a linha saiu curta e foi corrigida; nunca entregue com a linha curta em silêncio. Linha antiga que já estava curta antes de você tocar na tabela não é sua para corrigir: aponte na resposta qual linha e quantas células faltam. Se a pessoa deu o link do post, guarde-o na coluna de fonte ou de link se a tabela tiver uma; se não tiver, deixe na resposta e não crie coluna.

## Formato da resposta

```
Modo: manual (config.md: [o valor lido | ausente, tratado como manual]).
Pacote: publicar/<data>-<tema>/
→ post.txt ([N] caracteres)
→ primeiro-comentario.txt ([N] linhas | sem comentário)
→ legenda-instagram.txt ([N] caracteres)
→ 01.png a NN.png ([N] arquivos)
→ carrossel.pdf ([N] páginas, se o relatório do render disser)
→ passo-a-passo.md
Checagem: check-voz.sh em post.txt [código], primeiro-comentario.txt [código], legenda-instagram.txt [código]; post.txt idêntico à origem [por cmp | por leitura].
Faltou: [o que não existia em saida/ e ficou de fora, ou "nada"].
Nada foi publicado: esta versão monta o pacote e o passo a passo, e a publicação é sua. Quando publicar, diga "publicado" e eu marco na base.
```

## O que este especialista não faz

- Não chama API do LinkedIn, do Instagram nem de ferramenta de agendamento, com qualquer valor em `config.md`.
- Não escreve nem corrige texto: post, comentário e legenda entram como os especialistas os gravaram.
- Não monta pacote de peça com status `rascunho`.
- Não gera imagem, PDF ou legenda que não existe em `saida/`: falta é falta.
- Não muda coluna de `base-conteudo.md` além de `Status`, e só para `publicado`, quando a pessoa disser que publicou; não entrega em silêncio uma linha com menos células que o cabeçalho.
