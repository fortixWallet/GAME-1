#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""ПРАВИЛО 19: кадри одного предмета мусять тримати одну камеру.

Міряє фазову кореляцію по НЕРУХОМІЙ частині кадру (стіл, сукно, лампа — периферія,
46 % пікселів). Центр, де стоїть сам предмет, замаскований: він і має мінятись.

  1.000  той самий файл
  >0.30  та сама камера — кадр стану, годиться
  <0.30  чужа зйомка — у грі дасть стрибок ракурсу, за який плачено тижнем 24–31.07

Плити-ДЕТАЛІ (наближення) сюди не входять: вони кроп із майстра, їхня камера інша
за задумом. Якщо деталь опинилась у списку станів — це помилка, і скрипт її покаже.

Правило 17: спершу друкує, СКІЛЬКИ кадрів побачив.
Запуск: python3 tools/check_frames.py    (код виходу 1 = є чужа зйомка)
"""
import os
import sys

try:
    import numpy as np
    from PIL import Image
except ImportError:
    print("FRAMES_SKIP немає numpy/PIL — перевірку кадрів пропущено")
    sys.exit(0)

ART = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "art")

# групи кадрів одного предмета: (еталон, [решта станів])
GROUPS = [
    ("box_closed", ["box_a1", "box_a2", "box_open", "box_noboard", "box_under"]),
    ("cablock_closed", ["cablock_open", "cablock_drawer"]),
]
MIN_MATCH = 0.30
MAX_SHIFT = 2


def load(name):
    p = os.path.join(ART, name + ".png")
    if not os.path.exists(p):
        return None
    return np.asarray(Image.open(p).convert("L"), dtype=np.float64)


def match(ref, other, mask):
    h, w = ref.shape
    a = np.fft.fft2(ref * mask)
    b = np.fft.fft2(other * mask)
    r = a * np.conj(b)
    r /= (np.abs(r) + 1e-9)
    r = np.fft.ifft2(r).real
    i = np.unravel_index(np.argmax(r), r.shape)
    dy = i[0] if i[0] < h // 2 else i[0] - h
    dx = i[1] if i[1] < w // 2 else i[1] - w
    return dx, dy, float(r.max())


seen = 0
bad = []
for base, states in GROUPS:
    ref = load(base)
    if ref is None:
        print("FRAMES_FAIL еталон %s не знайдено" % base)
        sys.exit(1)
    h, w = ref.shape
    mask = np.ones((h, w))
    mask[int(h * 0.10):int(h * 0.95), int(w * 0.18):int(w * 0.82)] = 0.0
    for name in states:
        other = load(name)
        seen += 1
        if other is None:
            bad.append((name, "файлу нема"))
            continue
        if other.shape != ref.shape:
            bad.append((name, "інший розмір %s проти %s" % (other.shape, ref.shape)))
            continue
        dx, dy, q = match(ref, other, mask)
        if q < MIN_MATCH or abs(dx) > MAX_SHIFT or abs(dy) > MAX_SHIFT:
            bad.append((name, "збіг %.3f dx=%+d dy=%+d — чужа зйомка" % (q, dx, dy)))
        else:
            print("  %-14s збіг %.3f  dx=%+d dy=%+d" % (name, q, dx, dy))

print("FRAMES перевірено кадрів стану: %d, з чужою камерою: %d" % (seen, len(bad)))
for name, why in bad:
    print("  ✗ %-14s %s" % (name, why))
sys.exit(1 if bad else 0)
