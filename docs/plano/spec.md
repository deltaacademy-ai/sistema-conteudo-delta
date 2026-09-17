---
type: Project
status: Active
tags: [conteudo, produto, skills, linkedin, instagram]
created: 2026-09-17
updated: 2026-09-17
belongs_to:
  - "[[conteudo]]"
related_to:
  - "[[dna-da-voz]]"
  - "[[dorias-socials-api]]"
_organized: true
---

# Sistema de Conteúdo

Produto @hdoria: um sistema de conteúdo para gestores e founders B2B, operado no Claude Code, com LinkedIn e carrossel de Instagram como carros-chefe. Nasce da produtização das skills que o Hugo criou em mentoria (squad de LinkedIn, entrevista de voz e compilador), modernizadas e unidas ao critério do [[dna-da-voz]] e do `linkedin-copy`. Decisões fechadas em sessão de debate em 2026-09-17 (log em `ai/sessions/2026-09-17-analise-kit-virada-ia.md`). Plano de execução em [[sistema-conteudo-plano]].

Referências que motivaram: kit "A Virada IA" da Bruna Santanna (produto e página em brunasantanna.com/sistema) e o repositório `holy-templar/marketing-agi` (arquitetura de roteador, painel de nota, trava contra invenção). Delas entram só ideias, sem texto copiado.

## Produto e venda

- Entrada com sistema e aulas gravadas; upgrade com turma ou mentoria ao vivo.
- Marca @hdoria pessoal, sem associação com a Idens.
- Primeiro a base quente: turma fundadora de 5 a 10 pessoas escolhidas a dedo, convidadas pelo Hugo, com preço simbólico entre R$297 e R$497. Preço de tabela e página pública só depois de número medido no perfil do Hugo.
- **Entrega da primeira turma: 2026-09-25, com LinkedIn e Instagram.**
- `hdoria/marketing-skills` e `hdoria/humanizar` seguem públicos e grátis, sem investimento, com link para o sistema no README.

## Plataforma e arquitetura

- O comprador roda no Claude Code. Distribuição como plugin num repositório privado `hdoria/sistema-conteudo`, com acesso liberado por compra.
- Especialistas independentes, chamáveis um a um, mais um `motor` que só orquestra (ideia, peça principal aprovada, derivados). Cada regra mora num lugar só.
- Tudo em markdown puro, sem dependência de recurso exclusivo do Claude Code, para rodar também no Grok Bot. No Grok Bot, uso só do Hugo, via clone com token de leitura restrito ao repositório e skills curtas que apontam para o clone (padrão de 2026-08-11). O marketing-agi já roda assim.
- Contexto do comprador numa pasta com git: `voz.md`, `voz-bruta.md`, `banidas.txt`, `icp.md`, `prova.md` (números com fonte e data), `base-conteudo.md`, `learnings.md`.

## Especialistas

`entrevista-voz`, `contexto-negocio`, `radar-pautas`, `angulo`, `gancho`, `linkedin-post`, `carrossel-roteiro`, `carrossel-render`, `revisor`, `reaproveitar`, `publicar`, `medir`, mais o `motor`.

- **Revisão**: o grep mecânico (travessão, emoji, banidas) roda dentro de cada especialista; o julgamento (painel de nota, passe de ICP) fica com o `revisor` em contexto limpo.
- **Aprendizado**: correção do comprador vira learning automático com regra, porquê e como aplicar; um `consolidar` periódico promove os recorrentes a regra no `voz.md` e no `icp.md`.
- **Dado de nicho**: o playbook B2B do Hugo é o padrão, rotulado como heurística. Um `analisar-nicho` fica para depois.
- **Tipos de post de LinkedIn (7)**: teardown de notícia, caso, build ou bastidor, educativo, posição, lead magnet, anúncio pessoal. Tamanho segue a regra bimodal (abaixo de 900 ou acima de 1.400 caracteres). O `angulo` escolhe o tipo perguntando se o fato é sobre o mercado ou sobre a pessoa.
- **Gancho** é especialista próprio, usado pelo post, pela capa do carrossel e pelos derivados. Capa nomeia a entrega.
- **Carrossel**: estático, um render só, PNG 1080x1350 para Instagram e PDF dos mesmos slides para o LinkedIn. Animado fica como upgrade.

## Voz

- Entrevista enxuta: lê de 10 a 20 textos reais e faz de 40 a 60 perguntas só sobre o que o texto não mostra (crenças, nojo, limites). Compilação em contexto limpo.
- Quem começa do zero: de 5 a 8 respostas faladas curtas viram o material de leitura. Recompilação do `voz.md` quando a pessoa tiver 10 posts publicados.
- Saídas: `voz-bruta.md` (transcrição), `voz.md` (XML até 5 mil tokens), `banidas.txt`.
- Validação: a pessoa lê e aprova, depois teste de reconhecimento (3 textos gerados misturados com 3 reais).

## Publicação e métricas

Interface única de publicar e medir, com destino escolhido na configuração do comprador: manual como padrão, Metricool opcional (plano pago, mídia em URL pública), Doria's Socials quando o isolamento de acesso entre clientes e a App Review da Meta estiverem prontos.

## Fontes e modernização

- Material é do Hugo, sem crédito a terceiros: squad de 2026-07-03 em `~/Downloads/squad-conteudo-linkedin/` (setup, kotler, hormozi, ogilvy, davinci), entrevista e compilador no Craft ("Criador de Alma" e "Você é só um arquivo de texto"), `linkedin-copy`, [[dna-da-voz]], `generate-carousel`, `popcode-instagram`, [[analise-concorrentes-linkedin-instagram]].
- Casos de referência antes da reescrita. Reescrita em Fable 5.1 na sessão principal; julgamento com Opus 5 em contexto limpo.
- Validação em Sonnet 5 (piso) e Opus 5, 5 casos por especialista do núcleo. Só entra o que empatar ou ganhar da versão antiga.

## Cronograma e qualidade

- **Núcleo em 2026-09-25**: `entrevista-voz`, `contexto-negocio`, `angulo`, `gancho`, `linkedin-post`, `carrossel-roteiro`, `carrossel-render`, `revisor`, `motor`, com `publicar` no modo manual.
- **Atualizações semanais durante a turma**: `radar-pautas`, `reaproveitar`, `medir`, `consolidar`, integração Metricool.
- Hugo como cliente zero: entrevista nova e 1 post e 1 carrossel reais pelo fluxo até 2026-09-23.
- As skills atuais do Hugo seguem funcionando e só saem depois do teste cego (10 briefings, a nova empata ou ganha em pelo menos 7) mais 2 a 4 semanas de uso real.

## Adiado de propósito

Valor exato do preço fundador, estrutura das aulas gravadas, página de venda, critérios detalhados da nota do `revisor`.

## Pendências fora do escopo

- Doria's Socials: API e MCP não isolam clientes (a chave de serviço ignora RLS e nenhum handler filtra por dono); exposição confirmada em 2026-09-17 (cadastro aberto em produção, conta nova cria chave e opera @hdoria e @popcode.ai). Hugo decidiu manter como está e tratar depois de 2026-09-25, aceitando o risco no intervalo.
- `linkedin-copy` lê o `dna-da-voz` de `~/Documents/HUGO OS/`, cópia antiga do vault.
