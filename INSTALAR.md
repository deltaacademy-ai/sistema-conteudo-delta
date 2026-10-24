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

## 3. Instale o plugin e ligue a atualização automática

Ainda no terminal, uma linha:

```bash
claude plugin install sistema-conteudo --marketplace hdoria/sistema-conteudo
claude plugin list
```

A segunda linha precisa mostrar `sistema-conteudo@sistema-conteudo` como habilitado. Essa forma precisa do Claude Code 2.1.292 ou mais novo (`claude --version` mostra o seu). Se o seu for anterior, use o caminho em duas linhas:

```bash
claude plugin marketplace add hdoria/sistema-conteudo
claude plugin install sistema-conteudo@sistema-conteudo
```

Agora ligue a atualização automática, senão você não recebe as versões novas: para plugin de terceiros ela vem desligada. Dentro do Claude Code, abra `/plugin`, vá em Marketplaces, escolha `sistema-conteudo` e ligue "Enable auto-update". Funciona porque o passo 2 deixou a credencial guardada.

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

A instalação do plugin já traz o Playwright. Falta o navegador que ele usa pra gerar as imagens. Uma vez só. Abra o Claude Code na sua pasta de conteúdo (`cd ~/conteudo` e `claude`) e peça "faz um check-up". Se a linha `chromium` vier como opcional, ela traz o comando pronto, com o caminho certo do seu computador. Copie e rode esse comando no terminal. É a forma de instalar sem depender do número da versão no caminho: quando o plugin atualizar, o Chromium continua instalado.

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

O `motor` vê que a pasta tá vazia, confere o que falta na instalação e chama a entrevista de voz primeiro, depois o contexto do seu negócio. São as conversas mais longas do sistema, e só acontecem uma vez. Elas rendem mais no modelo mais forte do seu plano; o dia a dia pode rodar no padrão.

Parou no meio? Abra o Claude Code na mesma pasta e diga "continuar": o `motor` lê a pasta e diz o próximo passo.

## Por que o terminal

O sistema roda no Claude Code do terminal, e não em outro lugar, por três motivos:

- O repositório é privado. Quem baixa o plugin é o `git` da sua máquina, com a credencial que o passo 2 guardou. Outro ambiente não tem essa credencial.
- O Claude na nuvem (claude.ai no navegador) não carrega plugin.
- A aba Code do app não documenta como adicionar um marketplace privado.

Com as duas prontas, abra uma conversa nova na mesma pasta e mande o tema: uma notícia, um link, algo que aconteceu na sua empresa. Tipo "faz um post disso: [o que aconteceu]". O sistema escreve, manda pra um revisor que não viu o raciocínio de quem escreveu e para pra você aprovar. Nada é publicado sozinho: no fim ele monta a pasta `publicar/` com o texto, o carrossel e o passo a passo, e quem posta é você.

## O que o Claude Code vai pedir pra liberar

O plugin já avisa o Claude Code de quais comandos próprios ele vai rodar (a checagem de voz, o check-up, o render do carrossel, a conferência das pautas e a montagem da pasta `publicar/`). Esses pedidos não aparecem pra você. Ficam só dois tipos, que o plugin não pode liberar por você:

- **Subagente (Agent):** é onde o revisor roda, sem ver a conversa de quem escreveu. Sem liberar, o sistema para antes da revisão e pede uma conversa nova.
- **Busca na web e leitura de página (só no pedido de pautas):** o `radar-pautas` procura novidades do seu nicho com a busca que o seu Claude Code já tem; a janela de tempo e o que acontece sem a busca estão em "As três camadas de fonte" do radar. O radar é instruído a só buscar e ler, e a regra está nele. O que o Claude Code garante é que pede a sua permissão antes de abrir cada página, a menos que você libere. Liberar a leitura de página é escolha sua; se não liberar, a lista sai só dos seus arquivos.

Se aparecer um pedido de `bash ... check-voz.sh`, `checkup.sh`, `checa-pautas.sh`, `node ... render-carrossel.mjs`, `jq`, `cmp`, `mkdir` ou `cp`, é o mesmo comando de sempre, e pode aprovar. Nenhum deles sai da sua pasta de conteúdo ou da pasta do plugin, e só o radar acessa a internet. Se negar algum, o sistema faz o que dá sem ele e diz o que ficou por conferir.

## Atualizar

Quando sair versão nova:

```bash
claude plugin marketplace update sistema-conteudo
claude plugin update sistema-conteudo@sistema-conteudo
```

Sua pasta de conteúdo não é tocada pela atualização.

Com a atualização automática ligada no passo 3, isso acontece sozinho ao abrir o Claude Code.

## Se der errado

- **`marketplace add` falha com erro de autenticação ou "repository not found":** refaça o passo 2 e rode o `git ls-remote`. Se ele funcionar e o add continuar falhando, rode `export CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` e tente de novo. Isso faz o Claude Code usar HTTPS em vez de tentar SSH primeiro.
- **O `cp` do passo 4 diz que a pasta não existe:** o passo 3 não terminou. Rode `claude plugin list` e confira.
- **O carrossel saiu só em HTML:** falta o passo 5. A resposta do sistema também explica como exportar pelo Chrome.
- **A entrevista começou numa pasta errada:** o sistema usa a pasta onde você abriu o Claude Code. Feche, entre na pasta de conteúdo e abra de novo.
- **Travou em qualquer ponto, ou algo não responde:** abra o Claude Code na sua pasta de conteúdo e diga "travei". O sistema faz o check-up (`git`, `node`, `jq`, o Chromium do carrossel e os arquivos da pasta), diz o que falta e o comando que resolve, e monta o pedido de suporte pronto, como descreve a seção "Pedido de suporte" do `motor`. Você cola o pedido em uma issue nova do repositório; o `motor` entrega o link.
