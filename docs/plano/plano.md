---
type: Note
tags: [conteudo, produto, plano]
created: 2026-09-17
belongs_to:
  - "[[sistema-conteudo]]"
_organized: true
---

# Sistema de Conteúdo: plano de execução até 25/09

> **Para agentes executores:** usar superpowers:subagent-driven-development (recomendado) ou superpowers:executing-plans, tarefa por tarefa. Passos em checkbox (`- [ ]`).

**Objetivo:** entregar à turma fundadora, em 2026-09-25, o plugin `sistema-conteudo` com o núcleo de 9 especialistas (LinkedIn e carrossel de Instagram), validado contra a squad antiga em Sonnet 5 e Opus 5.

**Arquitetura:** plugin do Claude Code num repositório privado. Cada especialista é uma skill em markdown puro que lê a pasta de contexto do comprador; o `motor` só encadeia. Scripts pequenos (checagem de voz, render, avaliação) ficam em `scripts/` e são opcionais para o texto sair.

**Stack:** Claude Code 2.1.273 (`claude -p --model --plugin-dir --output-format json`), Node LTS com Playwright (render), perl (checagem de voz, portátil entre macOS e Linux), jq, git, gh.

**Spec:** docs/plano/spec.md

## Restrições globais

- Todo texto do produto em português do Brasil. Autor: Hugo Doria. Nenhum crédito ou texto de terceiros; do marketing-agi só ideias.
- Zero travessão (U+2014, U+2013) e zero emoji em qualquer arquivo do repositório e em qualquer saída de especialista. Imperativo na forma de "você" (comprima, monte, escolha).
- Nenhum especialista inventa número, caso, depoimento ou nome. Dado ausente vira `[FALTA: descrição]` e a peça é entregue assim.
- Nada essencial depende de hook, comando `/` ou recurso exclusivo do Claude Code. Um especialista entrega o texto mesmo sem rodar script.
- Nada é publicado. `publicar` na versão de 25/09 só gera o pacote (texto, PNGs, PDF, legenda) e instrui o envio manual.
- Modelos: reescrita em `claude-fable-5-1` na sessão principal; execução de casos em `claude-sonnet-5` e `claude-opus-5`; juiz em `claude-opus-5` com contexto limpo.
- Tipos de post: teardown de notícia, caso, build ou bastidor, educativo, posição, lead magnet, anúncio pessoal. Tamanho: abaixo de 900 ou acima de 1.400 caracteres.
- Carrossel: slide 1080x1350, capa estática que nomeia a entrega, máximo 10 slides, fontes locais.
- Portão de cada especialista do núcleo: nos 5 casos, a versão nova empata ou vence a squad antiga nos dois modelos, segundo o juiz. Especialista sem equivalente antigo (`revisor`, `motor`) passa por rubrica própria descrita na tarefa.
- As skills atuais do Hugo (`linkedin-copy`, carrosséis) não são alteradas por este plano.

## Estrutura de arquivos

```
sistema-conteudo/
├── .claude-plugin/plugin.json          manifesto do plugin
├── .claude-plugin/marketplace.json     marketplace de um plugin só
├── README.md                           o que é, instalação, primeiro uso
├── INSTALAR.md                         passo a passo do comprador
├── contexto-modelo/                    pasta de contexto que o comprador copia
│   ├── voz.md  voz-bruta.md  banidas.txt  icp.md  prova.md
│   ├── base-conteudo.md  learnings.md  marca.md  config.md
├── skills/
│   ├── motor/SKILL.md
│   ├── entrevista-voz/SKILL.md  (+ references/perguntas.md, references/compilador.md)
│   ├── contexto-negocio/SKILL.md
│   ├── angulo/SKILL.md          (+ references/tipos-de-post.md)
│   ├── gancho/SKILL.md          (+ references/banco-de-ganchos.md)
│   ├── linkedin-post/SKILL.md   (+ references/tipos-de-post.md é lido de angulo)
│   ├── carrossel-roteiro/SKILL.md
│   ├── carrossel-render/SKILL.md (+ template/slide.html, template/tokens.css)
│   ├── revisor/SKILL.md         (+ references/painel.md)
│   └── publicar/SKILL.md
├── scripts/
│   ├── check-voz.sh                    grep mecânico
│   ├── render-carrossel.mjs            HTML para PNG e PDF
│   └── eval/run-case.sh  eval/judge.sh  eval/judge-prompt.md
├── evals/
│   ├── fixtures/hugo/                  contexto real do Hugo (novo formato)
│   ├── fixtures/hugo-legado/           contrato no formato da squad antiga
│   ├── cases/<especialista>/01.md ... 05.md
│   └── results/                        saídas e veredictos (fora do pacote)
└── legado/squad/                       squad de 2026-07-03 empacotada como plugin, só para baseline
```

A pasta de contexto do comprador é o contrato entre especialistas. Nomes de arquivo acima são fixos em todas as tarefas.

---

## Dia 1 (17/09)

### Tarefa 1: repositório, manifesto e pasta de contexto

