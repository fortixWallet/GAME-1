#!/usr/bin/env python3
"""Image-to-3D Meshy: точна Gemini-картинка компонента → GLB.
Використання: source .keys.env && python3 tools/meshy_img3d.py <ім'я> <шлях_до_png> [--poly N]
Text-to-3D глухий до «порожніх гнізд» (2/6 за 28.07) — картинку він поважає."""
import os, sys, time, json, base64, pathlib, urllib.request

API = "https://api.meshy.ai/openapi/v1/image-to-3d"
KEY = os.environ.get("MESHY_API_KEY", "")
if not KEY: sys.exit("MESHY_API_KEY нема — source .keys.env")
MODELS = pathlib.Path(__file__).resolve().parent.parent / "models"

def call(method, url, body=None):
    req = urllib.request.Request(url, method=method)
    req.add_header("Authorization", f"Bearer {KEY}")
    data = None
    if body is not None:
        req.add_header("Content-Type", "application/json")
        data = json.dumps(body).encode()
    with urllib.request.urlopen(req, data, timeout=180) as r:
        return json.loads(r.read().decode())

name, img_path = sys.argv[1], sys.argv[2]
poly = int(sys.argv[sys.argv.index("--poly")+1]) if "--poly" in sys.argv else 150000
b64 = base64.b64encode(pathlib.Path(img_path).read_bytes()).decode()
print(f"IMG3D: {name} ← {img_path} ({len(b64)//1024} КБ b64)")
t = call("POST", API, {"image_url": "data:image/png;base64," + b64,
                       "enable_pbr": True, "should_remesh": True,
                       "target_polycount": poly, "topology": "triangle"})
tid = t.get("result") or t.get("id")
t0, last = time.time(), ""
while True:
    d = call("GET", f"{API}/{tid}")
    line = f"{d.get('status')} {d.get('progress',0)}%"
    if line != last: print(f"  [{name}] {line} ({int(time.time()-t0)}s)"); last = line
    if d.get("status") == "SUCCEEDED": break
    if d.get("status") in ("FAILED","CANCELED"): sys.exit(f"{name}: {d.get('task_error')}")
    time.sleep(10)
glb = d.get("model_urls", {}).get("glb")
if not glb: sys.exit("нема glb")
dst = MODELS / f"{name}.glb"
urllib.request.urlretrieve(glb, dst)
print(f"ГОТОВО: {dst} ({dst.stat().st_size//1024} КБ)")
