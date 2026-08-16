# CONTRATO IASWARM — w-kimi · frente AUTOMAÇÃO (computador · navegador · coding)

## Missão
Garimpar OS MELHORES repositórios de código aberto que ajudem uma fábrica de
plataformas educacionais (e sua frota de agentes CLI) com:
**(A) Navegação/controle do computador** (computer-use, automação de desktop macOS,
acessibilidade/AX, cliques e teclado programáticos) · **(B) Navegação na internet**
(browser automation, scraping ético, agentes de navegação) · **(C) Coding**
(ferramentas/frameworks que elevam agentes de código: harnesses, sandboxes, test
runners agênticos, code-search).
Por categoria: 3 a 5 repositórios — consagrados E 1-2 novos famosos recentes (2025-2026).
Só entra com licença MIT/Apache-2.0/BSD OU confiança forte da comunidade (justificar).

## REGRA DE CARTÓRIO (inegociável)
NENHUM repo entra sem verificação via gh CLI:
`gh repo view <owner>/<repo> --json stargazerCount,licenseInfo,pushedAt,description`
Push parado >12 meses sem justificativa = fora. Novos famosos:
`gh search repos <termo> --sort stars --created ">2025-06-01" --limit 10` e variações.
Web search permitido como descobridor; o gh é o juiz de existência.

## ETAPAS (reporte cada uma no progress — protocolo iaswarm)
1. Mapear queries/fontes por categoria (nota no progress).
2. Categoria A (computador/desktop): candidatos verificados.
3. Categoria B (navegador/web): candidatos verificados.
4. Categoria C (coding agêntico): candidatos verificados.
5. Consolidar resultado (formato abaixo) + auto-revisão (nenhum repo sem cartório?).

## Formato do resultado (resultados/w-kimi.md)
`missão:` (1 linha) e depois, por categoria, tabela markdown:
| repo | o que faz (1 linha) | licença | ⭐ | último push | maduro/novo | por que é dos melhores | uso na casa Bauer |
Fechar com `resultado:` (3-5 linhas — os 3 imperdíveis da frente).

## Fronteira de escrita
SOMENTE: progress/w-kimi.jsonl e resultados/w-kimi.md (caminhos do despacho).
Não instalar nada; não clonar nada; pesquisa e cartório apenas.
