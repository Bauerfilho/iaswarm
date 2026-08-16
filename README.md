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

## v0.2 (2026-08-16) — o que a segunda execução real quebrou

A v0.1 nasceu de um dia. A segunda missão real (5 workers, 5 braços simultâneos) achou três
defeitos que a primeira não tinha exercitado. Dois estão corrigidos aqui; o terceiro está
documentado porque é comportamento, não bug.

**1. `agy` e `grok` travavam esperando aprovação — CORRIGIDO**
Os dois adaptadores estavam marcados `# BETA: validar a forma de chamada no 1º uso real` e
não passavam `--dangerously-skip-permissions`. Num despacho headless o worker fica parado
pedindo uma aprovação que ninguém vai dar: sem erro, sem log, sem falha — só "despachado"
para sempre. Foi exatamente o que o comentário previa que aconteceria, e aconteceu.

**2. O painel nascia morto — CORRIGIDO**
`dispatch.sh` gerava o `state.json` **uma vez** e subia o servidor HTTP. Quem regenerava era
o `bin/watch.sh`, um passo separado que só quem leu a SKILL.md sabe que precisa armar.
Resultado para quem clonava o repo: painel congelado em `0/N` no instante do disparo, com os
workers trabalhando normalmente por baixo. **O pior tipo de defeito — parece quebrado estando
inteiro.** Agora o `dispatch.sh` sobe seu próprio atualizador em background (2s), que morre
sozinho quando todos os workers chegam a estado terminal. O `watch.sh` continua existindo
para o que é dele: emitir TRANSIÇÕES para o Monitor da orquestradora. Duas responsabilidades,
duas peças, nenhuma dependendo de alguém lembrar.

**3. Braço de fora da casa nascia sem cor — CORRIGIDO**
O painel só conhecia os 10 braços de origem; qualquer outro caía no fallback `#8fb0ba`,
que é **a mesma cor do texto secundário** e quase idêntica ao cinza de "pulado". Quem
clonasse e plugasse o próprio provedor via um adaptador seu via o worker nascer parecendo
apagado. Agora são três camadas:
- **marca conhecida** → cor oficial (openai, anthropic, google/gemini, mistral, meta/llama,
  cohere, perplexity, groq, together, openrouter, xai, nvidia, huggingface, azure, bedrock,
  vertex, zhipu/glm, minimax, cerebras, replicate, fireworks, modal, fal… além dos 10 da casa)
- **alias e prefixo** → normalizados (`gpt-5`→openai · `claude`/`opus`/`sonnet`→anthropic ·
  `k3`→kimi · `nemotron`→nvidia · `qwen3-coder`→qwen · `openai-compatible-chat-abc123`→openai)
- **desconhecido** → matiz derivado do hash do NOME: determinístico (o mesmo braço tem sempre
  a mesma cor), distinto entre si, e **fora das faixas reservadas** — coral é falha, cinza é
  pulado, e um braço novo jamais deve se confundir com nenhum dos dois.

**4. `0/N` parado não significa travado — COMPORTAMENTO, não bug**
A granularidade do reporte é do worker, não da infra. Na missão de 16/08 o Codex ficou
**20 minutos em `0/5`** enquanto varria dez diretórios — 166 KB de log, `find`/`stat`/`ls`
rodando o tempo todo — porque só appenda a linha de progresso ao FECHAR a etapa. No mesmo
run, a agy reportou 6 vezes e o Qwen 5. **Antes de concluir que um worker morreu, olhe
`logs/<worker>.log`: crescendo = vivo.** O par que decide é *stderr + artefato*, nunca o
contador de etapas. (Um heartbeat derivado do log é o próximo passo — fora desta versão
porque ainda não foi testado, e aqui não se publica código não exercitado.)

## ⚠️ Segurança — leia antes de usar

**Os workers rodam com permissões amplas.** Os adaptadores auto-aprovam ferramentas:
Qwen com `-y`, agy e grok com `--dangerously-skip-permissions`, Kimi com babá que responde
"aprovar" aos prompts. Sem isso não existe despacho headless — um worker que para para pedir
permissão a ninguém fica parado para sempre. É uma troca consciente, não um descuido.

O que isso significa na prática, sem eufemismo:

- **A fronteira de escrita é o CONTRATO, e contrato é texto.** Se o seu contrato diz
  "somente leitura", você está confiando no worker obedecer. Não há sandbox aqui.
- **Escreva contratos com fronteira explícita** — caminhos permitidos nomeados um a um — e
  trate isso como a única trava que existe.
- **Não despache contrato que você não leu** e não aponte workers para diretório que você não
  pode perder. Rode em repositório versionado, ou com backup, ou em cópia.
- **Se o seu ambiente exige isolamento real**, troque o adaptador por uma chamada em
  container/sandbox antes de usar em produção. Cada `despacha_*` tem ~10 linhas; é o ponto
  certo para plugar seu confinamento.

A alternativa — pedir aprovação a cada tool — mata a premissa do enxame. Preferimos declarar
o risco em voz alta a escondê-lo atrás de um default que parece seguro e não é.

## Estado (honesto)

- Adaptadores incluídos são os da casa de origem (Qwen Code `-y` · Kimi via tmux com
  babá de aprovações · Codex `exec` · Ollama por marcador de stdout · agy/grok — agora
  validados em uso real).
  **Generalização por arquivo de config é o TODO nº 1** — hoje você adapta editando
  `bin/dispatch.sh` (funções `despacha_*`, ~10 linhas cada).
- Testado em macOS (zsh, tmux 3.7, python3). Painel: HTML puro + `python3 -m http.server`.
- Duas missões reais em dois dias. Maturidade é a de dois dias bem vividos — e o segundo
  serviu justamente para descobrir o que o primeiro não tinha tocado.

## Licença

MIT.
