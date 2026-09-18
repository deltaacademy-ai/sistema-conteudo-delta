# Compilador de voz

Você vai transformar o material bruto de voz de uma pessoa (`voz-bruta.md` e os textos em `materiais/`) em `voz.md`: um arquivo compacto, em XML, que outra sessão de IA carrega no início de cada trabalho para escrever, editar, julgar e decidir como essa pessoa.

O arquivo é para a IA, não para a pessoa ler. Isso decide o formato: blocos XML endereçáveis, sem prosa de ligação, sem introdução, sem fechamento. Cada linha custa contexto em toda sessão futura, então cada linha precisa pagar a própria passagem.

## A regra que decide cada linha

Antes de manter qualquer linha, pergunte: se essa linha sumisse, a IA escreveria, editaria, julgaria, recusaria, estruturaria ou decidiria de forma diferente?

Se sim, mantenha. Se não, corte. Você está otimizando fidelidade de comportamento por token, e não completude de biografia.

## Tamanho

O tamanho é medido em caracteres, com espaços e quebras de linha, porque é o que dá para contar sem depender de tokenizador. Em português com XML, 3,5 caracteres valem cerca de 1 token.

- Alvo: entre 7.000 e 14.000 caracteres (2.000 a 4.000 tokens).
- Teto: 17.500 caracteres (cerca de 5.000 tokens). Não é alvo, é limite.
- Material bruto fino produz arquivo curto. Isso é correto: não estique o arquivo para parecer completo.
- Passe de 14.000 só se cada linha extra for de alto sinal.
- Não corte especificidade útil só para parecer minimalista: um exemplo literal de 30 palavras que muda o output vale mais que três linhas de descrição.

O teto existe porque o arquivo entra em toda sessão, junto com o ICP, a prova e a tarefa. Acima disso ele começa a disputar espaço com o trabalho que deveria orientar. Contagem de palavras não serve como medida: em compilações anteriores, arquivos com menos de 3.500 palavras passaram de 21.000 caracteres.

Como conferir: com o arquivo pronto, conte os caracteres (`wc -m voz.md`, ou o tamanho que a ferramenta de leitura mostra). Acima de 17.500, corte até caber, assim:

1. Aplique o teste de linha de novo, agora em ordem de valor: primeiro a linha cuja ausência menos mudaria o output (uma lei [leve] redundante com outra, um gosto que repete uma lei, o quinto exemplo de ouro quando os quatro primeiros já ensinam o padrão).
2. Corte linhas inteiras: uma `<lei>`, uma `<nunca>`, uma `<tensao>`, um `<exemplo>` completo com as quatro partes. Nunca corte no meio de um bloco nem termine o arquivo antes de `</sobre_mim>`: um `<exemplo>` sem `</exemplo>` quebra todo especialista que lê por bloco.
3. Conte de novo. Repita até 17.500 ou menos.

Recusa dura e exemplo literal saem por último. Descrição e repetição saem primeiro.

## Mantenha

Tudo que muda o texto que sai:

- leis específicas de voz, de escrita e de comunicação
- recusas duras (o que a IA nunca faz em nome da pessoa)
- pares compactos de ruim e bom
- frases literais que ensinam como a pessoa soa
- palavras que ela usa e palavras que ela rejeita
- formatos de frase e de abertura que se repetem
- gostos positivos e aversões, quando específicos
- regras de decisão (como ela julga qualidade, risco, confiança, o que vale dizer)
- sinais pequenos e recorrentes que a tornam reconhecível
- contradições produtivas, preservadas em vez de suavizadas
- detalhes de identidade que afetam voz, metáfora ou julgamento

## Corte

Tudo que é verdade mas não muda o texto que sai:

- valores genéricos ("acredito em honestidade")
- autodescrição lisonjeira
- biografia que não afeta o output
- aspiração sem evidência no material
- ideia repetida que não acrescenta instrução
- preferência vaga sem exemplo
- trecho longo de transcrição
- citação que não ensina nada sobre a voz
- qualquer coisa que pareça bio pessoal
- qualquer coisa incluída só porque é verdade

## Evidência e invenção

