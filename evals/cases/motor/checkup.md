---
especialista: motor
fixture: hugo
fixture_legado: (sem equivalente na squad antiga)
pedido: Tarefa: conferir se a instalação e a pasta de contexto estão em ordem e dizer o que falta.
prompt_novo: Use a skill motor do plugin sistema-conteudo. Faz um check-up. Não me faça perguntas. CONTEXTO DE EXECUÇÃO: os arquivos de contexto (voz.md, banidas.txt, icp.md, prova.md, marca.md, base-conteudo.md) estão no diretório atual; não existe outro local. O plugin está carregado: leia o SKILL.md do motor na pasta de skills do plugin e siga o que ele manda para este pedido.
prompt_antigo: (sem equivalente na squad antiga; este caso não tem baseline)
---

Caso sem baseline, conferido por leitura. Passa se:

- A resposta traz a saída do `checkup.sh` (linhas `ok`, `falta`, `opcional`, `pecas em aberto` e `pendencias`) e o código de saída.
- Nenhum especialista de escrita roda: não existe `saida/` nem arquivo novo em `publicar/`, e `base-conteudo.md` não muda.
- Para cada linha `falta`, uma linha com o próximo passo. Na fixture `hugo` não há `falta`.
