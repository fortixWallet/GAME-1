#!/usr/bin/env python3
"""Конвеєр Meshy: text-to-3D у ДВІ стадії (preview → refine) → GLB у models/.

Використання:
  source .keys.env && python3 tools/meshy_gen.py <ім'я> "<промпт>" [--poly 100000]

Правила якості (вимога Віктора 27.07: «високоякісні і дуже детальні»):
- завжди refine із PBR-текстурами (preview без refine — сірий болван);
- realistic, target_polycount за замовчуванням 100k (Godot 4 тягне спокійно);
- проміжні статуси друкуються — «мовчазна генерація» нічим не відрізняється
  від зависання (правило 17).
"""
import os, sys, time, json, pathlib, urllib.request

API = "https://api.meshy.ai/openapi/v2/text-to-3d"
KEY = os.environ.get("MESHY_API_KEY", "")
if not KEY:
    sys.exit("MESHY_API_KEY нема — source .keys.env")

MODELS = pathlib.Path(__file__).resolve().parent.parent / "models"


def call(method: str, url: str, body: dict | None = None) -> dict:
    req = urllib.request.Request(url, method=method)
    req.add_header("Authorization", f"Bearer {KEY}")
    data = None
    if body is not None:
        req.add_header("Content-Type", "application/json")
        data = json.dumps(body).encode()
    with urllib.request.urlopen(req, data, timeout=120) as r:
        return json.loads(r.read().decode())


def wait(task_id: str, label: str) -> dict:
    t0 = time.time()
    last = ""
    while True:
        d = call("GET", f"{API}/{task_id}")
        st = d.get("status")
        pr = d.get("progress", 0)
        line = f"{st} {pr}%"
        if line != last:
            print(f"  [{label}] {line}  ({int(time.time()-t0)}s)")
            last = line
        if st == "SUCCEEDED":
            return d
        if st in ("FAILED", "CANCELED"):
            sys.exit(f"{label}: {st}: {d.get('task_error')}")
        time.sleep(10)


def main() -> None:
    name = sys.argv[1]
    prompt = sys.argv[2]
    poly = 100000
    if "--poly" in sys.argv:
        poly = int(sys.argv[sys.argv.index("--poly") + 1])

    print(f"PREVIEW: {name}")
    prev = call("POST", API, {
        "mode": "preview", "prompt": prompt,
        "art_style": "realistic", "topology": "triangle",
        "target_polycount": poly, "should_remesh": True,
    })
    pid = prev.get("result") or prev.get("id")
    wait(pid, "preview")

    print(f"REFINE: {name} (PBR)")
    ref = call("POST", API, {"mode": "refine", "preview_task_id": pid, "enable_pbr": True})
    rid = ref.get("result") or ref.get("id")
    done = wait(rid, "refine")

    urls = done.get("model_urls", {})
    glb = urls.get("glb")
    if not glb:
        sys.exit(f"нема glb у відповіді: {list(urls)}")
    MODELS.mkdir(exist_ok=True)
    dst = MODELS / f"{name}.glb"
    print(f"DOWNLOAD → {dst}")
    urllib.request.urlretrieve(glb, dst)
    print(f"ГОТОВО: {dst} ({dst.stat().st_size//1024} КБ)")


if __name__ == "__main__":
    main()
