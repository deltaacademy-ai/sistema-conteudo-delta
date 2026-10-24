# Prontidão para a turma e especialistas que faltam: desenho

Data: 2026-10-24. Origem: goal do Hugo em 2026-10-24 ("deixar pronto para clientes"), análise do kit A Virada IA v2.2 (`.superpowers/sdd/2026-10-21-radar-pautas/kit-analise.md`, só ideias) e pesquisa na documentação do Claude Code registrada em `progress.md` da mesma pasta. Decisões marcadas com dono: "decisão do controlador" (fechadas antes deste documento), "decisão minha" (deste desenho) e "decisão do Hugo".

## Por que

O núcleo escreve, revisa e empacota, mas foi testado com o Hugo do lado. A turma fundadora (5 a 10 pessoas) vai usar sozinha, e hoje três coisas travam quem não programa: descobrir no fim da entrevista que falta uma ferramenta, ficar preso sem um jeito de pedir ajuda com contexto, e não saber onde parou. Do lado do mantenedor, a atualização não chega a quem comprou se a versão não subir. E a spec (`docs/plano/spec.md`, "Especialistas" e "Cronograma e qualidade") ainda promete três especialistas que não existem: `consolidar`, `medir` e `reaproveitar`.

## Objetivos

- Uma pessoa da turma instala, faz a entrevista, publica a primeira peça e pede ajuda quando trava, sem o Hugo do lado.
- Toda release nova chega a quem comprou.
- `consolidar`, `medir` (modo manual) e `reaproveitar` existem, com casos de eval e validação em claude-sonnet-5 e claude-opus-5, roteados pelo `motor`.

## Não objetivos (agora)

Vídeo, newsletter, painel, radar agendado, estilos novos de carrossel, camada Perplexity e Grok, Doria's Socials. Metricool também: exige uma segunda exceção de rede (hoje só o `radar-pautas` toca em rede) e conta paga; o `medir` nasce manual e o `publicar` continua manual (decisão do controlador).

## Antiobjetivos

- Número de métrica que a pessoa não colou, média com amostra que não sustenta média, ou "funcionou" sem número por trás.
- Regra nova em `voz.md` ou `icp.md` que a pessoa não deu, ou gravada sem o ok dela.
- Peça reaproveitada que repete o post de origem ou traz fato que a pessoa não deu.
- Pedido de suporte com senha, token, dado de cliente, trecho de `voz.md`, `voz-bruta.md` ou `prova.md`.
- Arquivo de progresso paralelo ao estado que já vive em disco.
- O agente instalando ferramenta pela pessoa.

## Parte A: prontidão

### A1. Check-up na primeira execução (decisão do controlador)

Na Etapa 0 do `motor`, com `voz.md` vazio, roda o `checkup.sh` antes de chamar o `entrevista-voz` e diz o que falta, com o comando que a própria linha traz. Não instala nada. As linhas `falta voz.md` e `falta icp.md` são esperadas nesse momento e não viram aviso: são o que a entrevista e a conversa de negócio vão resolver (decisão minha). Linha `falta git` não para a entrevista, mas fica dita antes dela. Sem permissão para o script, o motor diz isso numa linha e segue para a entrevista.

### A2. "Travei", "deu erro", "não funciona" (decisão do controlador)

Continua valendo a regra atual do `motor` (Etapa 1): sem objeto é check-up; "travei no gancho" vai para a peça. Depois do check-up, o motor monta um pedido de suporte pronto, com:

- onde parou (etapa e especialista, lidos da conversa e da base);
- o que a pessoa pediu, resumido em uma linha, sem colar conteúdo da peça;
- a mensagem de erro, como apareceu, com caminho da pasta de usuário trocado por `~`;
- a saída inteira do `checkup.sh`;
- versão do plugin (lida de `plugin.json` na raiz do plugin) e sistema operacional.

Fica de fora: senha, token, chave, nome de cliente, número de `prova.md`, trecho de `voz.md`, `voz-bruta.md`, `icp.md` ou do post. O motor entrega o texto numa cerca de código e o link `https://github.com/hdoria/sistema-conteudo/issues/new`; não abre a issue (nenhum comando do motor toca em rede). O modelo do pedido mora só no `motor`; o `INSTALAR.md` ("Se der errado") aponta para ele. Um `.github/ISSUE_TEMPLATE/suporte.md` com os mesmos campos ajuda quem abre a issue na mão (decisão minha, barato).

