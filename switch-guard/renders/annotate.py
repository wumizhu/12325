"""Adds captions and callouts to the raw OpenSCAD renders."""
import sys
from PIL import Image, ImageDraw, ImageFont

src, dst = sys.argv[1], sys.argv[2]

def font(size, bold=False):
    name = "DejaVuSans-Bold.ttf" if bold else "DejaVuSans.ttf"
    for d in ("/usr/share/fonts/truetype/dejavu/", ""):
        try:
            return ImageFont.truetype(d + name, size)
        except OSError:
            pass
    return ImageFont.load_default()

def caption(img, title, sub):
    w, h = img.size
    out = Image.new("RGB", (w, h + 150), "white")
    out.paste(img, (0, 0))
    d = ImageDraw.Draw(out)
    d.text((40, h + 22), title, fill="#1d1d1f", font=font(44, True))
    d.text((40, h + 88), sub, fill="#555", font=font(30))
    return out

closed = Image.open(f"{src}/closed.png").convert("RGB")
caption(closed, "1. Closed: a plain box, nothing to press",
        "No keyhole, button or slider. The lid locks itself when shut.").save(f"{dst}/1_closed.png")

op = Image.open(f"{src}/open.png").convert("RGB")
caption(op, "2. Opened by an adult with the magnet key",
        "The lid swings down on its hinge; switches work as normal.").save(f"{dst}/2_open.png")

right = Image.open(f"{src}/right.png").convert("RGB")
caption(right, "Option: lock only the LIGHT switch",
        "Set guard = \"right\"; the other switch stays usable.").save(f"{dst}/4_right_only.png")
