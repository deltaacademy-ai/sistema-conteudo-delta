# Da Vinci — Prompt de Execução: Geração de Slides

Algoritmo passo a passo e templates HTML para geração de carrosséis LinkedIn.
Lido após carregar `carousel_design_system.md`.

---

## SISTEMA DE CORES DA MARCA (LER PRIMEIRO)

> **Todo template deste arquivo começa com um bloco de tokens `:root`.** A troca de cor por marca é feita em **um lugar só**: preencher **3 valores** (`--destaque`, `--escura`, `--clara`) no `:root` a partir do `brandbook.md`. Todo o resto — os tints, as pills translúcidas, o gradient, a barra de progresso — **deriva sozinho** via `color-mix()`. Não há mais hex de marca espalhado pelos templates: cada ocorrência já é `var(--...)`. Neutros e semânticos continuam literais (são universais).

### O bloco `:root` (já presente no `<style>` de cada template)

Preencher apenas as 3 primeiras variáveis com as cores da marca. Os valores de exemplo abaixo são o default (paleta de referência) — trocar pelos hexes do `brandbook.md`:

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

> `color-mix()` é suportado pelo Chromium headless do `render.py`, então os tints resolvem no render — não é preciso pré-calcular hex nenhum.

### Mapeamento — papel → variável

| Papel | Variável | Cor da marca (`brandbook.md`) |
|---|---|---|
| accent (CTA fundo, palavras-chave, barra de progresso, glow, pills, container do ícone/logo) | `var(--destaque)` | **destaque** |
| accent sólido em fundo dark, fim do gradient accent | `var(--destaque-tint)` | destaque + 75% (tint) |
| texto de eyebrow/pill sobre fundo dark | `var(--destaque-pale)` | destaque + 45% (pálido) |
| fundo de item em destaque, mark de texto | `var(--destaque-wash)` | destaque + 8% (wash) |
| hover/estado pressionado | `var(--destaque-shade)` | destaque escurecido (shade) |
| pills translúcidas / glow | `var(--destaque-08)` / `-15` / `-20` / `-25` | destaque + alpha |
| fundo capa dark; headings/texto sobre fundo claro | `var(--escura)` | **escura** |
| fundo dos slides claros / capa light | `var(--clara)` | **clara** |
| superfície branca (alternância par nos slides de conteúdo) | `var(--surface)` | branco fixo |

### Cores UNIVERSAIS — NÃO parametrizar (manter o hex literal)

- **Neutros:** `#6B7280`, `#9CA3AF`, `#4B5563`, `#E2E8F0`, `#C8D3E6`, `#1F2937`
- **Semânticos:** `#16A34A` (verde), `#EF4343` (vermelho), `#EAB30A` (amarelo), `#DCFCE7` (verde claro)

### Marca do cliente (do `brandbook.md`)

- `[NOME_DA_MARCA]` → o wordmark do cliente (substitui `<span class="logo-text">...</span>` em todos os templates)
- `[DOMINIO_DO_CLIENTE]` → o domínio do cliente (substitui no rodapé do slide CTA)
- **Ícone/logo:** o SVG de exemplo nos templates é um ícone genérico. Se o cliente tem ícone/logo próprio no `brandbook.md`, usar. Se **não** tiver ícone, remover o `.logo-icon` (container) e deixar só o wordmark `[NOME_DA_MARCA]`.

---

## Pré-etapa — Extrair dados do post

Do texto do post (redigido pelo Ogilvy ou fornecido pelo usuário) e da aprovação da Etapa A, extrair e registrar antes de começar:

- **Slug:** kebab-case do título (ex: `funil-retroalimentacao`)
- **Data:** YYYY-MM-DD da criação
- **Total de slides:** número final (incluindo capa e CTA)
- **Tipo de capa:** dark (cor **escura**) ou light (cor **clara**)
- **Composição da capa:** A (stacked) ou B (centralizada com balanço inferior)
- **Hook da capa:** primeira linha/título do post — extrair literalmente, não parafrasear
- **Mapeamento de conteúdo:** qual template (Tipo 2/2b/3/4/6/7) para cada slide de conteúdo
- **CTA:** ação do último slide — extrair do texto do post, não inventar
- **Cores do cliente:** destaque, escura, clara + tints derivados (do `brandbook.md`)
- **Marca:** `[NOME_DA_MARCA]`, `[DOMINIO_DO_CLIENTE]`, logo/ícone (do `brandbook.md`)

---

## Etapa 1 — Calcular barras de progresso

A barra de progresso aparece em **todos os slides exceto Capa e CTA** (e Tipo 7, que não tem barra).

Fórmula: `largura_preenchida = (número_do_slide ÷ total_de_slides) × 920`

Exemplo para 7 slides:
- Slide 2: `(2/7) × 920 = 263px`
- Slide 3: `(3/7) × 920 = 394px`
- Slide 4: `(4/7) × 920 = 526px`
- Slide 5: `(5/7) × 920 = 657px`
- Slide 6: `(6/7) × 920 = 789px`
- Slide 7: sem barra (CTA)

---

## Etapa 2 — Regras de fundo e alternância

(Cada `background` no template já usa a variável correspondente; basta manter.)

- **Slide 1 (capa dark):** `var(--escura)`
- **Slide 1 (capa light):** `var(--clara)`
- **Slides de conteúdo — posição par:** `var(--surface)` (branco)
- **Slides de conteúdo — posição ímpar:** `var(--clara)`
- **Slide CTA:** `var(--destaque)`
- **Nunca 3 slides consecutivos com o mesmo fundo** — alternar `var(--surface)` e `var(--clara)`

---

## Etapa 3 — Boilerplate compartilhado

Todo slide HTML começa com este boilerplate. Variam apenas: `background`, `padding`, layout interno e conteúdo. **Substituir a cor de fundo pela cor do cliente correspondente.**

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<!--FONTE-INTER-INLINE-->  <!-- render.py injeta @font-face base64 aqui (a rede do sandbox bloqueia Google Fonts) -->
<style>
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
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { width: 1080px; height: 1350px; overflow: hidden; }
body {
  font-family: 'Inter', -apple-system, sans-serif;
  background: [FUNDO_DO_SLIDE];   /* var(--clara) / var(--surface) / var(--escura) / var(--destaque) */
  display: flex; flex-direction: column;
  padding: 80px;
  -webkit-font-smoothing: antialiased;
}
</style>
</head>
<body>
  <!-- conteúdo do slide -->
