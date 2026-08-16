#!/usr/bin/env python3
"""iaswarm state.py — agrega workers.tsv + progress/*.jsonl + resultados/ em state.json.

Uso: state.py <run-dir>   (imprime o JSON no stdout)
Estados de worker: fila · despachado · rodando · entregue · falhou · pulado.
Fonte da verdade é o DISCO (progress appendado pelo worker + existência do resultado).
"""
import json, os, sys, time

def main(run):
    workers = []
    tsv = os.path.join(run, "workers.tsv")
    if not os.path.isfile(tsv):
        print(json.dumps({"erro": "workers.tsv ausente"})); return
    missao = ""
    mpath = os.path.join(run, "missao.md")
    if os.path.isfile(mpath):
        with open(mpath, encoding="utf-8") as f:
            missao = f.readline().strip().lstrip("# ")
    for ln in open(tsv, encoding="utf-8"):
        ln = ln.strip()
        if not ln or ln.startswith("#"):
            continue
        campos = ln.split("\t")
        if len(campos) < 4:
            continue
        w, braco, etapas, contrato = campos[0], campos[1], int(campos[2]), campos[3]
        feitas, estado, nota, ts = 0, "fila", "", ""
        pj = os.path.join(run, "progress", f"{w}.jsonl")
        if os.path.isfile(pj):
            for linha in open(pj, encoding="utf-8"):
                linha = linha.strip()
                if not linha:
                    continue
                try:
                    ev = json.loads(linha)
                except ValueError:
                    continue
                ts = ev.get("ts", ts)
                nota = ev.get("nota", nota) or nota
                est = ev.get("estado", "")
                if est:
                    estado = est
                et = ev.get("etapa", None)
                if isinstance(et, int) and et > feitas:
                    feitas = min(et, etapas)
        res = os.path.join(run, "resultados", f"{w}.md")
        if os.path.isfile(res) and os.path.getsize(res) > 0 and estado not in ("falhou", "pulado"):
            estado = "entregue"
            feitas = etapas
        workers.append({"worker": w, "braco": braco.split(":")[0], "variante": braco,
                        "etapas": etapas, "feitas": feitas, "estado": estado,
                        "nota": nota, "atualizado": ts})
    print(json.dumps({"missao": missao, "gerado": time.strftime("%H:%M:%S"),
                      "workers": workers}, ensure_ascii=False))

if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else ".")
