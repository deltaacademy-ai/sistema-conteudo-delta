# Design System de Carrosséis LinkedIn — interno da skill Da Vinci
**Guia de Design — v2.2**

> Este é o **brandbook de carrossel** que vive dentro da skill Da Vinci. Ele define o método de design (templates, tipografia, hierarquia, grid, atmosfera visual) que é **universal** entre marcas. O que muda por marca são apenas **3 cores** e a **identidade** (nome, logo, domínio), lidas do `brandbook.md` do projeto Claude.ai. Ver a seção "Sistema de cores da marca" abaixo.

> **Princípio de coerência de marca:** o visual dos carrosséis deve ser **indistinguível** das referências visuais da marca (site, LPs, materiais). Tipografia, hierarquia, pills, glow, dot pattern, pesos e letter-spacing devem manter a mesma linguagem. Se um elemento não existe na identidade visual da marca, ele não pertence ao carrossel.

---

## Sistema de cores da marca (LER PRIMEIRO)

> **Esta é a única parte do design system que muda por marca — e a troca é à prova de erro.** Todo template HTML (aqui e no `02_geracao_slides.md`) começa com um bloco de tokens `:root`. Para trocar de marca, preencher **3 valores** (`--destaque`, `--escura`, `--clara`) a partir do `brandbook.md`. Todo o resto — tints, pills translúcidas, gradient, barra de progresso — **deriva sozinho** via `color-mix()`. Não há hex de marca espalhado pelos slides: cada uso já é `var(--...)`.

### O bloco `:root` (referência — presente em cada template)

Preencher só as 3 primeiras variáveis. Os valores de exemplo são o default (paleta de referência) — trocar pelos hexes do `brandbook.md`:

```css
:root{
  /* === 3 CORES DO CLIENTE — preencher do brandbook.md === */
  --destaque:#1447E6;   /* cor de destaque do cliente */
  --escura:#121117;     /* cor escura do cliente (fundo dark + texto escuro) */
  --clara:#FAFAFA;      /* cor clara do cliente (fundo dos slides) */

  /* === superfície branca (alternância de fundo em slides de conteúdo) === */
  --surface:#FFFFFF;

  /* === tints derivados do destaque (automáticos — não mexer) === */
  --destaque-tint:  color-mix(in srgb, var(--destaque) 75%, #fff);   /* ~ #4D7BF3 */
  --destaque-pale:  color-mix(in srgb, var(--destaque) 45%, #fff);   /* ~ #93B4FF */
  --destaque-wash:  color-mix(in srgb, var(--destaque) 8%,  #fff);   /* ~ #EFF4FF */
  --destaque-shade: color-mix(in srgb, var(--destaque) 85%, #000);   /* ~ #1039C4 */
  --destaque-08: color-mix(in srgb, var(--destaque) 8%,  transparent);
  --destaque-15: color-mix(in srgb, var(--destaque) 15%, transparent);
  --destaque-20: color-mix(in srgb, var(--destaque) 20%, transparent);
  --destaque-25: color-mix(in srgb, var(--destaque) 25%, transparent);
}
```

> **`color-mix()` no render:** o Chromium headless do `render.py` suporta `color-mix()` nativamente, então os tints resolvem no momento do render — não é preciso pré-calcular nenhum hex. Basta preencher as 3 cores.

### Mapeamento — papel → variável

| Papel nos templates | Variável | Cor da marca (`brandbook.md`) |
|---|---|---|
| CTAs, palavras-chave, barra de progresso, glow sólido, pills, container do ícone/logo | `var(--destaque)` | **destaque** |
| accent sólido em fundo dark (onde `D` puro perde contraste), fim do gradient accent | `var(--destaque-tint)` | destaque + 75% (tint claro) |
| texto de eyebrow/pill sobre fundo dark | `var(--destaque-pale)` | destaque + 45% (pálido) |
| fundo de item em destaque em lista, mark de texto, callout | `var(--destaque-wash)` | destaque + 8% (wash) |
| hover/estado pressionado de botão | `var(--destaque-shade)` | destaque escurecido (shade) |
| pills translúcidas / glow / bordas de pill | `var(--destaque-08)` / `-15` / `-20` / `-25` | destaque + alpha |
| gradient accent (clip-text) | `linear-gradient(135deg, var(--destaque-tint), var(--destaque))` | destaque + tint |
| fundo da capa dark; headings e texto principal sobre fundo claro | `var(--escura)` | **escura** |
| fundos claros / capa light / card alt | `var(--clara)` | **clara** |
| superfície branca (alternância par nos slides de conteúdo) | `var(--surface)` | branco fixo |

**Regra prática:** os tints derivam por `color-mix()` (clarear com `#fff`, escurecer com `#000`, translúcido com `transparent`). Não invente cores fora dessa família.

### Cores UNIVERSAIS — NÃO parametrizar (ficam literais na skill)

Estas não vêm do cliente. Ficam fixas na skill:

| Categoria | Hexes | Uso |
|---|---|---|
| Neutros | `#6B7280`, `#9CA3AF`, `#4B5563`, `#E2E8F0`, `#C8D3E6`, `#1F2937` | subtítulos, metadados, atribuições, bordas de card, fundo da barra de progresso, dot pattern light |
| Semânticos | `#16A34A` (verde), `#EF4343` (vermelho), `#EAB30A` (amarelo), `#DCFCE7` (verde claro) | badges de variação em cards de métrica — **nunca decoram**, só comunicam estado de dado |

> **Marca do cliente:** o wordmark `[NOME_DA_MARCA]`, o `[DOMINIO_DO_CLIENTE]` e o logo/ícone vêm do `brandbook.md`. Onde os templates mostram um wordmark ou domínio de exemplo, substituir pelos do cliente. Se o cliente não tem ícone, usar só o wordmark (sem o container quadrado do ícone).

---

## Índice

