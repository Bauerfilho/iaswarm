#!/bin/bash
# iaswarm dispatch.sh — despacha os workers da FROTA (nunca da casa) e sobe o painel.
# Uso: dispatch.sh <run-dir>
# Espera no run-dir: missao.md · contratos/*.md · workers.tsv com linhas
#   worker<TAB>braco[:variante]<TAB>n_etapas<TAB>contratos/arquivo.md
# Braços v1: qwen · codex · kimi(tmux) · ollama[:modelo] · agy(beta) · grok(beta)
# Progresso: o worker appenda em progress/<worker>.jsonl (protocolo iaswarm);
# para braços de stdout puro (ollama), o wrapper converte marcadores [ETAPA K/N].
set -euo pipefail
RUN="$(cd "${1:?uso: dispatch.sh <run-dir>}" && pwd)"
IAS="$HOME/.claude/scripts/iaswarm"
cd "$RUN"
mkdir -p progress resultados logs
[ -f workers.tsv ] || { echo "workers.tsv ausente em $RUN"; exit 1; }

marca() { # worker etapa de estado nota
  printf '{"ts":"%s","etapa":%s,"de":%s,"estado":"%s","nota":"%s"}\n' \
    "$(date '+%H:%M:%S')" "$2" "$3" "$4" "$5" >> "progress/$1.jsonl"
}

protocolo() { # worker n_etapas contrato — o preâmbulo comum de todo despacho
  local w=$1 n=$2 c=$3
  echo "PROTOCOLO IASWARM. Leia e cumpra o contrato em $RUN/$c até o fim, sem perguntar. \
Após CADA etapa concluída, appenda 1 linha no arquivo $RUN/progress/$w.jsonl no formato \
{\"etapa\":K,\"de\":$n,\"estado\":\"rodando\",\"nota\":\"3-8 palavras\"}. \
Escreva o resultado final em $RUN/resultados/$w.md no formato 'missão:'/'resultado:'. \
Fronteira de escrita: SOMENTE os caminhos citados no contrato + progress/resultado acima."
}

# ---------------- adaptadores ----------------
despacha_qwen() { local w=$1 n=$2 c=$3
  marca "$w" 0 "$n" despachado "qwen -y"
  ( qwen -y -p "$(protocolo "$w" "$n" "$c")" < /dev/null > "logs/$w.log" 2>&1
    if [ -s "resultados/$w.md" ]; then marca "$w" "$n" "$n" entregue ""; else marca "$w" -1 "$n" falhou "sem resultado (ver logs/$w.log)"; fi ) &
  echo $! > "logs/$w.pid"
}

despacha_codex() { local w=$1 n=$2 c=$3
  marca "$w" 0 "$n" despachado "codex exec"
  ( codex exec "$(protocolo "$w" "$n" "$c")" < /dev/null > "logs/$w.log" 2>&1
    if [ -s "resultados/$w.md" ]; then marca "$w" "$n" "$n" entregue ""; else marca "$w" -1 "$n" falhou "sem resultado (ver logs/$w.log)"; fi ) &
  echo $! > "logs/$w.pid"
}

despacha_kimi() { local w=$1 n=$2 c=$3   # sessão tmux (kimi -p não escreve; auto-mode escreve)
  marca "$w" 0 "$n" despachado "kimi tmux"
  ( S="ia-$w"
    tmux kill-session -t "$S" 2>/dev/null || true
    tmux new-session -d -s "$S" -x 200 -y 50 "cd '$RUN' && kimi"
    sleep 20
    tmux capture-pane -t "$S" -p > "logs/$w-boot.txt" 2>/dev/null || true
    if grep -q "Trust this folder" "logs/$w-boot.txt" 2>/dev/null; then
      tmux send-keys -t "$S" Up; sleep 1; tmux send-keys -t "$S" Enter; sleep 15
    fi
    tmux send-keys -t "$S" "$(protocolo "$w" "$n" "$c")" Enter
    sleep 3; tmux send-keys -t "$S" Enter   # Enter extra: menus comem o primeiro (lição 15/08)
    fim=$(( $(date +%s) + 2400 ))
    while [ "$(date +%s)" -lt "$fim" ]; do
      [ -s "resultados/$w.md" ] && break
      tmux has-session -t "$S" 2>/dev/null || break
      # babá de aprovação (lição 15/08): sessão tmux nasce SEM auto — aprovar p/ sessão
      if tmux capture-pane -t "$S" -p 2>/dev/null | grep -q "Approve"; then
        tmux send-keys -t "$S" 2; sleep 1; tmux send-keys -t "$S" Enter
      fi
      sleep 15
    done
    tmux capture-pane -t "$S" -p -S -500 > "logs/$w.log" 2>/dev/null || true
    tmux kill-session -t "$S" 2>/dev/null || true
    if [ -s "resultados/$w.md" ]; then marca "$w" "$n" "$n" entregue ""; else marca "$w" -1 "$n" falhou "timeout/sessão (ver logs/$w.log)"; fi ) &
  echo $! > "logs/$w.pid"
}