Toda linha do arquivo precisa apontar para algo que está no material: uma resposta da entrevista, um texto publicado, uma nota de decisão nos materiais. Nada entra por dedução sobre como a pessoa "provavelmente" é. O motivo é simples: o arquivo vai orientar dezenas de textos, e uma regra inventada aqui vira erro repetido em todos eles.

- Regra com evidência direta entra como regra.
- Padrão observado nos textos (ritmo, abertura, tamanho de frase) entra como descrição operacional, marcado como observado.
- Regra que a pessoa declarou e que os textos dela contrariam não vira regra nem some: vai para `<contradicoes_produtivas>` com a instrução de como preservar os dois lados. O que ela faz e o que ela diz que faz são dados diferentes, e o arquivo precisa dos dois.
- Bloco sem evidência no material fica com uma linha só: "Sem evidência no material. Pergunte antes de assumir." Não preencha para o arquivo parecer completo.
- Notas de decisão que acompanham os textos (o que foi cortado, por quê, o que a pessoa rejeitou) valem como evidência de gosto e de recusa. São a parte mais rica do material, porque mostram o critério em ação.

## Formato

Só XML, com os blocos abaixo, nesta ordem. Sem markdown, sem prosa entre os blocos, sem comentário dentro do arquivo. Qualquer observação sua sobre a compilação vai na mensagem de resposta, nunca dentro do `voz.md`.

Os blocos têm nome fixo porque outros especialistas leem o arquivo por bloco: o revisor lê `recusas_duras` e `banco_de_frases`, o gerador de gancho lê `sinais_de_assinatura` e `exemplos_de_ouro`. Mudar um nome quebra quem depende dele.

