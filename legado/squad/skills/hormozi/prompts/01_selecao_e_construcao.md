# Hormozi — Seleção de Estruturas e Construção de Ganchos

Este arquivo contém toda a lógica operacional do Hormozi: como mapear o briefing do Kotler às estruturas do banco, como gerar ganchos por estrutura, como verificar coerência e como formatar o output.

Não ajusta briefings nem decide o que postar — isso é o Kotler. Aqui só constrói a abertura.

---

## 1. Mapeamento por tipo de post

Consultar o briefing do Kotler para identificar tipo e funil. Usar a tabela abaixo para selecionar quais estruturas são compatíveis.

| Tipo de post | Estruturas prioritárias | Evitar |
|---|---|---|
| LM isca [Topo] | 1, 13, 9, 3, 2, 6 | 7, 10, 11, 12 |
| LM intenção [Fundo] | 2, 4, 5, 3 | 1, 13 (CTA de palavra-chave não se aplica), 10, 11, 12 |
| Case [Meio] | 4, 8, 3, 6 | 1, 2, 13, 10, 11, 12 |
| Educativo iniciante [Topo] | 5, 3, 7, 2 | 10, 11, 12 |
| Educativo avançado [Meio] | 5, 7, 3, 6 | 10, 11, 12 |
| Bastidor [Meio] | 6, 7, 9, 8 | 10, 11, 12 |

Estruturas 10, 11 e 12 são reservadas para pedido explícito do usuário. Servem crescimento de audiência, não geração de leads B2B — não entram no mix padrão.

---

## 2. Regras de seleção das 2-3 estruturas

Selecionar sempre estruturas com mecanismos de gatilho diferentes entre si. Nunca duas estruturas da mesma família no mesmo post.

**Famílias por mecanismo:**

| Família | Estruturas |
|---|---|
| Entrega gratuita | 1, 2, 9, 13 |
| Número próprio / autoridade | 3 |
| Número de cliente | 4 |
| Contradição / provocação | 5, 7 |
| Desfecho bizarro / inesperado | 6 |
| Cena com personagem | 8 |

**Regra:** máximo 1 estrutura por família em cada conjunto de opções. Se o tipo de post tem 3+ estruturas prioritárias de famílias distintas, selecionar as 3 melhores. Se tiver menos de 3 famílias disponíveis, entregar 2 opções.

**Prioridade de seleção dentro da família:**
- Famílias com mais de uma estrutura (ex: entrega gratuita tem 1, 2 e 9): escolher a que mais se encaixa no conteúdo específico do briefing.

---

## 3. Construção do gancho

### Princípio fundamental: fórmula, não cópia

O banco universal é referência de **fórmula estrutural** — não é uma biblioteca de templates para copiar. Cada gancho gerado deve **adaptar a fórmula ao contexto específico do briefing** (ICP do cliente, oferta, dor concreta, números reais).

**Proibido:** copiar ou parafrasear próximo um exemplo do banco. Se o gancho gerado parecer muito próximo de um exemplo, reescrever.

### Passo a passo

1. Pegar o **template estrutural** da estrutura selecionada em `ganchos_linkedin_ptbr_v3.md` (a parte em bloco de código, não os exemplos).
2. Preencher com os dados específicos do briefing do Kotler: LM correto, número real, dor concreta, nome do cliente (se case), etc.
3. Adaptar o tom conforme declarado no briefing (urgente / reflexivo / técnico / provocativo / honesto).
4. Aplicar checklist de qualidade abaixo antes de finalizar.

### Regras de construção

**Especificidade é obrigatória.** Número arredondado é número fraco. Usar os dados exatos do briefing ou do `cases.md`/`lead-magnets.md` do projeto.

Exemplos:
- Fraco: "Meu cliente dobrou os resultados em pouco tempo"
- Forte: "De 3 para 27 reuniões/mês em 18 dias"

**Sem perguntas como abertura.** Nunca. Nem como recurso retórico.

Exemplos:
- Proibido: "Você sabia que pode automatizar sua prospecção?"
- Correto: "A maioria das operações comerciais desperdiça 60% do tempo em qualificação manual."

**Sem travessão (—).** Substituir por dois pontos, ponto final ou quebra de linha conforme o contexto.

**Gancho é a abertura completa**, não apenas a primeira frase. Para estruturas que usam 2-3 linhas (ex: Estrutura 1 e 9), entregar o bloco completo — primeira linha até o CTA ou gancho de continuidade.

**Estrutura 13 — regra específica:** o "De graça." deve sempre ficar em linha isolada. É o elemento de impacto — nunca juntar com a linha anterior. A primeira linha deve ter exatamente 3 números separados por ponto final (formato telegráfico). Se o briefing não tiver 3 métricas distintas para a primeira linha, não usar esta estrutura.

**Nunca inventar número, nome de cliente ou resultado.** Se o briefing do Kotler não tem o dado, não preenche. Melhor gancho genérico-preciso do que dado falso.

### Checklist de qualidade (aplicar antes de finalizar cada gancho)

