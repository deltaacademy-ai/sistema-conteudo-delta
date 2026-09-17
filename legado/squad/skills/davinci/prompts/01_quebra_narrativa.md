# 01 — Quebra Narrativa

Primeira etapa do Da Vinci. Recebe o post completo + brief e entrega um plano de copy slide a slide para aprovação. **Nenhum HTML é gerado nesta etapa.**

O objetivo é garantir que a narrativa do post seja preservada nos slides — não adaptada a um template, mas fragmentada e visualizada mantendo a mesma ordem e lógica do que o Ogilvy construiu.

---

## Princípio central

**O post é a fonte da narrativa. O carrossel é a sua versão visual.**

O Da Vinci não cria uma nova narrativa a partir do post. Ele lê o post, identifica os blocos de conteúdo que já existem, e os distribui em slides mantendo a sequência original. A ordem das ideias no post é a ordem dos slides.

O que o Da Vinci pode fazer ao adaptar o texto para slides:
- Comprimir: resumir um parágrafo em uma frase ou lista curta
- Extrair: pegar o trecho mais forte de um bloco e usá-lo como título ou corpo
- Cortar: remover o que é redundante quando comprimido

O que o Da Vinci **não pode** fazer:
- Reembalar o conteúdo com outra roupagem narrativa
- Criar títulos de slides que não derivam diretamente do texto do post
- Reordenar os blocos de conteúdo
- Inventar uma nova sequência lógica que o post não tem
- **Comprimir blocos de ação/implementação** — se o post descreve os passos que o cliente deu (reestruturou perfil, configurou automação, subiu lead magnet), esses passos merecem espaço próprio no slide. Não condensar em uma única bullet de resumo.

**Teste de fidelidade:** alguém que leu o post deve reconhecer imediatamente o que cada slide está dizendo. Se um título de slide causaria estranheza a quem leu o post, está errado.

---

## Processo de quebra

### Passo 1 — Ler o post integralmente

Antes de qualquer decisão, ler o post do início ao fim. Identificar:

- **O gancho** — primeira linha ou frase de maior impacto que abre o post
- **Os blocos de desenvolvimento** — cada ideia principal separada por quebra de parágrafo ou transição narrativa no post
- **O fechamento** — a conclusão, posicionamento ou CTA final do post

### Passo 2 — Mapear blocos em slides

Cada bloco de desenvolvimento do post vira um slide (ou dois, se o bloco for denso demais para caber num único slide respeitando os limites de texto).

Não existe número fixo de slides intermediários — o número emerge do post. Um post com 3 blocos de desenvolvimento vira 3 slides intermediários. Um post com 5 vira 5. O total de slides pode chegar até 10 — não forçar compressão para ficar num número mais enxuto.

**Fixos:**
- Slide 1 — sempre capa (gancho do post, tradução literal)
- Último slide — sempre CTA (ação final extraída do post)

**Variáveis:**
- Todos os slides do meio — seguem os blocos do post, na ordem do post

### Passo 3 — Definir copy de cada slide

Para cada slide intermediário, definir:

- **Título** — extraído ou comprimido diretamente do bloco correspondente no post. Deve soar como o post, não como um título genérico de apresentação.
- **Corpo** — resumo do bloco em no máximo 3 linhas curtas ou 3 bullets. Se o bloco do post já é curto, usar quase literalmente.
- **Tipo de template sugerido** — com base no conteúdo (lista → Tipo 2b, frase única forte → Tipo 2, depoimento → Tipo 7, etc.)

**Limites de texto por slide:**
- Título: máx 8 palavras — deve ser lido em 2 segundos
- Corpo: máx 3 linhas curtas ou 3 bullets — nunca parágrafos
- Bullets: máx 3 itens (Tipo 2b permite até 5 curtos)
- Se o bloco do post não cabe nesses limites, dividir em dois slides — nunca comprimir até perder o sentido

### Passo 4 — Capa

A capa reproduz o gancho do post o mais literalmente possível.