1. [Visão Geral do Formato](#1-visão-geral-do-formato)
2. [Anatomia de um Carrossel](#2-anatomia-de-um-carrossel)
3. [Adaptação de Conteúdo Fornecido](#3-adaptação-de-conteúdo-fornecido)
4. [Templates de Slide](#4-templates-de-slide)
5. [Sistema Tipográfico](#5-sistema-tipográfico)
6. [Paleta de Cores](#6-paleta-de-cores)
7. [Grid, Logo e Zonas de Segurança](#7-grid-logo-e-zonas-de-segurança)
8. [Boas Práticas de Copy](#8-boas-práticas-de-copy)
9. [O que Fazer e Não Fazer](#9-o-que-fazer-e-não-fazer)
10. [Checklist de Publicação](#10-checklist-de-publicação)
11. [Referência Rápida](#11-referência-rápida)
12. [Render — Sandbox do Claude.ai](#12-render--sandbox-do-claudeai)

---

## 1. Visão Geral do Formato

**O que é um carrossel no LinkedIn:** post nativo de múltiplas imagens (uma por slide). Cada arraste prolonga o tempo de permanência — o principal sinal que o algoritmo usa para distribuir o post organicamente.

| Especificação | Valor | Observação |
|---|---|---|
| Dimensões do canvas | 1080 × 1350 px (retrato 4:5) | Máximo aproveitamento de tela no feed mobile |
| Formato de saída | Um PNG por slide | LinkedIn aceita post de múltiplas imagens; publicar os PNGs na ordem |
| Resolução | render em `device_scale_factor=2` → PNG 2160×2700px | Qualidade 2× para nitidez no feed |
| Número ideal de slides | 5 a 8 slides | Mínimo 3. Máximo: 10. Acima disso, o abandono sobe |

> **Por que carrosséis funcionam:** carrosséis de alta qualidade costumam gerar 2–3× mais alcance orgânico do que posts de imagem estática, com custo zero de tráfego pago, porque o algoritmo premia o tempo de permanência que o swipe gera.

---

## 2. Anatomia de um Carrossel

Todo carrossel bem construído segue uma estrutura narrativa com 4 funções de slide:

```
[Slide 1: Capa/Hook] → [Slides 2–5: Conteúdo Principal] → [Slide N-1: Prova/Validação] → [Último: CTA]
```

| Função | Slide(s) | Objetivo | Fundo recomendado |
|---|---|---|---|
| **Capa / Hook** | Slide 1 — sempre | Parar o scroll. Prometer valor. Gerar clique | Dark (**escura**) **ou** Light (**clara**) |
| **Conteúdo Principal** | Slides 2–5 | Entrega da promessa. Uma ideia por slide | **clara** (alternar superfície/fundo) |
| **Prova / Validação** | Slide penúltimo | Dado, case, citação ou métrica que credencia | **clara** ou **escura** |
| **CTA Final** | Último slide — sempre | Direcionar para uma ação clara. Nunca omitir | **destaque** (cor de destaque sólida) |

> **Regra de ouro — Slide 1:** a capa deve funcionar como um anúncio autônomo. Quem não arrastar os slides ainda precisa entender a proposta de valor e sentir curiosidade suficiente para ler a legenda do post.

---

## 3. Adaptação de Conteúdo Fornecido

> **Esta seção é especialmente relevante para agentes de IA e designers que recebem um texto original para transformar em carrossel.**

Na grande maioria dos casos, o conteúdo do carrossel é fornecido pelo autor — seja um post de LinkedIn, um briefing ou um texto corrido. O papel do designer/agente é **adaptar visualmente**, não reescrever.

### 3.1 — Princípios de fidelidade ao conteúdo

| Princípio | Regra |
|---|---|
| **Hook intocável** | O texto do hook (slide 1) deve ser mantido o mais próximo possível do original. Só adapte para quebras de linha e destaques visuais — nunca parafraseie. |
| **Palavras do autor** | Nos slides de conteúdo, prefira usar as palavras exatas do autor. Condensar é permitido; reinterpretar, não. |
| **Narrativa fiel** | A sequência de slides deve refletir a narrativa do texto original — não reorganize a história sem motivo. |
| **Sem adições** | Não acrescente informações, exemplos ou dados que não estejam no conteúdo fornecido. |
| **CTA original** | A chamada para ação do último slide deve vir diretamente do texto, não ser inventada. |

### 3.2 — Mapeamento de conteúdo → tipo de slide

Ao receber um texto, identifique os padrões e mapeie para os templates:

| Padrão no texto | Template de slide indicado |
|---|---|
| Lista de itens com `→` ou numeração | Tipo 2 — Conteúdo com Lista |
| Fala literal de cliente ou parceiro com nome e cargo | Tipo 3 — Citação de Pessoa Identificada |
| Insight do autor, afirmação forte ou frase de impacto sem atribuição | Tipo 2 — 1 item de lista com destaque, ou texto simples |
| Números, resultados, métricas | Tipo 4 — Dados e Métricas |
| Instrução de ação do autor (comenta X, acessa Y) | Tipo 5 — CTA Final |
| Título/gancho do post | Tipo 1 — Capa (dark ou light) |
| Explicação de um conceito ou passo | Tipo 2 — Lista ou texto simples |
| Lista narrativa de resultados ou features com frases completas (sem hierarquia visual necessária) | Tipo 2b — Lista com Setas |
| Ponto de conteúdo que precisa de visual de suporte (screenshot do produto, mockup, print de resultado) | Tipo 6 — Conteúdo com Imagem |
| Screenshot de depoimento (WhatsApp, DM) como prova central do slide | Tipo 7 — Prova com Screenshot |

### 3.3 — Adaptação visual do hook

O hook do carrossel é o título do Slide 1. Quando o texto original tem um gancho forte, preservá-lo é prioridade.

**Processo correto:**
1. Identifique a frase de abertura/hook do texto original
2. Mantenha o conteúdo semântico integralmente
3. Quebre em linhas curtas para leitura rápida no slide (máximo 4 palavras por linha no title)
4. Aplique destaques visuais (cor de **destaque**, sublinhado) na palavra-chave — sem alterar o texto
5. Ajuste o tamanho da fonte para caber no canvas sem cortar

**Exemplo correto:**
```
Texto original: "Gerei 2.425 leads e 70 reuniões em 76 dias sem gastar R$1 em anúncios."

Hook no slide (dark):
  Linha 1: "Gerei 2.425 leads" → "2.425" em destaque (cor de destaque do cliente)
  Linha 2: "e 70 reuniões"
  Linha 3: "em 76 dias."
  Subtítulo: "Sem gastar R$1 em anúncios."
```

**Exemplo incorreto:**
```
❌ Reescrever como: "Como geramos resultados expressivos com marketing orgânico"
   (parafraseia, perde especificidade e destrói o hook original)
```

---

## 4. Templates de Slide

São 6 tipos de slide essenciais (mais as variantes 1a/1b, 2b e 7). Cada um tem função e comportamento visuais específicos.

> **Regra de template único:** cada slide usa exatamente 1 template. Proibido combinar sub-componentes de templates diferentes no mesmo slide (ex: callout box do Tipo 2 + aspas gigantes do Tipo 3). Se o conteúdo naturalmente pede dois padrões visuais, dividir em dois slides separados.

> **Nota de cor:** as specs abaixo citam papéis (destaque/escura/clara + tints), não hex fixos. Nos templates HTML esses papéis já são `var(--destaque)`, `var(--escura)`, `var(--clara)`, `var(--surface)` e os tints derivados — ver a seção "Sistema de cores da marca". Basta preencher as 3 cores no `:root`. Neutros e semânticos ficam literais.

### Tipo 1a — Capa Dark

**Fundo:** **escura** (`var(--escura)`)
**Quando usar:** tom assertivo, impacto numérico forte, contraste máximo no feed. Funciona especialmente bem com hooks curtos e métricas.

**Regra de layout:** a capa **nunca** é top-aligned nem side-by-side. O canvas 1080×1350 é retrato; tentar encaixar texto + imagem lado a lado comprime os dois. Escolha **uma** das duas composições:

**Composição A — Stacked (texto em cima, ilustração embaixo):** quando houver entregável visual (relatório, swipe file, aula, screenshot do produto). Bloco de texto ocupa ~50-55% do canvas superior. Ilustração ocupa ~40-45% da metade inferior, centralizada horizontalmente. Mockups duplos em `-5deg` e `+3deg` com `box-shadow: 0 24px 80px rgba(0,0,0,0.25), 0 6px 24px rgba(0,0,0,0.15)`. Single screenshot: borda sutil + sombra, sem rotação.

**Composição B — Centralizada sem ilustração:** quando o hook é o protagonista absoluto (capa "confissão pessoal", hook curto e provocativo). Texto vertical-centralizado. Abaixo do subtítulo, inclua **obrigatoriamente** um elemento de balanço visual: (1) barra decorativa 90×5px na cor de destaque, (2) linha de pills de nichos/segmentos, ou (3) row de 2–3 mini-badges com métrica-proof. Nunca deixe a metade inferior totalmente vazia.

**Regra de eyebrow nas capas:** o eyebrow é opcional. Quando usado, deve identificar o produto/isca (ex: "Nome do Produto", "Guia") ou o tipo de conteúdo (ex: "Case", "Tutorial"). Nunca usar label temático genérico nem fragmento de frase narrativa. O eyebrow e o título devem fazer sentido de forma independente — o eyebrow nunca pode ser a "primeira metade" do título.

**Atmosfera visual obrigatória na capa dark (ver seção 4.5):**
- **Dot pattern** ao fundo: `radial-gradient(circle, rgba(255,255,255,0.06) 1px, transparent 1px); background-size: 28px 28px`
- **Glow** num canto: elemento absoluto 600×600px com `radial-gradient(circle, var(--destaque-15), transparent 70%)` em top-right ou bottom-left

**Técnica de destaque no título (escolha uma):**

| Técnica | CSS de referência (usa as variáveis do `:root`) |
|---|---|
| **Gradient accent (preferencial)** | `background: linear-gradient(135deg, var(--destaque-tint), var(--destaque)); -webkit-background-clip: text; -webkit-text-fill-color: transparent` |
| **Destaque sólido** | `color: var(--destaque-tint)` (em fundo dark, nunca o destaque puro se perder contraste) |
| **Sublinhado** | `text-decoration: underline; text-decoration-color: var(--destaque); text-decoration-thickness: 5px; text-underline-offset: 8px` |

---

### Tipo 1b — Capa Light

**Fundo:** **clara** — `var(--clara)` (preferencial) ou `var(--surface)`
**Quando usar:** tom educativo, hooks textuais mais longos, conteúdo metodológico, storytelling de produto.

**Regra de layout:** mesma da capa dark — escolha **composição A (stacked com mockup embaixo)** ou **composição B (centralizada sem ilustração)**. Nunca top-align, nunca split lateral.

**Regra de eyebrow:** mesma da capa dark — opcional, identifica produto/isca ou tipo de conteúdo. Nunca fragmento de frase ou label temático.

**Atmosfera visual obrigatória na capa light (ver seção 4.5):**
- **Dot pattern sutil** ao fundo: `radial-gradient(circle, #C8D3E6 1px, transparent 1px); background-size: 28px 28px; opacity: 0.55` (`#C8D3E6` é neutro universal)
- **Fade gradient** opcional no rodapé (transparent → cor clara) para suavizar transição
- Dot pattern da capa light é **sempre mais leve** que da dark

**Técnicas de destaque em capa light (usar apenas uma por slide):**

| Técnica | Referência (usa as variáveis do `:root`) | Quando usar |
|---|---|---|
| **Cor de destaque** | `color: var(--destaque)` na palavra-chave | Termos curtos, nomes, números |
| **Sublinhado** | `text-decoration-color: var(--destaque); thickness 4-5px` | Frases inteiras, âncora visual forte |
| **Background mark** | `background: var(--destaque-wash); padding: 0 6px; border-radius: 4px` | Palavras isoladas, estilo "marca-texto" |
| **Barra decorativa** | Elemento 80-90px × 5px em `var(--destaque)`, acima ou abaixo do título | Capas sóbrias, sem alterar o texto |
| **Gradient accent** | Igual capa dark | Capas com hook metodológico/premium |

> **Regra:** nunca combine mais de uma técnica de destaque na mesma capa.

> **Regra anti-vazio:** se a composição escolhida for B e o slide tiver mais de 40% da altura vazia abaixo do subtítulo, a capa está incorreta. Adicione elemento de balanço ou reduza padding superior.

---

### Tipo 2 — Conteúdo com Lista

**Fundo:** **clara** — `var(--surface)` ou `var(--clara)` (alternar)
**Quando usar:** passos numerados, erros, insights com hierarquia visual.

```
[Header: Logo (esq) · Contador "X / N" (dir)]
[Eyebrow: cor de destaque, uppercase — âncora de navegação: "Passo 1", "Erro #2", "Pilar #3". Nunca fragmento de frase. Eyebrow e título devem fazer sentido independentemente.]
[Título: 54–72px / 700 / cor escura]
[Lista de itens — máximo 3. Com 4+ itens, usar dois slides consecutivos (Parte 1 / Parte 2):]
  - Bullet circular (cor de destaque ou escura)
  - Label do item: 18px / 700 / cor de destaque / uppercase
  - Texto: 28–34px / 500 / cor escura
  - Item em destaque: borda cor de destaque, fundo tint muito claro do destaque
[Barra de progresso: 4px, cor de destaque proporcional, fundo #E2E8F0]
```

---

### Tipo 3 — Citação de Pessoa Identificada

**Fundo:** **clara** — `var(--clara)`
**Quando usar:** fala literal de pessoa identificada — cliente, parceiro ou colaborador com nome e cargo/empresa na atribuição. Nunca usar para afirmações do autor, insights próprios ou frases de efeito sem atribuição a pessoa real. Essas vão para Tipo 2.

```
[Header: Logo (esq) · Contador (dir)]
[Eyebrow: cor de destaque]
[Aspas de abertura: 130–160px / Georgia / cor de destaque]
[Texto da citação: 46–56px / 600 / cor escura / line-height 1.3]
[Linha: 70px × 4px / cor de destaque]
[Atribuição: "Nome — Cargo, Empresa" / 24–28px / #6B7280]
[Barra de progresso]
```

---

### Tipo 4 — Dados e Métricas

**Fundo:** **clara** — `var(--surface)` (branco)
**Quando usar:** cases de resultado, benchmarks, números do produto.

```
[Header: Logo (esq) · Contador (dir)]
[Eyebrow: cor de destaque]
[Título: 54–60px / 700 / cor escura]
[Grid 2×2 de cards de métrica:]
  Card padrão — fundo `var(--clara)`, borda #E2E8F0, border-radius 16px:
    - Label: 22px / 500 / #6B7280
    - Valor: 72–88px / 700 / cor escura / letter-spacing -0.03em
    - Unidade: 26px / 500 / #6B7280
    - Badge de variação (opcional): #DCFCE7 / #16A34A, pill (semânticos universais)
  Card em destaque — fundo cor de destaque, textos em branco
[Barra de progresso]
```

---

### Tipo 5 — CTA Final

**Fundo:** **destaque** (cor de destaque sólida)
**Quando usar:** sempre o último slide. Nunca usar outro fundo.

```
[Header: Logo invertido (ícone/marca na cor de destaque sobre fundo #FFF) + wordmark branco · Contador rgba(255,255,255,0.4)]
[Eyebrow: rgba(255,255,255,0.6) / uppercase]
[Título: 62–80px / 700–800 / #FFFFFF]
[Subtítulo: 28–32px / 400 / rgba(255,255,255,0.72)]
[Botão visual: fundo #FFFFFF, texto na cor de destaque, padding 18px 32px, border-radius 12px, font-size 26px — inline-flex, hug do texto, NUNCA full-width]
[Rodapé: [DOMINIO_DO_CLIENTE] (esq) · "N / N" (dir)]
```

**Regra:** o CTA **não** tem círculos decorativos. A cor de destaque sólida já carrega a marca visualmente. Nunca adicionar `deco-circle-*`.

**Regra do botão:** `display: inline-flex` garante largura exata do conteúdo. Nunca envolver num pai `display: block`/`width: 100%`. Padding fixo `18px 32px`.

---

### Tipo 2b — Lista com Setas (variante narrativa)

**Fundo:** **clara** — `var(--surface)` ou `var(--clara)` (alternar)
**Quando usar:** lista de resultados, features ou tópicos narrativos onde os itens são frases completas sem necessidade de hierarquia visual. Alternativa ao Tipo 2 quando a lista é mais orgânica ou tem mais de 3 itens curtos.

```
[Header: Logo (esq) · Contador "X / N" (dir)]
[Eyebrow: cor de destaque, uppercase — âncora de navegação (opcional)]
[Título: 54–72px / 700 / cor escura]
[Lista com setas:]
  → [texto] — "→" na cor de destaque, 700; texto na cor escura, 500, 28–34px / line-height 1.4–1.5
  (sem label uppercase, sem bullet circular, sem borda/fundo de destaque)
  Máximo: 5 itens se curtos (1 linha cada); 3 itens se 2 linhas por item
[Barra de progresso]
```

---

### Tipo 6 — Conteúdo com Imagem (Stacked Interior)

**Fundo:** **clara** — `var(--surface)` ou `var(--clara)` (alternar)
**Quando usar:** slide de conteúdo interno que precisa mostrar um visual que reforça o ponto — screenshot do produto do cliente, print de resultado, mockup de material. A imagem é prova ou ilustração do que o texto afirma, não decoração.

```
[Header: Logo (esq) · Contador "X / N" (dir)]
[Eyebrow: âncora de navegação (opcional)]
[Título: 54–72px / 700 / cor escura]
[Texto ou lista curta: 1–2 linhas OU 2–3 itens com → / 28–34px / 500 / cor escura]
↓ (gap 24–32px)
[Imagem/mockup/screenshot — ocupa 45–55% da altura disponível:
  border: 1px solid #E2E8F0; border-radius: 12–16px
  box-shadow: 0 4px 24px rgba(0,0,0,0.08), 0 1px 6px rgba(0,0,0,0.04)
  largura: 85–100% da área de conteúdo; nunca excede o padding inferior seguro]
[Barra de progresso]
```

**Regra de imagem:** sempre com borda + shadow. Nunca soltar o screenshot diretamente sobre o fundo claro sem delimitação.

---

### Tipo 7 — Prova com Screenshot

**Fundo:** **clara** — `var(--surface)` ou `var(--clara)` (alternar)
**Quando usar:** slide de prova social com print real — depoimento de WhatsApp, resultado de DM, conversa com cliente. O screenshot é o protagonista: título curto e narrativo, print domina o slide. Diferente do Tipo 3 (fala transcrita em texto com aspas) — aqui a prova é a imagem original.

```
[Header: Logo (esq) · Contador "X / N" (dir)]
[Título narrativo: 54–68px / 700 / cor escura — curto, 1–2 linhas, tom de storytelling]
  ex: "E isso foi o que ele me disse..." / "O resultado depois de 7 dias:"
↓ (gap 20–28px)
[Screenshot centralizado horizontalmente:
  border: 1px solid #E2E8F0; border-radius: 16px
  box-shadow: 0 8px 40px rgba(0,0,0,0.10), 0 2px 8px rgba(0,0,0,0.05)
  largura: 70–85% da área de conteúdo
  ultrapassa levemente a borda inferior do canvas (bottom -40 a -60px) — corte intencional]
```

> **Exceção de barra de progresso:** o Tipo 7 é o único template de conteúdo **sem barra de progresso** — omitida para não interferir com o screenshot que estoura na borda inferior. O header (logo + contador) permanece no topo.

---

### Guia de escolha entre Capa Dark e Light

| Situação | Capa recomendada |
|---|---|
| Hook com métricas numéricas grandes (ex: "2.425 leads") | **Dark** — números na cor de destaque criam impacto máximo |
| Hook curto e provocativo | **Dark** — o contraste amplia o dramatismo |
| Hook textual longo ou metodológico | **Light** — mais espaço visual para respirar |
| Conteúdo com tom educativo ou tutorial | **Light** — combina com a linguagem mais suave |
| Série ou formato recorrente | Manter consistência — não alternar entre posts da série |

> **Regra de alternância intermediária:** nos slides de conteúdo (2 em diante), alterne entre `var(--surface)` (branco) e `var(--clara)`. Nunca coloque 3 slides sequenciais com o mesmo fundo.

> **Slide de transição opcional:** para carrosséis com 8+ slides, use fundo na cor **escura** (`var(--escura)`) como separador de seção. Máximo 1 por carrossel.

---

## 4.5. Atmosfera Visual — Dot Pattern, Glow e Decorações

Três recursos visuais criam profundidade sem ruído. Replicar traz coerência imediata com a marca.

### 4.5.1 — Dot Pattern (obrigatório nas capas)

**Capa dark:**
```css
.slide.dark::before {
  content: ''; position: absolute; inset: 0;
  background-image: radial-gradient(circle, rgba(255,255,255,0.06) 1px, transparent 1px);
  background-size: 28px 28px; pointer-events: none;
}
```

**Capa light:**
```css
.slide.light::before {
  content: ''; position: absolute; inset: 0;
  background-image: radial-gradient(circle, #C8D3E6 1px, transparent 1px);
  background-size: 28px 28px; opacity: 0.55; pointer-events: none;
}
```

> **Regra:** o dot pattern é **exclusivo das capas**. Em slides de conteúdo, o fundo permanece limpo.

### 4.5.2 — Glow (obrigatório na capa dark)

Elemento radial que cria profundidade luminosa no canto da capa. Usar a cor de **destaque** a 15% de opacidade:

```css
.slide.dark::after {
  content: ''; position: absolute;
  top: -200px; right: -200px;   /* ou bottom/left — variar entre carrosséis */
  width: 600px; height: 600px;
  background: radial-gradient(circle, var(--destaque-15), transparent 70%);
  pointer-events: none;
}
```

Na capa light, o equivalente é opcional — se usado, trocar `var(--destaque-15)` por `var(--destaque-08)`.

### 4.5.3 — Pill de eyebrow

O eyebrow das capas segue o padrão **pill**, não texto solto.

**Capa dark (pill translúcida na cor de destaque):**
```css
.eyebrow-pill-dark {
  display: inline-flex; align-items: center; gap: 7px;
  background: var(--destaque-15); border: 1px solid var(--destaque-25);
  color: var(--destaque-pale);
  font-size: 22px; font-weight: 600;
  padding: 6px 14px; border-radius: 9999px;
  text-transform: uppercase; letter-spacing: 0.02em; margin-bottom: 28px;
}
```

**Capa light (pill clara na cor de destaque):**
```css
.eyebrow-pill-light {
  display: inline-flex; align-items: center; gap: 7px;
  background: var(--destaque-08); color: var(--destaque);
  font-size: 22px; font-weight: 600;
  padding: 6px 14px; border-radius: 9999px;
  text-transform: uppercase; letter-spacing: 0.02em; margin-bottom: 28px;
}
```

**Variante "novidade"** (fundo `#DCFCE7`, texto `#16A34A`, dot pulsante — semânticos universais).

Nos slides de conteúdo intermediário, o eyebrow pode permanecer como texto simples uppercase. Reserve a pill para capas e slide CTA.

### 4.5.4 — Proof row / métricas inline (elemento de balanço)

Quando a capa precisa de conteúdo na metade inferior sem depender de mockup, use uma linha de **proof points**:

```css
.proof-row { display: flex; gap: 24px; flex-wrap: wrap; margin-top: 32px; }
.proof-item { display: flex; align-items: center; gap: 10px; }
.proof-icon {
  width: 36px; height: 36px; background: rgba(22, 163, 74, 0.12); border-radius: 8px;
  display: flex; align-items: center; justify-content: center; color: #16A34A; font-weight: 700;
}
.proof-text { font-size: 20px; font-weight: 600; color: rgba(255,255,255,0.8); }
/* Em capa light, ajustar: color: [cor escura]; */
```

### 4.5.5 — Balanceamento vertical em slides de conteúdo

Slides de conteúdo com bloco de texto curto tendem a ficar "bottom-heavy":
- Se o bloco de conteúdo ocupa **menos de 40% da altura disponível**, centralizar verticalmente via `justify-content: center`.
- Nunca deixar o bloco ancorado no topo com mais de 60% da área vazia abaixo.

### 4.5.6 — Pills de nicho / segmento (balanço alternativo)

```css
.niche-row { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 24px; }
.niche-pill {
  font-size: 18px; font-weight: 600; padding: 6px 16px; border-radius: 9999px;
  background: var(--destaque-15); color: var(--destaque-pale); border: 1px solid var(--destaque-25);
}
/* Em capa light: background: var(--destaque-08); color: var(--destaque); border: 1px solid var(--destaque-20); */
```

---

## 5. Sistema Tipográfico — Carrosséis

**Família:** Inter.

**Carregamento — base64 inline (NÃO Google Fonts):** a rede do sandbox do Claude.ai tem **allowlist e bloqueia `fonts.googleapis.com`/`fonts.gstatic.com`**. Um `<link>` de Google Fonts falha em silêncio e o texto cai numa fonte de sistema (fallback) sem erro visível. Por isso a fonte entra **embutida em base64** via `@font-face`. O fluxo (executado pelo `render.py` — seção 12):

1. Instalar a fonte via npm: `npm install @fontsource/inter` (o npm é liberado; Google Fonts não).
2. Ler os `.woff2` de `node_modules/@fontsource/inter/files/` e embutir em base64 num `@font-face` por peso.
3. Injetar esse `<style>` no `<head>` de cada slide (o template deixa o marcador `<!--FONTE-INTER-INLINE-->` no lugar onde ia o `<link>`).

No template HTML, em vez do `<link>`, fica só o marcador:

```html
<head>
  <!--FONTE-INTER-INLINE-->  <!-- render.py injeta @font-face base64 aqui -->
  ...
```

```css
body { font-family: 'Inter', -apple-system, sans-serif; -webkit-font-smoothing: antialiased; }
```

O render valida com `document.fonts.check("80px 'Inter'")` antes de exportar — se a fonte não aplicou, avisa em vez de gerar o PNG com fonte errada.

> Se o `brandbook.md` do cliente define uma fonte de marca própria e ela existir como pacote `@fontsource/*`, trocar Inter por ela no mesmo fluxo (npm + base64). Se não houver pacote, manter Inter como fallback seguro — nunca depender de Google Fonts por URL.

> **Tamanho mínimo:** textos abaixo de **28px no canvas 1080px** ficam ilegíveis no thumbnail do feed. Nunca use corpo de texto menor que 28px.

| Elemento | Tamanho (canvas 1080px) | Peso | Letter-spacing | Line-height | Cor (light) | Cor (dark) |
|---|---|---|---|---|---|---|
| Título capa (dark) | 80–100px | **800** | -0.03em | 1.1–1.15 | — | `#FFFFFF` |
| Título capa (light) | 72–90px | **700–800** | -0.03em | 1.1–1.15 | cor escura | — |
| Heading de slide | 54–72px | 700 | -0.025em | 1.1 | cor escura | — |
| Subtítulo | 28–32px | 400 | normal | 1.5–1.7 | `#6B7280` | `#9CA3AF` |
| Body / item de lista | 28–34px | 500 | normal | 1.4–1.6 | cor escura | — |
| Eyebrow pill | 22–24px | 600 | 0.02em | 1 | destaque | tint pálido do destaque |
| Metadado / contador | 20–24px | 500 | normal | 1 | `#6B7280` | `#4B5563` |
| Texto do botão CTA | 28–36px | 700 | -0.01em | 1 | destaque | — |
| Logo wordmark | 22–28px | 700 | -0.02em | 1 | cor escura | `#FFFFFF` |
| Atribuição em citação | 24–28px | 500 | normal | 1.4 | `#6B7280` | — |

### Regras de tipografia específicas para carrosséis

- **Máximo 3 blocos de texto por slide.** Se exigir mais, divida em dois slides.
- **Letter-spacing em títulos grandes:** `-0.02em` a `-0.03em`.
- **Line-height:** headings `1.0`–`1.15`; body `1.4`–`1.6`.
- **Alinhamento exclusivamente à esquerda.** Nunca centralizado/justificado (exceção: título do Tipo 7).
- **Negrito estratégico:** `font-weight: 700` na palavra-chave — nunca parágrafos inteiros em negrito.

---

## 6. Paleta de Cores — Uso em Carrosséis

> Ver a seção "Sistema de cores da marca" no topo. A coluna **Token/variável** é o que os templates usam; o **hex de exemplo** é só o default do `:root` (paleta de referência). As linhas 🎨 derivam das 3 cores da marca (basta preencher o `:root`); as ⚙️ são **universais** (ficam literais na skill).

| Token / variável | Hex de exemplo (default) | Origem | Uso em carrosséis |
|---|---|---|---|
| `var(--escura)` | `#121117` | 🎨 escura | Capa dark e transição de seção |
| `var(--destaque)` | `#1447E6` | 🎨 destaque | Slide CTA, eyebrows light, destaques sólidos, barra de progresso |
| `var(--destaque-shade)` | `~#1039C4` | 🎨 destaque (shade) | Hover/estado pressionado de botões |
| `var(--destaque-tint)` | `~#4D7BF3` | 🎨 destaque (tint) | Destaques em fundo dark (sólido alternativo ao gradient) |
| `var(--destaque-pale)` | `~#93B4FF` | 🎨 destaque (tint) | Texto de eyebrow/pill sobre fundo dark |
| `linear-gradient(135deg, var(--destaque-tint), var(--destaque))` | — | 🎨 destaque + tint | Texto destacado em títulos de capa (clip-text) |
| `var(--destaque-08)` | `~rgba(destaque,0.08)` | 🎨 destaque a 0.08 | Background de pill em capa light |
| `var(--destaque-15)` | `~rgba(destaque,0.15)` | 🎨 destaque a 0.15 | Background de pill em capa dark, glow |
| `var(--destaque-25)` | `~rgba(destaque,0.25)` | 🎨 destaque a 0.25 | Borda de pill em capa dark |
| `var(--destaque-wash)` | `~#EFF4FF` | 🎨 destaque (tint claro) | Item em destaque em listas, mark de texto |
| `var(--escura)` (texto) | `#0F1729`→`#121117` | 🎨 escura | Headings de slides claros, transição alternativa |
| `var(--surface)` | `#FFFFFF` | ⚙️ branco fixo | Slides de conteúdo (pares), capa light |
| `var(--clara)` | `#FAFAFA` | 🎨 clara | Slides de conteúdo (ímpares), capa light preferencial |
| Body Font | `#6B7280` | ⚙️ universal | Subtítulos, metadados, atribuições (light) |
| Body Dark | `#9CA3AF` | ⚙️ universal | Subtítulos sobre fundo dark |
| Meta Dark | `#4B5563` | ⚙️ universal | Contador sobre fundo dark |
| Card Border | `#E2E8F0` | ⚙️ universal | Bordas de cards, fundo da barra de progresso |
| Dot Pattern (light) | `#C8D3E6` | ⚙️ universal | Textura pontilhada capa light |
| Dark Border | `#1F2937` | ⚙️ universal | Bordas sobre fundo dark |

### 6.1 — Gradient accent no título (técnica preferencial em capa dark)

```css
.accent-gradient {
  background: linear-gradient(135deg, var(--destaque-tint), var(--destaque));
  -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
}
```

> Em capa light, o gradient accent é **opcional** (o destaque sólido já tem contraste). Em capa dark é **preferencial** (o destaque puro pode perder contraste sobre fundo escuro).

### Cores semânticas — uso restrito (universais)

| Cor | Hex | Uso permitido | Uso proibido |
|---|---|---|---|
| Verde | `#16A34A` | Badge de variação positiva em card de métrica | Fundo de slide, decoração |
| Amarelo | `#EAB30A` | Dado intermediário/benchmark neutro em gráfico | Fundo de slide, decoração |
| Vermelho | `#EF4343` | Queda, dado negativo em métrica | Fundo de slide, decoração |
| Verde claro | `#DCFCE7` | Fundo de badge positivo, pill "novidade" | Fundo de slide |

> **Regra absoluta:** cores semânticas comunicam estado de dados — nunca decoram.

---

## 7. Grid, Logo e Zonas de Segurança

### Grid

| Zona | Medida (canvas 1080px) | Conteúdo |
|---|---|---|
| Padding seguro (todos os lados) | 72–80px | Todo conteúdo dentro desta margem |
| Área de logo | Topo esquerdo — até 200px de altura | Logo sempre presente |
| Área do contador | Topo direito ou rodapé direito | "X / N" — progresso |
| Barra de progresso | Rodapé — 4px | Preenchida na cor de destaque, fundo `#E2E8F0` |
| Zona de heading | ~30–50% da altura, topo | Eyebrow + título |
| Zona de conteúdo | ~50–85% da altura | Listas, dados, citação, corpo |

### Barra de progresso — cálculo

**Fórmula:** `largura_preenchida = (número_do_slide ÷ total_de_slides) × 920px`

Exemplos para 8 slides: slide 2 → 230px; slide 4 → 460px; slide 7 → 805px; slide 8 (CTA) → sem barra.

### Logo do cliente — especificação

O logo é composto por dois elementos: **ícone/marca do cliente** (opcional) + **wordmark `[NOME_DA_MARCA]`**. Ambos vêm do `brandbook.md`.

**Com ícone/logo:** container quadrado 44–52px, `border-radius: 11px`, fundo na cor de destaque, com o logo/ícone do cliente dentro (branco/invertido). O container quadrado com border-radius faz parte da linguagem visual.

```css
.logo-icon {
  width: 48px; height: 48px; background: var(--destaque); border-radius: 11px;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
```

**Sem ícone (cliente só tem wordmark):** usar apenas o `<span class="logo-text">[NOME_DA_MARCA]</span>`, sem o container do ícone.

**Variações do logo por tipo de slide:**

| Tipo de slide | Container | Fundo do container | Wordmark |
|---|---|---|---|
| Capa dark | 48–52px | destaque | `#FFFFFF` |
| Slides de conteúdo (light) | 40–48px | destaque | cor escura |
| Capa light | 48–52px | destaque | cor escura |
| Slide CTA (fundo destaque) | 48–52px | `#FFFFFF` | `#FFFFFF` |
| Slide transição (escura) | 48–52px | destaque | `#FFFFFF` |

**Regras absolutas do logo:**
- Nunca usar emoji como substituto do logo/ícone
- Se houver ícone SVG do cliente, mantê-lo consistente em todos os slides
- O container quadrado com border-radius (quando há ícone) faz parte da identidade

---

## 8. Boas Práticas de Copy

### 8.1 — Slide de Capa: fórmulas de hook

> **O hook é a variável mais importante do carrossel.** Quando o conteúdo original já tem um hook forte, preserve-o integralmente (ver seção 3). As fórmulas abaixo servem para criar hooks do zero.

| Fórmula | Template | Exemplo para SaaS B2B |
|---|---|---|
| Número + promessa | N [elemento] que [resultado] | "5 erros que travam seu social selling" |
| Contradição / paradoxo | [Ação comum] não funciona. [Motivo] | "Quanto mais você posta, menos você vende." |
| Resultado específico | Como [resultado] em [tempo] sem [objeção] | "Como geramos 23 reuniões em 90 dias sem tráfego pago" |
| Pergunta direta ao ICP | Você está [dor do ICP]? | "Você está enviando 300 DMs por dia e fechando 0?" |
| Afirmação provocativa | [Crença popular] é [julgamento oposto] | "Prospecção ativa sem inbound é dinheiro queimado." |

### 8.2 — Slides de Conteúdo

- **Uma ideia por slide.**
- **O título entrega o ponto.** O leitor entende o slide mesmo sem ler o corpo.
- **Números reais sempre que possível.**
- **Eyebrow anchors:** palavras curtas no topo (Passo 1, Erro #2, Pilar #3) — nunca fragmento de frase.
- **Destaque uma palavra por slide** com a cor de destaque ou peso maior. Nunca destaque tudo.

### 8.3 — Slide de CTA

| Elemento | Especificação | Exemplo |
|---|---|---|
| Eyebrow | Rótulo curto em uppercase | "Próximo passo" / "Acesso gratuito" |
| Título | Pergunta/afirmação que direciona para ação. 2–3 linhas | "Pronto para gerar reuniões com conteúdo?" |
| Subtítulo | Próximo passo em 1–2 linhas | "Fale com a gente. Sem tráfego pago." |
| Botão visual | Fundo branco, texto na cor de destaque | "→ Comece agora" |
| Rodapé | `[DOMINIO_DO_CLIENTE]` (esq) · "N / N" (dir) | `suamarca.com · 8 / 8` |
| Microcopy opcional | Instrução de engajamento | "Salve este post para rever depois" |

> **Dica de algoritmo:** "Salve este post para consultar depois" gera sinal de engajamento de alta qualidade (saves têm peso maior que curtidas). Inclua como microcopy quando o conteúdo for educacional.

### 8.4 — Legenda do post (fora do carrossel)

```
1ª linha (hook de legenda): aparece antes do "ver mais". Repete/complementa o hook da capa — nunca verbatim.
Corpo (3–6 linhas): contexto complementar — não reproduz o conteúdo do carrossel.
CTA de legenda: ação diferente do carrossel.
Hashtags: 3 a 5, sempre ao final.
```

---

## 9. O que Fazer e Não Fazer

### ✅ Fazer

- Escolher o tema da capa (dark/light) com base no tom e conteúdo do post
- **Escolher uma das duas composições de capa**: stacked ou centralizada com balanço inferior
- **Aplicar dot pattern e glow** na capa
- **Usar pill para eyebrow** nas capas — texto solto só em slides de conteúdo
- **Usar gradient-clipped text** para destacar palavra-chave em capa dark
- **Preencher as 3 cores do cliente no `:root`** (`--destaque`/`--escura`/`--clara`) — os tints derivam via `color-mix()`
- **Fonte Inter embutida em base64 (`@fontsource`)**, injetada pelo `render.py` no marcador `<!--FONTE-INTER-INLINE-->` — nunca Google Fonts por URL nem `@import`
- Preservar o hook original — adaptar forma, não conteúdo
- Incluir barra de progresso em todos os slides intermediários (exceto Tipo 7)
- Colocar o logo/wordmark do cliente em todos os slides
- Alternar fundos `var(--surface)`/`var(--clara)` nos slides de conteúdo
- Terminar sempre com slide CTA na cor de destaque
- **Renderizar um PNG por slide** e confirmar que as imagens saíram corretas

### ❌ Não fazer

- Usar mais de 3 cores distintas num mesmo slide
- **Deixar a capa top-aligned** com vazio na metade inferior
- **Omitir dot pattern e glow na capa**
- **Usar eyebrow como texto solto na capa**
- **Usar a cor de destaque sólida em título de capa dark** se perder contraste — usar gradient ou tint claro
- **Subtítulo em itálico**
- **Carregar a fonte via Google Fonts por URL (`<link>`) ou `@import`** — sempre base64 inline via `render.py`
- Usar emoji no lugar do logo/ícone do cliente
- Texto com menos de 28px no canvas 1080px
- Gradientes decorativos no fundo (o único permitido é o accent-clip-text)
- Cores fora da paleta do cliente + neutros/semânticos universais
- Slides sem o logo/wordmark do cliente visível
- Mais de 3 itens de lista por slide (divida em dois)
- Cores semânticas (verde/amarelo/vermelho) como decoração
- Slide de CTA sem ação clara e domínio visível
- Mais de 10 slides num único carrossel
- Texto em uppercase em parágrafos ou headings (apenas eyebrows)
- Combinar mais de uma técnica de destaque na mesma capa
- Reescrever ou parafrasear o hook quando o conteúdo original foi fornecido
- Usar Tipo 3 (Citação) para afirmações/insights sem atribuição a pessoa identificada
- Misturar sub-componentes de templates diferentes no mesmo slide

---

## 10. Checklist de Publicação

| Prioridade | Item | Como verificar |
|---|---|---|
| 🔴 P0 | **Cores do cliente aplicadas** | `:root` de cada slide com as 3 cores (`--destaque`/`--escura`/`--clara`) do `brandbook.md`? Tints derivam via `color-mix()` |
| 🔴 P0 | **Marca do cliente** | Wordmark `[NOME_DA_MARCA]` e domínio `[DOMINIO_DO_CLIENTE]` corretos? |
| 🔴 P0 | **Hook preservado do conteúdo original** | O texto do slide 1 é fiel ao conteúdo fornecido? |
| 🔴 P0 | **Slide 1 com hook forte** | Mostre só a capa para alguém de fora. Ele quer ver o resto? |
| 🔴 P0 | **Capa com composição correta** | Stacked ou centralizada com balanço. Nunca top-aligned, nunca side-by-side |
| 🔴 P0 | **CTA sem deco-circles** | Slide CTA tem só fundo destaque sólido + conteúdo |
| 🔴 P0 | **Domínio correto no CTA** | `[DOMINIO_DO_CLIENTE]` |
| 🔴 P0 | **Capa tem atmosfera visual** | Dot pattern (obrigatório) + glow (dark) |
| 🔴 P0 | **Eyebrow é pill, não texto solto** | Capas usam pill com background + border-radius 9999px |
| 🔴 P0 | **Fonte Inter realmente carregada** | Render em 100% — o "a" tem formato Inter (não `-apple-system`). Fonte base64 inline injetada pelo `render.py` no marcador `<!--FONTE-INTER-INLINE-->`, nunca Google Fonts por URL nem `@import` |
| 🔴 P0 | **Logo/wordmark do cliente em todos os slides** | Percorrer todos os slides |
| 🔴 P0 | **CTA no último slide** | Ação clara + domínio + contador "N / N" |
| 🔴 P0 | **Nenhuma cor fora da paleta do cliente + universais** | Verificar cada slide |
| 🟡 P1 | **Teste de legibilidade mobile** | Reduzir preview a 25% — títulos ainda legíveis? |
| 🔵 P2 | **Barra de progresso correta** | Preenchimento proporcional (ver seção 7); Tipo 7 sem barra |
| 🔵 P2 | **Alternância de fundos** | Sem 3+ slides consecutivos com o mesmo fundo |
| 🔴 P0 | **PNGs gerados e conferidos** | Rodar `render.py` no sandbox. Abrir os PNGs e verificar fonte, cores, glow, barra |
| 🔵 P2 | **Legenda do post escrita** | Hook + corpo complementar + CTA + 3–5 hashtags |
| 🔵 P2 | **Contagem de slides validada** | Entre 5 e 10 (ideal 6–8), contando capa e CTA |

---

## 11. Referência Rápida

### Tipografia — tamanhos no canvas 1080px

| Elemento | px | Peso | Letter-spacing |
|---|---|---|---|
| Título capa (dark) | 80–100 | **800** | -0.03em |
| Título capa (light) | 72–90 | **700–800** | -0.03em |
| Heading slide | 54–72 | 700 | -0.025em |
| Subtítulo | 28–32 | 400 | normal |
| Body / lista | 28–34 | 500 | normal |
| Eyebrow pill | 22–24 | 600 | 0.02em |
| Contador | 20–24 | 500 | normal |
| Botão CTA | 28–36 | 700 | -0.01em |
| Logo wordmark | 22–28 | 700 | -0.02em |

### Fundos por posição do slide (variável de fundo)

| Slide | Fundo (variável) |
|---|---|
| Capa (Slide 1) — dark | `var(--escura)` |
| Capa (Slide 1) — light | `var(--clara)` |
| Conteúdo posição par | `var(--surface)` (branco) |
| Conteúdo posição ímpar | `var(--clara)` |
| Transição (opcional) | `var(--escura)` |
| CTA (último slide) | `var(--destaque)` |

### Composições de capa — obrigatório escolher uma

| Composição | Quando usar |
|---|---|
| **A — Stacked (texto em cima + ilustração embaixo)** | Quando há entregável visual (relatório, aula, screenshot do produto) |
| **B — Centralizada com balanço inferior** | Hook é o protagonista + proof points/pills |

### Atmosfera visual — obrigatório em toda capa

| Elemento | Dark | Light |
|---|---|---|
| Dot pattern | `rgba(255,255,255,0.06)` 28×28px | `#C8D3E6` 28×28px opacity 0.55 |
| Glow | destaque a 0.15, radial 600×600px | Opcional — 0.08 se usar |
| Eyebrow | Pill translúcida na cor de destaque | Pill clara na cor de destaque |

### Especificações do canvas

| Item | Valor |
|---|---|
| Dimensões | 1080 × 1350 px |
| Padding seguro | 72–80px todos os lados |
| Logo container (slides claros) | 40–48px, border-radius 11px |
| Logo container (capa/CTA) | 48–52px, border-radius 11px |
| Barra de progresso | 4px, rodapé |
| Slides ideais | 5–8 (máximo 10) |

### Fórmula da barra de progresso

```
largura_preenchida = (número_do_slide ÷ total_de_slides) × 920px
```

---

## 12. Render — Sandbox do Claude.ai

> **O entregável final é um PNG por slide.** O render roda dentro do ambiente de execução de código do Claude.ai (Python-first). O usuário não instala nada localmente. Detalhes do script em `02_geracao_slides.md`.

### 12.1 — Estrutura de arquivos por carrossel

Numa pasta de trabalho do sandbox:

```
[YYYY-MM-DD_slug]/
├── slide-01-capa.html
├── slide-02-[nome].html
├── ...
├── slide-NN-cta.html
├── carrossel-preview.html   ← visualização local (iframes escalados)
├── render.py                ← script Python + Playwright
├── slide-01.png             ← ENTREGÁVEIS (um por slide)
├── slide-02.png
└── ...
```

**Convenção de nomenclatura:**
- Slides HTML: `slide-NN-nome-descritivo.html` (numeração 2 dígitos, nome kebab-case)
- PNGs: `slide-NN.png`

### 12.2 — Princípios do render (universais, preservados do pipeline original)

| Decisão | Motivo |
|---|---|
| Esperar `document.fonts.ready` + margem 800ms | Garante que Inter carregou antes de capturar (fontes variáveis levam um tick a mais) |
| Screenshot PNG (não `page.pdf`) | Elimina artefatos de cor do engine de PDF do browser |
| `device_scale_factor=2` | PNG em 2160×2700px — nitidez 2× no feed |
| Viewport 1080×1350 | Canvas exato do slide, sem overflow |
| Fonte Inter base64 inline (injetada pelo `render.py`), nunca Google Fonts por URL nem `@import` | `@import`/URL externa atrasa o render, é bloqueada pela rede do sandbox e quebra o headless em silêncio |

### 12.3 — Nota de ambiente (crítica)

Este passo depende de o sandbox do Claude.ai conseguir rodar Chromium headless (já validado neste ambiente). **Se por algum motivo o Chromium não estiver disponível no ambiente, o Da Vinci deve avisar o usuário em vez de falhar silenciosamente** — entregar os HTMLs + o `render.py` + instruções, e explicar que o passo de imagem não pôde rodar aqui.

### 12.4 — Validação do PNG gerado

Antes de publicar no LinkedIn, conferir em cada PNG:
- Fonte Inter renderizada (não a fonte do sistema)
- Dot pattern e glow visíveis na capa
- Cores do cliente corretas (destaque/escura/clara) em todos os slides
- Barra de progresso proporcional nos slides intermediários
- Slide CTA com fundo na cor de destaque, sem artefatos

> Se a fonte sair como fonte de sistema: aumentar a margem de espera de 800 para 1500ms após `document.fonts.ready`.

---

## Notas de versão (genéricas)

- **v2.2:** Tipo 2b (Lista com Setas), Tipo 6 (Conteúdo com Imagem) e Tipo 7 (Prova com Screenshot) adicionados. Tipo 7 é o único template de conteúdo sem barra de progresso.
- **v2.1:** documentado o pipeline de render como entregável obrigatório (não só os HTMLs).
- **v2.0:** contagem de slides ajustada (5–8, máx 10); Tipo 3 restrito a citação de pessoa identificada; proibição de layouts híbridos (1 template por slide); subtítulo das capas tornado opcional; eyebrow com restrição de conteúdo; regra de balanceamento vertical.
- **v1.x:** alinhamento com a identidade visual da marca; capas não podem ser top-aligned; atmosfera visual obrigatória (dot pattern, glow, pills, proof-row); tipografia afinada (peso 800 no título da capa, letter-spacing -0.03em, subtítulo nunca em itálico).
