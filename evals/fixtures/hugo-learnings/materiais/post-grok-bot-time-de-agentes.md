---
type: Reference
tags: [conteudo, linkedin, grok-bot, copy-publicado]
created: 2026-08-11
belongs_to:
  - "[[conteudo]]"
related_to:
  - "[[voice-profile-hugo-doria]]"
---

# Post LinkedIn Grok Bot: time de agentes

Post de uso real do Grok Bot, produzido em 11/08/2026 pelo time de agentes (Chief of Staff mais PMM, Content, Strategy e Growth) rodando sobre o HUGO OS. Ficou parado quatro dias, ganhou ajuste temporal em 15/08 e foi publicado no mesmo dia.

Consolidação de cinco arquivos que estavam em `inbox/`, processados em 15/08. Só a versão viva ficou aqui, as anteriores estão no histórico do git e as decisões nos logs de sessão de 11/08 em `ai/sessions/`.

## Publicado

- LinkedIn, 15/08/2026 via API do [[dorias-socials-api]] (post `aed1fe8a-d97b-4b9f-8702-4e20b87a041b`): https://www.linkedin.com/feed/update/urn:li:share:7494458966622670848/
- **Primeiro comentário não saiu**: a API devolveu `comment_failed`, HTTP 403 em `partnerApiSocialActions`. Segunda ocorrência seguida, a mesma do post do Manus em 12/08. O comentário com o link do anúncio (https://x.ai/news/introducing-grok-bot) precisa ser feito na mão.

## Contexto que evita confusão

O post de lançamento do Grok Bot foi publicado no mesmo dia 11/08, com vídeo, e é outro texto: saiu de `CLAUDE COWORK/OUTPUTS/Grok-Bot-Launch/post-linkedin-grok-bot.md` e está no ar em https://www.linkedin.com/feed/update/urn:li:activity:7493013409257484288/ (log em `ai/sessions/2026-08-11-post-grok-bot.md`).

Este draft aqui é o segundo post, de uso real. O PMM vetou publicar a versão longa de lançamento como post separado, porque canibalizaria o de uso real e o beta já estava no post que foi ao ar.

## Copy (v2 ajustada, 2.224 chars no corpo)

Link só no primeiro comentário.

Ajustes de 15/08, para o texto parar de se ancorar no dia do lançamento: "Hoje estou documentando" virou "Essa semana eu documentei", e "o que valia escrever hoje" virou "naquele dia". Corrigido junto um erro de pessoa que atravessou as cinco versões: "Monte um Chief of Staff" no meio de uma narração em primeira pessoa, que virou "Montei". A regra do imperativo em "você" do [[dna-da-voz]] vale para instrução ao leitor, não para o Hugo contando o que ele fez.

<!-- ai:start -->

Toda vez que sai um modelo novo, o LinkedIn vira corrida pra parecer o primeiro que leu o blog.

Eu já caí nisso: cola o anúncio no chat, pede um post, sai texto que parece slide de consultoria. Rápido. Esquecível.

Essa semana eu documentei o teste de outro jeito.

Montei um Chief of Staff e quatro especialistas (PMM, Content, Strategy, Growth) em cima do HUGO OS. Pedido seco: pesquisar o que tá funcionando em IA/tech no LinkedIn agora e entregar um teardown no dia do drop. Stack da sessão: Grok Bot, computador próprio pra cada agente, memória de voz no vault.

O que rolou na prática: pesquisa ao vivo e ângulos que importam pra 2026 (save, tempo de leitura, prova específica). Curtida vazia não conta. Eu escolhi o formato teardown no mesmo dia. O rascunho cravou o Muse Glimmer da Meta (30B, Apache 2.0, agente local em ~24GB de VRAM): stack, custo, o que funciona e o que quebra. Em poucos minutos. Sem paráfrase de blog.

No meio do polish o PMM mandou brief novo (abre na dor, herói = sistema, corta isca). Content reescreveu com regra dura de voz. Eu só dizia "esse ângulo" ou "corta isso". Sem babá o loop de pesquisa. Sem colar contexto entre quatro threads abertas. O trabalho não morreu quando eu mudei de aba.

Foi aí que o ganho ficou óbvio pra mim.

A maior parte das ferramentas de "IA pra conteúdo" acelera a escrita. Aqui o ciclo curto da notícia virou decisão: o que valia escrever naquele dia, com que prova, e com que tom. O draft final ficou no vault, pronto pra colar.

O que ainda era meu apareceu em cena, não em checklist. O primeiro texto veio afiado e ainda assim não era eu, até o DNA da voz entrar. Quando faltou número real de antes/depois, o agente recusou inventar (certo). E na hora de publicar, quem posta e responde nos primeiros minutos continuo sendo eu.

Custo do experimento: uma noite e um sistema de conteúdo mais claro.

Computador próprio muda o ritmo. Decisão humana ainda define o gosto.

Se você ainda cola blog de lançamento no ChatGPT, testa outra coisa. Dá um brief, um vault de contexto e uma decisão humana. Mede se o draft tem opinião de quem opera, ou só vibes.

Qual fluxo você entregaria pra um time de agentes essa semana?

<!-- ai:end -->

Primeiro comentário: contexto do que rodou na sessão, https://x.ai/news/introducing-grok-bot

## Decisões de escrita

1. Expandiu o draft de uso real, não o de lançamento. O de lançamento longo foi arquivado.
2. Insight novo da sessão: Chief of Staff mais quatro especialistas com computador próprio, sem recap do blog e sem bloco de beta.
3. Anatomia da skill linkedin-copy: hook na dor, história da sessão, virada, conexão, reframe, pergunta.
4. Voz, prova e distribuição viraram cena (o DNA entrando no polish, a recusa de inventar métrica, postar na primeira hora), em vez do checklist numerado que a v1 usava.
5. Reframe de síntese: "Computador próprio muda o ritmo. Decisão humana ainda define o gosto."

## Versões anteriores (no histórico do git, commit 50f7e89)

- `2026-08-11-draft-linkedin-grok-bot`: primeiro rascunho de uso real, com CTA "comenta Muse" e paralelismos negativos ("Não foi X, foi Y").
- `2026-08-11-draft-linkedin-grok-bot-final`: copy edit mais brief do PMM. Abertura trocada para dor antes da marca, herói vira o sistema, CTA de comentário removido.
- `2026-08-11-draft-linkedin-grok-bot-launch`: rascunho de post de lançamento.
- `2026-08-11-draft-linkedin-grok-bot-launch-final`: versão longa do lançamento, 2.112 chars, marcada ARQUIVADO pelo PMM.

## Para que pode servir

Prova de operação com time de agentes, que é pauta recorrente do [[conteudo]]. Mesmo sem publicar como está, o ângulo "o trabalho não morre quando você troca de aba" e o reframe final servem para qualquer post sobre agentes com computador próprio.
