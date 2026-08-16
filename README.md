# 🐝 iaswarm

**Esta skill é para quem trabalha com mais de uma IA** e quer delegar as missões
grandes aos provedores que já paga — maximizando desempenho, espalhando o peso dos
custos entre as assinaturas e chegando a resultados melhores, mais rápido.

Orquestrar **não é repassar** — o trabalho se divide assim:

| quem | executa o quê |
|---|---|
| **IA orquestradora** (a que ativa a skill) | grande parte do trabalho: decompõe a missão, **escreve os contratos** (etapas, fronteiras, critérios verificáveis), despacha e **pilota** os CLIs, vigia as transições, **destrava incidentes** (worker preso, cota, diálogo de aprovação), colhe os resultados, arma o juiz, **arbitra os vereditos** e assina a síntese final |
| **Workers** (os outros provedores, em paralelo) | o **músculo das sub-tarefas**: pesquisa, geração, código — cada um numa frente independente e autocontida, reportando progresso etapa a etapa no painel |
| **Juiz** (motor diferente de todos os autores) | **re-verifica amostras por conta própria** e dá veredito por worker — heterogeneidade virando auditoria de graça |

A única coisa que a skill **proíbe** à orquestradora é executar o músculo ela mesma —
é isso que espalha o custo e mantém quem julga separado de quem produz.

> Inspirada na habilidade `/swarm` do Kimi Code e no modo ultracode do Claude Code —
> e nascida do encontro dos dois: a dispersão de um, a exigência do outro.

## Instalação

```bash
git clone https://github.com/Bauerfilho/iaswarm && cd iaswarm && ./install.sh
```

Instala os scripts + painel em `~/.claude/scripts/iaswarm` e a skill em
`~/.claude/skills/iaswarm` (destinos customizáveis via `IASWARM_SCRIPTS` /
`IASWARM_SKILL`). Depois: adapte as funções `despacha_*` aos SEUS CLIs de IA
(~10 linhas por braço) e dispare sua primeira missão com o modelo em
[`exemplos/garimpo-repos/`](exemplos/garimpo-repos/).

## O ciclo

```
missão → contratos (etapas enumeradas) → dispatch paralelo nos CLIs
       → progresso universal (1 linha JSON por etapa concluída)
       → painel vivo (bolinha acende na cor da IA)  +  watch (eventos por transição)
       → colheita → JUIZ (motor ≠ de todo autor, com spot-check próprio)
       → síntese assinada
```

## Caso real (2026-08-15, primeira prova de fogo)

3 workers (Qwen Code · Kimi CLI · Codex CLI) garimparam os melhores repositórios em
9 categorias: **45 repos verificados um a um via `gh` (estrelas, licença, último push),
15/15 etapas reportadas ao vivo, 0 falhas, 0 alucinações** no spot-check do juiz
(GitHub Copilot re-rodou o cartório por conta própria). Resultado completo em
[`exemplos/garimpo-repos/`](exemplos/garimpo-repos/).

## Estrutura

| caminho | o que é |
|---|---|
| `bin/dispatch.sh` | despacha os workers pelos adaptadores + sobe o painel |
| `bin/watch.sh` | agrega progresso → `state.json`; emite 1 linha por TRANSIÇÃO (para armar em monitores) |
| `bin/state.py` | o agregador (workers.tsv + progress/*.jsonl + resultados/ → state.json) |
| `painel/painel.html` | painel de bolinhas: cor por IA, glow por etapa, falha coral, zero dependência |
| `skill/SKILL.md` | a "lei" do enxame para o agente orquestrador (formato skill) |
| `exemplos/` | contrato-modelo + caso real completo |

## Princípios (o que faz funcionar)

1. **Contrato universal**: todo worker recebe um arquivo com missão, escopo, fronteira
   de escrita e ETAPAS enumeradas — e reporta cada etapa concluída com 1 linha JSON.
   Brilho no painel = evidência em disco, nunca autoconfiança.
2. **Cartório**: afirmação verificável exige verificação embutida no contrato
   (no caso real: nenhum repositório entra sem `gh repo view` confirmar).
3. **Juiz rotativo**: quem julga não é quem produziu — e é de motor DIFERENTE.
   O juiz refaz amostras por conta própria (anti-alucinação estrutural).
4. **Ciclo aberto no worker, fechado no orquestrador**: worker roda uma rodada e para;
   re-despacho (no braço IRMÃO, nunca no que falhou) é decisão do orquestrador.
5. **Falha nunca é silêncio**: worker que trava reporta `falhou` + motivo; o watch
   emite a transição; o painel pinta coral.

## Estado (v0.1 — honesto)

- Adaptadores incluídos são os da casa de origem (Qwen Code `-y` · Kimi via tmux com
  babá de aprovações · Codex `exec` · Ollama por marcador de stdout · agy/grok beta).
  **Generalização por arquivo de config é o TODO nº 1** — hoje você adapta editando
  `bin/dispatch.sh` (funções `despacha_*`, ~10 linhas cada).
- Testado em macOS (zsh, tmux 3.7, python3). Painel: HTML puro + `python3 -m http.server`.
- Nascido e provado em produção real em um único dia — maturidade é a de um dia bem vivido.

## Licença

MIT.