**Arquivos:**
- Criar: `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `README.md`, `contexto-modelo/*`, `.gitignore`

**Interfaces:**
- Produz: nomes fixos da pasta de contexto; plugin carregável por `--plugin-dir`.

- [ ] **Passo 1: criar o repositório privado**

```bash
mkdir -p ~/projects/sistema-conteudo && cd ~/projects/sistema-conteudo && git init -b main
gh repo create hdoria/sistema-conteudo --private --source . --remote origin
```

- [ ] **Passo 2: manifesto**

`.claude-plugin/plugin.json`:
```json
{
  "name": "sistema-conteudo",
  "description": "Sistema de conteúdo para gestores e founders B2B: voz, pauta, gancho, post de LinkedIn e carrossel de Instagram, com revisão em contexto limpo.",
  "version": "0.1.0",
  "author": { "name": "Hugo Doria" }
}
```
`.claude-plugin/marketplace.json`:
```json
{
  "name": "sistema-conteudo",
  "owner": { "name": "Hugo Doria" },
  "plugins": [{ "name": "sistema-conteudo", "source": "./", "description": "Sistema de conteúdo @hdoria" }]
}
```

- [ ] **Passo 3: pasta `contexto-modelo/`** com cada arquivo contendo só o cabeçalho e uma linha dizendo qual especialista o preenche: `voz.md` e `voz-bruta.md` e `banidas.txt` (entrevista-voz), `icp.md` e `prova.md` e `marca.md` (contexto-negocio), `base-conteudo.md` (motor), `learnings.md` (qualquer especialista), `config.md` com `destino_publicacao: manual`.

- [ ] **Passo 4: `.gitignore`** com `evals/results/` e `node_modules/`.

- [ ] **Passo 5: verificar que o plugin carrega**

Run: `claude -p --model claude-sonnet-5 --plugin-dir ~/projects/sistema-conteudo --output-format json "liste os plugins carregados" | jq -r .result`
Esperado: a resposta cita `sistema-conteudo`.

- [ ] **Passo 6: commit**

```bash
git add -A && git commit -m "chore: estrutura inicial do plugin sistema-conteudo" && git push -u origin main
```

### Tarefa 2: checagem de voz e harness de avaliação

**Arquivos:**
- Criar: `scripts/check-voz.sh`, `scripts/eval/run-case.sh`, `scripts/eval/judge.sh`, `scripts/eval/judge-prompt.md`, `evals/cases/README.md`
- Teste: `scripts/eval/test-check-voz.sh`

**Interfaces:**
- Produz: `check-voz.sh <arquivo> [banidas.txt]` sai 0 se limpo, 1 com as linhas culpadas; `run-case.sh <plugin-dir> <caso.md> <modelo> <saida.md>`; `judge.sh <caso.md> <saida-A> <saida-B> <veredito.json>` devolve `{"vencedor":"nova|antiga|empate","motivo":"..."}` já desembaralhado.
- Formato de caso: frontmatter com `especialista`, `fixture` (caminho relativo a `evals/fixtures/`), `fixture_legado`, `prompt_novo`, `prompt_antigo`, e corpo com a rubrica específica do caso.

- [ ] **Passo 1: teste da checagem (falha primeiro)**

`scripts/eval/test-check-voz.sh`:
```bash
#!/usr/bin/env bash
set -u
d=$(mktemp -d)
printf 'texto limpo, sem nada.\n' > "$d/ok.md"
printf 'texto com travess\xe2\x80\x94o\n' > "$d/trav.md"
printf 'vamos alavancar isso\n' > "$d/ban.md"
printf 'alavancar\n' > "$d/banidas.txt"
s=scripts/check-voz.sh
bash $s "$d/ok.md" "$d/banidas.txt" >/dev/null && echo "ok limpo" || { echo "FALHA limpo"; exit 1; }
bash $s "$d/trav.md" >/dev/null && { echo "FALHA travessao"; exit 1; } || echo "ok travessao"
bash $s "$d/ban.md" "$d/banidas.txt" >/dev/null && { echo "FALHA banida"; exit 1; } || echo "ok banida"
```
Run: `bash scripts/eval/test-check-voz.sh`
Esperado: falha, porque `check-voz.sh` não existe.

- [ ] **Passo 2: implementar `scripts/check-voz.sh`**

```bash
#!/usr/bin/env bash
# uso: check-voz.sh <arquivo> [banidas.txt]
arq="$1"; ban="${2:-}"; falhou=0
if perl -CSD -ne 'if (/[\x{2014}\x{2013}]/) { print "$.: $_"; $f=1 } END { exit($f?0:1) }' "$arq"; then echo "travessao"; falhou=1; fi
if perl -CSD -ne 'if (/[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}]/) { print "$.: $_"; $f=1 } END { exit($f?0:1) }' "$arq"; then echo "emoji"; falhou=1; fi
if [ -n "$ban" ] && [ -s "$ban" ]; then
  if perl -CSD -e '
    open my $b, "<", $ARGV[0]; my @p = grep { length } map { chomp; s/^\s+|\s+$//g; $_ } grep { !/^#/ } <$b>;
    open my $a, "<", $ARGV[1]; my $f = 0;
    while (my $l = <$a>) { for my $w (@p) { if ($l =~ /\b\Q$w\E\b/i) { print "$.: [$w] $l"; $f = 1 } } }
    exit($f ? 0 : 1)' "$ban" "$arq"; then echo "banida"; falhou=1; fi
fi
exit $falhou
```

- [ ] **Passo 3: rodar o teste**

Run: `bash scripts/eval/test-check-voz.sh`
Esperado: `ok limpo`, `ok travessao`, `ok banida`.

- [ ] **Passo 4: `scripts/eval/run-case.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
# uso: run-case.sh <plugin-dir> <caso.md> <modelo> <saida.md> [novo|antigo]
plugin=$(cd "$1" && pwd); caso="$2"; modelo="$3"; saida="$4"; lado="${5:-novo}"
raiz=$(cd "$(dirname "$caso")/../.." && pwd)
campo() { awk -v k="$1" -F': ' '$1==k{sub(/^[^:]*: /,""); print; exit}' "$caso"; }
if [ "$lado" = antigo ]; then fx=$(campo fixture_legado); pr=$(campo prompt_antigo); else fx=$(campo fixture); pr=$(campo prompt_novo); fi
work=$(mktemp -d); cp -R "$raiz/fixtures/$fx/." "$work/"
( cd "$work" && claude -p --model "$modelo" --plugin-dir "$plugin" --permission-mode acceptEdits --output-format json "$pr" ) | jq -r '.result' > "$saida"
mkdir -p "$saida.arquivos" && cp -R "$work/." "$saida.arquivos/"
```

- [ ] **Passo 5: `scripts/eval/judge-prompt.md`**

```markdown
Você é um editor sênior avaliando duas saídas para o mesmo pedido, sem saber qual sistema gerou cada uma.
Leia, nesta ordem: o CONTEXTO (voz e ICP do autor), o PEDIDO e a RUBRICA DO CASO. Depois leia A e B.
Critérios, nesta ordem de peso: (1) soa como o autor descrito no contexto, não como IA imitando; (2) serve ao leitor do ICP, sem jargão que ele não usa; (3) cumpre o pedido e a rubrica; (4) não inventa número, caso ou nome; (5) forma (tamanho, formatação do tipo pedido).
Uma saída que inventa dado perde, independente do resto.
Responda só com JSON: {"vencedor":"A"|"B"|"empate","motivo":"até 3 frases citando trechos"}
```

- [ ] **Passo 6: `scripts/eval/judge.sh`** (embaralha A e B e desfaz no fim)

```bash
#!/usr/bin/env bash
set -euo pipefail
# uso: judge.sh <caso.md> <saida-nova> <saida-antiga> <veredito.json> <fixture-dir>
caso="$1"; nova="$2"; antiga="$3"; out="$4"; fx="$5"
dir=$(cd "$(dirname "$0")" && pwd)
if [ $((RANDOM % 2)) -eq 0 ]; then A="$nova"; B="$antiga"; mapa=nova; else A="$antiga"; B="$nova"; mapa=antiga; fi
msg=$(printf 'CONTEXTO:\n%s\n\n%s\n\nPEDIDO E RUBRICA:\n%s\n\nA:\n%s\n\nB:\n%s\n' "$(cat "$fx/voz.md")" "$(cat "$fx/icp.md")" "$(cat "$caso")" "$(cat "$A")" "$(cat "$B")")
res=$(cd "$(mktemp -d)" && claude -p --model claude-opus-5 --append-system-prompt "$(cat "$dir/judge-prompt.md")" --output-format json "$msg" | jq -r .result | sed -n '/^{/,/}$/p')
v=$(echo "$res" | jq -r .vencedor)
if [ "$v" = empate ]; then r=empate; elif [ "$v" = A ]; then r=$mapa; else [ "$mapa" = nova ] && r=antiga || r=nova; fi
echo "$res" | jq --arg r "$r" '{vencedor:$r, motivo:.motivo}' > "$out"
```

- [ ] **Passo 7: rodar um caso de fumaça**

Criar `evals/cases/_fumaca/01.md` com `prompt_novo: responda apenas a palavra ok` e `fixture: hugo` (fixture criada na Tarefa 3, então rodar este passo ao fim da Tarefa 3).
Run: `bash scripts/eval/run-case.sh . evals/cases/_fumaca/01.md claude-sonnet-5 /tmp/fumaca.md && cat /tmp/fumaca.md`
Esperado: `ok`.

- [ ] **Passo 8: commit**

```bash
chmod +x scripts/*.sh scripts/eval/*.sh
git add -A && git commit -m "feat(eval): checagem de voz e harness de casos com juiz cego"
```

---

## Dia 2 (18/09)

### Tarefa 3: fixtures, squad antiga como baseline e casos

**Arquivos:**
- Criar: `legado/squad/.claude-plugin/plugin.json`, `legado/squad/skills/{setup,kotler,hormozi,ogilvy,davinci}/`, `evals/fixtures/hugo/*`, `evals/fixtures/hugo-legado/*`, `evals/cases/{contexto-negocio,angulo,gancho,linkedin-post,carrossel-roteiro,entrevista-voz}/01..05.md`

**Interfaces:**
- Consome: formato de caso e scripts da Tarefa 2.
- Produz: baseline antiga em `evals/results/baseline/<especialista>/<caso>-<modelo>.md`.

- [ ] **Passo 1: empacotar a squad antiga**

```bash
mkdir -p legado/squad/skills legado/squad/.claude-plugin
for s in setup kotler hormozi ogilvy davinci; do unzip -oq ~/Downloads/squad-conteudo-linkedin/$s.zip -d /tmp/squad && cp -R /tmp/squad/$s legado/squad/skills/$s; done
printf '{"name":"squad-legado","version":"0.0.1","author":{"name":"Hugo Doria"}}\n' > legado/squad/.claude-plugin/plugin.json
```
Esperado: `ls legado/squad/skills` lista as 5 pastas, cada uma com `SKILL.md`.

- [ ] **Passo 2: fixture `hugo` (formato novo)**, montada a partir do vault, sem inventar nada:
  - `voz.md`: compilar do `resources/dna-da-voz.md` e `resources/voice-profile-hugo-doria.md` usando o prompt Compilador do Craft (doc 6DE9F3D2) numa conversa limpa. É a referência provisória até a Tarefa 4 gerar a versão nova.
  - `banidas.txt`: lista de banidas do `dna-da-voz`, uma por linha.
  - `icp.md`: seções 3 e 5 de `~/Documents/CLAUDE COWORK/SOBRE MIM/sobre-mim.md`.
  - `prova.md`: só números com fonte (20 anos, 200 projetos, 20 milhões de usuários), cada um com origem.
  - `marca.md`: tokens Atlas do `animated-carousel-hdoria/template/src/theme.ts` (#101010, #f3a46c, #f1eec8, Cal Sans, DM Sans, JetBrains Mono).
  - `materiais/`: `resources/post-grok-bot-time-de-agentes.md`, `post-manus-meta-dados-apagados.md`, `post-spacex-ai-embaixador.md` e `~/Documents/CLAUDE COWORK/OUTPUTS/LinkedIn/ia-rouba-empregos.md`.

- [ ] **Passo 3: fixture `hugo-legado`**: rodar o `setup` antigo sobre os mesmos materiais e salvar os 6 arquivos do contrato.

```bash
bash scripts/eval/run-case.sh legado/squad evals/cases/_setup-legado.md claude-opus-5 /tmp/setup.md antigo
cp -R /tmp/setup.md.arquivos/. evals/fixtures/hugo-legado/
```
Com `_setup-legado.md` pedindo: "rode /setup com os arquivos de materiais/ e gere os 6 arquivos do contrato nesta pasta, marcando como pendente o que faltar".

- [ ] **Passo 4: escrever os 30 casos** (5 por especialista do núcleo com equivalente antigo). Cada caso usa um tema real do Hugo tirado do journal ou dos posts, com rubrica de 3 a 5 linhas. Distribuição mínima em `linkedin-post`: 1 teardown, 1 caso, 1 build, 1 posição, 1 anúncio pessoal. Em `carrossel-roteiro`: 5 temas, um deles de prompts (capa nomeia a entrega). Em `entrevista-voz`: os casos testam a compilação (entrada: `materiais/` mais respostas simuladas), não a conversa.

- [ ] **Passo 5: gerar a baseline antiga**

```bash
for c in evals/cases/*/0?.md; do e=$(basename $(dirname $c)); [ "$e" = _fumaca ] && continue
  for m in claude-sonnet-5 claude-opus-5; do mkdir -p evals/results/baseline/$e
    bash scripts/eval/run-case.sh legado/squad $c $m evals/results/baseline/$e/$(basename $c .md)-$m.md antigo & done; done; wait
