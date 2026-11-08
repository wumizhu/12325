#!/usr/bin/env bash
# Regenerates the preview images and the STL files.
# Needs OpenSCAD 2021.01+, xvfb-run on a headless machine, and Python 3 + Pillow.
set -euo pipefail
cd "$(dirname "$0")/.."
OS="openscad"; command -v xvfb-run >/dev/null && OS="xvfb-run -a openscad"
TMP=$(mktemp -d)
cam="250,-560,100,0,-10,-5"
img="--imgsize=1200,1200 --colorscheme=Tomorrow"

$OS -o "$TMP/closed.png" $img --camera=$cam -D 'part="scene"' -D lid_angle=0   switch_guard.scad
$OS -o "$TMP/open.png"   $img --camera=$cam -D 'part="scene"' -D lid_angle=170 switch_guard.scad
$OS -o "$TMP/right.png"  $img --camera=$cam -D 'part="scene"' -D 'guard="right"' switch_guard.scad

# 2D slices through the latch for the cut-away diagram
for p in hood lid bolt cap; do
  $OS -o "$TMP/slice_$p.svg" -D 'part="slice"' -D "slice_of=\"$p\"" switch_guard.scad
done
$OS -o "$TMP/slice_lid_open.svg" -D 'part="slice"' -D 'slice_of="lid"' -D lid_angle=8 switch_guard.scad
$OS -o "$TMP/slice_bolt_up.svg"  -D 'part="slice"' -D 'slice_of="bolt"' -D bolt_raised=true switch_guard.scad

python3 renders/annotate.py "$TMP" renders
python3 renders/section_diagram.py "$TMP" renders/3_how_the_latch_works.png

for g in both right left; do
  for p in hood lid; do $OS -o "stl/${p}_${g}.stl" -D "part=\"$p\"" -D "guard=\"$g\"" switch_guard.scad; done
done
$OS -o stl/cap.stl -D 'part="cap"' switch_guard.scad
rm -rf "$TMP"
