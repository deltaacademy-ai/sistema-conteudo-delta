# Etapa A — Calibração do Mix e Sugestão de Calendário

Esta é a primeira etapa do Kotler. Recebe os 7 inputs validados e entrega 2-3 sugestões de calendário macro para aprovação do usuário. Não gera headlines nem briefings — só o mapa estrutural da semana.

---

## 1. Classificação de funil por tipo de post

Convenção usada em toda saída do Kotler:

| Etapa | Marcador | Tipos de post |
|---|---|---|
| Topo de funil | [Topo] | LM de isca · Educativo (tema/dor de iniciante) |
| Meio de funil | [Meio] | Case · Bastidor · Educativo (tema/dor avançada) |
| Fundo de funil | [Fundo] | LM de intenção/demo · Oferta direta |

Opinião fica fora do mix padrão. Só entra com pedido explícito do usuário no direcionamento da semana.

### Sub-tipos de Lead Magnet

**LM de isca ([Topo]):** material rico gratuito — ebook, aula, planilha, diagnóstico, agente de IA. Objetivo: expansão de rede, captação de leads frios, geração de MQL.

**LM de intenção ([Fundo]):** demo do produto, trial, comparação de ferramentas, calculadora de ROI. Objetivo: conversão de quem já está consciente da dor.

A classificação de cada LM (isca ou intenção) está fixada na tabela do `lead-magnets.md` do projeto — consultar antes de alocar qualquer LM no calendário. Não inferir o tipo a partir do nome — usar o que o arquivo declara.

---

## 2. Mix default da semana

Estrutura base por perfil quando o perfil da semana é `equilibrada`:

| Tipo | % do mix por perfil | Etapa do funil |
|---|---|---|
| LM isca | 40% | [Topo] |
| LM intenção | 20% | [Fundo] |
| Case | 20% | [Meio] |
| Educativo / Bastidor | 20% | [Topo] ou [Meio] conforme tema |

**Aplicação por número de perfis:**

- **1 perfil × 5 posts** (caso mais comum): 2 LM isca + 1 LM intenção + 1 Case + 1 Educativo/Bastidor
- **2 perfis × 5 posts = 10 posts:** 4 LM isca + 2 LM intenção + 2 Case + 2 Educativo/Bastidor
- **3 perfis × 5 posts = 15 posts:** 6 LM isca + 3 LM intenção + 3 Case + 3 Educativo/Bastidor
- **N perfis × M posts:** aplicar proporção ao total (round half up)

### Ajustes por perfil da semana

- `expansão`: mais peso em [Topo] — educativos como iniciantes, iscas reforçadas se base de iscas for baixa
- `conversão`: mais peso em [Meio] e [Fundo] — educativos avançados, case pode ocupar 1 slot extra
- `equilibrada`: mix default acima

### Proporção de funil esperada

- Cenário balanceado (default): [Topo] 47% · [Meio] 33% · [Fundo] 20%
- Semana de expansão: [Topo] 53% · [Meio] 27% · [Fundo] 20%
- Semana de conversão: [Topo] 40% · [Meio] 40% · [Fundo] 20%

Mixes menores (3 posts/semana, 2 posts/semana) ou configurações atípicas (calendário mensal): perguntar ao usuário como distribuir antes de sugerir.

---

## 3. Hierarquia por dia da semana

Padrão de referência para semana de 5 posts/perfil com perfil `equilibrada`. É **referência, não regra fixa** — a distribuição real emerge do mix + anti-colisão.

- **Segunda:** peso em [Topo] — LM isca ou educativo iniciante
- **Terça:** transição — combinar [Topo], [Meio] e [Fundo] entre os perfis
- **Quarta:** meio da semana — [Meio] (case, bastidor) ou [Fundo] para quem veio das segundas/terças
- **Quinta:** reativação de [Topo] — novas iscas, novo ciclo de captação
- **Sexta:** fechamento — [Meio] ou educativo puxando aprendizado da semana