despacha_ollama() { local w=$1 n=$2 c=$3 modelo=$4  # stdout puro: wrapper converte [ETAPA K/N]
  marca "$w" 0 "$n" despachado "ollama $modelo"
  ( { echo "Cumpra o contrato abaixo até o fim. Ao concluir CADA etapa, emita numa linha própria o marcador [ETAPA K/$n] antes de continuar. Ao final, escreva o resultado completo após a linha [RESULTADO]. Contrato:"; cat "$c"; } \
      | ollama run "$modelo" 2>"logs/$w.err" | tee "logs/$w.log" | \
      while IFS= read -r linha; do
        case "$linha" in
          *"[ETAPA "*"/$n]"*) k=$(printf '%s' "$linha" | sed -n 's/.*\[ETAPA \([0-9]*\)\/.*/\1/p')
                              [ -n "$k" ] && marca "$w" "$k" "$n" rodando "";;
        esac
      done
    awk '/\[RESULTADO\]/{f=1;next} f' "logs/$w.log" > "resultados/$w.md" || true
    if [ -s "resultados/$w.md" ]; then marca "$w" "$n" "$n" entregue ""; else marca "$w" -1 "$n" falhou "sem [RESULTADO] (ver logs/$w.log)"; fi ) &
  echo $! > "logs/$w.pid"
}

despacha_agy() { local w=$1 n=$2 c=$3   # BETA: validar a forma de chamada no 1º uso real
  marca "$w" 0 "$n" despachado "agy (beta)"
  ( agy --print-timeout 20m --dangerously-skip-permissions -p "$(protocolo "$w" "$n" "$c")" < /dev/null > "logs/$w.log" 2>&1
    if [ -s "resultados/$w.md" ]; then marca "$w" "$n" "$n" entregue ""; else marca "$w" -1 "$n" falhou "beta: conferir forma de chamada (logs/$w.log)"; fi ) &
  echo $! > "logs/$w.pid"
}

despacha_grok() { local w=$1 n=$2 c=$3   # BETA: validar a forma de chamada no 1º uso real
  marca "$w" 0 "$n" despachado "grok (beta)"
  ( grok -p "$(protocolo "$w" "$n" "$c")" --dangerously-skip-permissions < /dev/null > "logs/$w.log" 2>&1
    if [ -s "resultados/$w.md" ]; then marca "$w" "$n" "$n" entregue ""; else marca "$w" -1 "$n" falhou "beta: conferir forma de chamada (logs/$w.log)"; fi ) &
  echo $! > "logs/$w.pid"
}

# ---------------- painel ----------------
PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()')
echo "$PORT" > painel-porta.txt
cp "$IAS/painel.html" index.html
python3 "$IAS/state.py" "$RUN" > state.json || true
( python3 -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 & echo $! > http.pid )
# atualizador do painel — independe do watch.sh: quem só roda o dispatch TAMBÉM vê o painel vivo.
# (defeito corrigido 16/08: sem isto o painel congela no instante do disparo.)
( while :; do
    python3 "$IAS/state.py" "$RUN" > state.json.tmp 2>/dev/null && mv state.json.tmp state.json
    vivo=$(python3 -c "
import json
try:
    d=json.load(open('state.json'))
    print(sum(1 for w in d.get('workers',[]) if w['estado'] not in ('entregue','falhou','pulado')))
except Exception: print(1)" 2>/dev/null)
    [ "${vivo:-1}" = "0" ] && break
    sleep 2
  done ) >/dev/null 2>&1 &
echo $! > painel-refresh.pid
open "http://127.0.0.1:$PORT/index.html" 2>/dev/null || true

# ---------------- despacho ----------------
while IFS=$'\t' read -r w braco n c; do
  [ -z "${w:-}" ] && continue; case "$w" in \#*) continue;; esac
  base="${braco%%:*}"; variante="${braco#*:}"
  case "$base" in
    qwen)   despacha_qwen  "$w" "$n" "$c" ;;
    codex)  despacha_codex "$w" "$n" "$c" ;;
    kimi)   despacha_kimi  "$w" "$n" "$c" ;;
    ollama) despacha_ollama "$w" "$n" "$c" "${variante:-qwen2.5-coder:32b}" ;;
    agy)    despacha_agy   "$w" "$n" "$c" ;;
    grok)   despacha_grok  "$w" "$n" "$c" ;;
    *) marca "$w" -1 "$n" pulado "braço sem adaptador v1: $base" ;;
  esac
done < workers.tsv

echo "iaswarm no ar — painel: http://127.0.0.1:$PORT/index.html"
echo "vigiar: $IAS/watch.sh $RUN (armar no Monitor)"