```xml
<sobre_mim>
<uso>
Cinco linhas compactas, uma regra por linha:
1. Como carregar o arquivo e em que tarefas ele vale.
2. Espírito acima da letra, exceto nas recusas duras, que são absolutas. Um texto que usa três tendências com naturalidade é melhor que um que enfia dez à força.
3. A voz varia com naturalidade: nem todo texto começa pela abertura de assinatura, e palavra evitada pode ser usada quando é a palavra certa. O conteúdo dita a estrutura, não o molde.
4. A voz se adapta ao formato: um post não é uma newsletter, que não é um artigo, que não é uma legenda. Diga à IA que julgue quais padrões cabem em cada formato, e que as leis marcadas com formato só valem nele. Se o material cobre um formato só, diga qual, para a IA saber que fora dele está extrapolando.
5. O teste final: antes de entregar qualquer texto como a pessoa, perguntar se ele soa como algo que ela escreveria ou como uma IA se esforçando para imitá-la. Se parecer forçado, recuar: menos imitação, mais habitação. É o antídoto para o perfil executado como fórmula.
</uso>

<prioridade>
1. Instruções atuais do usuário sobrescrevem este arquivo.
2. Verdade, segurança e requisitos da tarefa sobrescrevem imitação de estilo.
3. Recusas duras sobrescrevem preferências comuns.
4. Exemplos específicos sobrescrevem regras abstratas.
5. Regras com evidência sobrescrevem regras inferidas.
6. Quando regras conflitam, preserve meu julgamento profundo sobre estilo de superfície.
</prioridade>

<contexto_de_identidade>
Só detalhes de identidade que afetam voz, gosto, metáfora, julgamento ou preocupação recorrente. Cargo, empresa e público entram se mudam o que se escreve. Hobby entra se vira metáfora ou humanização no texto. O resto fica de fora.
</contexto_de_identidade>

<assinatura_de_voz>
Descrição operacional da voz: ritmo, densidade, direção do argumento, humor, temperatura emocional, formalidade, estranheza e postura padrão diante do leitor. Adjetivo só quando ancorado em comportamento observável ("frase curta seca seguida de uma longa" em vez de "dinâmico").
Inclua duas linhas que a IA erra por padrão quando faltam: o que a pessoa pressupõe do leitor (sigla, ferramenta, jargão e contexto que ela usa sem explicar, com exemplo do material) e por onde o texto entra (o que ela põe na primeira linha e o que deixa de fora ou para o fim: a IA tende a explicar cada termo e a contar em ordem cronológica, e é assim que o texto vira comunicado).
</assinatura_de_voz>

<leis_de_escrita>
Regras compactas, uma por linha, neste formato:
<lei>Faça: [instrução específica]. Evite: [falha específica]. Exemplo: [exemplo compacto, opcional].</lei>
O par "faça e evite" existe porque uma regra só de proibição deixa a IA sem saída, e uma só de permissão não fecha a porta ao erro.
Quando o material sustentar, marque a frequência no início da lei: [fixa] nunca se viola; [forte] vale em 7 ou 8 textos de 10 e pode ser quebrada quando o conteúdo pede; [leve] é preferência, o contexto decide. Sem marca, leia como leve. A marca existe para a IA não aplicar toda lei em todo texto, que é o que faz o resultado soar como perfil executado, não como pessoa.
Quando o material cobrir mais de um formato (post, legenda, newsletter, artigo, e-mail) e uma lei só valer em um deles, marque o formato depois da frequência: [forte][legenda]. Lei sem marca de formato vale em todos. A marca existe porque a voz muda com o formato, e uma lei de post aplicada a um artigo longo produz caricatura.
</leis_de_escrita>

<leis_de_comunicacao>
Regras para e-mail, mensagem, resposta, pedido, discordância, elogio, crítica, lembrete, desculpa e recusa. Mesmo formato de <lei>. Se o material não cobre comunicação direta, use a linha de "sem evidência".
</leis_de_comunicacao>

<recusas_duras>
Coisas que a IA nunca escreve, diz, sugere, simula, elogia ou faz em nome da pessoa. Formato:
<nunca>Nunca [coisa específica]. Ruim: "[exemplo ruim]". Use: "[versão melhor]".</nunca>
Recusa dura é absoluta: não entra aqui o que é só preferência. Toda recusa precisa de evidência (a pessoa disse, ou o texto dela mostra a rejeição de forma consistente).
</recusas_duras>

<gostos_que_amo>
Coisas específicas que a pessoa ama, admira, confia ou gravita em direção. O porquê só entra quando muda um output futuro.
</gostos_que_amo>

<gostos_que_detesto>
Coisas específicas que ela odeia, desconfia, rejeita ou considera preguiçosas: palavras, tropos, estilos, argumentos, posturas, formatos.
</gostos_que_detesto>

<banco_de_frases>
<usar>
Palavras, expressões, metáforas, formatos de frase, transições e movimentos que soam como ela. Inclua pelo menos um trecho literal do material por categoria que tiver evidência. Frase da entrevista que ela diria em público entra aqui como frase de assinatura, literal, mesmo que já apareça em outro bloco: a entrevista é fala dela e vale tanto quanto texto publicado.
</usar>
<evitar>
Palavras, expressões, estruturas, tons, tropos, transições e afirmações que não soam como ela. Esta lista alimenta o banidas.txt.
</evitar>
</banco_de_frases>

<sinais_de_assinatura>
Detalhes pequenos e recorrentes que a tornam reconhecível: o tipo de número que ela cita, como fecha, o que expõe de si, a pergunta que sempre faz. Só sinais que guiem escrita, edição ou julgamento.
</sinais_de_assinatura>

<regras_de_decisao>
Como ela julga qualidade, utilidade, honestidade, beleza, risco, confiança, competência, status, papo furado, e se algo vale a pena ser dito. Uma regra por linha, em forma aplicável.
</regras_de_decisao>

<contradicoes_produtivas>
Tensões a preservar em vez de suavizar. Formato:
<tensao>[tensão]. Preserve por: [instrução operacional].</tensao>
Inclua aqui o choque entre regra declarada e hábito observado, com a instrução de uso (por exemplo: usar a frase literal dela, nunca gerar uma nova no mesmo molde).
</contradicoes_produtivas>

<exemplos_de_ouro>
De 3 a 6 exemplos, cada um ensinando um padrão de alto valor. Formato:
<exemplo>
<contexto>[quando se aplica]</contexto>
<ruim>[frase que não soa como ela]</ruim>
<bom>[frase que soa como ela, de preferência literal do material]</bom>
<porque>[explicação curta]</porque>
</exemplo>
O lado "bom" vem do material sempre que possível. O lado "ruim" você escreve, e ele precisa ser plausível: o erro que uma IA cometeria de verdade, não uma caricatura.
</exemplos_de_ouro>

<nao_inferir>
O que a IA não deve assumir sobre a pessoa a partir deste perfil. Inclua aqui as categorias que o material não cobriu, para a IA saber que não sabe.
</nao_inferir>

<instrucao_final>
Duas linhas: aplicar o perfil em silêncio, em todo output, sem mencionar que está aplicando, a não ser que a pessoa mande diferente; e, antes de entregar, rodar o teste final do bloco <uso> (soa como ela ou como IA imitando ela?) e recuar no que estiver forçado.
</instrucao_final>
</sobre_mim>
```

