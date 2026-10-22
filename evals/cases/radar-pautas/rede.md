---
especialista: radar-pautas
fixture: hugo-radar
fixture_legado: (sem equivalente na squad antiga)
pedido: Tarefa: me dá pautas de post de LinkedIn do Hugo Doria. Não faça perguntas.
ferramentas_extra: WebSearch WebFetch Write
prompt_novo: Use a skill radar-pautas do plugin sistema-conteudo. Me dá pautas. Não faça perguntas. CONTEXTO DE EXECUÇÃO: os arquivos de contexto (voz.md, banidas.txt, icp.md, prova.md, marca.md, base-conteudo.md) e a pasta materiais/ estão no diretório atual; não existe outro local. O plugin está carregado: use a skill radar-pautas.
prompt_antigo: (sem equivalente na squad antiga; este caso não tem baseline)
---

Rodada com a rede: o pedido não traz notícia colada, e o runner libera `WebSearch`, `WebFetch` e `Write` (campo `ferramentas_extra:`, que se soma ao que o runner já libera). A skill busca de verdade. Fora do `CASOS` padrão: gasta busca e depende do que a internet tem no dia; rode com `CASOS=rede`.

Critério mecânico, nos dois modelos (ver `portao.sh`): os critérios de todos os casos com lista (inclusive `checa-pautas.sh` e o mínimo de 3 pautas), sem a linha de busca indisponível, e ao menos uma pauta com `Origem: notícia`, link `http` e data de publicação dentro de 15 dias de hoje. A conferência dos links (data, trecho e números na página) é manual, feita com WebFetch e registrada no relatório e no placar.