**Regra de progressão:** pontos [Fundo] de cada perfil devem vir depois de ao menos um ponto [Topo] ou [Meio] do mesmo perfil na semana.

**Quando há apenas 1 perfil:** a sequência segunda→sexta naturalmente cobre topo→meio→fundo. Sequência típica:
- Seg: LM isca · Ter: Educativo · Qua: Case · Qui: LM isca · Sex: LM intenção

---

## 4. Regras de anti-colisão entre perfis

Os posts da semana são um bloco complementar do mesmo cliente, publicado em N vozes diferentes. As regras abaixo garantem que não soem redundantes.

**⚠️ Quando o cliente opera com apenas 1 perfil**, as regras 1, 2, 3 e 7 ficam inativas (não há "entre perfis" para validar). Regras 4, 5, 6 seguem ativas.

### Regras duras (rejeitar calendário que viole qualquer uma)

1. **Mesmo dia, iscas diferentes entre perfis.** Se dois ou mais perfis fazem LM isca no mesmo dia, as iscas têm que ser distintas.
2. **Mesmo dia, cases diferentes entre perfis.** Se dois perfis fazem case no mesmo dia, são cases distintos.
3. **Mesmo dia, pilar temático diferente entre perfis.** Os perfis não atacam o mesmo pilar/dor no mesmo dia, mesmo com tipos distintos.
4. **Mesmo perfil, tipos consecutivos diferentes.** Nenhum perfil faz 2 dias seguidos do mesmo tipo.
5. **Cases recorrentes variam dimensão.** Se o mesmo case aparece 2x na semana, cada post explora uma dimensão diferente (receita vs. tempo vs. eficiência vs. velocidade).
6. **Educativos recorrentes variam formato.** Os educativos da semana nunca repetem formato entre si (lista, passo a passo, erro comum, framework, comparação).
7. **Cases da semana são distintos.** Um por perfil quando há cases suficientes disponíveis. Se há menos cases que slots, o caso que repete usa ângulos diferentes nos posts.

### Regras moles (alertar mas não rejeitar)

8. **Reuso de iscas entre semanas:** permitido se a base de iscas ativas for baixa, desde que o ângulo mude entre os posts. Alertar quando detectar reuso.
9. **Distribuição de funil fora da faixa esperada** para o perfil da semana deve ser justificada no output.
10. **Cada perfil com ao menos 3 tipos distintos na semana** — para não virar monotema.

---

## 5. Formato de output das sugestões

Entregar **2-3 sugestões numeradas** ("Sugestão 1", "Sugestão 2", "Sugestão 3"). Cada sugestão:

Tabela com dias como colunas e perfis como linhas. Cada célula contém só:

```
[Topo/Meio/Fundo] Tipo · pilar em 3-5 palavras
```

Abaixo de cada sugestão, **3 linhas de resumo obrigatórias**:
- Distribuição de funil calculada: [Topo] X% · [Meio] Y% · [Fundo] Z%
- Variação por perfil: quantos tipos distintos cada perfil tem na semana
- Observação (se houver): reuso de isca detectado, desvio de faixa justificado, alerta de base baixa

**Sem briefings nível 3 nesta etapa. Sem headlines nesta etapa. Só o mapa macro.**

---

## 6. Checklist antes de entregar as sugestões

- [ ] Perfil da semana declarado pelo usuário respeitado em todas as sugestões?
- [ ] Mix de tipos bate com o default ou com ajuste conforme perfil da semana?
- [ ] Cada sugestão respeita as 7 regras duras de anti-colisão (ou as ativas, se 1 perfil)?
- [ ] Distribuição de funil calculada e informada abaixo de cada sugestão?
- [ ] Tabela com dias nas colunas e perfis nas linhas?
- [ ] Zero headline nesta etapa?
- [ ] Alertas de reuso ou desvio sinalizados quando aplicável?

Se qualquer item falhar, corrigir antes de entregar.