```
Esperado: 50 arquivos em `evals/results/baseline/` (25 casos com equivalente antigo, 2 modelos), nenhum vazio (`find evals/results/baseline -name '*.md' -empty` sem saída).

- [ ] **Passo 6: commit** (sem `evals/results/`)

```bash
git add -A && git commit -m "test(eval): fixtures do hugo, squad legado e 30 casos de referencia"
```

### Tarefa 4: `entrevista-voz`

**Arquivos:**
- Criar: `skills/entrevista-voz/SKILL.md`, `skills/entrevista-voz/references/perguntas.md`, `skills/entrevista-voz/references/compilador.md`

**Interfaces:**
- Consome: `materiais/` na pasta de contexto (opcional).
- Produz: `voz-bruta.md`, `voz.md` (XML, até 5 mil tokens, blocos do Compilador do Craft), `banidas.txt`.

Fontes: prompts Entrevistador e Compilador do doc Craft 6DE9F3D2 e o Criador de Alma (doc 73D19770), reescritos em Fable 5.1.

- [ ] **Passo 1: SKILL.md** com estas seções obrigatórias:
  1. Detecção de modo: se `materiais/` tem texto, modo leitura; se não, modo zero, que pede de 5 a 8 respostas faladas curtas (explique o que você vende para um cliente; conte o caso de um cliente; sua opinião sobre um tema do seu mercado; o que te irrita no seu setor; como você explicaria seu trabalho num almoço) e transcreve em `materiais/respostas-faladas.md`.
  2. Leitura: extrai ritmo, abertura, fechamento, palavras recorrentes e tamanho de frase, e mostra o achado à pessoa antes de perguntar.
  3. Entrevista: de 40 a 60 perguntas, uma por vez, só nas categorias que os textos não cobrem (crenças contrárias, crimes estéticos, nãos absolutos, sinais de alarme). Pressiona resposta vaga pedindo exemplo. Salva cada par pergunta e resposta em `voz-bruta.md` à medida que avança, para retomar se a sessão cair.
  4. Compilação: em subagente de contexto limpo quando disponível, senão instrui abrir conversa nova; aplica `references/compilador.md`; grava `voz.md` e extrai `banidas.txt`.
  5. Validação: a pessoa lê o `voz.md` e aprova; depois teste de reconhecimento com 3 textos gerados e 3 reais embaralhados; se ela acertar os 3 gerados com facilidade, pergunta o que denunciou e recompila.
  6. Recompilação: quando `base-conteudo.md` tiver 10 posts publicados, recompila usando os posts e o `learnings.md`.
- [ ] **Passo 2: `references/compilador.md`**: Compilador modernizado, mesmos blocos XML (uso, prioridade, contexto_de_identidade, assinatura_de_voz, leis_de_escrita, recusas_duras, gostos, banco_de_frases, sinais_de_assinatura, regras_de_decisao, contradicoes_produtivas, exemplos_de_ouro, nao_inferir), teste de linha e teto de 5 mil tokens. Modernizar: explicar o porquê de cada regra, remover caixa alta enfática, sem perder nenhuma restrição.
- [ ] **Passo 3: checar**

Run: `bash scripts/check-voz.sh skills/entrevista-voz/SKILL.md && bash scripts/check-voz.sh skills/entrevista-voz/references/compilador.md`
Esperado: saída 0.

- [ ] **Passo 4: casos**: rodar os 5 casos de `entrevista-voz` nos dois modelos; para cada `voz.md` gerado, gerar 3 posts com ele e pedir ao juiz Opus que aponte, entre 3 gerados e 3 reais do Hugo, quais são reais.
Esperado (portão): em pelo menos 3 dos 5 casos, em cada modelo, o juiz erra 2 ou mais. Tokens de `voz.md` até 5 mil (`wc -w` abaixo de 3.500 palavras como aproximação).

- [ ] **Passo 5: commit**

```bash
git add skills/entrevista-voz && git commit -m "feat(entrevista-voz): entrevista enxuta com leitura, modo zero e compilacao"
```

---

## Dia 3 (19/09)

### Tarefa 5: `contexto-negocio`

**Arquivos:** Criar `skills/contexto-negocio/SKILL.md`

**Interfaces:**
- Consome: `materiais/`, site ou briefing.
- Produz: `icp.md` (quem lê, o que já acredita, o que o preocupa, jargão que usa e não usa), `prova.md` (cada número com fonte e data; sem fonte não entra), `marca.md` (2 ou 3 cores em hex, fontes, @ e domínio).

Fonte: `legado/squad/skills/setup` (prompts 01 e 02, modelos de contrato), reescrito em Fable 5.1. Campos anti-exagero obrigatórios em `icp.md`: "o que o produto NÃO faz" e "claims que precisam de aval".

- [ ] **Passo 1: SKILL.md** com: leitura de materiais antes de perguntar; perguntas só do que faltou, uma por vez; `[FALTA: ...]` em vez de preencher; nenhuma pergunta de voz (isso é do `entrevista-voz`).
- [ ] **Passo 2:** `bash scripts/check-voz.sh skills/contexto-negocio/SKILL.md` com saída 0.
- [ ] **Passo 3: casos** nos dois modelos e juiz contra a baseline:

```bash
for c in evals/cases/contexto-negocio/0?.md; do for m in claude-sonnet-5 claude-opus-5; do n=$(basename $c .md)-$m
  bash scripts/eval/run-case.sh . $c $m evals/results/nova/contexto-negocio/$n.md
  bash scripts/eval/judge.sh $c evals/results/nova/contexto-negocio/$n.md evals/results/baseline/contexto-negocio/$n.md evals/results/veredito/contexto-negocio/$n.json evals/fixtures/hugo; done; done