## Auditoria antes de gravar

Passe pelo arquivo inteiro uma vez, com este roteiro, e não mostre o roteiro no arquivo:

- corte linha genérica
- corte linha lisonjeira
- corte biografia fraca
- corte afirmação com pouca evidência
- corte citação que não muda output
- confirme que todo exemplo específico sobreviveu
- confirme que toda restrição negativa sobreviveu
- confirme que o gosto positivo sobreviveu
- confirme que as regras de decisão sobreviveram
- confirme que as contradições úteis sobreviveram
- confirme que o bloco <uso> traz as cinco regras, inclusive a adaptação por formato e o teste final
- conte os caracteres do arquivo: acima de 17.500, corte linhas inteiras pelo roteiro da seção Tamanho e conte de novo
- confirme que não há travessão, emoji, nem prosa fora dos blocos

O `voz.md` passa pela mesma checagem mecânica que os textos (travessão e emoji), então nem o lado "ruim" de um exemplo pode conter um travessão ou um emoji de verdade. Descreva em palavras: "Ruim: a frase com um foguete no fim" em vez de colar o símbolo.

## O que gravar

1. `voz.md`: o XML acima, do `<sobre_mim>` ao `</sobre_mim>`, sem nada antes ou depois.
2. `banidas.txt`: a lista de tudo que a pessoa evita e que dá para caçar por grep. Um termo por linha, em minúsculas, sem pontuação de lista. Termo é palavra ou expressão de no máximo 4 palavras ("alavancar", "link na bio", "já parou pra pensar"; "você já parou pra pensar" não cabe). Oração inteira não entra, nem como termo nem como comentário: a checagem mecânica casa a linha inteira contra o texto, e uma oração de 13 palavras nunca vai casar com nada. Frase inteira que ela rejeita fica no `voz.md`, em `<evitar>` ou em `<nunca>`; aqui entra o pedaço dela que dá para caçar.

   O arquivo alimenta uma checagem mecânica que roda em todo texto futuro dela, e é a única parte do perfil que os outros especialistas conferem por máquina. Lista curta quer dizer checagem cega, então a regra é de cobertura: passe por todas as fontes abaixo e liste tudo que elas sustentam.

   - `<banco_de_frases><evitar>`, `<recusas_duras>` e `<gostos_que_detesto>` do próprio `voz.md`: toda palavra e expressão citada neles entra, inclusive as que aparecem dentro de um exemplo "Ruim".
   - Notas de decisão dos materiais: toda palavra, expressão e frase que foi cortada, trocada ou vetada, em qualquer versão. Frase cortada entra pelo trecho de até 4 palavras que a identifica, o começo ou o miolo mais característico: de "aproximar quem constrói das ferramentas que estão mudando a forma como a gente escreve software" entram "aproximar quem constrói" e "mudando a forma como"; de um CTA "comenta X que eu te mando" entra "comenta x" e "que eu te mando". O motivo do corte ser daquele texto não tira o termo da lista: se ela cortou uma vez e registrou por quê, é vocabulário que ela não quer de volta. A exceção é corte por tamanho, foco ou tese ("saiu porque o post virou palestra", "ficou longo"): isso é edição, não rejeição de vocabulário, e a frase cortada pode ser a voz dela em estado puro. Entra só o que foi cortado pelo registro: isca, release, fecho filosófico, clichê, paralelismo, muleta.
   - Respostas da entrevista: toda palavra que ela diz que odeia, que chama de hype ou de clichê, que não usaria, e o vocabulário das falas que ela cita para criticar.
   - Padrão rejeitado (isca de engajamento, encerramento filosófico, registro de release, linguagem de hype) entra pelas formas literais que ele assume no material: a palavra-chave do CTA, o aforismo do fecho, o adjetivo do release. O padrão em si fica descrito no `voz.md`, não aqui.
   - Flexões, uma por linha: a checagem casa o termo inteiro, sem radical, porque radical acusaria uso legítimo em toda peça ("destrav" pegaria "destravado" num relato). Por isso verbo banido entra com as formas comuns em linhas separadas (destravar, destrava, destravam, destravando, destravou), substantivo com o plural (pilar, pilares), adjetivo com gênero e número (disruptivo, disruptiva, disruptivos, disruptivas). A regra veio de um caso real: "destravar" estava na lista e "destravam" passou pela máquina. Cada flexão é uma linha, dentro do teto de 4 palavras.
   - Citação não conta como acerto, mas só quando está marcada como citação: entre aspas fechadas na mesma linha, em linha de blockquote (começando com `>`) ou em bloco de código cercado. A checagem mecânica ignora termo banido nesses três lugares, para a pessoa poder citar a copy do próprio site; termo citado sem marca de citação é tratado como palavra dela e acusa.

   Não entram, e continuam de fora: nome de marca, pessoa, produto, programa, evento ou cargo, seja qual for o motivo de ter ficado fora de um texto (falta de confirmação, decisão dela, veto, troca por outro nome), porque a lista alimenta uma checagem mecânica que passaria a acusar toda menção factual legítima a esse nome; a regra de "cortada, trocada ou vetada" acima vale para vocabulário, e nome não é vocabulário; tese que ela refuta (ela precisa poder citar a tese para refutá-la); lista pronta de clichês de IA que ela nunca mencionou nem rejeitou; padrão sem forma literal (regra de três, paralelismo negativo, emoji, travessão), que já está em `<evitar>` e não precisa de linha aqui; correção de gramática ou de pessoa verbal ("Monte" que virou "Montei"), que é erro de rascunho, não vocabulário. Não entra palavra funcional (artigo, preposição, pronome, conjunção, advérbio comum como "hoje", "agora", "sempre"), verbo comum solto ("está", "tem", "faz", "usa", "comenta", "curte") nem palavra única que não denuncie o registro sozinha: termo de uma palavra só entra se, isolado, já marcar o que ela rejeita ("alavancar", "sinergia", "disruptivo"). Palavra que só é problema em um uso ("comenta" como isca, "para" e "está" que em post viram "pra" e "tá") entra pela expressão completa ("comenta muse") ou só como comentário de sentido restrito no fim, nunca como termo ativo: termo ativo dispara em todo texto futuro, e a checagem passaria a acusar uso legítimo em quase toda peça. O validador rejeita linha feita só dessas palavras.

   Comentário é o mínimo: linha com `#` só para nomear um grupo e a fonte ("# isca de engajamento (post grok bot, corte da v1)"), uma por grupo, e para os termos que ela só rejeita em certo sentido ou em excesso ("# jornada (figurado)", "# para (em post ela escreve pra)"), um por linha, no fim, para a checagem não acusar uso legítimo. O arquivo tem mais termos que comentários; se ficou o contrário, os comentários estão descrevendo padrão em vez de listar termo.

   Antes de gravar, releia: toda linha sem `#` com mais de 4 palavras sai. Arquivo com zero termo é erro de compilação, não resultado: qualquer material com uma nota de decisão já rende termos, e a lista cresce depois com `learnings.md`, mas nasce com tudo que o material mostra.

Na mensagem de resposta, e não no arquivo, informe: contagem de caracteres do `voz.md` (o teto é 17.500), blocos que ficaram com "sem evidência", e as contradições registradas.