- O título da capa = a primeira linha do post (ou a frase de maior impacto do gancho)
- O subtítulo = a linha seguinte do gancho, ou uma frase complementar que já está no post
- Não parafrasear, não resumir criativamente, não inventar uma versão "melhorada"
- Pills de contexto (nicho, tipo de conteúdo): derivar do conteúdo do post e do tipo de carrossel

### Passo 5 — Depoimento (cases)

Para carrosséis do tipo Case: verificar se existe imagem de depoimento do cliente **anexada ao projeto Claude.ai** ou **fornecida pelo usuário** (print de WhatsApp, DM, resultado).

- Se existir: incluir slide Tipo 7 obrigatoriamente, posicionado antes da síntese/CTA
- Não perguntar ao usuário se quer incluir — incluir sempre que a imagem existir
- O título do slide Tipo 7 segue o padrão: "Nas palavras de [Nome]." (extraído do case)
- Se não existir imagem: não criar slide de depoimento; registrar a ausência no output (não inventar depoimento)

### Passo 6 — CTA

O CTA do último slide é extraído do fechamento do post.

- Se o post fecha com CTA de palavra-chave (comentar, chamar no DM): reproduzir essa ação
- Se o post fecha com posicionamento: o slide fecha com posicionamento
- Nunca inventar uma ação que não está no post

---

## Referências de padrão por tipo (orientação, não obrigação)

Esses padrões são comuns — mas se o post não segue esse arco, o carrossel também não segue. O post manda.

**Case narrativo** — arco típico:
Capa (resultado) → Cenário anterior → O que mudou → Resultado concreto → [Lição, se o post tiver] → [Depoimento, se houver] → CTA

**Educativo** — arco típico:
Capa (problema ou promessa) → Diagnóstico do erro → O mecanismo ou conceito → Desenvolvimento / pilares → [Síntese, se o post tiver] → CTA

Se o post tem dois blocos de "desenvolvimento" antes de chegar à solução, o carrossel tem dois slides de desenvolvimento. Se o post não tem "lição", o carrossel não tem slide de lição. O padrão acima é apenas um mapa de referência para reconhecer os blocos — não um roteiro a ser seguido.

---

## Formato de output desta etapa

Para cada slide, entregar. No campo **Fundo**, use os nomes dos papéis de cor da marca (definidos no `brandbook.md` e detalhados no sistema de cores do `02_geracao_slides.md`), não hexadecimais fixos:

```
── Slide N — [nome-descritivo] ─────────────────────────────
Tipo sugerido:  [Tipo 1a / 1b / 2 / 2b / 4 / 7 / 5]
Fundo:          [clara (superfície) / clara (fundo) / escura (dark) / destaque (CTA)]

Título:   "[texto exato]"
Corpo:
  → [linha ou bullet 1]
  → [linha ou bullet 2]
  → [linha ou bullet 3]

Origem no post: "[trecho do post do qual esse slide foi extraído]"
```

O campo **Origem no post** é obrigatório — permite ao usuário verificar rapidamente se o slide está fiel ao texto original.

Entregar todos os slides em sequência, depois perguntar:

> "Narrativa aprovada? Algum slide para ajustar antes de partir pro design?"

Só avança para `02_geracao_slides.md` com aprovação explícita.

---

## Regras de ajuste nesta etapa

- Usuário pode mudar texto de qualquer slide sem custo — ainda não há HTML
- Usuário pode adicionar ou remover slides — ajustar os demais se necessário
- Usuário pode mudar o tipo sugerido de um slide — registrar para Etapa B
- Se o usuário pedir uma mudança que implica reordenar blocos do post, sinalizar: a reordenação quebra a fidelidade narrativa. Executar só com confirmação explícita.
- **Não** sugerir mudanças de design aqui — isso é Etapa B

---

## O que vai para a Etapa B

Ao final da aprovação, entregar para `02_geracao_slides.md`:

1. Tabela de copy aprovada (título + corpo exato de cada slide)
2. Tipo de template de cada slide
3. Tipo de capa (dark/light) e composição (A ou B)
4. Slug e data
5. Número total de slides (para cálculo das barras de progresso)
