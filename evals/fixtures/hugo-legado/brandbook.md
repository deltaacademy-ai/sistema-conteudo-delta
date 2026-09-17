# Brandbook — Hugo Doria

> **Como preencher:** este arquivo é consumido pela skill **Davinci** (geração de carrosséis). A maior parte das regras de design (templates, hierarquia, layouts) já estão dentro da skill. Aqui você define **apenas o que muda entre clientes**: cores, tipografia (se for o caso) e regras visuais críticas.

**Última atualização:** 2026-09-17

---

## 1. Cores (obrigatório)

> Defina as 3 cores em hexadecimal. A skill Davinci usa essas cores nos templates de carrossel.

| Função | Hex | Uso típico |
|---|---|---|
| **Cor clara** | `#f1eec8` | Fundos, espaços negativos, áreas de respiração |
| **Cor escura** | `#101010` | Texto principal, títulos, blocos de ênfase |
| **Cor de destaque** | `#f3a46c` | Números, palavras-chave, CTAs, elementos de impacto |

> Substitua os hex acima pelas cores do cliente. **Não use nomes de cor** (ex: "azul"). Sempre hex.

**Critérios para escolha das cores:**
- Cor clara: alto contraste com a cor escura (idealmente branco ou off-white claro)
- Cor escura: legível sobre a cor clara (preto, grafite, navy escuro)
- Cor de destaque: vibrante, contrastante com as duas anteriores, não satura nem cansa o olho em uso pontual

> Fonte: identidade Atlas do @hdoria (`marca.md`). Na identidade original, `#101010` é o fundo escuro.

---

## 2. Tipografia (opcional)

> Se o cliente tem fonte de marca definida, listar abaixo. **Se não tiver, deixar em branco** — a skill Davinci usa fontes default seguras.

**Fonte para títulos:** Cal Sans
**Fonte para corpo:** DM Sans
**Observações:** Rótulos e código: JetBrains Mono.

---

## 3. Logo / assinatura visual (opcional)

> Se o cliente quer a marca em algum slide do carrossel.

**Posição preferida:**
**Arquivo:**
**Observação:** Identificação da marca: @hdoria (Instagram) e hdoria.me. Nenhum arquivo de logo foi fornecido.

---

## 4. Don'ts visuais

> Regras de proibição que a skill Davinci precisa respeitar para esse cliente.

- Nunca usar a identidade visual da Popcode: conteúdo do @hdoria sai sempre na identidade Atlas
- Capa do carrossel é imagem estática; vídeo só do slide 2 em diante

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
