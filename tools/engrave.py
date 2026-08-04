#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""ГРАВЮРНИЙ КОНВЕРТЕР — детермінований, без ШІ (правило: фінальний піксель наш).
Робить із рендера/фото штрихову гравюру XIX ст.: штрихи йдуть ПО ФОРМІ предмета
(за напрямком градієнта), щільність — за яскравістю, тіні добираються
перехресним штрихуванням, світлові плями лишаються чистим папером.

Вжиток: python3 tools/engrave.py <вхід.png> <вихід.png> [--paper art/atestat_flat_blank.png]
Правило 17: друкує, скільки шарів і скільки пікселів покрито штрихом.
"""
import sys, pathlib
import numpy as np
from PIL import Image, ImageFilter, ImageOps


def sobel(gray):
    k = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]], dtype=np.float32)
    from scipy.ndimage import convolve
    gx = convolve(gray, k)
    gy = convolve(gray, k.T)
    return gx, gy


def sobel_np(gray):
    """Sobel без scipy — згортка зсувами."""
    g = gray
    up = np.roll(g, -1, axis=0); dn = np.roll(g, 1, axis=0)
    lf = np.roll(g, -1, axis=1); rt = np.roll(g, 1, axis=1)
    upl = np.roll(up, -1, axis=1); upr = np.roll(up, 1, axis=1)
    dnl = np.roll(dn, -1, axis=1); dnr = np.roll(dn, 1, axis=1)
    gx = (upr + 2 * rt + dnr) - (upl + 2 * lf + dnl)
    gy = (dnl + 2 * dn + dnr) - (upl + 2 * up + upr)
    return gx, gy


def hatch_layer(shape, angle_rad, period, phase=0.0, thickness=0.42):
    """Прямі штрихи під кутом: 1 там, де штрих, 0 де папір."""
    h, w = shape
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    proj = xx * np.cos(angle_rad) + yy * np.sin(angle_rad)
    t = np.mod(proj / period + phase, 1.0)
    return (t < thickness).astype(np.float32)


def flow_hatch(shape, ang_field, period, thickness=0.42):
    """Штрихи, що ЙДУТЬ ПО ФОРМІ: фаза рахується вздовж поля напрямків.
    Наближення: проєкція координат на локальну нормаль форми."""
    h, w = shape
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    proj = xx * np.cos(ang_field) + yy * np.sin(ang_field)
    t = np.mod(proj / period, 1.0)
    return (t < thickness).astype(np.float32)


def engrave(src_path, out_path, paper_path=None, base_period=6.0, levels=4):
    im = Image.open(src_path).convert("RGB")
    W, H = im.size
    g = np.asarray(ImageOps.autocontrast(im.convert("L"), cutoff=1), dtype=np.float32) / 255.0

    # м'яка версія для тону, різка для контурів
    tone = np.asarray(Image.fromarray((g * 255).astype(np.uint8)).filter(
        ImageFilter.GaussianBlur(2.2)), dtype=np.float32) / 255.0
    gx, gy = sobel_np(np.asarray(Image.fromarray((g * 255).astype(np.uint8)).filter(
        ImageFilter.GaussianBlur(3.0)), dtype=np.float32) / 255.0)

    # напрямок ШТРИХА = перпендикуляр до градієнта (штрих іде по формі)
    ang = np.arctan2(gy, gx) + np.pi / 2.0
    # згладити поле напрямків, щоб штрих не тремтів
    ang_s = np.arctan2(
        np.asarray(Image.fromarray(((np.sin(ang) + 1) * 127).astype(np.uint8)).filter(
            ImageFilter.GaussianBlur(6)), dtype=np.float32) / 127.0 - 1.0,
        np.asarray(Image.fromarray(((np.cos(ang) + 1) * 127).astype(np.uint8)).filter(
            ImageFilter.GaussianBlur(6)), dtype=np.float32) / 127.0 - 1.0)

    # ЩІЛЬНІСТЬ ШТРИХА = ТОН (головний закон гравюри): товщина лінії росте
    # з темрявою плавно, а не «є/нема». Світло — чистий папір, тінь — густа сітка.
    dark = np.clip(1.0 - tone, 0.0, 1.0)
    ink = np.zeros((H, W), dtype=np.float32)
    covered = 0

    def lay(mask_field, t_local):
        # t_local: локальна товщина 0..0.5 у частках періоду
        return (np.mod(mask_field, 1.0) < t_local).astype(np.float32)

    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    # ШАР 1 — по формі, товщина від тону
    f1 = (xx * np.cos(ang_s) + yy * np.sin(ang_s)) / base_period
    t1 = np.clip((dark - 0.20) * 0.72, 0.0, 0.46)
    l1 = lay(f1, t1)
    ink = np.maximum(ink, l1); covered += int(l1.sum())
    # ШАР 2 — перехресний 45°, вмикається із середніх тонів
    f2 = (xx * np.cos(np.deg2rad(45)) + yy * np.sin(np.deg2rad(45))) / (base_period * 1.08)
    t2 = np.clip((dark - 0.42) * 0.85, 0.0, 0.44)
    l2 = lay(f2, t2)
    ink = np.maximum(ink, l2); covered += int(l2.sum())
    # ШАР 3 — перехресний -45°, тільки глибокі тіні
    f3 = (xx * np.cos(np.deg2rad(-45)) + yy * np.sin(np.deg2rad(-45))) / (base_period * 1.17)
    t3 = np.clip((dark - 0.66) * 1.1, 0.0, 0.42)
    l3 = lay(f3, t3)
    ink = np.maximum(ink, l3); covered += int(l3.sum())

    # КОНТУР — тонкий і лише на СИЛЬНИХ краях (гравер веде одну лінію, не заливає)
    mag = np.hypot(gx, gy)
    mag = mag / (mag.max() + 1e-6)
    edge = (mag > 0.34).astype(np.float32)
    ink = np.maximum(ink, edge * 0.9)

    # СВІТЛОВІ ПЛЯМИ — чистий папір
    # чистий папір там, де світло: інакше рівний фон береться шумом
    ink *= (tone < 0.82).astype(np.float32)

    # ЧОРНИЛО на папері
    ink_img = Image.fromarray(((1.0 - ink) * 255).astype(np.uint8)).convert("L")
    ink_img = ink_img.filter(ImageFilter.GaussianBlur(0.4))
    if paper_path and pathlib.Path(paper_path).exists():
        paper = Image.open(paper_path).convert("RGB").resize((W, H), Image.LANCZOS)
    else:
        paper = Image.new("RGB", (W, H), (238, 230, 210))
    ink_rgb = Image.merge("RGB", [ink_img] * 3)
    # мультиплікативне накладання: чорнило темнить папір
    out = Image.fromarray(
        (np.asarray(paper, dtype=np.float32) * (np.asarray(ink_rgb, dtype=np.float32) / 255.0)
         ).astype(np.uint8))
    out.save(out_path)
    print("ENGRAVE %s -> %s  %dx%d  шарів=%d  пікселів під штрихом=%d (%.1f%%)"
          % (pathlib.Path(src_path).name, pathlib.Path(out_path).name, W, H,
             levels, covered, 100.0 * covered / (W * H)))


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    paper = None
    if "--paper" in sys.argv:
        paper = sys.argv[sys.argv.index("--paper") + 1]
    per = float(sys.argv[sys.argv.index("--period") + 1]) if "--period" in sys.argv else 6.0
    engrave(args[0], args[1], paper, base_period=per)
