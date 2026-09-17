# Setup — Coleta de Contexto e Mapa de Cobertura

Este arquivo contém a lógica das **Fases 2 e 3** do `/setup`: como destilar os inputs brutos que você trouxe, identificar lacunas, pedir complementos e confirmar escopo antes de gerar os arquivos.

Não gera arquivos finais — isso é o `02_geracao_arquivos.md`. Aqui só prepara o terreno.

---

## Sub-etapa A — Validação dos inputs primários

Confirmar que recebeu:

1. Nome e segmento do negócio/perfil
2. **Briefing do negócio** — texto do site, resumo escrito ou transcrição de call (o que a pessoa tiver)
3. URL do site (ou explícito "não tem site")
4. Direcionamento (objetivo do conteúdo, perfil que assina — normalmente 1, restrições)

**Mínimo aceitável:**
- Um **briefing do negócio** (pode vir do site) **+** direcionamento

Se faltar o mínimo, **parar e pedir**. Não inventar. Transcrição de call é opcional — se a pessoa tiver, ótimo; se não, seguir com briefing/site.

Se o contexto veio raso (só o site, sem detalhe de oferta/dores), **alertar suavemente**:
> "Trabalhei com o que você passou. Se puder detalhar sua oferta principal e as dores que ela resolve, o resultado fica bem mais afiado. Quer complementar ou seguir assim?"

---

## Sub-etapa B — Análise rápida do contexto

Antes de identificar lacunas, **destilar mentalmente** o que está nos inputs. Não gerar nada ainda — só estruturar o conhecimento.

### Sobre a empresa (do briefing/site — ou da transcrição, se houver)
- Quem são os tomadores de decisão da empresa?
- Qual o segmento e modelo de negócio?
- Qual a tese central / proposta de valor?
- Qual histórico (quanto tempo opera, marcos importantes)?
- Quais clientes atendidos foram mencionados?

### Sobre a oferta e o conteúdo (do briefing/direcionamento)
- Qual a oferta principal pra divulgar?
- Quais perfis vão assinar o conteúdo?
- Quais lead magnets já existem ou vão ser criados?
- Quais dores e objeções foram citadas?
- Qual o objetivo concreto do trabalho (X leads/mês, lançamento Y, autoridade no segmento Z)?

### Do site (se disponível)
- Posicionamento textual da home
- 3 cores principais visuais (extrair em hex)
- Tipografia (se claramente diferenciada)
- Ofertas listadas
- Cases ou depoimentos visíveis
- Posts/blog (se houver)

### Do direcionamento macro
- Restrições explícitas (não falar de X, só falar de Y)
- Tom desejado (provocativo / consultivo / técnico / outro)
- Frequência prevista de publicação
- Perfis ativos e quem assina o quê

---

## Sub-etapa C — Mapa de cobertura

Para cada arquivo do contrato, marcar uma das três categorias:

- ✅ **Tenho dado suficiente** — consigo gerar com confiança
- ⚠️ **Tenho parcial** — gera mas com alguns campos como `[Pendente]`
- ❌ **Não tenho** — gera com várias `[Pendente]` (vale pedir input adicional antes)

Apresentar como tabela:

```
| Arquivo                | Cobertura | O que tenho                                         | O que falta              |
|------------------------|-----------|-----------------------------------------------------|--------------------------|
| briefing.md            | ✅        | Empresa, segmento, ICP, oferta, jornada             | —                        |
| tom-de-voz.md          | ⚠️        | 1 perfil definido (João — fundador)                 | 3 posts de referência    |
| brandbook.md           | ⚠️        | Cores extraídas do site                             | Confirmação dos hex      |
| lead-magnets.md        | ❌        | Não tenho info sobre LMs ativos                     | Lista de LMs com link    |
| cases.md               | ⚠️        | 2 cases mencionados sem números                     | Números e prazos         |
| referencias.md         | ⚠️        | Sei que tem perfil LinkedIn ativo                   | Posts aprovados/links    |
```

---

## Sub-etapa D — Pedidos de complemento

Para cada `⚠️` ou `❌` da tabela, fazer **pedidos específicos**. Não pedidos genéricos como "tem mais material?".

### Templates de pedido

**`tom-de-voz.md` (⚠️ ou ❌):**
> "Não vi posts publicados de [Nome do perfil]. Pra `tom-de-voz.md` ficar útil, preciso de pelo menos 3 posts reais por perfil. Pode anexar 3-5 ao projeto Claude.ai temporariamente, ou colar aqui no chat?"

**`cases.md` (⚠️):**
> "Identifiquei [N] cases mencionados no que você passou, mas sem números. Pra cada um, preciso: cliente atendido + resultado quantificado (Ex: '+R$X em pipe' / 'Y leads em Z dias') + permissão de uso (público / anonimizado / proibido). Pode passar?"

**`lead-magnets.md` (❌):**
> "Não vi referência a lead magnets ativos. Você tem materiais (ebook, planilha, diagnóstico, demo, calculadora)? Se sim, passa: nome + tipo (isca/intenção) + link + 3-5 frases descrevendo o conteúdo."

**`brandbook.md` (⚠️):**
> "Extraí essas cores do site — confirma os hex: clara `#XXXXXX`, escura `#XXXXXX`, destaque `#XXXXXX`? Se você tem brandbook formal, melhor anexar."

**`referencias.md` (⚠️):**
> "Tem links de 3-5 posts seus já publicados que funcionaram bem? Eu cataloguo no `referencias.md` com 'por que funcionou' pra ajudar Ogilvy/Hormozi/Davinci depois."

Iterar até você dizer "manda ver" ou os ❌ críticos virarem ✅/⚠️.

### Critérios de "crítico" (bloqueante)

- `briefing.md` ❌ → **bloqueante**. Não dá pra seguir sem briefing — todas as skills dependem dele.
- `tom-de-voz.md` com 0 posts de referência → **bloqueante** (Ogilvy vai parar e pedir antes de redigir qualquer post).
- Demais arquivos opcionais ❌ → **não-bloqueante**. Pode seguir com aviso explícito.

---

## Sub-etapa E — Confirmação de escopo

Apresentar lista final dos arquivos que vão ser gerados. Formato:

```
Vou gerar:
1. briefing.md
2. tom-de-voz.md (com X perfis)
3. brandbook.md
4. lead-magnets.md (com Y LMs)
5. cases.md (com Z cases)
6. referencias.md

Confirma? Se quiser mudar algo, é só falar.
```

Aguardar confirmação. Se mudar escopo (incluir/excluir arquivo), confirmar de novo antes de avançar.

Após confirmação: passar a **Fase 4 (Geração)** usando `02_geracao_arquivos.md`.
