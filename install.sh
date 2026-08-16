#!/bin/bash
# iaswarm — instalador (Claude Code por padrão; destinos customizáveis por env)
#   IASWARM_SCRIPTS  (default: ~/.claude/scripts/iaswarm)
#   IASWARM_SKILL    (default: ~/.claude/skills/iaswarm)
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST_SCRIPTS="${IASWARM_SCRIPTS:-$HOME/.claude/scripts/iaswarm}"
DEST_SKILL="${IASWARM_SKILL:-$HOME/.claude/skills/iaswarm}"

mkdir -p "$DEST_SCRIPTS" "$DEST_SKILL"
cp "$SRC/bin/dispatch.sh" "$SRC/bin/watch.sh" "$SRC/bin/state.py" "$DEST_SCRIPTS/"
cp "$SRC/painel/painel.html" "$DEST_SCRIPTS/"
cp "$SRC/skill/SKILL.md" "$DEST_SKILL/"
chmod +x "$DEST_SCRIPTS/dispatch.sh" "$DEST_SCRIPTS/watch.sh" "$DEST_SCRIPTS/state.py"

echo "✓ scripts + painel → $DEST_SCRIPTS"
echo "✓ skill           → $DEST_SKILL"
echo
echo "Próximos passos:"
echo "  1. Adapte os seus braços: edite as funções despacha_* em $DEST_SCRIPTS/dispatch.sh"
echo "     (cada adaptador tem ~10 linhas; exemplos prontos: qwen, codex, kimi, ollama)."
echo "  2. Crie um run-dir com missao.md, contratos/*.md e workers.tsv"
echo "     (modelo em exemplos/garimpo-repos/)."
echo "  3. Dispare:  $DEST_SCRIPTS/dispatch.sh <run-dir>   (abre o painel no navegador)"
echo "  4. Vigie:    $DEST_SCRIPTS/watch.sh <run-dir>      (1 linha por transição)"
