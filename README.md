# sistema-conteudo

Plugin do Claude Code para o sistema de conteúdo de gestores e founders B2B: voz, pauta, gancho, post de LinkedIn e carrossel de Instagram, com revisão em contexto limpo.

## O que é

Um conjunto de especialistas (skills) que leem o contexto do comprador em `contexto-modelo/` e produzem peças de conteúdo em português do Brasil, na voz do autor, sem publicar nada automaticamente.

## Instalação

Passo a passo completo em [INSTALAR.md](INSTALAR.md): convite do repositório, credencial do git, instalação do plugin, pasta de contexto e primeiro uso.

Para desenvolver no próprio plugin, sem instalar:

```bash
claude --plugin-dir /caminho/para/sistema-conteudo
```

## Versão e release

A `version` em `.claude-plugin/plugin.json` sobe a cada release. Sem isso o auto-update de quem já instalou não entrega nada, porque o Claude Code só atualiza quando o número muda.

- **Patch** (0.2.0 para 0.2.1): ajuste de texto de uma skill, sem gatilho nem especialista novo.
- **Minor** (0.2.0 para 0.3.0): especialista novo ou gatilho novo no `motor`.
- **Major** (0.2.0 para 1.0.0): mudança de formato de arquivo da pasta de contexto que exige migração. A nota da release traz a instrução de migração, passo a passo, para quem já tem a pasta montada.

Para publicar: suba a versão no `plugin.json`, faça o commit e rode `claude plugin tag --push`. O comando cria a tag `sistema-conteudo--v<versão>` e confere se `plugin.json` e o marketplace concordam.