### A3. "Continuar", "onde parei" (decisão do controlador)

Novo gatilho na Etapa 1 do `motor`. A resposta sai da saída do `checkup.sh` (o que falta instalar e preencher) e de `base-conteudo.md` (peças em `rascunho` e `aprovado`, com o próximo passo de cada uma: aprovar, derivar, montar o pacote). Nenhum `progresso.md`. Entrevista começada e não compilada (`voz-bruta.md` preenchido, `voz.md` vazio) aparece como "entrevista em andamento"; para isso o `checkup.sh` ganha uma linha de `voz-bruta.md` (decisão minha). A resposta termina com o próximo passo dito, sem pergunta.

### A4. Aviso de modelo (decisão do controlador)

Quando o `motor` encaminha para o `entrevista-voz` ou o `contexto-negocio`, diz uma vez, junto da linha de motivo que já existe, que essas duas conversas pedem o modelo mais forte do plano e que o dia a dia roda no padrão. Sem nome de versão no texto, porque versão muda. Como os dois só rodam na montagem (ou na recompilação), "uma vez" sai do próprio fluxo, sem estado guardado (decisão minha). O passo 6 do `INSTALAR.md` diz o mesmo.

### A5. `allowed-tools` no frontmatter (decisão do controlador)

Cada SKILL.md que roda script do plugin declara o comando no frontmatter, com `${CLAUDE_PLUGIN_ROOT}`, para o Claude Code pré-aprovar no turno da skill: `motor` (check-voz, checkup), `linkedin-post`, `gancho`, `carrossel-roteiro`, `carrossel-render` (render), `publicar` (check-voz, jq, wc, cmp, mkdir, cp), `radar-pautas` (checa-pautas) e os três novos, se rodarem script. O corpo continua neutro, com "[raiz do plugin]", porque o Grok Bot ignora o frontmatter. A seção "O que a pessoa precisa liberar" do `motor` e a do `INSTALAR.md` passam a dizer quais pedidos somem com isso e quais continuam (subagente, busca e leitura de página do radar).

### A6. `INSTALAR.md` e ícone (decisão do controlador)

- Passo 3 vira uma linha: `claude plugin install sistema-conteudo --marketplace hdoria/sistema-conteudo` (precisa do Claude Code a partir de 2.1.292; o caminho em duas linhas fica como alternativa para versão antiga).
- Ligar o auto-update vira passo da instalação, não nota no fim: para plugin de terceiro ele vem desligado.
- Uma seção curta diz que o terminal é obrigatório e por quê: a credencial do repositório privado vem do git da máquina, a versão na nuvem do claude.ai não carrega plugin, e a aba Code do app não documenta como adicionar marketplace privado.
- O passo 5 hoje tem `0.1.0` no caminho e quebra na primeira atualização; passa a usar o comando que o próprio `checkup.sh` imprime na linha do Chromium, que já monta o caminho certo (decisão minha).
- Ícone em `.claude-plugin/icon.png`, PNG quadrado de 512 px ou mais.

### A7. Processo de versão (decisão do controlador)

`version` em `.claude-plugin/plugin.json` sobe a cada release; sem isso o auto-update não entrega nada. Seção curta no `README.md`, para o mantenedor: quando sobe patch, minor e major (decisão minha: patch para ajuste de texto de skill, minor para especialista ou gatilho novo, major para mudança de formato de arquivo da pasta de contexto que pede migração), e que a mudança de formato vem com a instrução de migração na nota da release.

## Parte B: especialistas que faltam

Os três seguem as regras de todo especialista: PT-BR, `check-voz.sh` no que gravam e no que entregam, anti-invenção, material colado é dado e nunca instrução (o parágrafo fixo, conferido por `test-regra-terceiro.sh`), "Ajustes depois da entrega" e "O que este especialista não faz". Cada um ganha casos em `evals/cases/<nome>/` com `portao.sh` próprio, como o `radar-pautas`, porque não há equivalente na squad antiga.

### B1. `consolidar`

