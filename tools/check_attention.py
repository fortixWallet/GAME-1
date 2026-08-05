#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""СЕНСОР УВАГИ — перевіряє кадр за правилами керування поглядом (дослідження 05.08).
Кожен тест друкує ЧИСЛО (правило 17), не «добре/погано».

Вжиток:
  python3 tools/check_attention.py <кадр.png> [--obj x0,y0,x1,y1]   # робоча зона в частках
  --obj задає прямокутник предмета; без нього береться центральна зона 40%×40%.

Правила (дослідження: meaning maps > salience; центральне зміщення; 60-30-10;
Cowan ≈4; фовеа ~2.5 см; атмосферна перспектива = падіння контрасту):
 1 ПРИЖМУР      після гаусу σ=8 лишається РІВНО ОДНА виразна пляма
 2 МОНОПОЛІЯ    найтемніші 2% і найсвітліші 2% пікселів — у робочій зоні
 3 КРАЇ         щільність країв фону ≤40% від предметної
 4 КОНТРАСТ     локальний контраст фону ≤50% від предметного
 5 АКЦЕНТ       сургучевий червоний 2–5% кадру (до 8% у вироку)
 7 ЦЕНТР        предмет перекриває центральні 40%×40%
 9 ДЕТАЛЬ       найдрібніша вирішальна деталь ≥8% ширини кадру (перевіряє людина)
