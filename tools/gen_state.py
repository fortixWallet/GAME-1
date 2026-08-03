#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Генерація СТАНУ предмета за правилом 19 + автоматична перевірка камери.
Вжиток:  source .keys.env && $SCRATCH/gvenv/bin/python3 tools/gen_state.py \
             <референс.png> <вихід.png> "<промпт>" [--anchor art/box_closed.png] [--tries 2]
Промпт БЕЗ слів про камеру (закриваємо це і механічно). Правило 17: друкує
розмір і збіг кожної спроби; ставить НАЙКРАЩУ, що пройшла поріг 0.3."""
import io, os, re, sys, pathlib

BANNED = re.compile(r"closer|macro|zoom|move the camera|close-up|camera", re.I)

def phase_match(ref_path, img):
    import numpy as np
    from PIL import Image
    ref = np.asarray(Image.open(ref_path).convert("L"), dtype=np.float64)
    H, W = ref.shape
    a = np.asarray(img.convert("L").resize((W, H)), dtype=np.float64)
    mask = np.ones((H, W)); mask[int(H*0.10):int(H*0.95), int(W*0.18):int(W*0.82)] = 0.0
    A = np.fft.fft2(ref*mask); B = np.fft.fft2(a*mask)
    R = A*np.conj(B); R /= (np.abs(R)+1e-9)
    r = np.fft.ifft2(R).real
    i = np.unravel_index(np.argmax(r), r.shape)
    dy = i[0] if i[0] < H//2 else i[0]-H
    dx = i[1] if i[1] < W//2 else i[1]-W
    return float(r.max()), int(dx), int(dy)

def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    ref_p, out_p, prompt = args[0], args[1], args[2]
    anchor = ref_p
    if "--anchor" in sys.argv: anchor = sys.argv[sys.argv.index("--anchor")+1]
    tries = int(sys.argv[sys.argv.index("--tries")+1]) if "--tries" in sys.argv else 2
    bad = BANNED.search(prompt)
    if bad:
        sys.exit("ЗАБОРОНЕНЕ СЛОВО В ПРОМПТІ (правило 19): %r — наближення тільки кропом" % bad.group(0))
    from google import genai
    from google.genai import types
    from PIL import Image
    client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])
    ref = Image.open(ref_p).convert("RGB")
    best, best_img = -1.0, None
    for att in range(1, tries+1):
        r = client.models.generate_content(model="gemini-3-pro-image", contents=[prompt, ref],
            config=types.GenerateContentConfig(response_modalities=["IMAGE"],
                image_config=types.ImageConfig(aspect_ratio="4:3")))
        img = None
        for part in r.candidates[0].content.parts:
            if getattr(part, "inline_data", None) and part.inline_data.data:
                img = Image.open(io.BytesIO(part.inline_data.data)).convert("RGB")
        if img is None:
            print("  спроба %d: порожньо" % att); continue
        img = img.resize(ref.size, Image.LANCZOS)
        q, dx, dy = phase_match(anchor, img)
        print("  спроба %d: %s  збіг %.3f dx=%+d dy=%+d" % (att, img.size, q, dx, dy))
        if q > best and abs(dx) <= 2 and abs(dy) <= 2:
            best, best_img = q, img
    if best_img is None or best < 0.3:
        sys.exit("ЖОДНА СПРОБА НЕ ВТРИМАЛА КАМЕРУ (поріг 0.3) — кадр не ставимо")
    best_img.save(out_p)
    print("ПОСТАВЛЕНО %s (збіг %.3f). Далі: godot --headless --import і гейт --c2" % (out_p, best))

if __name__ == "__main__":
    main()
