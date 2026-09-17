# Brandbook — [Nome do cliente]

> **Como preencher:** este arquivo é consumido pela skill **Davinci** (geração de carrosséis). A maior parte das regras de design (templates, hierarquia, layouts) já estão dentro da skill. Aqui você define **apenas o que muda entre clientes**: cores, tipografia (se for o caso) e regras visuais críticas.

**Última atualização:** [AAAA-MM-DD]

---

## 1. Cores (obrigatório)

> Defina as 3 cores em hexadecimal. A skill Davinci usa essas cores nos templates de carrossel.

| Função | Hex | Uso típico |
|---|---|---|
| **Cor clara** | `#FFFFFF` | Fundos, espaços negativos, áreas de respiração |
| **Cor escura** | `#000000` | Texto principal, títulos, blocos de ênfase |
| **Cor de destaque** | `#FF0000` | Números, palavras-chave, CTAs, elementos de impacto |

> Substitua os hex acima pelas cores do cliente. **Não use nomes de cor** (ex: "azul"). Sempre hex.

**Critérios para escolha das cores:**
- Cor clara: alto contraste com a cor escura (idealmente branco ou off-white claro)
- Cor escura: legível sobre a cor clara (preto, grafite, navy escuro)
- Cor de destaque: vibrante, contrastante com as duas anteriores, não satura nem cansa o olho em uso pontual

---

## 2. Tipografia (opcional)

> Se o cliente tem fonte de marca definida, listar abaixo. **Se não tiver, deixar em branco** — a skill Davinci usa fontes default seguras.

**Fonte para títulos:** [Ex: "Inter Bold" / deixar em branco se não tiver]
**Fonte para corpo:** [Ex: "Inter Regular" / deixar em branco se não tiver]
**Observações:** [Ex: "fonte só está disponível em assinatura X, fallback é Y"]

---

## 3. Logo / assinatura visual (opcional)

> Se o cliente quer a marca em algum slide do carrossel.

**Posição preferida:** [Ex: rodapé do slide 1 e do último slide / só no último]
**Arquivo:** [Nome do arquivo PNG/SVG anexado ao projeto — ex: `logo-cliente.png`]
**Observação:** [Ex: "usar versão branca em fundo escuro"]

---

## 4. Don'ts visuais

> Regras de proibição que a skill Davinci precisa respeitar para esse cliente.

- [Ex: "Nunca usar amarelo neon"]
- [Ex: "Evitar mais de 2 cores no mesmo slide"]
- [Ex: "Não usar gradientes"]
- [Ex: "Não usar imagens stock — só ilustrações geométricas"]

---

## Do / Don't (preenchimento)

**Faça:**
- ✅ Use sempre hexadecimal completo (`#1A2B3C`, não `#abc`)
- ✅ Teste contraste das cores antes (escura sobre clara precisa ser legível)
- ✅ Se cliente não tem brandbook formal, escolha 3 cores **representativas** (do site, do logo, da identidade existente)

**Não faça:**
- ❌ Mais de 3 cores principais — a skill Davinci foi feita pra paleta de 3
- ❌ Cores muito próximas em luminosidade (cor escura e destaque ambas escuras = sem contraste)
- ❌ Inventar regras de design não previstas na skill (layouts custom, hierarquia diferente)
- ❌ Deixar `[#FFFFFF]` placeholder se não preencher de verdade (a skill vai parar e pedir)
