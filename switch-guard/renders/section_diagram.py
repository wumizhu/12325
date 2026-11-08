"""Draws the two-panel latch cross-section (locked / unlocked) from the 2D
slices that OpenSCAD exports as SVG (part = "slice").

usage: python3 section_diagram.py <dir-with-slice-svgs> <output.png>
"""
import re
import sys
from PIL import Image, ImageChops, ImageDraw, ImageFont

SRC, OUT = sys.argv[1], sys.argv[2]
PX = 18                       # pixels per mm
Z0, Z1 = -7.0, 45.0           # depth range shown (mm from wall)
Y0, Y1 = 31.0, 75.0           # height range shown
PW, PH = int((Z1 - Z0) * PX), int((Y1 - Y0) * PX)
TOP = 120                     # room for the panel title
BOTTOM = 0

COL = {"hood": "#dcd6c8", "cap": "#b9b09c", "lid": "#7fb3d5", "bolt": "#4d4d4d"}
EDGE = "#3a3a3a"
RED = "#d0362b"


def font(size, bold=False):
    name = "DejaVuSans-Bold.ttf" if bold else "DejaVuSans.ttf"
    try:
        return ImageFont.truetype("/usr/share/fonts/truetype/dejavu/" + name, size)
    except OSError:
        return ImageFont.load_default()


def subpaths(svg_file):
    d = " ".join(re.findall(r'd="([^"]*)"', open(svg_file).read()))
    for chunk in re.split(r"[Mm]", d):
        pts = [(float(a), -float(b)) for a, b in re.findall(r"(-?[\d.e+-]+),(-?[\d.e+-]+)", chunk)]
        if len(pts) >= 3:
            yield pts                      # (depth z, height y) in mm


def to_px(p):
    z, y = p
    return ((z - Z0) * PX, TOP + (Y1 - y) * PX)


def fill(img, svg_file, colour):
    """Even-odd fill so holes in the slice stay open."""
    mask = Image.new("1", img.size, 0)
    polys = list(subpaths(svg_file))
    for pts in polys:
        m = Image.new("1", img.size, 0)
        ImageDraw.Draw(m).polygon([to_px(p) for p in pts], fill=1)
        mask = ImageChops.logical_xor(mask, m)
    img.paste(Image.new("RGB", img.size, colour), (0, 0), mask)
    d = ImageDraw.Draw(img)
    for pts in polys:
        d.line([to_px(p) for p in pts + pts[:1]], fill=EDGE, width=2)


def label(d, target, at, text, colour=RED):
    tx, ty = to_px(target)
    d.line([at, (tx, ty)], fill=colour, width=3)
    d.ellipse([tx - 6, ty - 6, tx + 6, ty + 6], fill=colour)
    f = font(26, True)
    box = d.textbbox(at, text, font=f, anchor="mm")
    d.rectangle([box[0] - 8, box[1] - 6, box[2] + 8, box[3] + 6], fill="white", outline=colour, width=2)
    d.text(at, text, fill=colour, font=f, anchor="mm")


def panel(lid_svg, bolt_svg, title, colour, magnet):
    img = Image.new("RGB", (PW, TOP + PH + BOTTOM), "white")
    d = ImageDraw.Draw(img)
    # wall (hatched)
    x_wall = to_px((0, 0))[0]
    d.rectangle([0, TOP, x_wall, TOP + PH], fill="#ece8e1")
    for k in range(-PH, PW, 22):
        d.line([(k, TOP + PH), (k + PH, TOP)], fill="#c9c3b8", width=2)
    d.rectangle([x_wall, TOP, PW, TOP + PH], fill="white")
    fill(img, f"{SRC}/slice_hood.svg", COL["hood"])
    fill(img, f"{SRC}/slice_cap.svg", COL["cap"])
    fill(img, lid_svg, COL["lid"])
    fill(img, bolt_svg, COL["bolt"])
    d = ImageDraw.Draw(img)
    if magnet:
        a, b = to_px((9.5, 66.5)), to_px((19.5, 62.0))
        d.rounded_rectangle([a, b], radius=6, fill="#c0392b", outline=EDGE, width=2)
        d.text(((a[0] + b[0]) / 2, (a[1] + b[1]) / 2), "MAGNET", fill="white", font=font(22, True), anchor="mm")
        ax = to_px((25.5, 50))[0]
        d.line([(ax, to_px((0, 52))[1]), (ax, to_px((0, 58.5))[1])], fill=RED, width=5)
        d.polygon([(ax - 12, to_px((0, 58))[1]), (ax + 12, to_px((0, 58))[1]), (ax, to_px((0, 60.5))[1])], fill=RED)
        d.text((ax + 18, to_px((0, 55.5))[1]), "bolt\nlifts", fill=RED, font=font(24, True), anchor="lm")
    d.text((24, 22), title, fill=colour, font=font(38, True))
    return img


locked = panel(f"{SRC}/slice_lid.svg", f"{SRC}/slice_bolt.svg",
               "LOCKED", "#1d6b3a", magnet=False)
d = ImageDraw.Draw(locked)
d.text((24, 72), "Bolt has dropped into the lid's tongue", fill="#444", font=font(26))
label(d, (14.5, 52), to_px((33, 70)), "steel bolt")
label(d, (8.0, 40.5), to_px((10, 33.8)), "lid tongue")
label(d, (21.5, 35), to_px((34, 36)), "lid", colour="#2a6f9e")
label(d, (-3, 50), to_px((-3, 72)), "wall", colour="#6b6457")

unlocked = panel(f"{SRC}/slice_lid_open.svg", f"{SRC}/slice_bolt_up.svg",
                 "UNLOCKED", "#b03a2e", magnet=True)
d = ImageDraw.Draw(unlocked)
d.text((24, 72), "Magnet on top lifts the bolt; lid swings down", fill="#444", font=font(26))

gap = 30
sheet = Image.new("RGB", (PW * 2 + gap, locked.height), "white")
sheet.paste(locked, (0, 0))
sheet.paste(unlocked, (PW + gap, 0))
ImageDraw.Draw(sheet).line([(PW + gap // 2, 20), (PW + gap // 2, sheet.height - 20)], fill="#ddd", width=3)
sheet.save(OUT)