"""
import sys, pathlib
import numpy as np
from PIL import Image, ImageFilter


def to_lab_L(rgb):
    """L* (0..100) з sRGB — без scipy."""
    a = rgb.astype(np.float64) / 255.0
    a = np.where(a <= 0.04045, a / 12.92, ((a + 0.055) / 1.055) ** 2.4)
    Y = a[..., 0] * 0.2126 + a[..., 1] * 0.7152 + a[..., 2] * 0.0722
    e = 216 / 24389.0; k = 24389 / 27.0
    f = np.where(Y > e, np.cbrt(Y), (k * Y + 16) / 116)
    return 116 * f - 16


def edges(gray):
    up = np.roll(gray, -1, 0); dn = np.roll(gray, 1, 0)
    lf = np.roll(gray, -1, 1); rt = np.roll(gray, 1, 1)
    gx = rt - lf; gy = dn - up
    return np.hypot(gx, gy)


def local_std(a, win=32):
    """Ковзне std через інтегральні суми (без scipy)."""
    p = np.pad(a, win // 2, mode="edge")
    c1 = np.cumsum(np.cumsum(p, 0), 1)
    c2 = np.cumsum(np.cumsum(p * p, 0), 1)
    def box(c):
        return (c[win:, win:] - c[:-win, win:] - c[win:, :-win] + c[:-win, :-win])
    n = win * win
    m = box(c1) / n
    v = box(c2) / n - m * m
    return np.sqrt(np.maximum(v, 0))


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    p = pathlib.Path(args[0])
    im = Image.open(p).convert("RGB")
    W, H = im.size
    rgb = np.asarray(im)
    L = to_lab_L(rgb)
    hsv = np.asarray(im.convert("HSV"), dtype=np.float64)
    Hh, S = hsv[..., 0] * 360 / 255.0, hsv[..., 1] / 255.0

    # маска робочої зони
    if "--obj" in sys.argv:
        x0, y0, x1, y1 = [float(v) for v in sys.argv[sys.argv.index("--obj") + 1].split(",")]
    else:
        x0, y0, x1, y1 = 0.30, 0.30, 0.70, 0.70
    obj = np.zeros((H, W), bool)
    obj[int(H*y0):int(H*y1), int(W*x0):int(W*x1)] = True
    bg = ~obj

    print("ATTENTION %s  %dx%d  робоча зона=%.0f%% кадру"
          % (p.name, W, H, 100.0 * obj.mean()))

    # 1 ПРИЖМУР: скільки виразних плям після сильного розмиття
    sm = np.asarray(im.convert("L").filter(ImageFilter.GaussianBlur(8)), dtype=np.float64)
    thr = sm.mean() + 1.1 * sm.std()
    blobs = sm > thr
    # грубий підрахунок зв'язних плям: сканування рядками
    lab = np.zeros_like(blobs, dtype=np.int32); cur = 0; sizes = {}
    for y in range(0, H, 4):
        for x in range(0, W, 4):
            if blobs[y, x] and lab[y, x] == 0:
                cur += 1; stack = [(y, x)]; n = 0
                while stack:
                    cy, cx = stack.pop()
                    if cy < 0 or cx < 0 or cy >= H or cx >= W: continue
                    if not blobs[cy, cx] or lab[cy, cx]: continue
                    lab[cy, cx] = cur; n += 1
                    stack += [(cy+4, cx), (cy-4, cx), (cy, cx+4), (cy, cx-4)]
                sizes[cur] = n
    big = [k for k, v in sizes.items() if v > (W * H / 16) * 0.02]
    print("  1 ПРИЖМУР    виразних плям після σ=8: %d   %s"
          % (len(big), "OK" if len(big) == 1 else "УВАГА: має бути 1"))

    # 2 МОНОПОЛІЯ тону
    lo, hi = np.percentile(L, 2), np.percentile(L, 98)
    dark_in = (L <= lo)[obj].sum() / max((L <= lo).sum(), 1)
    light_in = (L >= hi)[obj].sum() / max((L >= hi).sum(), 1)
    print("  2 МОНОПОЛІЯ  найтемніші 2%% у зоні: %.0f%% · найсвітліші 2%%: %.0f%%   %s"
          % (100*dark_in, 100*light_in,
             "OK" if dark_in > 0.5 and light_in > 0.5 else "УВАГА: фон тримає крайні тони"))

    # 3 КРАЇ
    g = np.asarray(im.convert("L"), dtype=np.float64)
    e = edges(g); et = e > (e.mean() + e.std())
    d_obj, d_bg = et[obj].mean(), et[bg].mean()
    ratio_e = d_bg / max(d_obj, 1e-6)
    print("  3 КРАЇ       предмет %.3f · фон %.3f · відношення %.2f   %s (норма ≤0.40)"
          % (d_obj, d_bg, ratio_e, "OK" if ratio_e <= 0.40 else "УВАГА"))

    # 4 ЛОКАЛЬНИЙ КОНТРАСТ
    ls = local_std(L, 32)
    c_obj, c_bg = np.median(ls[obj]), np.median(ls[bg])
    ratio_c = c_bg / max(c_obj, 1e-6)
    print("  4 КОНТРАСТ   предмет %.1f · фон %.1f · відношення %.2f   %s (норма ≤0.50)"
          % (c_obj, c_bg, ratio_c, "OK" if ratio_c <= 0.50 else "УВАГА"))

    # 5 АКЦЕНТ (сургучевий)
    acc = (((Hh <= 12) | (Hh >= 350)) & (S > 0.5)).mean()
    print("  5 АКЦЕНТ     сургучевого в кадрі: %.1f%%   %s (норма 2–5%%)"
          % (100*acc, "OK" if 0.02 <= acc <= 0.05 else ("НУЛЬ — акцент не працює" if acc < 0.02 else "ЗАБАГАТО")))

    # 7 ЦЕНТР
    cen = np.zeros((H, W), bool); cen[int(H*0.30):int(H*0.70), int(W*0.30):int(W*0.70)] = True
    overlap = (obj & cen).sum() / max(obj.sum(), 1)
    print("  7 ЦЕНТР      робоча зона в центральних 40%%×40%%: %.0f%%   %s (норма ≥60%%)"
          % (100*overlap, "OK" if overlap >= 0.6 else "УВАГА"))

    # діапазон тону фону (атмосферна перспектива)
    bl, bh = np.percentile(L[bg], 2), np.percentile(L[bg], 98)
    print("  +  ФОН       діапазон L* %.0f–%.0f (ширина %.0f)   %s (норма ширина ≤35)"
          % (bl, bh, bh-bl, "OK" if (bh-bl) <= 35 else "УВАГА: фон тримає повний діапазон"))


if __name__ == "__main__":
    main()
