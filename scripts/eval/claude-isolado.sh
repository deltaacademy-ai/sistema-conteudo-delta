#!/usr/bin/env bash
# uso: claude-isolado.sh [demais argumentos do claude...]
#
# Wrapper usado por run-case.sh e judge.sh para rodar `claude -p` sem herdar
# a configuracao pessoal do dono da maquina: CLAUDE.md global
# (~/.claude/CLAUDE.md), hooks de usuario (ex.: o Stop hook
# ~/.claude/hooks/check_style_stop.py, que reescreve a resposta na voz do
# Hugo), skills pessoais (ex.: linkedin-copy) e plugins instalados/sincronizados.
# Sem isso, tanto a saida da squad nova quanto a da squad antiga herdam a
# voz do Hugo de fora do experimento e o placar do juiz fica contaminado.
#
# --safe-mode desliga CLAUDE.md, skills, plugins instalados, hooks, MCP
# servers, comandos e agents customizados. Continua honrando o que este
# script passa explicitamente na linha de comando: --plugin-dir (o plugin
# sistema-conteudo em teste) e --append-system-prompt (o prompt do juiz).
# Autenticacao continua por OAuth normalmente (nao precisa de
# ANTHROPIC_API_KEY, ao contrario de --bare). Evidencia da investigacao em
# .superpowers/sdd/plano/task-1-2-report.md.
exec claude -p --safe-mode "$@"
