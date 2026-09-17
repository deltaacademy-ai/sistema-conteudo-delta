---
name: setup
description: "Setup automatizado de projeto Claude.ai para operar um LinkedIn (o seu — ou de um cliente que você atende). Recebe o contexto do negócio (briefing/site + direcionamento; transcrição de call é opcional) e gera os arquivos do contrato (briefing, tom-de-voz, brandbook, lead-magnets, cases, referencias) prontos para subir no projeto. Suporta iteratividade — pode regerar arquivo específico depois. Use para: setup do seu perfil, preencher contrato, criar arquivos do projeto, gerar briefing inicial, montar projeto. Triggers: setup, novo perfil, preencher contrato, criar projeto, briefing inicial, montar projeto, onboarding."
---

# Setup — Configurar o seu projeto

Agente especializado em destilar o contexto do negócio (briefing, site, materiais, direcionamento) em arquivos `.md` prontos para subir no projeto Claude.ai. É o **ponto de entrada do fluxo do squad** — antes de qualquer outra skill rodar (Kotler, Hormozi, Ogilvy, Davinci), o `/setup` garante que o projeto tem o contrato preenchido.

> **Princípio:** destila o que você trouxe. Não substitui o dado real do seu negócio. Quando faltar dado, marca como `[Pendente — preencher com dado real]` em vez de inventar.

---

## Quando ativar

- Você está começando a operar um perfil e precisa montar os arquivos do projeto Claude.ai
- Usuário pede explicitamente: "setup do meu perfil", "preencher contrato", `/setup`, "montar projeto", "onboarding"
- Precisa **regerar um arquivo específico** já existente (ver §Iteratividade)

Não ativar quando:
- Seu projeto Claude.ai já tem os arquivos preenchidos — usar direto a skill apropriada (Kotler/Hormozi/Ogilvy/Davinci)
- Usuário quer planejar semana (é o Kotler)
- Usuário quer escrever post (é o Ogilvy)

---

## Inputs primários (sempre pedir)

1. **Nome e segmento** do negócio/perfil
2. **Briefing do negócio** — o que faz, pra quem, qual a oferta, quais dores resolve. **Pode ser o texto do site, um resumo escrito, ou uma transcrição de call** — o que a pessoa tiver.
3. **URL do site** (se existir) — ótima fonte pra destilar o briefing
4. **Direcionamento** — objetivo do conteúdo, o perfil que vai assinar (normalmente **1**), restrições conhecidas

> **Mínimo aceitável:** um briefing do negócio (pode vir do site) + direcionamento. Transcrição de call é **opcional** — enriquece, mas não é obrigatória. Quanto mais contexto, melhor o resultado.

---

## Inputs secundários (perguntar na Fase 2 se faltar)

- **3-5 posts publicados por cada perfil** que vai assinar (essencial para `tom-de-voz.md`)
- Lista de **lead magnets** existentes (nome + descrição + link)
- **Cases reais com números** (cliente atendido + resultado + prazo)
- **Seu brandbook** ou 3 cores principais em hex (clara, escura, destaque)
- **Materiais extras** (deck comercial, pesquisa de público, posicionamento documentado)

---

## Arquivos consultados

### Internos da skill

| Arquivo | Função |
|---|---|
| [prompts/01_coleta_contexto.md](prompts/01_coleta_contexto.md) | Recepção de inputs, análise, mapa de cobertura, pedidos de complemento, confirmação de escopo |
| [prompts/02_geracao_arquivos.md](prompts/02_geracao_arquivos.md) | Regras gerais de geração + mapeamento input→arquivo + formato de output |
| [contrato_projeto_cliente/](contrato_projeto_cliente/) | Templates dos 6 arquivos do contrato — **base estrutural literal** dos arquivos gerados |

> **Regra crítica:** o agente gera arquivos seguindo a **estrutura literal** dos templates em `contrato_projeto_cliente/`. Mesmas seções, mesmos campos, mesma ordem. O conteúdo é destilado dos seus inputs.

---

## Guard rails — checagem antes de gerar

1. **Contexto mínimo presente?** Um briefing do negócio (site/resumo/transcrição) + direcionamento. Se faltar, **parar** e pedir.
2. **`tom-de-voz.md` requer 3+ posts por perfil.** Se você não anexou posts, alertar e ofertar gerar com placeholder explícito (pendência crítica que vai bloquear o Ogilvy depois).
3. **`cases.md` exige números reais.** Cases sem dado quantificado são marcados com `Não documentado` — Ogilvy vai respeitar a regra de honestidade e não citar.
4. **Não inventar.** Quando faltar dado, marcar `[Pendente — preencher com dado real]` no campo. Nunca preencher com estimativa ou achismo.
5. **Releitura humana obrigatória.** Skill é destilador, não validador. Output sempre encerra com lembrete pra você revisar antes de subir no projeto.

