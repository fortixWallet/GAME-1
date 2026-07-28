#!/usr/bin/env python3
"""Multi Image to 3D (Meshy 6): кілька ракурсів → чиста ПОВНА геометрія.
Використання: source .keys.env && python3 tools/meshy_multi.py <ім'я> img1 img2 [img3 img4]
Важелі якості (з docs.meshy.ai): ai_model=latest (Meshy6), 4k+PBR, quad-ремеш 200k."""
import os, sys, time, json, base64, pathlib, urllib.request

API = "https://api.meshy.ai/openapi/v1/multi-image-to-3d"
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

name = sys.argv[1]
imgs = sys.argv[2:]
urls = []
for p in imgs:
    b64 = base64.b64encode(pathlib.Path(p).read_bytes()).decode()
    urls.append("data:image/png;base64," + b64)
print(f"MULTI3D: {name} ← {len(urls)} ракурси")
body = {
    "image_urls": urls,
    "ai_model": "latest",            # Meshy 6
    "should_texture": True,
    "enable_pbr": True,
    "texture_resolution": "4k",
    "should_remesh": True,
    "topology": "quad",
    "target_polycount": 200000,
    "image_enhancement": True,
}
t = call("POST", API, body)
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
if not glb: sys.exit("нема glb: " + str(list(d.get("model_urls", {}))))
dst = MODELS / f"{name}.glb"
urllib.request.urlretrieve(glb, dst)
print(f"ГОТОВО: {dst} ({dst.stat().st_size//1024} КБ)")