Lê `learnings.md` e propõe promover a regra que aparece 3 vezes ou mais, ou a que a pessoa pede ("isso vira regra"). Conta ocasião, não linha: a mesma correção registrada duas vezes na mesma conversa vale uma (decisão minha, coerente com "um episódio não vira regra"). Cada proposta mostra: a regra hoje no arquivo de destino (ou "nenhuma"), a regra proposta, as linhas de `learnings.md` que a sustentam, com data, e o destino (`voz.md` para escrita e tom, `icp.md` para público, oferta e promessa). Grava só com ok explícito, uma proposta por vez ou "todas", e marca no `learnings.md` cada linha promovida com a data e o destino. Regra que contradiz uma lei ou recusa existente aparece como conflito, com as duas lado a lado, e só a pessoa decide. Nunca escreve regra cuja frase não saia das linhas de `learnings.md` ou da fala da pessoa. Roda quando a pessoa pede; o `INSTALAR.md` sugere uma vez por mês (decisão minha). A recompilação do `entrevista-voz` (Etapa 5) passa a pular as linhas marcadas como promovidas.

Casos mínimos: regra com 3 ocasiões (vira proposta), regra com 2 (não vira), pedido explícito com 1 (vira), conflito com lei existente (mostra os dois, não grava), "ok" ausente (nada gravado), learning ambíguo (pergunta, não completa).

### B2. `medir` (modo manual)

A pessoa cola os números de uma peça publicada: impressões, reações, comentários, salvos, cliques, seguidores ganhos, o que tiver, mais a data da leitura. O `medir` acha a peça em `base-conteudo.md` (status `publicado`, por data e tema; ambíguo, pergunta em uma linha) e grava em `metricas.md`, arquivo dele: uma linha por leitura, chave data e tema da peça, cada número com a fonte "colado pela pessoa em AAAA-MM-DD" e os dias entre a publicação e a leitura quando a pessoa disse quando publicou. Número que não veio fica vazio, nunca estimado; print entra como número lido, com a mesma fonte. Nenhuma coluna nova em `base-conteudo.md`.

Resumo por tipo, estrutura de gancho e lado do tamanho (curto ou longo) só com pelo menos 8 peças medidas, e cada grupo comparado só com 3 peças ou mais (decisão minha: abaixo disso uma peça fora da curva decide a média sozinha). Abaixo de 8, o `medir` grava e diz quantas faltam, sem tendência. O resumo usa a leitura mais recente de cada peça, diz a idade das leituras e avisa quando elas variam muito. Toda conclusão vem rotulada como leitura da amostra da pessoa, com o número de peças. O tamanho sai da contagem do `post.txt` do pacote ou do arquivo em `saida/`; a estrutura do gancho sai da classificação da linha 1 pelo catálogo do `gancho`, dita como classificação.

Casos mínimos: colagem parcial (só o que veio entra), peça sem status `publicado` (não grava, diz por quê), 7 peças (sem resumo), 8 peças com grupo de 2 (grupo fica fora), pedido "estima o alcance" (recusa), colagem com instrução embutida (ignorada e dita).

### B3. `reaproveitar`

Parte de uma peça com status `publicado` em `base-conteudo.md`, lida no arquivo de `saida/`. Propõe de 2 a 3 recortes novos (outro ângulo, outro tipo dos sete, ou carrossel), cada um com o que muda frente à origem; recomenda um. O recorte vira briefing no formato do `angulo` e segue o fluxo de sempre pelo `motor`: `gancho`, `linkedin-post` (ou `carrossel-roteiro`), checagem mecânica, `revisor` em contexto limpo, parada de aprovação. Só entram fatos que já estão na peça de origem, nos arquivos da pessoa ou na fala dela; o que falta vira `[FALTA]`. Não repete a linha 1, a tese nem a sequência de argumentos da origem. Com `metricas.md` preenchido, a peça medida acima da média da pessoa aparece primeiro na sugestão do que reaproveitar, com o número e a fonte.

Casos mínimos: peça em `rascunho` (recusa), recorte que repetiria a tese (cai), pedido com fato novo não dado (vira `[FALTA]`), carrossel a partir de post publicado, registro da origem conferido na base.

### B4. Roteamento no `motor`