jq -r .vencedor evals/results/veredito/contexto-negocio/*.json | sort | uniq -c
```
Esperado (portão): `antiga` em no máximo 0 casos por modelo, ou seja, só `nova` e `empate`. (Criar as pastas de results antes com `mkdir -p`.)
- [ ] **Passo 4: commit** `feat(contexto-negocio): icp, prova com fonte e marca`

### Tarefa 6: `gancho`

**Arquivos:** Criar `skills/gancho/SKILL.md`, `skills/gancho/references/banco-de-ganchos.md`

**Interfaces:**
- Consome: tema ou briefing, `voz.md`, `icp.md`, tipo de peça (`post`, `capa`, `derivado`).
- Produz: de 2 a 3 ganchos por pedido, cada um com a estrutura usada; modo avulso com 10 ganchos.

Fontes: `legado/squad/skills/hormozi` (seleção e banco v3), seção "O hook" do `linkedin-copy`, learning de 2026-08-15 (capa nomeia a entrega).

- [ ] **Passo 1:** SKILL.md com as regras: linha 1 até 15 palavras com fato, cena ou número; linha 2 avança, nunca explica a linha 1; notícia crua em segunda pessoa para teardown; capa de carrossel nomeia a entrega no formato do que a pessoa vai conseguir fazer; categorias banidas: paralelismo negativo, pergunta retórica de aquecimento, isca de engajamento.
- [ ] **Passo 2:** banco modernizado: manter as 13 estruturas, trocar exemplos que conflitam com as categorias banidas.
- [ ] **Passo 3:** check-voz nos dois arquivos, saída 0.
- [ ] **Passo 4:** casos e juiz (mesmo laço da Tarefa 5 com `gancho`). Portão: nenhum `antiga`.
- [ ] **Passo 5: commit** `feat(gancho): banco modernizado e regra de capa`

---

## Dia 4 (20/09)

### Tarefa 7: `linkedin-post`

**Arquivos:** Criar `skills/linkedin-post/SKILL.md`, `skills/angulo/references/tipos-de-post.md` (criado aqui, lido também pelo `angulo`)

**Interfaces:**
- Consome: briefing com tipo, tese e gancho escolhido; `voz.md`, `banidas.txt`, `icp.md`, `prova.md`.
- Produz: post pronto, primeiro comentário (link e fonte, quando houver), 2 linhas de nota (tipo usado e o que ficou de fora), e registro em `base-conteudo.md` (data, tema, tipo, gancho, status `rascunho`).

Fontes: `legado/squad/skills/ogilvy` (01a, 01b, 02 naturalidade, 03 tom, 04 formatação), `linkedin-copy` inteiro, learning de 2026-09-03 (anúncio pessoal).

- [ ] **Passo 1: `tipos-de-post.md`** com os 7 tipos, cada um com estrutura, faixa de tamanho e quando usar: teardown (1.400 a 2.500), caso (1.500 a 2.500), build ou bastidor (1.500 a 2.900, com o que não funcionou obrigatório), educativo (acima de 1.400), posição (abaixo de 900, termina em pergunta genuína), lead magnet (acima de 1.400, CTA de palavra-chave só com material pronto), anúncio pessoal (abaixo de 900, cena, sentimento e convite, sem tese).
- [ ] **Passo 2: SKILL.md** com: dois passes (voz e ICP); bullet com `→`; sem hashtag, emoji ou negrito unicode; CTA de palavra-chave no máximo em 1 de cada 3 posts (conferir em `base-conteudo.md`); `[FALTA: número real]` em vez de inventar; ao fim roda `scripts/check-voz.sh` no rascunho se disponível e cola o resultado; se o comprador corrigir, grava em `learnings.md` a regra, o porquê e como aplicar.
- [ ] **Passo 3:** check-voz nos arquivos, saída 0.
- [ ] **Passo 4:** casos e juiz. Portão: nenhum `antiga`.
- [ ] **Passo 5: commit** `feat(linkedin-post): 7 tipos com regra bimodal e dois passes`

### Tarefa 8: `revisor`

**Arquivos:** Criar `skills/revisor/SKILL.md`, `skills/revisor/references/painel.md`, `evals/cases/revisor/01..05.md`

**Interfaces:**
- Consome: a peça, `voz.md`, `icp.md`, `banidas.txt`, `prova.md`. Nunca recebe o raciocínio de quem escreveu.
- Produz: `{nota: 0-100, por_critico: {...}, veredito: "aprovar"|"reescrever"|"descartar", correcoes: [trecho, problema, sugestão]}` mais o resultado do check-voz.

- [ ] **Passo 1: `painel.md`**: cinco críticos de 0 a 20 (cético, estranho, concorrente que cola o próprio logo, leitor do ICP, editor). 90 ou mais aprova; de 70 a 89 reescreve apontando o que falta; abaixo de 70 descarta. Número sem lastro em `prova.md` zera o cético.
- [ ] **Passo 2: SKILL.md**: roda como subagente de contexto limpo quando o host permite; senão, instrui o comprador a abrir conversa nova; sempre roda `check-voz.sh`.
- [ ] **Passo 3: casos próprios** (sem baseline): 5 peças com defeito plantado conhecido (travessão, número sem fonte, jargão fora do ICP, linha 2 que explica a linha 1, tamanho na faixa morta). Portão: o revisor aponta o defeito plantado em 5 de 5, nos dois modelos.
- [ ] **Passo 4: commit** `feat(revisor): painel de cinco criticos em contexto limpo`

---

## Dia 5 (21/09)

### Tarefa 9: `angulo`

**Arquivos:** Criar `skills/angulo/SKILL.md`

**Interfaces:**
- Consome: tema, `base-conteudo.md`, `icp.md`, `tipos-de-post.md`.
- Produz: briefing com tipo, tese em 1 frase, formato (post, carrossel ou os dois), e aviso se o tema repete a base.

Fonte: `legado/squad/skills/kotler` (02 construção de briefings; o 01 de calibração de semana fica para o `radar-pautas`).

- [ ] **Passo 1:** SKILL.md com a pergunta de escolha de tipo ("o fato é sobre o mercado ou sobre a pessoa?"), leitura da base para não repetir, e 2 ou 3 ângulos para a pessoa escolher.
- [ ] **Passo 2:** check-voz, casos e juiz. Portão: nenhum `antiga`.
- [ ] **Passo 3: commit** `feat(angulo): tipo, tese e checagem de repeticao`

### Tarefa 10: `carrossel-roteiro`

**Arquivos:** Criar `skills/carrossel-roteiro/SKILL.md`

**Interfaces:**
- Consome: post aprovado ou briefing; gancho de capa do `gancho`.
- Produz: `carrossel.json` na pasta da peça: `{"slides":[{"tipo":"capa|conteudo|fecho","titulo":"...","corpo":"...","apoio":"..."}], "legenda_instagram":"...", "titulo_pdf":"..."}`, com até 10 slides.

Fontes: `legado/squad/skills/davinci/prompts/01_quebra_narrativa.md`, learnings de 2026-08-15 e 2026-09-10.

- [ ] **Passo 1:** SKILL.md com: capa nomeia a entrega; 1 ideia por slide, de 15 a 30 palavras; título, corpo e linha de apoio não repetem a mesma coisa; imperativo em "você"; aprovação da copy antes do render.
- [ ] **Passo 2:** check-voz, casos e juiz. Portão: nenhum `antiga`.
- [ ] **Passo 3: commit** `feat(carrossel-roteiro): quebra narrativa com capa que nomeia a entrega`

### Tarefa 11: `carrossel-render`

**Arquivos:** Criar `skills/carrossel-render/SKILL.md`, `skills/carrossel-render/template/slide.html`, `skills/carrossel-render/template/tokens.css`, `scripts/render-carrossel.mjs`, `skills/carrossel-render/fonts/` (fontes livres locais)
- Teste: `evals/cases/carrossel-render/fumaca.json`

**Interfaces:**
- Consome: `carrossel.json` (Tarefa 10) e `marca.md`.
- Produz: `01.png` a `NN.png` em 1080x1350 e `carrossel.pdf` na pasta de saída.

Fonte: `legado/squad/skills/davinci/prompts/carousel_design_system.md` e `02_geracao_slides.md`; padrão de render do `popcode-instagram`.

- [ ] **Passo 1: teste de render (falha primeiro)**

```bash
node scripts/render-carrossel.mjs evals/cases/carrossel-render/fumaca.html /tmp/render-teste
ls /tmp/render-teste/*.png | wc -l
```
Esperado: falha, porque o script não existe.

- [ ] **Passo 2: `scripts/render-carrossel.mjs`**

```js
import { chromium } from 'playwright';
import { mkdir } from 'node:fs/promises';
import path from 'node:path';

const [, , htmlPath, outDir] = process.argv;
await mkdir(outDir, { recursive: true });
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1080, height: 1350 }, deviceScaleFactor: 1 });
await page.goto('file://' + path.resolve(htmlPath));
await page.evaluate(() => document.fonts.ready);
const slides = await page.$$('.slide');
for (const [i, slide] of slides.entries()) {
  await slide.screenshot({ path: path.join(outDir, String(i + 1).padStart(2, '0') + '.png') });
}
await page.pdf({ path: path.join(outDir, 'carrossel.pdf'), width: '1080px', height: '1350px', printBackground: true });
await browser.close();
console.log(slides.length);
```

- [ ] **Passo 3: template** `slide.html` com `.slide { width:1080px; height:1350px; page-break-after:always; }`, tokens de cor e fonte vindos de `tokens.css` (que a skill gera a partir de `marca.md`), fontes por `@font-face` com caminho relativo local, sem Google Fonts.
- [ ] **Passo 4: instalar e rodar**

```bash
npm init -y >/dev/null && npm i playwright && npx playwright install chromium
node scripts/render-carrossel.mjs evals/cases/carrossel-render/fumaca.html /tmp/render-teste
sips -g pixelWidth -g pixelHeight /tmp/render-teste/01.png
strings /tmp/render-teste/carrossel.pdf | grep -o '/BaseFont /[A-Za-z+-]*' | sort -u
```
Esperado: número de slides igual ao do HTML; 1080 por 1350; todas as fontes declaradas no CSS aparecem em `/BaseFont` (nenhuma fonte de sistema no lugar).

- [ ] **Passo 5: olhar.** Abrir 3 PNGs com a ferramenta de leitura de imagem e conferir legibilidade e contraste. Texto no HTML não prova texto legível.
- [ ] **Passo 6: SKILL.md** com: gera `tokens.css` de `marca.md`, monta o HTML de `carrossel.json`, roda o script; se Node ou Playwright faltar, entrega o HTML e explica como abrir e exportar. Capa sempre PNG.
- [ ] **Passo 7: commit** `feat(carrossel-render): png 1080x1350 e pdf do mesmo render com fontes locais`

---

## Dia 6 (22/09)

### Tarefa 12: `motor` e `publicar` manual

**Arquivos:** Criar `skills/motor/SKILL.md`, `skills/publicar/SKILL.md`, `evals/cases/motor/01..03.md`

**Interfaces:**
- Consome: todos os especialistas pelos nomes acima.
- Produz: fluxo ideia, `angulo`, `gancho`, peça principal, `revisor`, aprovação, derivados, pacote de publicação; `publicar` monta `publicar/<data>-<tema>/` com `post.txt`, `primeiro-comentario.txt`, `legenda-instagram.txt`, PNGs e PDF, e um passo a passo manual.

- [ ] **Passo 1: `motor/SKILL.md`**: primeira execução confere a pasta de contexto e chama `entrevista-voz` e `contexto-negocio` se `voz.md` ou `icp.md` estiverem vazios; peça principal primeiro, derivados só após o "aprovado"; nenhuma regra de escrita dentro do motor (só referência aos especialistas); atualiza `base-conteudo.md` com status `aprovado`.
- [ ] **Passo 2: `publicar/SKILL.md`**: lê `config.md`; em `manual` só gera o pacote e o passo a passo; nunca chama API de rede social nesta versão.
- [ ] **Passo 3: casos do motor** (sem baseline): 3 fluxos completos na fixture `hugo` rodados com `--permission-mode acceptEdits`. Portão: cada fluxo para e pede aprovação após a peça principal; o pacote final tem os 6 arquivos; `check-voz.sh` passa em todos os `.txt`.
- [ ] **Passo 4: commit** `feat(motor): orquestracao com aprovacao da peca principal e pacote manual`

### Tarefa 13: rodada completa de validação

- [ ] **Passo 1:** rodar todos os casos novos nos dois modelos e todos os juízes em paralelo.
- [ ] **Passo 2:** consolidar em `evals/results/placar.md`: por especialista e modelo, contagem de `nova`, `empate`, `antiga`, e os portões próprios de `entrevista-voz`, `revisor` e `motor`.

```bash
for e in contexto-negocio gancho linkedin-post angulo carrossel-roteiro; do for m in claude-sonnet-5 claude-opus-5; do
  printf '%s %s: ' $e $m; jq -r .vencedor evals/results/veredito/$e/*-$m.json | sort | uniq -c | tr '\n' ' '; echo; done; done
```
- [ ] **Passo 3:** todo especialista com `antiga` volta para reescrita com o `motivo` do juiz como entrada, e roda só os casos perdidos de novo. Limite de 2 voltas; se ainda perder, o especialista sai do núcleo de 25/09 e a versão antiga correspondente vai no pacote com nota.
- [ ] **Passo 4: commit** `test(eval): placar da validacao do nucleo`

---

## Dia 7 (23/09)

### Tarefa 14: Hugo como cliente zero

Tarefa humana, conduzida na sessão principal.

- [ ] **Passo 1:** instalar o plugin numa pasta nova `~/Documents/CLAUDE COWORK/sistema-conteudo-hugo/` a partir do GitHub (não do diretório local), seguindo o `INSTALAR.md` em rascunho.
- [ ] **Passo 2:** Hugo roda `motor`, faz a entrevista de voz em modo leitura, produz 1 post de LinkedIn e 1 carrossel reais.
- [ ] **Passo 3:** registrar cada atrito (tempo da entrevista, pergunta confusa, erro de instalação, correção feita) em `evals/results/cliente-zero.md` e corrigir no mesmo dia.
- [ ] **Passo 4:** gravar no vault, em `resources/learnings-do-hugo.md`, as correções do Hugo que virarem regra.
- [ ] **Passo 5: commit** `fix: ajustes do teste com cliente zero`

---

## Dia 8 (24/09)

### Tarefa 15: instalação limpa, Grok Bot e publicação da versão

**Arquivos:** Criar `INSTALAR.md`; modificar `README.md`; modificar `README.md` de `hdoria/marketing-skills` e `hdoria/humanizar` (link para o sistema)

- [ ] **Passo 1: `INSTALAR.md`**: requisitos (Claude Code com Claude Pro ou Max, git, Node LTS opcional para render); aceitar convite do repositório; `gh auth login`; `/plugin marketplace add hdoria/sistema-conteudo`; `/plugin install sistema-conteudo@sistema-conteudo`; copiar `contexto-modelo/` para uma pasta própria com `git init`; primeiro comando: pedir ao motor para começar.
- [ ] **Passo 2: instalação limpa**: numa conta de usuário do macOS sem configuração do Hugo (ou `HOME` temporário), seguir o `INSTALAR.md` à risca com um colaborador de teste convidado no repositório. Esperado: o motor abre e inicia a entrevista sem nenhum passo fora do documento.
- [ ] **Passo 3: Grok Bot (uso do Hugo)**: token fino do GitHub com leitura só de `hdoria/sistema-conteudo`, configurado no computador do Grok Bot; clone em `/workspace/sistema-conteudo`; uma skill curta por especialista apontando para o SKILL.md do clone. Esperado: pedir 10 ganchos a um tema no Grok Bot devolve saída do `gancho`.
- [ ] **Passo 4: links nos repositórios públicos**: uma linha no topo do README de `marketing-skills` e `humanizar` apontando para o sistema. Rodar check-voz nos READMEs.
- [ ] **Passo 5: versão**

```bash
git tag v0.1.0 && git push origin main --tags
```

## Dia 9 (25/09)

- [ ] Convidar como colaboradores (leitura) os membros confirmados da turma e enviar o `INSTALAR.md`. Os convites da turma são feitos pelo Hugo.

## Depois de 25/09 (atualizações semanais durante a turma)

`radar-pautas`, `reaproveitar`, `medir`, `consolidar` e integração Metricool, cada um com o mesmo ciclo: casos, reescrita, validação em dois modelos, commit e versão menor. Teste cego contra as skills atuais do Hugo (10 briefings, a nova empata ou vence em pelo menos 7) e 2 a 4 semanas de uso real antes de aposentar `linkedin-copy` e os carrosséis atuais.
