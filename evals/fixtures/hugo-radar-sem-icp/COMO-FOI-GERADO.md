Variante da `hugo-radar` sem `icp.md`, para o caso em que o radar não pode gravar lista. Mudança em `hugo-radar` não se propaga para cá.

Cópia da fixture `hugo-5col` para o `radar-pautas`, com uma peça `publicado` a mais em `base-conteudo.md` (tema: NPS do Sprint de IA do G4) e sem `pautas.md`. Mudança em `hugo-5col` não se propaga para cá; refaça a cópia se precisar.

Cópia da fixture `hugo` com `prova.md` no formato de produção (5 colunas com `Tipo` e linha `Atualizado:`). Mudança na `hugo` não se propaga para cá; refaça a cópia se precisar.

# Como foi gerada a fixture hugo

Fixture de avaliação montada em 2026-09-17 a partir do vault `hugo-os` (`~/projects/hugo-os`). Nada foi escrito de cabeça: cada arquivo cita a fonte.

## voz.md

Referência provisória, até a Tarefa 4 gerar a versão nova com o `entrevista-voz`. Compilada com o prompt Compilador (cópia em `.superpowers/sdd/plano/ref-compilador.md`, origem no doc Craft 6DE9F3D2) sobre `resources/dna-da-voz.md` e `resources/voice-profile-hugo-doria.md`, numa sessão isolada, com Opus 5, dentro de uma pasta temporária vazia. Na hora da compilação o wrapper `claude-isolado.sh` usava `--safe-mode` (sem CLAUDE.md, skills, plugins, hooks nem MCP do dono da máquina); depois ele passou a usar `--setting-sources "" --strict-mcp-config`, que ainda carrega as skills de `--plugin-dir`. A sonda do evento `system/init` conferiu CLAUDE.md, skills, plugins e MCP: nenhum vazou. Hook de usuário não foi conferido por sonda direta (`--debug hooks` não imprimiu nada em nenhuma das duas configurações), então a equivalência com `--safe-mode` vale para o que foi medido, não para hook. A compilação não usa plugin, então o resultado vale para as duas versões. `$SCRATCH` abaixo é qualquer pasta temporária fora do repositório.

Montagem da mensagem (raiz do repositório `sistema-conteudo`):

```bash
V=~/projects/hugo-os/resources
{ echo "ARQUIVO BRUTO DE VOZ, PARTE 1: dna-da-voz.md"; echo; cat $V/dna-da-voz.md; echo
  echo "ARQUIVO BRUTO DE VOZ, PARTE 2: voice-profile-hugo-doria.md"; echo; cat $V/voice-profile-hugo-doria.md; echo
  echo "---"; echo; cat .superpowers/sdd/plano/ref-compilador.md; } > "$SCRATCH/mensagem.txt"
```

Compilação:

```bash
cd "$(mktemp -d)" && ~/projects/sistema-conteudo/scripts/eval/claude-isolado.sh \
  --model claude-opus-5 --output-format json "$(cat "$SCRATCH/mensagem.txt")" > "$SCRATCH/saida.json"
```

O modelo gravou o resultado como `sobre-mim.md` na pasta temporária (2 turnos, nenhuma permissão negada), e esse arquivo foi copiado sem edição para `voz.md`. Tamanho: 2.922 palavras e 20.979 caracteres; o modelo estimou perto de 4.800 tokens, abaixo do teto de 5.000. Saída sem travessão e sem emoji (`scripts/check-voz.sh` com saída 0).

Observações do próprio compilador, na mensagem final da sessão: as frases de assinatura com formato de reframe ("IA não substitui. IA multiplica.") ficaram restritas ao uso literal, no máximo 1 por texto; o dado de 4% dos commits do GitHub foi para `<nao_inferir>` como número a confirmar; `<leis_de_comunicacao>` foi deduzido do tom geral, porque as fontes quase não falam de e-mail, desculpa ou recusa.

## banidas.txt

Lista da seção 3 de `resources/dna-da-voz.md` (3A a 3E), uma entrada por linha. As entradas que o DNA só bane em certo sentido ("jornada" figurada, "estratégico" em excesso) ficaram comentadas no fim, para o grep mecânico não acusar uso legítimo.

## icp.md

`resources/voice-profile-hugo-doria.md`, "SEÇÃO 3: AUDIÊNCIA", mais `areas/conteudo.md`. A fonte prevista no plano (`CLAUDE COWORK/SOBRE MIM/sobre-mim.md`, seções 3 e 5) não é legível nesta máquina (macOS devolve "Operation not permitted").

## prova.md

Só números escritos em `resources/` e `areas/`, cada um com a linha citada. As divergências entre fontes (20M+ contra 10 milhões de usuários, 200+ contra +400 projetos) estão registradas no próprio arquivo.

## marca.md

Tokens de `~/.claude/skills/animated-carousel-hdoria/template/src/theme.ts` (#101010, #f3a46c, #f1eec8, Cal Sans, DM Sans, JetBrains Mono), regra de uso da lição de 2026-09-10 em `resources/learnings-do-hugo.md`, @ e domínio das notas citadas no arquivo.

## base-conteudo.md

As três peças arquivadas em `resources/post-*.md`, com data, tipo e status registrados nas próprias notas.

## materiais/

Cópia literal de `resources/post-grok-bot-time-de-agentes.md`, `resources/post-manus-meta-dados-apagados.md` e `resources/post-spacex-ai-embaixador.md`. O quarto material previsto no plano (`CLAUDE COWORK/OUTPUTS/LinkedIn/ia-rouba-empregos.md`) não é legível nesta máquina e ficou de fora.
