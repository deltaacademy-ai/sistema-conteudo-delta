# Setup — Geração dos Arquivos do Contrato

Este arquivo contém a lógica da **Fase 4** do `/setup`: como gerar cada arquivo do contrato a partir dos inputs destilados, mantendo a estrutura literal dos templates.

Não destila contexto nem confirma escopo — isso é o `01_coleta_contexto.md`. Aqui já parte do escopo confirmado e vai pra geração.

---

## 1. Regras gerais de geração

### Princípios

- **Estrutura literal:** seguir EXATAMENTE a mesma ordem de seções, nomes de campo e formatação dos templates em `contrato_projeto_cliente/`. Não reordenar, não renomear, não fundir seções.
- **Manter as seções "Do/Don't":** essas seções são instruções pro seu uso futuro, não conteúdo a preencher. Manter intactas no output.
- **Nunca inventar:** quando faltar dado, marcar `[Pendente — preencher com dado real]` no campo específico. Nunca preencher com estimativa.
- **Datas:** usar `2026` em todos os arquivos.
- **"Última atualização":** preencher com a data corrente em formato `AAAA-MM-DD`.
- **Linguagem do negócio:** usar termos exatos que apareceram no briefing/site e no direcionamento — não traduzir nem reescrever.

### Formato de saída

Cada arquivo gerado vem dentro de **um bloco delimitado e numerado**, no formato:

````
=== ARQUIVO N/X: nome-do-arquivo.md ===

```
[conteúdo literal do arquivo, dentro de fenced code block sem linguagem]
```

=== ARQUIVO (N+1)/X: ...
````

