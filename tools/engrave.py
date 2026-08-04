#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""ГРАВЮРНИЙ КОНВЕРТЕР v2 — детермінований, без ШІ.
Закони різцевої гравюри XIX ст., реалізовані буквально:
  · штрихи йдуть ПО ФОРМІ (напрямок із згладженого поля градієнта);
  · товщина лінії плавно росте з темрявою (swelling line) — ознака різця;
  · лінії ЗГЛАДЖЕНІ (anti-alias), а не бінарні — інакше рвань і «фотофільтр»;
  · ДЕТАЛЬ зберігається: локальний контраст піднімається unsharp-маскою ДО
    штрихування; тон рахується у двох масштабах (великий — напрямок, дрібний — тон);
  · фон відсікається маскою предмета, інакше рівне тло береться шумом;
  · контур — тонка чиста лінія на сильних краях, без потовщення.
Вжиток: python3 tools/engrave.py <вхід> <вихід> [--period 7] [--paper …png] [--dark 1.0] [--detail 1.6]
Правило 17: друкує розмір, частку предмета в кадрі і покриття штрихом.
"""
import sys, pathlib
import numpy as np
from PIL import Image, ImageFilter, ImageOps


def blur(a, r):
    return np.asarray(Image.fromarray(np.clip(a * 255, 0, 255).astype(np.uint8))
                      .filter(ImageFilter.GaussianBlur(r)), dtype=np.float32) / 255.0


def sobel_np(g):
    up = np.roll(g, -1, 0); dn = np.roll(g, 1, 0)
    lf = np.roll(g, -1, 1); rt = np.roll(g, 1, 1)
    upl = np.roll(up, -1, 1); upr = np.roll(up, 1, 1)
    dnl = np.roll(dn, -1, 1); dnr = np.roll(dn, 1, 1)
    gx = (upr + 2 * rt + dnr) - (upl + 2 * lf + dnl)
    gy = (dnl + 2 * dn + dnr) - (upl + 2 * up + upr)
    return gx, gy


def smoothstep(e0, e1, x):
    t = np.clip((x - e0) / max(abs(e1 - e0), 1e-6), 0.0, 1.0) if np.isscalar(e0) else \
        np.clip((x - e0) / np.maximum(np.abs(e1 - e0), 1e-6), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)


def aa_lines(phase, half_width, feather=0.055):
    """Згладжена система паралельних ліній: phase — координата поперек ліній
    у частках періоду; half_width — половина товщини (0..0.5), може бути полем."""
    d = np.abs(np.mod(phase + 0.5, 1.0) - 0.5)
    return 1.0 - np.clip((d - half_width) / feather, 0.0, 1.0) ** 1.0


def engrave(src, out, paper_path=None, period=7.0, dark_gain=1.0, detail=1.6):
    im = Image.open(src).convert("RGB")
    W, H = im.size
    g0 = np.asarray(ImageOps.autocontrast(im.convert("L"), cutoff=1), dtype=np.float32) / 255.0

    # 1. ДЕТАЛЬ: локальний контраст (unsharp) — інакше гільош і клейма гинуть
    g = np.clip(g0 + detail * (g0 - blur(g0, 3.0)), 0.0, 1.0)

    # 2. ДВА МАСШТАБИ: великий — напрямок штриха, дрібний — тон
    tone = blur(g, 1.0)
    form = blur(g0, 7.0)
    gx, gy = sobel_np(form)
    ang = np.arctan2(gy, gx) + np.pi / 2.0
    ang = np.arctan2(blur(np.sin(ang) * 0.5 + 0.5, 9) * 2 - 1,
                     blur(np.cos(ang) * 0.5 + 0.5, 9) * 2 - 1)

    # 3. МАСКА ПРЕДМЕТА: фон = рівні ділянки без градієнта
    ex, ey = sobel_np(blur(g0, 2.0))
    emag = np.hypot(ex, ey); emag /= (emag.max() + 1e-6)
    obj = blur((emag > 0.05).astype(np.float32), 14.0)
    obj = smoothstep(0.06, 0.20, obj)

    dark = np.clip((1.0 - tone) * dark_gain, 0.0, 1.0)
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    ink = np.zeros((H, W), dtype=np.float32)

    # ШАР 1 — по формі, товщина росте з темрявою
    p1 = (xx * np.cos(ang) + yy * np.sin(ang)) / period
    w1 = 0.10 + 0.32 * smoothstep(0.05, 0.65, dark)
    ink = np.maximum(ink, aa_lines(p1, w1))

    # ШАР 2 — перехресний 52°, середні й глибокі тони
    p2 = (xx * np.cos(np.deg2rad(52)) + yy * np.sin(np.deg2rad(52))) / (period * 1.05)
    ink = np.maximum(ink, aa_lines(p2, 0.34 * smoothstep(0.34, 0.78, dark)))

    # ШАР 3 — перехресний -38°, найглибші тіні
    p3 = (xx * np.cos(np.deg2rad(-38)) + yy * np.sin(np.deg2rad(-38))) / (period * 1.11)
    ink = np.maximum(ink, aa_lines(p3, 0.32 * smoothstep(0.58, 0.92, dark)))

    # 4. КОНТУР — тонка чиста лінія на сильних краях
    cx, cy = sobel_np(blur(g, 1.2))
    cmag = np.hypot(cx, cy); cmag /= (cmag.max() + 1e-6)
    ink = np.maximum(ink, smoothstep(0.22, 0.40, cmag) * 0.92)

    # 5. Фон і світлові плями — чистий папір
    ink *= obj
    ink *= (1.0 - smoothstep(0.86, 0.96, tone))   # чистий папір лише в яскравому світлі

    # 6. Друк
    ink_img = Image.fromarray(((1.0 - np.clip(ink, 0, 1)) * 255).astype(np.uint8))
    if paper_path and pathlib.Path(paper_path).exists():
        paper = Image.open(paper_path).convert("RGB").resize((W, H), Image.LANCZOS)
    else:
        paper = Image.new("RGB", (W, H), (240, 233, 214))
    res = (np.asarray(paper, np.float32) *
           (np.asarray(ink_img.convert("RGB"), np.float32) / 255.0))
    res *= np.array([1.0, 0.985, 0.95], np.float32)   # тепле друкарське чорнило
    Image.fromarray(np.clip(res, 0, 255).astype(np.uint8)).save(out)
    print("ENGRAVE %s -> %s  %dx%d  предмет=%.1f%% кадру  штрих=%.1f%% предмета"
          % (pathlib.Path(src).name, pathlib.Path(out).name, W, H,
             100.0 * obj.mean(), 100.0 * ink.sum() / max(obj.sum(), 1.0)))


if __name__ == "__main__":
    a = [x for x in sys.argv[1:] if not x.startswith("--")]
    def opt(n, d, cast=float):
        return cast(sys.argv[sys.argv.index(n) + 1]) if n in sys.argv else d
    engrave(a[0], a[1], opt("--paper", None, str), opt("--period", 7.0),
            opt("--dark", 1.0), opt("--detail", 1.6))
