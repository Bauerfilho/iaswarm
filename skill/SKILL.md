---
name: iaswarm
description: O ultracode invertido do Bauer — enxame de FROTA onde só outras IAs trabalham e NADA da casa executa (zero Agent/Workflow Fable). Use quando ele pedir "iaswarm", "enxame de frota", "resolve com as outras IAs", ou quando uma missão decomponível merecer motores heterogêneos com custo zero no plano Anthropic. A orquestradora decompõe, contrata, despacha, colhe, julga (juiz rotativo) e sintetiza — músculo é 100% da frota, com painel de progresso vivo por worker.
---

# iaswarm — enxame de frota (só outras IAs, nada daqui)

## ⛔ REGRA-MÃE (fail-closed, sem exceção)
**Nenhum worker da casa.** Proibido Agent tool, proibido Workflow, proibido subagente
Fable/Claude para EXECUTAR trabalho. O papel da orquestradora é exclusivamente:
decompor · escrever contratos · despachar pela frota · colher · armar o juiz ·
sintetizar e assinar. Se um worker exigir tool exclusiva da casa, a missão NÃO é
iaswarm — declare e proponha a rota normal.

## A CASCATA DE SELEÇÃO (nesta ordem)
1. **VOCAÇÃO filtra primeiro** — visual/SVG/PNG → agy · construção longa → grok, kimi ·
   código/raciocínio → codex, qwen · leitura-total/2ª opinião → dourada ·
   **revisão de bug/código → copilot, SEMPRE e SOMENTE** (sol+max) · volume barato → ollama.
2. **TIER decide o bolso** — ①ASSINATURAS → ②FREE reais (OmniRoute nemotron `:free`,
   Gemini free-tier via hermes, OpenCode Free) → ③CRÉDITOS (deepseek API · hermes rotas
   pagas · copilot premium-credits).
3. **A ORDEM DELE desempata e cai de fallback** — assinaturas: 1-agy · 2-kimi ·
   3-codex · 4-grok · 5-qwen · 6-ollama; créditos: 1-deepseek · 2-hermes · 3-copilot.
Braço em cooldown/cota → pula para o próximo da cascata e o desvio aparece no painel
(cinza, com motivo). Versões: sempre o catálogo VIVO do braço/OmniRoute, nunca lista fixa.

## CONTRATO DE WORKER (único, para todo braço)
Arquivo por worker com: missão (1 parágrafo) · escopo e fronteira de escrita ·
**ETAPAS enumeradas** (3-7; verificáveis) · instrução de progresso (abaixo) · caminho
do resultado (`resultados/<worker>.md`) · formato `missão:`/`resultado:` · proibições.
Worker é stateless: o contrato carrega TODO o contexto.

## PROGRESSO UNIVERSAL (ordem dele — sem exceção de braço)
Após CADA etapa concluída, o worker appenda 1 linha JSON no seu
`progress/<worker>.jsonl`:
`{"etapa": K, "de": N, "estado": "rodando", "nota": "<3-8 palavras>"}`
O protocolo mora também no arquivo de instrução de cada braço (QWEN.md/memórias,
capa da Kimi, AGENTS do codex, grok.md, agy) — o worker obedece porque a regra vive
NA CASA DELE. Brilho do painel = evidência em disco; barra não substitui gate.

## CICLO FECHADO + JUIZ ROTATIVO
- Colheita → **juiz de motor ≠ de TODO autor** (rotação de auditor) dá veredito por
  worker contra o contrato (etapas × resultado real).
- ITERA → re-despacho **no braço IRMÃO** (rotação de executor — nunca insistir no
  motor que falhou), nova rodada no painel.
- Síntese final assinada: `— síntese: Fable (orquestradora da frota)`.

## MECÂNICA (infra pronta em ~/.claude/scripts/iaswarm/)
1. Criar `~/.claude/iaswarm-runs/<run-id>/` com `missao.md`, `contratos/*.md`,
   `workers.tsv` (worker→braço→n_etapas→contrato).
2. `dispatch.sh <run-dir>` — despacha cada worker pelo adaptador do braço, sobe o
   painel (porta livre) e abre no navegador dele.
3. `watch.sh <run-dir>` armado no **Monitor tool** — a orquestradora só é acordada por
   TRANSIÇÃO (etapa completada, worker terminou, falha). Nunca poll manual.
4. Colher `resultados/`, despachar juiz, sintetizar, cristalizar placar na memória.

## PAINEL (obrigatório por rodada)
1 fileira por worker, bolinhas por etapa, **cor da IA** — marca conhecida usa a cor
oficial dela; braço de fora da casa recebe matiz derivado do hash do NOME (determinístico e
fora das faixas reservadas: coral=falha, cinza=pulado). Nenhum braço nasce sem cor — (agy azul-Google · kimi violeta ·
codex teal · grok branco-neon · qwen roxo · ollama âmbar · deepseek azul-profundo ·
hermes dourado-nous · copilot cobalto · dourada dourado) — concluída acesa com glow,
ativa pulsando, falha coral (universal), fila apagada, pulada cinza. Lindo com 1 ou 10.
