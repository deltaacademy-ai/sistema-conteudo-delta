# Instalar o sistema de conteúdo

São 6 passos, feitos uma vez. Depois disso você abre o Claude Code na sua pasta de conteúdo e pede o post.

## O que você precisa

- Claude Code instalado e logado com Claude Pro ou Max.
- `git` e o GitHub CLI (`gh`). No Mac: `brew install git gh`.
- Uma conta no GitHub com o convite deste repositório aceito. O repositório é privado, então sem o convite nada abaixo funciona.

Opcional, pro carrossel sair em PNG e PDF direto: Node LTS (`brew install node`). Sem Node o carrossel sai em HTML e você exporta pelo Chrome.

Opcional também: `jq` (`brew install jq`). Sem ele o sistema confere o JSON do carrossel por leitura e avisa isso na resposta.

## 1. Aceite o convite

O convite chega no seu e-mail do GitHub. Se não achar, abra https://github.com/hdoria/sistema-conteudo/invitations logado na sua conta e aceite por lá.

## 2. Deixe o git com acesso ao repositório

O Claude Code baixa o plugin com o `git` da sua máquina e não pede senha no meio. A credencial precisa estar guardada antes. No terminal:

```bash
gh auth login
gh auth setup-git
```

No `gh auth login`, escolha GitHub.com, HTTPS e "Login with a web browser". Pra conferir se deu certo:

```bash
git ls-remote https://github.com/hdoria/sistema-conteudo.git HEAD
```

Se aparecer uma linha com um código longo e `HEAD`, o acesso tá ok. Se pedir senha ou der erro 404, o convite não foi aceito ou o login foi em outra conta.

## 3. Instale o plugin

Ainda no terminal:

```bash
claude plugin marketplace add hdoria/sistema-conteudo
claude plugin install sistema-conteudo@sistema-conteudo
claude plugin list
```

A última linha precisa mostrar `sistema-conteudo@sistema-conteudo` como habilitado. Se preferir fazer de dentro do Claude Code: `/plugin marketplace add hdoria/sistema-conteudo` e depois `/plugin install sistema-conteudo@sistema-conteudo`, que abre a tela do plugin com o botão de instalar.

## 4. Crie sua pasta de conteúdo

É nela que ficam sua voz, seu contexto de negócio e tudo que o sistema produz. Uma pasta por pessoa. O modelo vem junto com o plugin:

```bash
cp -R ~/.claude/plugins/marketplaces/sistema-conteudo/contexto-modelo ~/conteudo
cd ~/conteudo
git init
git add -A && git commit -m "inicio"
```

Pode trocar `~/conteudo` pelo caminho que quiser. O `git init` é pra você ter histórico: quando o sistema regrava sua voz ou sua base, dá pra ver o que mudou e voltar atrás.

## 5. Instale o render do carrossel (se tiver Node)

A instalação do plugin já traz o Playwright. Falta o navegador que ele usa pra gerar as imagens. Uma vez só:

```bash
cd ~/.claude/plugins/cache/sistema-conteudo/sistema-conteudo/0.1.0
npm install
npx playwright install chromium
```

O `npm install` quase sempre responde que já tá tudo lá. Ele fica aqui pro caso de não estar. Quando o plugin atualizar, o número da versão no caminho muda, e o Chromium continua instalado.

## 6. Primeiro uso

Abra o Claude Code dentro da pasta de conteúdo:

```bash
cd ~/conteudo
claude
```

E peça:

```
Quero começar o sistema de conteúdo.
```

O `motor` vê que a pasta tá vazia e chama a entrevista de voz primeiro, depois o contexto do seu negócio. São as conversas mais longas do sistema, e só acontecem uma vez.

Com as duas prontas, abra uma conversa nova na mesma pasta e mande o tema: uma notícia, um link, algo que aconteceu na sua empresa. Tipo "faz um post disso: [o que aconteceu]". O sistema escreve, manda pra um revisor que não viu o raciocínio de quem escreveu e para pra você aprovar. Nada é publicado sozinho: no fim ele monta a pasta `publicar/` com o texto, o carrossel e o passo a passo, e quem posta é você.

## O que o Claude Code vai pedir pra liberar

Na primeira peça aparecem vários pedidos de permissão que você não digitou. São esses:

- **Subagente (Agent):** é onde o revisor roda, sem ver a conversa de quem escreveu. Sem liberar, o sistema para antes da revisão e pede uma conversa nova.
- **`bash .../scripts/check-voz.sh`:** a checagem de travessão, emoji e termo proibido. Às vezes vem junto com `rm -f`, que apaga só o rascunho temporário que o próprio sistema acabou de gravar.
- **`node .../scripts/render-carrossel.mjs`:** gera os PNGs e o PDF do carrossel.
- **`jq`, `wc`, `cmp`, `mkdir`, `cp`:** leem o JSON do carrossel, contam caracteres, conferem a cópia do post e montam a pasta `publicar/`.

Nenhum desses comandos sai da sua pasta de conteúdo ou da pasta do plugin, e nenhum acessa a internet. Pode escolher "sempre permitir" pra não ver o pedido de novo. Se negar algum, o sistema faz o que dá sem ele e diz o que ficou por conferir.

## Atualizar

Quando sair versão nova:

```bash
claude plugin marketplace update sistema-conteudo
claude plugin update sistema-conteudo@sistema-conteudo
```

Sua pasta de conteúdo não é tocada pela atualização.

Pra atualizar sozinho: dentro do Claude Code, abra `/plugin`, vá em Marketplaces, escolha `sistema-conteudo` e ligue "Enable auto-update". Funciona porque o passo 2 deixou a credencial guardada.

## Se der errado

- **`marketplace add` falha com erro de autenticação ou "repository not found":** refaça o passo 2 e rode o `git ls-remote`. Se ele funcionar e o add continuar falhando, rode `export CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` e tente de novo. Isso faz o Claude Code usar HTTPS em vez de tentar SSH primeiro.
- **O `cp` do passo 4 diz que a pasta não existe:** o passo 3 não terminou. Rode `claude plugin list` e confira.
- **O carrossel saiu só em HTML:** falta o passo 5. A resposta do sistema também explica como exportar pelo Chrome.
- **A entrevista começou numa pasta errada:** o sistema usa a pasta onde você abriu o Claude Code. Feche, entre na pasta de conteúdo e abra de novo.
- **Travou em qualquer ponto, ou algo não responde:** abra o Claude Code na sua pasta de conteúdo e peça "faz um check-up". O sistema confere `git`, `node`, `jq`, o Chromium do carrossel e os arquivos da pasta, e diz o que falta e o comando que resolve.
