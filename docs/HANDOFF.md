# Handoff: sistema-conteudo

Escrito em 2026-09-19 por causa de limite semanal de uso (reseta 2026-09-23, 1h). Quem pegar este trabalho continua daqui. Entrega combinada com o Hugo: 2026-09-25.

## O que é o produto

Plugin do Claude Code, privado, vendido para gestores e founders B2B no Brasil. Pega uma ideia e devolve post de LinkedIn e carrossel de Instagram na voz do comprador, sem inventar fato. Dez skills em `skills/`: `entrevista-voz`, `contexto-negocio`, `angulo`, `gancho`, `linkedin-post`, `carrossel-roteiro`, `carrossel-render`, `revisor`, `motor`, `publicar`.

Spec e decisões: `docs/plano/spec.md`. Plano de execução com as 15 tarefas: `docs/plano/plano.md`. Restrições globais: `.superpowers/sdd/plano/global-constraints.md`.

## Regra de ouro deste projeto

Nenhuma afirmação de qualidade entra em relatório sem resultado de execução que a sustente. Portão medido num commit vale para aquele commit, não para o que está no ar. Quando uma correção melhora o número, a pergunta seguinte é se a régua afrouxou.

## Onde está tudo

- Repositório: `~/projects/sistema-conteudo`, remoto `hdoria/sistema-conteudo` (privado), branch de trabalho `nucleo-v0.1`. `main` tem só o plano e a spec.
- Ledger com todas as decisões tomadas, cada uma com o motivo e o custo se estiver errada: `.superpowers/sdd/plano/progress.md`. Leia antes de decidir qualquer coisa; várias regras nasceram de erro medido.
- Relatórios e revisões por tarefa: `.superpowers/sdd/plano/task-N-report.md`, `task-N-review.md`, `task-N-rereview.md`.
- Resultados de execução (fora do git): `evals/results/`.

## Como rodar as coisas

```bash
# um caso contra a squad antiga, isolado da configuracao pessoal da maquina
bash scripts/eval/run-case.sh . evals/cases/<especialista>/01.md claude-sonnet-5 saida.md

# juiz cego (nao ve qual lado e qual, nomes de skill removidos)
bash scripts/eval/judge.sh <caso.md> <saida-nova> <saida-antiga> <veredito.json> evals/fixtures/hugo

# checagem mecanica de voz (travessao, emoji, termos banidos; modo json para carrossel)
bash scripts/check-voz.sh arquivo.md evals/fixtures/hugo/banidas.txt
bash scripts/check-voz.sh --json carrossel.json evals/fixtures/hugo/banidas.txt

# render do carrossel
node scripts/render-carrossel.mjs caminho/carrossel.json pasta-de-saida
```

Regras de execução aprendidas na marra: no máximo 2 execuções em paralelo, sempre como job de fundo com log que você consulta (`timeout` não existe no macOS); em HTTP 429, esperar e repetir, nunca trocar o protocolo no meio; nunca editar a skill enquanto o lote roda, porque cada execução lê o arquivo na hora.

## Estado por tarefa

| # | Tarefa | Estado | Portão |
|---|---|---|---|
| 1 e 2 | repositório, plugin, ferramental de teste | completa | testes do check-voz |
| 3 | base de comparação (fixtures, squad antiga, 30 casos, 50 saídas) | completa, 2 rodadas de correção | n/a |
| 4 | `entrevista-voz` | completa | preferência pareada 5/5 e 5/5 |
| 5 | `contexto-negocio` | completa | 10/10 |
| 6 | `gancho` | completa | 10/10 |
| 7 | `linkedin-post` | completa | 9/10 com exceção registrada |
| 8 | `revisor` | completa | defeito nomeado 10/10; controle independente aprovou 94 e 95 |
| 9 | `angulo` | completa | 10/10, tipo dentro da rubrica 9/10 |
| 10 | `carrossel-roteiro` | completa | 10/10 |
| 11 | `carrossel-render` | completa | 10 casos, 0 falhas |
| 12 | `motor` e `publicar` | **correção em andamento** | fluxos 6/6 antes da última correção |
| 13 | validação consolidada | **em andamento** | ver abaixo |
| 14 | Hugo como cliente zero | não começou | depende do Hugo |
| 15 | instalação limpa, Grok Bot, versão | não começou | |

## O que exatamente falta

### 1. Terminar a correção da Tarefa 12 (prioridade)

A re-revisão (`task-12-rereview.md`) aprovou dois achados e reprovou um. O implementer chegou a commitar `7d1fb0e` e `9e7f060` antes do limite estourar, mas **não verificou por execução**. Falta:

- confirmar por execução que o procedimento de troca de status não está mais duplicado (ele vivia em `motor` e em `publicar`, e o dono é `linkedin-post`);
- confirmar que o motor roda `scripts/check-voz.sh` ele mesmo na peça antes de mandar para o revisor, e que a parada mostra esse resultado como oficial. Motivo: em Sonnet o revisor nunca roda o script e responde "contei por leitura", de forma determinística. Checagem mecânica não pode depender do modelo;
- rodar ao menos um fluxo por modelo e anexar em `task-12-report.md`;
- gerar o pacote de revisão com a base certa (`git log` do primeiro commit da rodada, sufixo `^`) e disparar a re-revisão.

