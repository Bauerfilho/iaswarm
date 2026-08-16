# 🐝 iaswarm · Garimpo de repositórios — SÍNTESE FINAL (2026-08-15)

**Enxame:** 3 workers de assinatura (qwen · kimi · codex), 15 etapas, 45 repositórios
cartoriados via gh, 0 falhas, 0 alucinações no spot-check do juiz (Copilot, sol/max).
Veredito do juiz: codex PASS · qwen/kimi ITERA por acabamento de formato (absorvido
nesta síntese; substância aprovada 45/45).

## OS IMPERDÍVEIS POR CATEGORIA (consolidado das 3 frentes + veredito do juiz)

| categoria | imperdível | por quê |
|---|---|---|
| PDF | **opendatalab/MinerU** + **docling** | parsing PDF→markdown pronto pra LLM — a porta de entrada de toda fonte da fábrica |
| Word/docs | **microsoft/markitdown** + **iOfficeAI/OfficeCLI** | o conversor-tudo (já é hook da casa) + suíte Office feita pra agentes |
| Planilhas | **duckdb** + **pandas** + **XlsxWriter** | ler, analisar e gerar sem dependência externa |
| Computador | **bytedance/UI-TARS-desktop** | computer-use em desktop real — a lacuna que a frota ainda tem |
| Navegador | **browser-use/browser-use** (109k) + **playwright** | navegação autônoma pronta pra virar braço + a base consagrada (já via MCP) |
| Coding | **anomalyco/opencode** (198k) + aider/OpenHands/ast-grep | o harness aberto mais adotado — e já é cliente do OmniRoute da casa |
| Agentes/skills | **obra/superpowers** (272k) + mem0/langgraph/crewAI | a mina de disciplina de skills; os outros pra minerar padrões de orquestração |
| Terminal | **rtk-ai/rtk** (76k) + fzf/lazygit + **witr** | o nosso rtk consagrado pelo mercado; witr = causalidade de processo (remédio da lição do wrapper) |
| UI/front-end | **knadh/oat** + **open-props** + shadcn (referência) | vanilla 10KB + tokens CSS — os encaixes diretos do chassi Bauer |

## Validações cruzadas (pesquisa cega confirmou escolhas da casa)
markitdown · rtk · superpowers · ui-ux-pro-max · opencode · playwright · aider · codex —
8 ferramentas que a casa já usa apareceram como finalistas sem nenhum worker saber disso.

## Achados genuinamente novos pra avaliar
**witr** (causalidade de processos) · **oat** (UI vanilla) · **open-props** (tokens) ·
**MinerU/docling** (ingestão PDF) · **UI-TARS-desktop** (computer-use) ·
**browser-use** (braço navegador) · novatos de olho: anydoc, liteparse, crawl4ai.

## Riscos anotados pelos workers (honestidade que evita dor)
pandoc GPL-2.0 (só ferramenta local) · MinerU licença própria · anydoc jovem demais ·
robotjs saúde a provar · openpyxl sem cartório possível (Bitbucket).

## Placar da prova de fogo do iaswarm
Paralelismo real (3 motores, custo zero no plano Anthropic) · progresso universal
funcionou (15/15 etapas reportadas, kimi destravada 1× por aprovação de sessão) ·
juiz independente com spot-check próprio · painel + Monitor = vigilância sem poll.
Lições pro contrato-modelo: exigir fechamento 3-5 linhas COM negrito · top-3 cobre
as 3 categorias · babá de aprovação agora é parte do adaptador kimi.

— síntese: Fable (orquestradora da frota)