</body>
</html>
```

**Componente de logo (light — slides de conteúdo):** substituir o wordmark por `[NOME_DA_MARCA]`. O SVG abaixo é um ícone de exemplo — se o cliente tem logo/ícone próprio, usar; se não tem ícone, remover o `.logo-icon` e deixar só o `.logo-text`.

```html
<div class="logo">
  <div class="logo-icon"><!-- container 44×44px, background: var(--destaque), border-radius 11px -->
    <!-- ícone/logo do cliente (do brandbook.md). Exemplo genérico abaixo: -->
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
         fill="none" stroke="white" stroke-width="2.5"
         stroke-linecap="round" stroke-linejoin="round">
      <path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"/>
    </svg>
  </div>
  <span class="logo-text">[NOME_DA_MARCA]</span>
</div>
```

**Componente de barra de progresso:**
```html
<div class="progress-bar">
  <div class="progress-fill" style="width: [LARGURA]px;"></div>
</div>
```

---

## Etapa 4 — Templates HTML por tipo de slide

> **Lembrete:** cada template abaixo já usa **variáveis CSS** (`var(--destaque)`, `var(--escura)`, `var(--clara)`, `var(--surface)` + os tints derivados) e traz o bloco `:root` no topo do `<style>`. A troca por cliente é só **preencher as 3 cores** (`--destaque`, `--escura`, `--clara`) no `:root` a partir do `brandbook.md` — nada de caçar hex slide a slide. Neutros (`#6B7280`, `#9CA3AF`, `#4B5563`, `#E2E8F0`, `#C8D3E6`) e semânticos (`#16A34A`, `#DCFCE7`, etc.) → **ficam literais**. `#FFFFFF` só é literal quando é branco de contraste (texto/elemento sobre fundo escuro/destaque). Substituir o wordmark por `[NOME_DA_MARCA]` e o domínio por `[DOMINIO_DO_CLIENTE]`.