Onde:
- `N` é o número sequencial (1, 2, 3...)
- `X` é o total de arquivos confirmados na Sub-etapa E
- O conteúdo do arquivo vai dentro de fenced code block **sem linguagem** (apenas ` ``` `)
- Linha em branco entre blocos pra escaneabilidade

---

## 2. Mapeamento input → arquivo

### 2.1 — `briefing.md` (sempre gerado)

**Inputs principais:** o briefing do negócio (site, resumo ou transcrição — o que houver) + o direcionamento.

**Como preencher cada seção:**

| Seção do template | Fonte |
|---|---|
| §1 Sobre a empresa | Briefing/site (nome, segmento, modelo, histórico, posicionamento) |
| §2 Oferta principal | Briefing (oferta, preço, modelo de venda) |
| §3 ICP (1-3 perfis) | Briefing (cliente ideal mencionado) |
| §4 Buyer personas | Briefing (quem decide a compra) |
| §5 Dores principais | Briefing (dores citadas) |
| §6 Objeções comuns | Briefing (o que faz o lead não comprar) |
| §7 Concorrência | Briefing/site (comparações citadas) |
| §8 Diferenciais competitivos | Briefing (o que só esse negócio entrega) |
| §9 Jornada do cliente | Direcionamento + briefing |
| §10 Objetivo do conteúdo | Direcionamento |

**Ano de operação do conteúdo:** `2026`.

### 2.2 — `tom-de-voz.md` (sempre gerado)

**Inputs principais:** posts publicados pelos perfis (3-5 por perfil) + direcionamento macro (quem assina).

**Como preencher:**

- **Perfis ativos:** listar conforme direcionamento. Cada perfil ganha um bloco completo do template.
- **Vocabulário, estrutura típica, formatação:** destilar dos posts que você colou (frases curtas/longas, uso de listas, emojis sim/não, etc.).
- **3 posts de referência por perfil:** colar **literalmente** os posts que você anexou. **Não reescrever, não resumir, não corrigir gramática, não trocar emojis.** Capturar como é.
- **Regras gerais (formatação, pontuação, CTAs):** destilar do que é comum entre os posts.

**Se faltar posts (< 3 por perfil):**
- Manter a estrutura do template
- Marcar bloco "3 posts de referência" como `[Pendente — colar 3 posts reais publicados pelo perfil]`
- Avisar no encerramento: "Tom de voz com X perfil(s) sem posts de referência — Ogilvy vai parar e pedir antes de redigir."

### 2.3 — `brandbook.md` (sempre gerado)

**Inputs principais:** site (cores principais) ou brandbook anexado.

**Como preencher:**

- **3 cores hex:** extrair do site (clara, escura, destaque). Sempre formato completo `#XXXXXX`.
- **Tipografia:** preencher só se você tem fonte de marca declarada. Senão, deixar vazio (template aceita).
- **Logo:** apontar arquivo se anexado ao projeto, senão deixar vazio.
- **Don'ts visuais:** preencher só se direcionamento macro mencionar (ex: "evitar amarelo neon"). Senão, manter exemplos genéricos do template.

**Se não tem site nem brandbook:**
- Marcar 3 cores como `[Pendente — definir cor clara, escura e destaque em hex]`
- Não chutar cores

### 2.4 — `lead-magnets.md` (sai se há contexto)

**Inputs principais:** lista de LMs que você trouxe (ou identificada no briefing/site).

**Como preencher cada LM:** nome, tipo (isca ou intenção), formato, link, conteúdo resumido em 3-5 frases, critério de qualificação, métricas se houver, status.

**Decisão de tipo (isca vs intenção):**
- **Isca [Topo]:** material gratuito que captura leads frios — ebook, planilha, diagnóstico, agente IA, aula gratuita.
- **Intenção [Fundo]:** demo, trial, comparação de ferramentas, calculadora de ROI.

Se houver dúvida, perguntar antes de chutar.

**Status:** se há LM em construção, marcar como `Em construção` (Kotler vai evitar alocar no calendário).

### 2.5 — `cases.md` (sai se há contexto)

**Inputs principais:** cases mencionados no briefing/direcionamento + complementos que você trouxe.

**Como preencher cada case:** cliente atendido, contexto inicial, solução aplicada, resultado quantificado, citação se houver, permissão de uso, tags.

**Regra de honestidade (compartilhada com Ogilvy):**
- Se um campo (número, prazo, citação) não está nos inputs, marcar **literalmente** como `Não documentado` no arquivo.
- Ogilvy vai respeitar e não citar o campo no post.
- **Não inventar números.** Se você disse "o cliente Y teve um aumento expressivo", marcar resultado como `Não documentado` — não chutar percentual.

### 2.6 — `referencias.md` (sempre gerado, mesmo que mínimo)

**Inputs principais:** links/menções de posts publicados + anexos visuais no projeto + inspirações citadas.

**Como preencher:**

- **Posts aprovados:** listar com link, perfil, data, tipo, métrica e "por que funcionou" (extrair do que você trouxe).
- **Anexos visuais soltos:** catalogar todos os arquivos não-`.md` que você mencionou estar no projeto (ex: `post-aprovado-01.png`, `caso-cliente-X.pdf`).
- **Inspirações externas:** preencher só se direcionamento macro mencionar.

**Se não tem nada:**
- Manter estrutura do template
- Marcar seções como `[Pendente — adicionar quando houver]`
- Skill ainda gera o arquivo (estrutura é importante pra outras skills consultarem mesmo vazio)

---

## 3. Checklist final antes de entregar

- [ ] Todos os arquivos confirmados na Sub-etapa E foram gerados?
- [ ] Cada arquivo segue **estrutura literal** do template em `contrato_projeto_cliente/`?
- [ ] Lacunas marcadas como `[Pendente — preencher com dado real]` em vez de invenções?
- [ ] Cases sem números marcados como `Não documentado` (não estimados)?
- [ ] Posts em `tom-de-voz.md` colados **literalmente** (sem reescrever)?
- [ ] Cada arquivo entregue em bloco numerado (`=== ARQUIVO N/X: nome-do-arquivo.md ===`)?
- [ ] Datas em todos os arquivos = 2026?
- [ ] Mensagem final de encerramento incluída com lista de pendências?

Se qualquer item falhar, corrigir antes de entregar.

---

## 4. Mensagem final de encerramento

Após o último arquivo, entregar:

```
Setup finalizado. Próximos passos:

1. Salvar cada arquivo localmente (copiar do code block, salvar com o nome indicado)
2. Criar o seu projeto no Claude.ai
3. Anexar os arquivos no projeto (Claude.ai não suporta subpastas — sobem todos no mesmo nível)
4. Releia cada arquivo antes de seguir — eu sou destilador, não validador
5. Dispare /kotler para planejar a primeira semana de conteúdo

Lembrete: para Ogilvy (redação de posts) recomendo Sonnet 4.6, não Opus.

Pendências marcadas (preencher manualmente antes de operar):
[lista organizada por arquivo:
  - briefing.md: campos [Pendente] encontrados
  - tom-de-voz.md: perfis sem posts de referência
  - cases.md: campos "Não documentado" (Ogilvy vai respeitar)
  - etc.]
```

A lista de pendências ajuda você a saber o que precisa preencher manualmente antes de começar a operação editorial.