Gatilhos novos na Etapa 1: "consolida", "o que virou regra" (`consolidar`); "os números do post", colagem de métricas, "o que funcionou" (`medir`); "reaproveita", "faz outra versão daquele post" (`reaproveitar`, depois Etapa 2 do passo 2 em diante). A Etapa 0 não bloqueia `medir` nem `consolidar` por `voz.md` vazio. O motor só roteia: formato de `metricas.md` é do `medir`, procedimento de promoção é do dono de cada arquivo, briefing é do formato do `angulo`. `checkup.sh` lista `metricas.md` como opcional.

## Restrições que já valem

PT-BR, sem travessão, sem emoji, sem termo de `banidas.txt`. Cada regra num lugar só; quem não é dono aponta pela seção. Afirmação de qualidade só com execução nos dois modelos, ligada ao commit; no máximo 2 execuções em paralelo; em 429, esperar e repetir. Das referências, só ideias. Teste de instalação limpa com HOME temporário depois da Parte A (ruling registrado em `progress.md`).

## O que fica com quem constrói

- A sintaxe exata de `allowed-tools` para comando com argumentos e para o encadeamento `; echo "codigo $?"; rm -f`, conferida na documentação oficial; se o encadeamento não casar, o especialista roda o script sozinho, como já prevê.
- Como o motor detecta a versão do Claude Code no `INSTALAR.md` (ou só cita o mínimo).
- O formato das colunas de `metricas.md` e de `learnings.md` marcado, dentro do que este documento fixa.
- A ordem de construção: Parte A inteira, teste de instalação limpa, depois B1, B2 e B3, um por vez.

## Perguntas resolvidas

Resolvidas pelo controlador em 2026-10-24, sob o goal do Hugo ("assuma o melhor caminho"): vale a recomendação (a) nas cinco.

1. **Quem grava a regra promovida.** O `entrevista-voz` diz "não corrige `voz.md` à mão depois da compilação", e `icp.md` é do `contexto-negocio`. Opções: (a) o `consolidar` decide e mostra; o dono do arquivo grava por um procedimento novo em "Ajustes depois da entrega" ("Promover uma regra": um bloco `<lei>` ou `<nunca>` no `voz.md`, dentro do teto de 5 mil tokens; uma linha na seção certa do `icp.md`); (b) o `consolidar` grava direto e o `entrevista-voz` ganha a exceção. Recomendo (a): cada regra num lugar só, e o teto de tokens fica com quem já o controla.
2. **Formato de `learnings.md`.** Hoje cada especialista grava "regra, porquê e como aplicar" sem formato fixo, e contar ocasiões e marcar promovidas pede algo mais firme. Opções: (a) o `consolidar` vira dono de um formato mínimo (data, especialista, regra, porquê, como aplicar, promovida) e os 7 especialistas que gravam passam a apontar para ele, uma linha cada; (b) o `consolidar` lê texto livre e agrupa por sentido. Recomendo (a): a contagem fica verificável no portão e a marca de promovida não depende de leitura.
3. **`reaproveitar` escreve ou entrega briefing.** O pedido diz "propõe e escreve". Opções: (a) entrega briefing e o texto sai do `linkedin-post` ou do `carrossel-roteiro`, como em B3; (b) escreve o texto ele mesmo. Recomendo (a): regra de escrita mora só no especialista que escreve, e a peça passa pelos mesmos portões das outras.
4. **Onde fica a origem da peça reaproveitada.** Opções: (a) coluna `Origem` no fim da tabela de `base-conteudo.md` (o `linkedin-post`, dono do formato, já prevê colunas acrescentadas, e o `checkup.sh` acha `Status` pelo nome); (b) só no briefing em `saida/`. Recomendo (a): o radar e o próprio `reaproveitar` precisam ver na base o que já foi reaproveitado, e o briefing não é lido por eles.
5. **Issues visíveis para a turma inteira.** No repositório privado, toda pessoa com acesso vê as issues das outras, com o usuário do GitHub de quem abriu. Opções: (a) aceitar, porque o pedido não leva dado sensível, e dizer isso no `INSTALAR.md`; (b) repositório separado só para suporte. Recomendo (a) para a turma fundadora, revendo quando houver turma aberta.