### 2. Terminar o portão de confirmação da Tarefa 13

Os especialistas foram medidos antes da varredura anti-invenção (`fba546c`), então o número vigente não é o da versão entregue. Já rodou:

- `gancho`: 10/10 (igual ao original)
- `linkedin-post`: 8/10 (era 9/10; dois casos trocaram de lado, e um que perdia passou a ganhar)
- `carrossel-roteiro`: 2 veredictos de 10
- `angulo` e `entrevista-voz`: não começaram

Falta terminar e escrever o placar com **duas colunas**: o número medido então e o número na versão entregue, dizendo qual commit foi medido em cada caso.

Sobre o 8/10: parte é variação do juiz. O mesmo caso perdeu numa rodada e ganhou na seguinte com o texto antigo idêntico, e o mesmo juiz puniu "num dia"/"numa tarde" como invenção numa rodada e aceitou na outra. Reportar a faixa, não o melhor número. Não mexer na skill para caçar o ponto; a decisão de aceitar 8/10, 9/10 ou corrigir a regra da leitura pessoal é do Hugo.

### 3. Tarefa 14, Hugo como cliente zero

Ele instala pelo GitHub numa pasta nova, faz a entrevista de voz, produz 1 post e 1 carrossel reais. Registrar cada atrito em `evals/results/cliente-zero.md` e corrigir no mesmo dia. É o único teste com humano de verdade antes da turma.

### 4. Tarefa 15, instalação limpa e versão

`INSTALAR.md`, teste numa conta de usuário limpa com um colaborador convidado, wrappers no Grok Bot (clone com token de leitura só deste repositório), link para o sistema no README de `hdoria/marketing-skills` e `hdoria/humanizar`, tag `v0.1.0`.

## Decisões que valem para qualquer mudança daqui pra frente

Todas estão no ledger com o motivo. As que mais mordem:

1. **voz.md dá estilo e as posições já declaradas pela pessoa, aplicadas ao fato como posição.** Nunca experiência, reação, sentimento ou fato. A posição aplicada precisa ser uma que o fato confirme ou contrarie, dita com as palavras do caso. Frase de assinatura no fecho não conta como leitura, e não se repete em peças consecutivas.
2. **Anti-invenção:** nada de número, caso, depoimento, nome, citação, cena, data ou sentimento inventado; nenhuma afirmação de qualidade que o contexto não sustente; um episódio não vira hábito nem regra geral, nem em primeira pessoa nem na forma impessoal. Falta vira `[FALTA: descrição]`.
3. **Tamanho do post é material, não contagem:** 8 a 10 fatos dão 1.500 caracteres, 2 ou 3 vão para o lado curto. Glosa não é material. Nada sai entre 900 e 1.400.
4. **Revisor:** aprovar em 85 ou mais sem crítico abaixo de 15; reescrever de 65 a 84; descartar abaixo de 65. Paralelismo negativo em qualquer forma que negue um termo para afirmar outro (fonte: `resources/dna-da-voz.md` seção 3F do vault do Hugo), e contraste sem negação não conta. Erro de conta ou data que muda um fato é achado de peso total.
5. **Anúncio pessoal** exige a frase da pessoa, o convite (ou a confirmação de que não há) e os nomes a agradecer, pedidos pelo `angulo`. Sem isso o texto sai curto e declarado, nunca inventado.
6. **Checagem mecânica não depende de modelo.** Quem orquestra roda o script.
7. **Exceção registrada:** o portão da Tarefa 7 fecha em 9 de 10. O caso perdido só seria ganho inventando o sentimento do Hugo, e o juiz premiou a invenção do lado antigo. Está no plano, não só no relatório.

## Riscos conhecidos para o dia um do comprador

1. Permissões de ferramenta e `jq` na primeira execução (todo comprador, primeira sessão). Está documentado no adendo da Tarefa 12; confirmar que o `INSTALAR.md` também diz.
2. Anúncio pessoal sai como bilhete curto quando a pessoa não dá a frase.
3. O revisor aprova pouco, e com variação entre modelos. Os posts publicados do Hugo ficam entre 42 e 79.
4. `evals/results/` está fora do git, então os portões só se ligam aos commits por disciplina e pelos relatórios.

## O que depende do Hugo

- Fazer a Tarefa 14 (1h30 a 2h).
- Escolher os 5 a 10 nomes da turma fundadora e convidar.
- Decidir o valor fundador dentro da faixa de R$297 a R$497.
- Decidir se aceita 8/10 no `linkedin-post` ou se quer a regra da leitura pessoal afrouxada.
- Fora do projeto e pendente por decisão dele: a exposição do Doria's Socials (cadastro aberto em produção), tratada depois de 25/09.
