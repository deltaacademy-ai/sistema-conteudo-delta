#!/usr/bin/env bash
# uso: claude-isolado.sh [demais argumentos do claude...]
#
# Wrapper usado por run-case.sh e judge.sh para rodar `claude -p` sem herdar
# a configuracao pessoal do dono da maquina: CLAUDE.md global
# (~/.claude/CLAUDE.md), hooks de usuario, skills pessoais (ex.: linkedin-copy),
# plugins instalados e conectores MCP da conta. Sem isso, tanto a saida da
# squad nova quanto a da squad antiga herdam a voz do Hugo de fora do
# experimento e o placar do juiz fica contaminado.
#
# --setting-sources "" nao carrega nenhuma fonte de configuracao (user,
# project, local): some o CLAUDE.md global, as skills e os plugins do usuario
# e os hooks. --strict-mcp-config sem --mcp-config tira todos os servidores
# MCP, inclusive os conectores do claude.ai. O que este script recebe
# explicitamente continua valendo: --plugin-dir (o plugin em teste, com as
# skills carregadas) e --append-system-prompt (o prompt do juiz).
# Autenticacao continua por OAuth (nao precisa de ANTHROPIC_API_KEY).
#
# Historico: a versao da Tarefa 2 usava --safe-mode. Na Tarefa 3 a sonda do
# evento system/init mostrou que --safe-mode registra o plugin de
# --plugin-dir mas nao carrega as skills dele, entao nenhum especialista
# rodava de verdade. Evidencia em .superpowers/sdd/plano/task-3-report.md.
exec claude -p --setting-sources "" --strict-mcp-config "$@"
