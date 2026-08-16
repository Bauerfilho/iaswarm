#!/bin/bash
# iaswarm watch.sh — reconstrói state.json a cada 2s e emite 1 linha por TRANSIÇÃO.
# Uso: watch.sh <run-dir> [timeout-min=45]
# Desenhado para o Monitor tool da orquestradora: silêncio = nada mudou;
# linha = etapa completada / estado mudou / enxame terminou. Nunca poll manual.
set -u
RUN="${1:?uso: watch.sh <run-dir> [timeout-min]}"
TMIN="${2:-45}"
SP="$HOME/.claude/scripts/iaswarm/state.py"
prev=""
fim=$(( $(date +%s) + TMIN*60 ))
while [ "$(date +%s)" -lt "$fim" ]; do
  python3 "$SP" "$RUN" > "$RUN/state.json.tmp" 2>/dev/null && mv "$RUN/state.json.tmp" "$RUN/state.json"
  cur=$(python3 -c "
import json
d=json.load(open('$RUN/state.json'))
for w in d.get('workers',[]):
    print(f\"{w['worker']}|{w['braco']}|{w['estado']}|{w['feitas']}/{w['etapas']}|{w.get('nota','')}\")" 2>/dev/null)
  if [ "$cur" != "$prev" ]; then
    while IFS= read -r linha; do
      case "$prev" in *"${linha}"*) ;; *) [ -n "$linha" ] && echo "[iaswarm] $linha";; esac
    done <<< "$cur"
    prev="$cur"
  fi
  # terminou? (todo worker em estado terminal)
  vivo=$(python3 -c "
import json
d=json.load(open('$RUN/state.json'))
print(sum(1 for w in d.get('workers',[]) if w['estado'] not in ('entregue','falhou','pulado')))" 2>/dev/null)
  if [ "${vivo:-1}" = "0" ]; then
    echo "[iaswarm] ENXAME-COMPLETO $(python3 -c "
import json
d=json.load(open('$RUN/state.json'))
e=sum(1 for w in d['workers'] if w['estado']=='entregue'); f=sum(1 for w in d['workers'] if w['estado']=='falhou')
print(f'{e} entregues, {f} falhas, {len(d[\"workers\"])} total')")"
    exit 0
  fi
  sleep 2
done
echo "[iaswarm] TIMEOUT após ${TMIN}min — workers ainda vivos; inspecionar o run-dir"
exit 2