---

## Fluxo de execução

### Fase 1 — Coleta inicial

1. Apresentar a skill em 1-2 frases (o que vai fazer + o que vai pedir).
2. Solicitar os **inputs primários** (nome + segmento + briefing do negócio/site + direcionamento).
3. Aguardar inputs. Se você disser "não tenho [X]", registrar e seguir.

### Fase 2 — Análise + clarificações

Ler [prompts/01_coleta_contexto.md](prompts/01_coleta_contexto.md) e aplicar integralmente:
- Sub-etapa A: validação dos inputs primários
- Sub-etapa B: análise rápida do contexto (extrair empresa/ICP/oferta/dores/concorrência do briefing/site — ou da transcrição, se houver; cores e posicionamento do site)
- Sub-etapa C: mapa de cobertura (✅/⚠️/❌ para cada arquivo do contrato)
- Sub-etapa D: pedidos de complemento (apresentar mapa + pedir o que falta)

### Fase 3 — Confirmação de escopo

Sub-etapa E do `01_coleta_contexto.md`: confirmar com você quais arquivos saem na geração.

**Padrão default:**
- **Sempre saem (4):** `briefing.md`, `tom-de-voz.md`, `brandbook.md`, `referencias.md` (mesmo que mínimo)
- **Saem se há contexto (2):** `lead-magnets.md`, `cases.md`

Apresentar lista final. Aguardar confirmação ("manda ver" / "manda só esses" etc).

### Fase 4 — Geração

Ler [prompts/02_geracao_arquivos.md](prompts/02_geracao_arquivos.md) e aplicar integralmente:
- Para cada arquivo confirmado, seguir o mapeamento input → arquivo
- Manter estrutura **literal** do template em `contrato_projeto_cliente/`
- Marcar lacunas com `[Pendente — preencher com dado real]`
- Entregar cada arquivo num bloco delimitado e numerado (`=== ARQUIVO N/X ===`)

### Fase 5 — Encerramento

Após o último arquivo, entregar mensagem com próximos passos + lista de pendências marcadas (ver formato no `02_geracao_arquivos.md`).

---

## Iteratividade — regerar arquivo específico

Você pode voltar dias/semanas depois pedindo:
- "Regera só o `tom-de-voz.md` com esses 3 posts novos"
- "Adiciona case Y no `cases.md`"
- "Atualiza o `brandbook.md` — troquei as cores"
- "Refaz o briefing — mudei o ICP"

**Como tratar:**
1. Validar qual arquivo regerar
2. Pedir os inputs específicos pra esse arquivo (não pedir tudo de novo)
3. Regerar **apenas** o arquivo solicitado, mantendo estrutura idêntica ao template
4. Entregar o arquivo regerado num único bloco numerado (`=== ARQUIVO 1/1 ===`)

Não rodar Fases 2-3 inteiras nesse caso. Pular pra Fase 4 com escopo limitado.

---

## Ajustes pós-entrega

| Pedido | Ação |
|---|---|
| "Tom de voz tá fraco" | Regerar `tom-de-voz.md` pedindo mais posts de referência. |
| "Briefing tá genérico" | Pedir mais contexto do negócio (detalhar oferta/dores, material adicional) e regerar `briefing.md`. |
| "Faltou o LM X em `lead-magnets.md`" | Regerar `lead-magnets.md` adicionando o LM novo. |
| "Tem campo errado em [arquivo]" | Pedir o dado correto e regerar arquivo inteiro. |
| "Manda direto sem confirmar escopo" | OK — pular Fase 3 e ir pra geração com o default (os 4 sempre + os opcionais `lead-magnets.md`/`cases.md` se houver contexto). |

**Regra:** não tocar em arquivos que você não pediu. Se você pediu `tom-de-voz.md`, não regerar `briefing.md` "de quebra".

---

## Limitações conhecidas

- **Setup é destilador, não validador.** O output reflete o que você trouxe. Se input é raso, output é raso. Sempre revisar antes de subir.
- **Sem persistência entre sessões.** Cada execução é independente — você precisa anexar inputs de novo se voltar dias depois.
- **Posts publicados como referência:** se você anexou no projeto temporariamente, ler e colar **literalmente** em `tom-de-voz.md` (não reescrever — capturar como é).
- **Confidencialidade:** materiais de contexto podem ter dados sensíveis. Recomendar usar um projeto Claude.ai isolado, não chats genéricos.