### Template: Tipo 1a — Capa Dark

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<!--FONTE-INTER-INLINE-->  <!-- render.py injeta @font-face base64 aqui (a rede do sandbox bloqueia Google Fonts) -->
<style>
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
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { width: 1080px; height: 1350px; overflow: hidden; }
body {
  font-family: 'Inter', -apple-system, sans-serif;
  background: var(--escura);
  display: flex; flex-direction: column;
  padding: 80px;
  -webkit-font-smoothing: antialiased;
  position: relative;
}
body::before {
  content: ''; position: absolute; inset: 0;
  background-image: radial-gradient(circle, rgba(255,255,255,0.06) 1px, transparent 1px);
  background-size: 28px 28px; pointer-events: none; z-index: 0;
}
body::after {
  content: ''; position: absolute;
  top: -200px; right: -200px;
  width: 600px; height: 600px;
  background: radial-gradient(circle, var(--destaque-15), transparent 70%);
  pointer-events: none; z-index: 0;
}
header, .main { position: relative; z-index: 1; }
header { display: flex; align-items: center; justify-content: space-between; }
.logo { display: flex; align-items: center; gap: 12px; }
.logo-icon {
  width: 48px; height: 48px; background: var(--destaque); border-radius: 11px;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.logo-text { font-size: 26px; font-weight: 700; color: #FFFFFF; letter-spacing: -0.02em; }
.counter { font-size: 22px; font-weight: 500; color: #4B5563; }
.main { flex: 1; display: flex; flex-direction: column; justify-content: center; }
.eyebrow-pill {
  display: inline-flex; align-items: center;
  background: var(--destaque-15); border: 1px solid var(--destaque-25);
  color: var(--destaque-pale); font-size: 22px; font-weight: 600;
  padding: 7px 16px; border-radius: 9999px;
  text-transform: uppercase; letter-spacing: 0.02em;
  margin-bottom: 36px; width: fit-content;
}
h1 {
  font-size: 88px; font-weight: 800; color: #FFFFFF;
  line-height: 1.08; letter-spacing: -0.035em; margin-bottom: 28px;
}
.accent {
  background: linear-gradient(135deg, var(--destaque-tint), var(--destaque));
  -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
}
.subtitle { font-size: 30px; font-weight: 400; color: #9CA3AF; line-height: 1.6; margin-bottom: 48px; }
/* Composição B: elemento de balanço inferior — niche-pills */
.niche-row { display: flex; gap: 10px; flex-wrap: wrap; }
.niche-pill {
  font-size: 20px; font-weight: 600; padding: 8px 20px; border-radius: 9999px;
  background: var(--destaque-15); color: var(--destaque-pale); border: 1px solid var(--destaque-25);
}
/* Composição A: mockup container */
.mockup-area {
  width: 100%; flex: 1; display: flex; align-items: flex-end; justify-content: center;
  margin-top: 32px;
}
.mockup-area img {
  width: 92%; max-height: 480px; object-fit: contain;
  box-shadow: 0 24px 80px rgba(0,0,0,0.25), 0 6px 24px rgba(0,0,0,0.15);
  border-radius: 12px;
}
</style>
</head>
<body>
  <header>
    <div class="logo">
      <div class="logo-icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="26" height="26" viewBox="0 0 24 24"
             fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"/>
        </svg>
      </div>
      <span class="logo-text">[NOME_DA_MARCA]</span>
    </div>
    <span class="counter">1 / [TOTAL]</span>
  </header>

  <div class="main">
    <!-- Eyebrow: opcional — identifica produto/isca ou tipo de conteúdo -->
    <div class="eyebrow-pill">[EYEBROW OPCIONAL]</div>

    <h1>
      <!-- Hook do post — preservar literalmente. Palavras-chave em .accent -->
      [LINHA 1 DO HOOK]<br>
      <span class="accent">[PALAVRA-CHAVE EM DESTAQUE]</span><br>
      [RESTANTE DO HOOK]
    </h1>

    <!-- Subtítulo: opcional — só se o título não for autoexplicativo -->
    <p class="subtitle">[SUBTÍTULO OPCIONAL]</p>

    <!-- Composição B: niche-pills (quando não há mockup) -->
    <div class="niche-row">
      <span class="niche-pill">[Segmento 1]</span>
      <span class="niche-pill">[Segmento 2]</span>
      <span class="niche-pill">[Segmento 3]</span>
    </div>

    <!-- Composição A: mockup (quando há entregável visual) — remover niche-row acima -->
    <!-- <div class="mockup-area"><img src="[PATH_DA_IMAGEM]" alt=""></div> -->
  </div>
</body>
</html>
```

---

### Template: Tipo 1b — Capa Light

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<!--FONTE-INTER-INLINE-->  <!-- render.py injeta @font-face base64 aqui (a rede do sandbox bloqueia Google Fonts) -->
<style>
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
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { width: 1080px; height: 1350px; overflow: hidden; }
body {
  font-family: 'Inter', -apple-system, sans-serif;
  background: var(--clara);
  display: flex; flex-direction: column;
  padding: 80px;
  -webkit-font-smoothing: antialiased;
  position: relative;
}
body::before {
  content: ''; position: absolute; inset: 0;
  background-image: radial-gradient(circle, #C8D3E6 1px, transparent 1px);
  background-size: 28px 28px; opacity: 0.55; pointer-events: none; z-index: 0;
}
header, .main { position: relative; z-index: 1; }
header { display: flex; align-items: center; justify-content: space-between; }
.logo { display: flex; align-items: center; gap: 12px; }
.logo-icon {
  width: 48px; height: 48px; background: var(--destaque); border-radius: 11px;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.logo-text { font-size: 26px; font-weight: 700; color: var(--escura); letter-spacing: -0.02em; }
.counter { font-size: 22px; font-weight: 500; color: #6B7280; }
.main { flex: 1; display: flex; flex-direction: column; justify-content: center; }
.eyebrow-pill {
  display: inline-flex; align-items: center;
  background: var(--destaque-08); color: var(--destaque);
  font-size: 22px; font-weight: 600;
  padding: 7px 16px; border-radius: 9999px;
  text-transform: uppercase; letter-spacing: 0.02em;
  margin-bottom: 32px; width: fit-content;
}
h1 {
  font-size: 80px; font-weight: 800; color: var(--escura);
  line-height: 1.1; letter-spacing: -0.03em; margin-bottom: 28px;
}
.accent { color: var(--destaque); }
.subtitle { font-size: 30px; font-weight: 400; color: #6B7280; line-height: 1.6; margin-bottom: 48px; }
/* Elemento de balanço inferior */
.niche-row { display: flex; gap: 10px; flex-wrap: wrap; }
.niche-pill {
  font-size: 20px; font-weight: 600; padding: 8px 20px; border-radius: 9999px;
  background: var(--destaque-08); color: var(--destaque); border: 1px solid var(--destaque-20);
}
/* Composição A: mockup container */
.mockup-area {
  width: 100%; flex: 1; display: flex; align-items: flex-end; justify-content: center;
  margin-top: 32px;
}
.mockup-area img {
  width: 92%; max-height: 480px; object-fit: contain;
  border: 1px solid #E2E8F0; border-radius: 12px;
  box-shadow: 0 24px 80px rgba(0,0,0,0.12), 0 6px 24px rgba(0,0,0,0.08);
}
</style>
</head>
<body>
  <header>
    <div class="logo">
      <div class="logo-icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="26" height="26" viewBox="0 0 24 24"
             fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"/>
        </svg>
      </div>
      <span class="logo-text">[NOME_DA_MARCA]</span>
    </div>
    <span class="counter">1 / [TOTAL]</span>
  </header>

  <div class="main">
    <div class="eyebrow-pill">[EYEBROW OPCIONAL]</div>
    <h1>
      [HOOK]<br>
      <span class="accent">[PALAVRA-CHAVE]</span>
    </h1>
    <p class="subtitle">[SUBTÍTULO OPCIONAL]</p>
    <!-- Composição B: niche-pills -->
    <div class="niche-row">
      <span class="niche-pill">[Segmento 1]</span>
      <span class="niche-pill">[Segmento 2]</span>
    </div>
    <!-- Composição A: mockup — remover niche-row acima -->
    <!-- <div class="mockup-area"><img src="[PATH_DA_IMAGEM]" alt=""></div> -->
  </div>
</body>
</html>
```

---

### Template: Tipo 2 — Conteúdo com Lista (estruturada)

Usar para: passos numerados, erros, insights com hierarquia visual. Máximo 3 itens.

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<!--FONTE-INTER-INLINE-->  <!-- render.py injeta @font-face base64 aqui (a rede do sandbox bloqueia Google Fonts) -->
<style>
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
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { width: 1080px; height: 1350px; overflow: hidden; }
body {
  font-family: 'Inter', -apple-system, sans-serif;
  background: var(--surface);   /* ou var(--clara) — alternar; nunca 3 iguais seguidos */
  display: flex; flex-direction: column;
  padding: 80px;
  -webkit-font-smoothing: antialiased;
}
header { display: flex; align-items: center; justify-content: space-between; flex-shrink: 0; }
.logo { display: flex; align-items: center; gap: 12px; }
.logo-icon {
  width: 44px; height: 44px; background: var(--destaque); border-radius: 11px;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.logo-text { font-size: 24px; font-weight: 700; color: var(--escura); letter-spacing: -0.02em; }
.counter { font-size: 22px; font-weight: 500; color: #6B7280; }
.main { flex: 1; display: flex; flex-direction: column; justify-content: center; }
.eyebrow {
  font-size: 22px; font-weight: 600; color: var(--destaque);
  text-transform: uppercase; letter-spacing: 0.07em; margin-bottom: 20px;
}
h1 {
  font-size: 60px; font-weight: 700; color: var(--escura);
  line-height: 1.1; letter-spacing: -0.025em; margin-bottom: 48px;
}
.list { display: flex; flex-direction: column; gap: 16px; }
.list-item {
  display: flex; align-items: flex-start; gap: 20px;
  padding: 24px 28px; border-radius: 14px; border: 1.5px solid transparent;
}
.list-item.highlight { background: var(--destaque-wash); border-color: var(--destaque); }
.bullet { width: 10px; height: 10px; background: var(--destaque); border-radius: 50%; margin-top: 12px; flex-shrink: 0; }
.item-label { font-size: 17px; font-weight: 700; color: var(--destaque); text-transform: uppercase; letter-spacing: 0.04em; margin-bottom: 4px; }
.item-text { font-size: 30px; font-weight: 500; color: var(--escura); line-height: 1.45; }
.item-text strong { font-weight: 700; color: var(--destaque); }
.progress-bar { height: 4px; background: #E2E8F0; border-radius: 2px; overflow: hidden; width: 920px; flex-shrink: 0; }
.progress-fill { height: 100%; background: var(--destaque); border-radius: 2px; }
</style>
</head>
<body>
  <header>
    <div class="logo">
      <div class="logo-icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
             fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"/>
        </svg>
      </div>
      <span class="logo-text">[NOME_DA_MARCA]</span>
    </div>
    <span class="counter">[N] / [TOTAL]</span>
  </header>

  <div class="main">
    <!-- Eyebrow: âncora de navegação — "Passo 1", "Erro #2", "Pilar #3" -->
    <p class="eyebrow">[EYEBROW — âncora de navegação, opcional]</p>
    <h1>[TÍTULO DO SLIDE — entrega o ponto principal]</h1>
    <div class="list">
      <div class="list-item">
        <div class="bullet"></div>
        <div>
          <p class="item-label">[LABEL OPCIONAL]</p>
          <p class="item-text">[texto do item 1]</p>
        </div>
      </div>
      <div class="list-item">
        <div class="bullet"></div>
        <div>
          <p class="item-label">[LABEL OPCIONAL]</p>
          <p class="item-text">[texto do item 2]</p>
        </div>
      </div>
      <!-- Item em destaque — usar .highlight no item mais importante -->
      <div class="list-item highlight">
        <div class="bullet"></div>
        <div>
          <p class="item-label">[LABEL OPCIONAL]</p>
          <p class="item-text">[texto do item 3 — destaque]</p>
        </div>
      </div>
    </div>
  </div>

  <div class="progress-bar">
    <div class="progress-fill" style="width: [LARGURA]px;"></div>
  </div>
</body>
</html>
```

---

### Template: Tipo 2b — Lista com Setas (variante narrativa)

Usar para: listas de resultados, features ou tópicos com frases completas. Até 5 itens curtos ou 3 itens de 2 linhas.

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<!--FONTE-INTER-INLINE-->  <!-- render.py injeta @font-face base64 aqui (a rede do sandbox bloqueia Google Fonts) -->
<style>
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
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { width: 1080px; height: 1350px; overflow: hidden; }
body {
  font-family: 'Inter', -apple-system, sans-serif;
  background: var(--surface);   /* ou var(--clara) — alternar; nunca 3 iguais seguidos */
  display: flex; flex-direction: column;
  padding: 80px;
  -webkit-font-smoothing: antialiased;
}
header { display: flex; align-items: center; justify-content: space-between; flex-shrink: 0; }
.logo { display: flex; align-items: center; gap: 12px; }
.logo-icon {
  width: 44px; height: 44px; background: var(--destaque); border-radius: 11px;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.logo-text { font-size: 24px; font-weight: 700; color: var(--escura); letter-spacing: -0.02em; }
.counter { font-size: 22px; font-weight: 500; color: #6B7280; }
.main { flex: 1; display: flex; flex-direction: column; justify-content: center; }
.eyebrow {
  font-size: 22px; font-weight: 600; color: var(--destaque);
  text-transform: uppercase; letter-spacing: 0.07em; margin-bottom: 20px;
}
h1 {
  font-size: 60px; font-weight: 700; color: var(--escura);
  line-height: 1.1; letter-spacing: -0.025em; margin-bottom: 44px;
}
.arrow-list { display: flex; flex-direction: column; gap: 20px; }
.arrow-item { display: flex; align-items: flex-start; gap: 18px; }
.arrow { font-size: 30px; font-weight: 700; color: var(--destaque); line-height: 1.45; flex-shrink: 0; }
.arrow-text { font-size: 30px; font-weight: 500; color: var(--escura); line-height: 1.45; }
.progress-bar { height: 4px; background: #E2E8F0; border-radius: 2px; overflow: hidden; width: 920px; flex-shrink: 0; }
.progress-fill { height: 100%; background: var(--destaque); border-radius: 2px; }
</style>
</head>
<body>
  <header>
    <div class="logo">
      <div class="logo-icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
             fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"/>
        </svg>
      </div>
      <span class="logo-text">[NOME_DA_MARCA]</span>
    </div>
    <span class="counter">[N] / [TOTAL]</span>
  </header>

  <div class="main">
    <p class="eyebrow">[EYEBROW — âncora de navegação, opcional]</p>
    <h1>[TÍTULO DO SLIDE]</h1>
    <div class="arrow-list">
      <div class="arrow-item">
        <span class="arrow">→</span>
        <p class="arrow-text">[texto do item 1]</p>
      </div>
      <div class="arrow-item">
        <span class="arrow">→</span>
        <p class="arrow-text">[texto do item 2]</p>
      </div>
      <div class="arrow-item">
        <span class="arrow">→</span>
        <p class="arrow-text">[texto do item 3]</p>
      </div>
      <!-- Máximo 5 se curtos (1 linha cada) / 3 se 2 linhas por item -->
    </div>
  </div>

  <div class="progress-bar">
    <div class="progress-fill" style="width: [LARGURA]px;"></div>
  </div>
</body>
</html>
```

---

### Template: Tipo 3 — Citação de Pessoa Identificada

Usar **apenas** para fala literal de pessoa real com nome e cargo/empresa. Nunca para afirmações do autor.

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<!--FONTE-INTER-INLINE-->  <!-- render.py injeta @font-face base64 aqui (a rede do sandbox bloqueia Google Fonts) -->
<style>
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
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { width: 1080px; height: 1350px; overflow: hidden; }
body {
  font-family: 'Inter', -apple-system, sans-serif;
  background: var(--clara);
  display: flex; flex-direction: column;
  padding: 80px;
  -webkit-font-smoothing: antialiased;
}
header { display: flex; align-items: center; justify-content: space-between; flex-shrink: 0; }
.logo { display: flex; align-items: center; gap: 12px; }
.logo-icon {
  width: 44px; height: 44px; background: var(--destaque); border-radius: 11px;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.logo-text { font-size: 24px; font-weight: 700; color: var(--escura); letter-spacing: -0.02em; }
.counter { font-size: 22px; font-weight: 500; color: #6B7280; }
.main { flex: 1; display: flex; flex-direction: column; justify-content: center; }
.eyebrow {
  font-size: 22px; font-weight: 600; color: var(--destaque);
  text-transform: uppercase; letter-spacing: 0.07em; margin-bottom: 28px;
}
.quote-mark { font-family: Georgia, serif; font-size: 140px; color: var(--destaque); line-height: 1; margin-bottom: 8px; }
.quote-text {
  font-size: 50px; font-weight: 600; color: var(--escura);
  line-height: 1.3; margin-bottom: 36px;
}
.divider { width: 70px; height: 4px; background: var(--destaque); border-radius: 2px; margin-bottom: 24px; }
.attribution { font-size: 26px; font-weight: 500; color: #6B7280; }
.progress-bar { height: 4px; background: #E2E8F0; border-radius: 2px; overflow: hidden; width: 920px; flex-shrink: 0; }
.progress-fill { height: 100%; background: var(--destaque); border-radius: 2px; }
</style>
</head>
<body>
  <header>
    <div class="logo">
      <div class="logo-icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
             fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"/>
        </svg>
      </div>
      <span class="logo-text">[NOME_DA_MARCA]</span>
    </div>
    <span class="counter">[N] / [TOTAL]</span>
  </header>

  <div class="main">
    <p class="eyebrow">[EYEBROW — ex: "O que ele disse"]</p>
    <div class="quote-mark">"</div>
    <p class="quote-text">[FALA LITERAL DA PESSOA — verbatim, não parafrasear]</p>
    <div class="divider"></div>
    <p class="attribution">[Nome] — [Cargo], [Empresa]</p>
  </div>

  <div class="progress-bar">
    <div class="progress-fill" style="width: [LARGURA]px;"></div>
  </div>
</body>
</html>
```

---

### Template: Tipo 4 — Dados e Métricas

Usar para cases de resultado, benchmarks, números do produto. Grid 2×2 de cards.

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<!--FONTE-INTER-INLINE-->  <!-- render.py injeta @font-face base64 aqui (a rede do sandbox bloqueia Google Fonts) -->
<style>
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
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { width: 1080px; height: 1350px; overflow: hidden; }
body {
  font-family: 'Inter', -apple-system, sans-serif;
  background: var(--surface);   /* ou var(--clara) — alternar; nunca 3 iguais seguidos */
  display: flex; flex-direction: column;
  padding: 80px;
  -webkit-font-smoothing: antialiased;
}
header { display: flex; align-items: center; justify-content: space-between; flex-shrink: 0; }
.logo { display: flex; align-items: center; gap: 12px; }
.logo-icon {
  width: 44px; height: 44px; background: var(--destaque); border-radius: 11px;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.logo-text { font-size: 24px; font-weight: 700; color: var(--escura); letter-spacing: -0.02em; }
.counter { font-size: 22px; font-weight: 500; color: #6B7280; }
.main { flex: 1; display: flex; flex-direction: column; justify-content: center; }
.eyebrow {
  font-size: 22px; font-weight: 600; color: var(--destaque);
  text-transform: uppercase; letter-spacing: 0.07em; margin-bottom: 20px;
}
h1 {
  font-size: 58px; font-weight: 700; color: var(--escura);
  line-height: 1.1; letter-spacing: -0.025em; margin-bottom: 44px;
}
.metrics-grid {
  display: grid; grid-template-columns: 1fr 1fr; gap: 20px;
}
.metric-card {
  background: var(--clara); border: 1.5px solid #E2E8F0; border-radius: 16px;
  padding: 32px 28px;
}
.metric-card.highlight { background: var(--destaque); border-color: var(--destaque); }
.metric-label { font-size: 22px; font-weight: 500; color: #6B7280; margin-bottom: 12px; }
.metric-card.highlight .metric-label { color: rgba(255,255,255,0.7); }
.metric-value {
  font-size: 80px; font-weight: 700; color: var(--escura);
  letter-spacing: -0.03em; line-height: 1;
}
.metric-card.highlight .metric-value { color: #FFFFFF; }
.metric-unit { font-size: 26px; font-weight: 500; color: #6B7280; margin-top: 8px; }
.metric-card.highlight .metric-unit { color: rgba(255,255,255,0.7); }
.metric-badge {
  display: inline-block; margin-top: 12px;
  font-size: 20px; font-weight: 600; color: #16A34A;
  background: #DCFCE7; padding: 4px 12px; border-radius: 9999px;
}
.progress-bar { height: 4px; background: #E2E8F0; border-radius: 2px; overflow: hidden; width: 920px; flex-shrink: 0; }
.progress-fill { height: 100%; background: var(--destaque); border-radius: 2px; }
</style>
</head>
<body>
  <header>
    <div class="logo">
      <div class="logo-icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
             fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"/>
        </svg>
      </div>
      <span class="logo-text">[NOME_DA_MARCA]</span>
    </div>
    <span class="counter">[N] / [TOTAL]</span>
  </header>

  <div class="main">
    <p class="eyebrow">[EYEBROW — ex: "Os Números"]</p>
    <h1>[TÍTULO — contextualiza as métricas]</h1>
    <div class="metrics-grid">
      <div class="metric-card">
        <p class="metric-label">[label da métrica]</p>
        <p class="metric-value">[NÚMERO]</p>
        <p class="metric-unit">[unidade — ex: leads gerados]</p>
        <!-- badge opcional: <span class="metric-badge">+X%</span> -->
      </div>
      <div class="metric-card highlight">
        <!-- card em destaque: fundo na cor de destaque -->
        <p class="metric-label">[label destaque]</p>
        <p class="metric-value">[NÚMERO]</p>
        <p class="metric-unit">[unidade]</p>
      </div>
      <div class="metric-card">
        <p class="metric-label">[label]</p>
        <p class="metric-value">[NÚMERO]</p>
        <p class="metric-unit">[unidade]</p>
      </div>
      <div class="metric-card">
        <p class="metric-label">[label]</p>
        <p class="metric-value">[NÚMERO]</p>
        <p class="metric-unit">[unidade]</p>
      </div>
    </div>
  </div>

  <div class="progress-bar">
    <div class="progress-fill" style="width: [LARGURA]px;"></div>
  </div>
</body>
</html>
```

---

### Template: Tipo 5 — CTA Final

**Sempre o último slide.** Fundo na cor de **destaque**. Logo invertido (ícone/logo sobre fundo branco). Domínio do cliente no rodapé.

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<!--FONTE-INTER-INLINE-->  <!-- render.py injeta @font-face base64 aqui (a rede do sandbox bloqueia Google Fonts) -->
<style>
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
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { width: 1080px; height: 1350px; overflow: hidden; }
body {
  font-family: 'Inter', -apple-system, sans-serif;
  background: var(--destaque);
  display: flex; flex-direction: column;
  padding: 80px;
  -webkit-font-smoothing: antialiased;
}
header { display: flex; align-items: center; justify-content: space-between; flex-shrink: 0; }
.logo { display: flex; align-items: center; gap: 12px; }
.logo-icon {
  width: 48px; height: 48px; background: #FFFFFF; border-radius: 11px;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.logo-text { font-size: 26px; font-weight: 700; color: #FFFFFF; letter-spacing: -0.02em; }
.counter { font-size: 22px; font-weight: 500; color: rgba(255,255,255,0.4); }
.main { flex: 1; display: flex; flex-direction: column; justify-content: center; }
.eyebrow {
  font-size: 22px; font-weight: 600; color: rgba(255,255,255,0.6);
  text-transform: uppercase; letter-spacing: 0.07em; margin-bottom: 24px;
}
h1 {
  font-size: 72px; font-weight: 800; color: #FFFFFF;
  line-height: 1.1; letter-spacing: -0.03em; margin-bottom: 28px;
}
.subtitle { font-size: 30px; font-weight: 400; color: rgba(255,255,255,0.72); line-height: 1.6; margin-bottom: 52px; }
.cta-button {
  display: inline-flex; align-items: center; gap: 10px;
  background: #FFFFFF; color: var(--destaque);
  font-size: 28px; font-weight: 700; letter-spacing: -0.01em;
  padding: 18px 32px; border-radius: 12px;
  width: fit-content;
}
footer {
  display: flex; align-items: center; justify-content: space-between;
  flex-shrink: 0; padding-top: 0;
}
.domain { font-size: 22px; font-weight: 500; color: rgba(255,255,255,0.5); }
.slide-count { font-size: 22px; font-weight: 500; color: rgba(255,255,255,0.5); }
</style>
</head>
<body>
  <header>
    <div class="logo">
      <div class="logo-icon">
        <!-- Ícone/logo com stroke na cor de destaque no CTA (fundo branco) -->
        <svg xmlns="http://www.w3.org/2000/svg" width="26" height="26" viewBox="0 0 24 24"
             fill="none" stroke="var(--destaque)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"/>
        </svg>
      </div>
      <span class="logo-text">[NOME_DA_MARCA]</span>
    </div>
    <span class="counter">[TOTAL] / [TOTAL]</span>
  </header>

  <div class="main">
    <p class="eyebrow">[EYEBROW — ex: "Próximo Passo" ou "Acesso Gratuito"]</p>
    <h1>[TÍTULO DO CTA — pergunta ou afirmação que direciona ação]</h1>
    <p class="subtitle">[SUBTÍTULO — explica o próximo passo em 1-2 linhas]</p>
    <div class="cta-button">→ [TEXTO DO BOTÃO — extraído do post]</div>
  </div>

  <footer>
    <span class="domain">[DOMINIO_DO_CLIENTE]</span>
    <span class="slide-count">[TOTAL] / [TOTAL]</span>
  </footer>
</body>
</html>
```

---

### Template: Tipo 6 — Conteúdo com Imagem (Stacked Interior)

Usar para slides com visual de suporte (screenshot do produto do cliente, print de resultado, mockup). **Imagem é prova, não decoração.** A imagem é um anexo do projeto ou fornecida pelo usuário.

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<!--FONTE-INTER-INLINE-->  <!-- render.py injeta @font-face base64 aqui (a rede do sandbox bloqueia Google Fonts) -->
<style>
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
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { width: 1080px; height: 1350px; overflow: hidden; }
body {
  font-family: 'Inter', -apple-system, sans-serif;
  background: var(--surface);   /* ou var(--clara) — alternar; nunca 3 iguais seguidos */
  display: flex; flex-direction: column;
  padding: 80px;
  -webkit-font-smoothing: antialiased;
}
header { display: flex; align-items: center; justify-content: space-between; flex-shrink: 0; }
.logo { display: flex; align-items: center; gap: 12px; }
.logo-icon {
  width: 44px; height: 44px; background: var(--destaque); border-radius: 11px;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.logo-text { font-size: 24px; font-weight: 700; color: var(--escura); letter-spacing: -0.02em; }
.counter { font-size: 22px; font-weight: 500; color: #6B7280; }
.main { flex: 1; display: flex; flex-direction: column; justify-content: center; }
.eyebrow {
  font-size: 22px; font-weight: 600; color: var(--destaque);
  text-transform: uppercase; letter-spacing: 0.07em; margin-bottom: 20px;
}
h1 {
  font-size: 60px; font-weight: 700; color: var(--escura);
  line-height: 1.1; letter-spacing: -0.025em; margin-bottom: 20px;
}
.body-text { font-size: 30px; font-weight: 500; color: var(--escura); line-height: 1.5; margin-bottom: 28px; }
.image-container {
  width: 92%; flex-shrink: 0;
  border: 1px solid #E2E8F0; border-radius: 14px;
  box-shadow: 0 4px 24px rgba(0,0,0,0.08), 0 1px 6px rgba(0,0,0,0.04);
  overflow: hidden;
  /* altura ~45-55% da área disponível entre header e barra de progresso */
  max-height: 540px;
}
.image-container img { width: 100%; height: 100%; object-fit: cover; display: block; }
.progress-bar { height: 4px; background: #E2E8F0; border-radius: 2px; overflow: hidden; width: 920px; flex-shrink: 0; }
.progress-fill { height: 100%; background: var(--destaque); border-radius: 2px; }
</style>
</head>
<body>
  <header>
    <div class="logo">
      <div class="logo-icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
             fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"/>
        </svg>
      </div>
      <span class="logo-text">[NOME_DA_MARCA]</span>
    </div>
    <span class="counter">[N] / [TOTAL]</span>
  </header>

  <div class="main">
    <p class="eyebrow">[EYEBROW — opcional]</p>
    <h1>[TÍTULO — afirma o ponto que a imagem comprova]</h1>
    <!-- Texto ou lista curta: 1-2 linhas OU 2-3 itens com → -->
    <p class="body-text">[texto curto ou lista 2b inline — max 2 linhas]</p>
    <!-- Imagem: sempre com borda + shadow — NUNCA solta sobre fundo claro -->
    <div class="image-container">
      <img src="[PATH_DA_IMAGEM]" alt="[descrição]">
    </div>
  </div>

  <div class="progress-bar">
    <div class="progress-fill" style="width: [LARGURA]px;"></div>
  </div>
</body>
</html>
```

---

### Template: Tipo 7 — Prova com Screenshot

Usar para depoimentos de WhatsApp, DM, resultado de cliente. **Sem barra de progresso** — exceção única. A imagem é um anexo do projeto ou fornecida pelo usuário.

**Regras de layout:**
- Sem eyebrow — o título ocupa direto o topo de `.main`
- Título sempre centralizado (`text-align: center`)
- `.screenshot-container` é **filho de `.main`** (não sibling do body) — garante que a imagem nunca sobreponha o texto
- `flex: 1` + `min-height: 0` no container → absorve o espaço vertical restante após o título
- `object-fit: cover; object-position: top center` → mostra o topo da conversa, corta o excesso na base
- `margin-bottom: -48px` → bleed visual na borda inferior do slide

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<!--FONTE-INTER-INLINE-->  <!-- render.py injeta @font-face base64 aqui (a rede do sandbox bloqueia Google Fonts) -->
<style>
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
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { width: 1080px; height: 1350px; overflow: hidden; }
body {
  font-family: 'Inter', -apple-system, sans-serif;
  background: var(--surface);   /* ou var(--clara) — alternar; nunca 3 iguais seguidos */
  display: flex; flex-direction: column;
  padding: 80px 80px 0 80px;
  -webkit-font-smoothing: antialiased;
}
header { display: flex; align-items: center; justify-content: space-between; flex-shrink: 0; }
.logo { display: flex; align-items: center; gap: 12px; }
.logo-icon {
  width: 44px; height: 44px; background: var(--destaque); border-radius: 11px;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.logo-text { font-size: 24px; font-weight: 700; color: var(--escura); letter-spacing: -0.02em; }
.counter { font-size: 22px; font-weight: 500; color: #6B7280; }
.main {
  flex: 1; display: flex; flex-direction: column;
  justify-content: flex-start; padding-top: 40px;
}
h1 {
  font-size: 58px; font-weight: 700; color: var(--escura);
  line-height: 1.1; letter-spacing: -0.025em;
  margin-bottom: 32px; text-align: center;
}
.screenshot-container {
  flex: 1;
  min-height: 0;
  width: 76%; align-self: center;
  overflow: hidden;
  border: 1px solid #E2E8F0;
  border-radius: 16px 16px 0 0;
  box-shadow: 0 8px 40px rgba(0,0,0,0.10), 0 2px 8px rgba(0,0,0,0.05);
  margin-bottom: -48px;
}
.screenshot-container img {
  width: 100%; height: 100%;
  display: block;
  object-fit: cover;
  object-position: top center;
}
/* SEM .progress-bar neste template — exceção única do design system */
</style>
</head>
<body>
  <header>
    <div class="logo">
      <div class="logo-icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
             fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"/>
        </svg>
      </div>
      <span class="logo-text">[NOME_DA_MARCA]</span>
    </div>
    <span class="counter">[N] / [TOTAL]</span>
  </header>

  <div class="main">
    <!-- Título narrativo curto, centralizado — sem eyebrow -->
    <!-- ex: "E isso foi o que ele me disse..." / "O resultado depois de 7 dias:" -->
    <h1>[TÍTULO NARRATIVO — 1-2 linhas, tom de storytelling]</h1>
    <!-- Screenshot filho de .main — nunca sobreporá o título -->
    <div class="screenshot-container">
      <img src="[PATH_DA_IMAGEM]" alt="depoimento">
    </div>
  </div>
  <!-- SEM barra de progresso — exceção única -->
</body>
</html>
```

---

## Etapa 5 — Arquivos de suporte

### carrossel-preview.html

Visualização local de todos os slides escalados para revisão. Substituir `[LISTA_DE_SLIDES]` com os iframes dos slides do carrossel.

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<title>Preview — [SLUG DO CARROSSEL]</title>
<style>
body { background: #1a1a2e; padding: 40px; font-family: sans-serif; }
h1 { color: #fff; font-size: 18px; margin-bottom: 24px; opacity: 0.6; }
.slides { display: flex; flex-wrap: wrap; gap: 20px; }
.slide-wrapper {
  position: relative;
  width: 270px; height: 337px;
  border-radius: 8px; overflow: hidden;
  box-shadow: 0 4px 20px rgba(0,0,0,0.4);
}
.slide-wrapper iframe {
  width: 1080px; height: 1350px;
  border: none;
  transform: scale(0.25); transform-origin: 0 0;
  pointer-events: none;
}
.slide-label {
  position: absolute; bottom: 8px; left: 0; right: 0;
  text-align: center; color: rgba(255,255,255,0.5); font-size: 11px;
}
</style>
</head>
<body>
  <h1>Preview — [SLUG DO CARROSSEL]</h1>
  <div class="slides">
    <!-- Repetir para cada slide: -->
    <div class="slide-wrapper">
      <iframe src="slide-01-capa.html"></iframe>
      <div class="slide-label">01 — Capa</div>
    </div>
    <!-- slide-02, slide-03, ..., slide-NN-cta -->
  </div>
</body>
</html>
```

### render.py — script de render (Python + Playwright)

> **Render primário no sandbox do Claude.ai.** Para cada `slide-NN-*.html`, injeta a fonte Inter **inline em base64** (a rede do sandbox bloqueia Google Fonts — ver seção de Fonte), abre a página, espera a fonte aplicar, valida overflow de texto e salva `slide-NN.png` (viewport 1080×1350, `device_scale_factor=2`, screenshot PNG). **Saída = um PNG por slide.** Não gera PDF.

```python
import asyncio, base64, re
from pathlib import Path
from playwright.async_api import async_playwright

HERE = Path(__file__).parent
WEIGHTS = [400, 500, 600, 700, 800]
FONT_DIR = Path("node_modules/@fontsource/inter/files")   # via: npm install @fontsource/inter
# No Claude.ai, salvar em /mnt/user-data/outputs/ deixa os PNGs baixáveis; senão, pasta local.
OUT_DIR = Path("/mnt/user-data/outputs") if Path("/mnt/user-data/outputs").exists() else HERE
MARKER = "<!--FONTE-INTER-INLINE-->"

def build_font_css():
    faces = []
    for w in WEIGHTS:
        f = FONT_DIR / f"inter-latin-{w}-normal.woff2"
        if not f.exists():
            print(f"⚠ fonte ausente: {f} — rode: npm install @fontsource/inter")
            continue
        b64 = base64.b64encode(f.read_bytes()).decode()
        faces.append(
            f"@font-face{{font-family:'Inter';font-style:normal;font-weight:{w};"
            f"font-display:block;src:url(data:font/woff2;base64,{b64}) format('woff2');}}"
        )
    return "<style>\n" + "\n".join(faces) + "\n</style>"

FONT_STYLE = build_font_css()
slides = sorted(p for p in HERE.glob("slide-*.html"))

async def main():
    if not slides:
        print("Nenhum slide-*.html encontrado."); return
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"→ {len(slides)} slides. Saída em: {OUT_DIR}")

    async with async_playwright() as p:
        browser = await p.chromium.launch(args=["--no-sandbox", "--disable-setuid-sandbox"])
        page = await browser.new_page(viewport={"width": 1080, "height": 1350}, device_scale_factor=2)

        for slide in slides:
            html = slide.read_text(encoding="utf-8")
            # injeta a fonte inline (marcador deixado pelo template; senão, logo após <head>)
            if MARKER in html:
                html = html.replace(MARKER, FONT_STYLE)
            else:
                html = re.sub(r"(<head[^>]*>)", r"\1" + FONT_STYLE, html, count=1)
            # grava temporário na MESMA pasta p/ preservar caminhos relativos de imagem (Tipo 6/7)
            tmp = slide.with_name(f"_r_{slide.name}")
            tmp.write_text(html, encoding="utf-8")

            await page.goto(tmp.as_uri(), wait_until="networkidle")
            await page.evaluate("document.fonts.ready")
            await page.wait_for_timeout(300)

            # gate de overflow: reporta blocos marcados com data-check cujo texto estourou
            overflows = await page.evaluate("""() => {
              const bad = [];
              document.querySelectorAll('[data-check]').forEach(el => {
                const ovf = el.scrollHeight - el.clientHeight;
                if (ovf > 2) bad.push({el: el.id || el.className, ovf});
              });
              return bad;
            }""")
            # anti-fallback: confirma que Inter aplicou (não caiu em fonte de sistema)
            inter_ok = await page.evaluate("() => document.fonts.check(\"80px 'Inter'\")")

            m = re.search(r"slide-(\d+)", slide.stem)
            num = m.group(1) if m else slide.stem
            out = OUT_DIR / f"slide-{num}.png"
            if not inter_ok:
                print(f"⚠ {slide.name}: Inter NÃO aplicou — confira o npm install @fontsource/inter.")
            if overflows:
                print(f"⚠ {slide.name}: texto estourou — {overflows}. Ajuste copy/tamanho antes de publicar.")

            await page.screenshot(path=str(out), clip={"x": 0, "y": 0, "width": 1080, "height": 1350})
            tmp.unlink(missing_ok=True)
            print(f"✓ {out.name}")

        await browser.close()
    print("\nDone. Um PNG por slide em:", OUT_DIR)

asyncio.run(main())
```

**Como rodar no sandbox do Claude.ai:**

```bash
python3 -m playwright install chromium     # idempotente — 1x por sessão (Chromium costuma já vir no ambiente)
npm install @fontsource/inter              # fonte via npm; NÃO usar Google Fonts (a rede bloqueia)
python3 render.py
# Se faltar o pacote: pip install --break-system-packages playwright
```

> **Marque com `data-check`** os blocos de título/corpo que precisam caber num espaço fixo — o gate de overflow do `render.py` valida só esses e avisa antes de exportar um slide com texto cortado.

> **Nota de ambiente (crítica):** este passo depende de o sandbox do Claude.ai conseguir rodar Chromium headless (já validado neste ambiente). **Se por algum motivo o Chromium não estiver disponível no ambiente, avisar o usuário em vez de falhar silenciosamente** — entregar os HTMLs + o `render.py` + estas instruções, e explicar que o passo de imagem não pôde rodar aqui.

> **Se as imagens de Tipo 6/7 forem anexos do projeto Claude.ai** com caminhos que o Playwright não resolve via `file://`, embutir as imagens como data URI no HTML antes de renderizar (ler o arquivo, converter para base64 e substituir o `src`), ou colocar as imagens na mesma pasta dos HTMLs.

---

## Checklist antes de entregar

- [ ] `:root` de cada slide preenchido com as 3 cores do cliente (`--destaque`/`--escura`/`--clara` do `brandbook.md`)? (tints derivam sozinhos via `color-mix()`)
- [ ] Wordmark `[NOME_DA_MARCA]` e domínio `[DOMINIO_DO_CLIENTE]` preenchidos com os dados do `brandbook.md`?
- [ ] Se o cliente tem ícone/logo próprio, aplicado? Se não tem, `.logo-icon` removido e só o wordmark presente?
- [ ] Cada slide tem o template correto para o tipo de conteúdo?
- [ ] Nenhum slide tem mais de 3 itens de lista (exceto Tipo 2b que permite até 5 curtos)?
- [ ] Capa tem dot pattern + glow (dark) ou dot pattern (light)?
- [ ] Eyebrow nas capas está em pill (`.eyebrow-pill`), não texto solto?
- [ ] Slides de conteúdo alternam `var(--surface)` e `var(--clara)`? (nunca 3 consecutivos iguais)
- [ ] Barras de progresso calculadas corretamente para cada slide?
- [ ] Tipo 7 não tem barra de progresso?
- [ ] Tipo 7: `.screenshot-container` é filho de `.main` (não sibling do body)?
- [ ] Tipo 7: título centralizado (`text-align: center`) e sem eyebrow?
- [ ] Tipo 7: `object-fit: cover; object-position: top center` na imagem?
- [ ] CTA tem fundo na cor de destaque, logo invertido (ícone com stroke na cor de destaque sobre fundo branco), rodapé com `[DOMINIO_DO_CLIENTE]`?
- [ ] CTA não tem círculos decorativos?
- [ ] Logo/wordmark do cliente em todos os slides (nunca emoji)?
- [ ] Tipo 6 e Tipo 7 têm `src="[PATH_DA_IMAGEM]"` como placeholder explícito?
- [ ] `carrossel-preview.html` lista todos os slides?
- [ ] `render.py` presente e pronto para rodar no sandbox?
- [ ] Um PNG por slide gerado (ou HTMLs + `render.py` + aviso, se o Chromium não rodou)?
- [ ] Hook da capa é fiel ao post — não parafraseado?
- [ ] CTA do último slide é extraído do texto do post — não inventado?

---

## Regras duras de output

- Nunca reescrever ou parafrasear o hook quando o post original foi fornecido
- Nunca usar Tipo 3 para afirmações do autor — apenas para fala literal de pessoa identificada com nome + cargo/empresa
- Nunca misturar sub-componentes de templates diferentes no mesmo slide
- Nunca usar cores fora da paleta do cliente (destaque/escura/clara + tints) + neutros/semânticos universais
- Nunca usar emoji no lugar do logo/ícone do cliente
- Nunca adicionar `deco-circle-*` ou elementos decorativos no slide CTA
- Nunca usar a cor de destaque sólida em título sobre fundo dark se perder contraste — usar gradient ou tint claro do destaque
- Fonte Inter embutida em base64 (`@fontsource`), injetada pelo `render.py` no marcador `<!--FONTE-INTER-INLINE-->`. Nunca Google Fonts por URL nem `@import`.
- Saída final = **um PNG por slide** — nunca montar PDF
- Sempre confirmar a narrativa (Etapa A aprovada) antes de gerar os HTMLs