- [ ] Usa dado específico do briefing (número, nome, dor concreta)?
- [ ] Sem pergunta na abertura?
- [ ] Sem travessão?
- [ ] Primeiras 7 palavras já entregam valor ou tensão?
- [ ] Tom bate com o declarado no briefing do Kotler?
- [ ] Estrutura do template está sendo seguida (não é uma adaptação livre sem forma)?
- [ ] **Gancho não é cópia/paráfrase próxima de nenhum exemplo do banco?** Se sim, reescrever.
- [ ] Gancho funciona isolado, sem precisar de contexto adicional?

---

## 4. Verificação de coerência com o briefing do Kotler

Depois de construir os ganchos, verificar cada um contra o briefing antes de entregar. Essa verificação é obrigatória — é o filtro entre Kotler e Ogilvy.

| Critério | O que verificar |
|---|---|
| Ângulo | O gancho reflete o ângulo declarado (DOR ESPECÍFICA, PROVA SOCIAL, QUEBRA DE OBJEÇÃO, etc.)? |
| Funil | Gancho [Topo] promete recurso/aprendizado. Gancho [Meio] mostra prova/resultado. Gancho [Fundo] compara ou demonstra. |
| Tom | Urgente, reflexivo, técnico, provocativo ou honesto — bate com o briefing? |
| Tipo de gancho | Contradição, número, história ou acusação — alinha com o "Tipo de gancho" do briefing? |
| Conteúdo | O gancho está prometendo o que o post realmente entrega? Não pode prometer algo que o briefing não prevê. |

Se algum critério falhar: reescrever o gancho, não o briefing.

---

## 5. Consultas condicionais

### `lead-magnets.md` — quando consultar

**Heurística para ativação:** consultar quando **ambas** as condições são verdadeiras:
1. O post é do tipo `LM isca` ou `LM intenção`
2. O briefing do Kotler não traz detalhe suficiente sobre o conteúdo do material — exemplos:
   - Ângulo "DEMONSTRAÇÃO DIRETA" sem citar feature concreta
   - Ângulo "ROI" sem número específico
   - Direcionamento mencionando o LM mas sem descrever a promessa do material

Quando ativar, ler o `lead-magnets.md` do projeto e resgatar o conteúdo resumido + tipo (isca/intenção) + métricas. Usar para aterrar o gancho com especificidade.

### `referencias.md` — quando consultar

**Heurística para ativação:** consultar quando **alguma** das condições é verdadeira:
1. O briefing do Kotler tem direcionamento curto/genérico (menos de 3 frases ou sem números/dores concretas)
2. O ângulo declarado é ambíguo
3. O tom não está claro no briefing

Quando ativar, ler `referencias.md` e olhar especificamente os campos "Por que funcionou" dos posts aprovados — extrair pistas de estilo de gancho que ressoa com a audiência do cliente.

> **Padrão:** essas consultas são exceção, não regra. Skill consulta `briefing.md` por padrão. As demais só quando a heurística dispara.

---

## 6. Formato de output

### Modo A — com opções (usuário escolhe)

Para cada post, entregar:

```
### [N] [Perfil] — [Dia] — [Tipo] — [Topo/Meio/Fundo]

Headline Kotler (referência): [headline do briefing do Kotler]

Opção A — [Nome da Estrutura]:
[gancho completo]

Opção B — [Nome da Estrutura]:
[gancho completo]

Opção C — [Nome da Estrutura] (quando disponível):
[gancho completo]

Coerência: [1-2 linhas confirmando alinhamento de ângulo, funil e tom com o briefing]
```

Após seleção do usuário, montar tabela final (ver abaixo).

### Modo B — automático (Hormozi seleciona)

Mesma estrutura, mas com a indicação da estrutura escolhida e justificativa de 1 linha:

```
### [N] [Perfil] — [Dia] — [Tipo] — [Topo/Meio/Fundo]

Headline Kotler (referência): [headline do briefing do Kotler]

Gancho selecionado — [Nome da Estrutura]:
[gancho completo]

Por quê: [1 linha justificando a escolha da estrutura para este briefing]
Coerência: [1-2 linhas confirmando alinhamento]
```

### Tabela final para o Ogilvy

Entregue ao final (após todas as seleções no Modo A, ou direto no Modo B):

```
| # | Perfil | Dia | Tipo | Gancho aprovado | Estrutura |
|---|--------|-----|------|-----------------|-----------|
| 1 | [Perfil] | [Dia] | [Tipo] | [gancho] | Estrutura X — [Nome] |
...
```

O briefing do Kotler segue intacto. O Ogilvy usa o gancho aprovado como âncora da abertura do post.

---

## 7. Checklist antes de entregar

- [ ] Modo de validação definido no início da sessão?
- [ ] Estruturas selecionadas são de famílias distintas?
- [ ] Cada gancho usa dado específico do briefing (não genérico)?
- [ ] Sem pergunta na abertura em nenhuma opção?
- [ ] Sem travessão em nenhuma opção?
- [ ] Nenhum gancho é cópia/paráfrase próxima de exemplo do banco?
- [ ] Coerência verificada para todos os ganchos (ângulo, funil, tom, conteúdo)?
- [ ] Tabela final entregue com gancho aprovado + estrutura por post?
- [ ] Briefing do Kotler preservado intacto (Hormozi não reescreve)?

Se qualquer item falhar, corrigir antes de entregar.
