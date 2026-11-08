// =====================================================================
//  Hidden-Latch Switch Guard
//  A replacement 2-gang Decora wall plate with a hinged, self-locking lid.
//
//  The lid locks automatically when you push it shut. There is no keyhole,
//  button or slider for a child to find. To open it, an adult holds a
//  strong magnet on top of the box. The magnet lifts a hidden steel bolt
//  out of the lid's latch tongue, and the lid swings down.
//
//  Units: millimetres.
//  Axes:  X = left/right along the wall, Y = up, Z = out from the wall.
//  Origin: the centre point between the two switches.
// =====================================================================

/* [What to show / export] */
// hood / lid / cap = printable parts (export these as STL)
// assembly, scene, section = previews; slice = 2D latch cut (SVG);
// check_lid, check_bolt = collision tests (an empty result means no collision)
part = "assembly"; // [assembly, scene, section, hood, lid, cap, slice, check_lid, check_bolt]
// Which switch(es) the locking box covers
guard = "both";    // [both, right, left]
// Lid opening angle (preview only)
lid_angle = 0;     // [0:180]
show_hardware = true;
// For part = "slice": which part to slice through the latch (2D export)
slice_of = "hood"; // [hood, lid, bolt, cap]
// For part = "slice": bolt lifted by the magnet?
bolt_raised = false;

/* [Your existing switch: measure and adjust] */
gang_spacing  = 46.0;   // centre-to-centre of the two switches (1.81")
decora_w      = 33.3;   // rocker opening width  (1.31")
decora_h      = 66.8;   // rocker opening height (2.63")
screw_spacing = 96.8;   // plate screws above/below each rocker (3.81")
old_plate_w   = 115.8;  // existing plate, to hide paint lines (4.56")
old_plate_h   = 114.3;  // (4.50")

/* [Guard body] */
plate_t    = 2.5;   // reduce if the rocker rubs on the plate opening
wall       = 3.0;
H          = 20.0;  // depth of box from wall to lid
lid_t      = 3.0;
cav_half_w = 21.0;  // cavity half-width around each guarded rocker
cav_half_h = 53.0;  // cavity half-height (clears the plate screws)
corner_r   = 4.0;
tol        = 0.4;

/* [Latch hardware] */
bolt_d      = 4.0;  // M4 x 10 socket head cap screw, ALLOY steel (magnetic)
bolt_len    = 10.0;
bolt_head_d = 7.0;
bolt_head_h = 4.0;
lift        = 5.5;  // how far the magnet lifts the bolt
cap_t       = 1.2;  // thin cap between magnet and bolt
tongue_w    = 10.0;
tongue_t    = 6.0;
latch_w     = 16.0;
bolt_z      = 14.5; // depth of the bolt axis from the wall

/* [Hinge] */
pin_d = 3.0;        // 3 mm steel rod (or M3 threaded rod)
kr    = 4.5;        // knuckle radius

$fn = 64;

// ---------------------------------------------------------------- derived
gx      = [-gang_spacing / 2, gang_spacing / 2];
guarded = guard == "both" ? [0, 1] : guard == "right" ? [1] : [0];
gmin    = min([for (i = guarded) gx[i]]);
gmax    = max([for (i = guarded) gx[i]]);

hx0 = gmin - cav_half_w - wall;
hx1 = gmax + cav_half_w + wall;
HW  = hx1 - hx0;

// Latch sits beside the screws so a screwdriver can still reach them.
lx = guard == "both" ? (gx[0] + gx[1]) / 2
   : guard == "right" ? gx[1] - 15 : gx[0] + 15;

// Latch stack (Y), bottom to top
lb_y0      = decora_h / 2 + 2.6;           // bottom of latch block
slot_y0    = lb_y0 + 2;                    // slot floor
tongue_y0  = slot_y0 + 0.4;                // tongue bottom when shut
tongue_y1  = tongue_y0 + tongue_t;         // tongue top
slot_h     = 0.4 + tongue_t + 1.4;         // room for the lid's arc
bolt_end_y = tongue_y0 + 2.0;              // bolt tip at rest (4 mm engaged)
shoulder_y = bolt_end_y + bolt_len;        // under side of bolt head
head_top_y = shoulder_y + bolt_head_h + lift;
hy1        = head_top_y + cap_t;           // top of box
hy0        = -cav_half_h - wall;           // bottom of box

slot_back_z  = 3.0;
tongue_tip_z = slot_back_z + 0.8;
wedge_end_z  = tongue_tip_z + 7.5;

// Hinge axis: under the box, knuckles flush with the lid's front face
ya = hy0 - kr - 0.5;
za = H + lid_t - kr;

// Base plate: covers old plate footprint and the whole guard
px0 = min(-old_plate_w / 2 - 3, hx0 - 4);
px1 = max( old_plate_w / 2 + 3, hx1 + 4);
py0 = min(-old_plate_h / 2 - 3, ya - kr - 3);
py1 = max( old_plate_h / 2 + 3, hy1 + 4);

echo(str("Plate ", px1 - px0, " x ", py1 - py0, " mm; box ", HW, " x ",
         hy1 - hy0, " x ", H + lid_t, " mm deep"));
echo(str("Hinge rod: cut to ", floor(HW - 2.5), " mm"));

// ------------------------------------------------------------ primitives
module rrect(x0, y0, x1, y1, r) {
    translate([x0 + r, y0 + r]) offset(r = r) square([x1 - x0 - 2 * r, y1 - y0 - 2 * r]);
}

// 2D teardrop pointing +Y, tip truncated so it prints without support.
module teardrop2d(r, trunc = 1.1) {
    intersection() {
        union() { circle(r); rotate(45) square(r); }
        translate([-2 * r, -2 * r]) square([4 * r, 2 * r + r * trunc]);
    }
}

// Bore along Y from y1 to y2 at (x, z). dir = +1 tip to +Z, -1 tip to -Z.
module bore_y(x, z, y1, y2, r, dir = 1) {
    translate([x, y2, z]) rotate([90, 0, 0]) linear_extrude(y2 - y1)
        rotate(dir > 0 ? 0 : 180) teardrop2d(r);
}

// Bore along X from x1 to x2 at (y, z). dir as above.
module bore_x(y, z, x1, x2, r, dir = 1) {
    translate([x1, y, z]) rotate([0, 90, 0]) linear_extrude(x2 - x1)
        rotate(dir > 0 ? 90 : -90) teardrop2d(r);
}

module box(p0, p1) { translate(p0) cube(p1 - p0); }

// Knuckle layout: hood owns both ends and the middle, lid owns the gaps.
kh = min(10, HW / 6);
kg = 0.5;
kl = (HW - 3 * kh - 4 * kg) / 2;
hood_knuckles = [[hx0, hx0 + kh],
                 [hx0 + kh + 2 * kg + kl, hx0 + 2 * kh + 2 * kg + kl],
                 [hx1 - kh, hx1]];
lid_knuckles  = [[hx0 + kh + kg, hx0 + kh + kg + kl],
                 [hx1 - kh - kg - kl, hx1 - kh - kg]];

// ------------------------------------------------------------------ hood
module hood() {
    difference() {
        union() {
            // wall plate
            linear_extrude(plate_t) rrect(px0, py0, px1, py1, 6);
            // box walls
            difference() {
                linear_extrude(H) rrect(hx0, hy0, hx1, hy1, corner_r);
                translate([0, 0, -1]) linear_extrude(H + 2)
                    rrect(hx0 + wall, hy0 + wall, hx1 - wall, hy1 - wall, 1);
            }
            // latch block
            box([lx - latch_w / 2, lb_y0, 0], [lx + latch_w / 2, hy1 - 0.5, H]);
            // hinge knuckles
            for (k = hood_knuckles) {
                box([k[0], ya - kr, 0], [k[1], hy0 + 0.01, za]);
                translate([k[0], ya, za]) rotate([0, 90, 0]) cylinder(r = kr, h = k[1] - k[0]);
            }
        }
        // rocker openings (every gang)
        for (x = gx)
            translate([x, 0, -1]) linear_extrude(plate_t + 2)
                offset(r = 0.8) square([decora_w + tol - 1.6, decora_h + tol - 1.6], center = true);
        // countersunk plate screw holes (#6-32)
        for (x = gx, s = [-1, 1])
            translate([x, s * screw_spacing / 2, 0]) {
                translate([0, 0, -1]) cylinder(d = 3.8, h = plate_t + 2);
                translate([0, 0, plate_t - 1.9]) cylinder(d1 = 3.8, d2 = 7.4, h = 1.91);
                translate([0, 0, plate_t]) cylinder(d = 7.4, h = H);
            }
        // tongue slot, open toward the lid, with a lead-in chamfer
        box([lx - (tongue_w + 1) / 2, slot_y0, slot_back_z],
            [lx + (tongue_w + 1) / 2, slot_y0 + slot_h, H + 1]);
        hull() {
            box([lx - (tongue_w + 1) / 2, slot_y0, H - 1.5],
                [lx + (tongue_w + 1) / 2, slot_y0 + slot_h, H - 1.4]);
            box([lx - (tongue_w + 3) / 2, slot_y0 - 1, H],
                [lx + (tongue_w + 3) / 2, slot_y0 + slot_h + 1, H + 0.01]);
        }
        // bolt shank guide and head chamber
        bore_y(lx, bolt_z, slot_y0 + slot_h - 0.1, shoulder_y, (bolt_d + 0.6) / 2);
        bore_y(lx, bolt_z, shoulder_y, head_top_y + 0.01, (bolt_head_d + 0.6) / 2);
        // counterbore for the glued-in cap
        bore_y(lx, bolt_z, head_top_y, hy1 + 1, 4.5);
        // hinge rod hole: open on the left end, blind on the right
        bore_x(ya, za, hx0 - 1, hx1 - 1.5, (pin_d + 0.1) / 2);
    }
}

// ------------------------------------------------------------------- lid
module tongue() {
    translate([lx + tongue_w / 2, 0, 0]) rotate([0, -90, 0]) linear_extrude(tongue_w)
        polygon([[H + 0.01, tongue_y0], [H + 0.01, tongue_y1], [wedge_end_z, tongue_y1],
                 [tongue_tip_z, tongue_y0 + 0.5], [tongue_tip_z, tongue_y0]]);
}

module lid() {
    difference() {
        union() {
            translate([0, 0, H]) linear_extrude(lid_t) rrect(hx0, hy0, hx1, hy1, corner_r);
            tongue();
            for (k = lid_knuckles) {
                box([k[0], ya, H], [k[1], hy0 + 1, H + lid_t]);
                translate([k[0], ya, za]) rotate([0, 90, 0]) cylinder(r = kr, h = k[1] - k[0]);
            }
        }
        // latch hole through the tongue (teardrops point down when printed face-down)
        bore_y(lx, bolt_z, tongue_y0 - 1, tongue_y1 + 1, (bolt_d + 0.8) / 2, -1);
        // hinge hole, free running
        bore_x(ya, za, hx0 - 1, hx1 + 1, (pin_d + 0.5) / 2, -1);
        // fingertip bevel along the top front edge (for adults)
        translate([hx0 - 1, hy1, H + lid_t - 3 / sqrt(2)]) rotate([45, 0, 0])
            cube([HW + 2, 3, 3]);
    }
}

// ------------------------------------------------------------------- cap
module cap() { cylinder(r = 4.5 - 0.15, h = cap_t); }

// -------------------------------------------------------------- hardware
module bolt(raise = 0) {
    color("DimGray") translate([lx, bolt_end_y + raise, bolt_z]) rotate([-90, 0, 0]) {
        cylinder(d = bolt_d, h = bolt_len);
        translate([0, 0, bolt_len]) difference() {
            cylinder(d = bolt_head_d, h = bolt_head_h);
            translate([0, 0, 1.5]) cylinder(d = 3.4, h = 3, $fn = 6);
        }
    }
}

module rod() {
    color("Silver") translate([hx0 + 0.5, ya, za]) rotate([0, 90, 0])
        cylinder(d = pin_d, h = HW - 2.5);
}

module section_cut() { box([lx, py0 - 10, -10], [px1 + 10, py1 + 10, 60]); }

module lid_posed(a) {
    translate([0, ya, za]) rotate([a, 0, 0]) translate([0, -ya, -za]) lid();
}

// Simple stand-ins for the real wall and rocker switches (renders only)
module wall_and_switches() {
    color("#f4f1ec") translate([-400, -400, -6]) cube([800, 800, 6]);
    for (x = gx) {
        color("Ivory") translate([x, 0, 0]) linear_extrude(plate_t + 0.6)
            square([decora_w - 0.6, decora_h - 0.6], center = true);
        color("White") translate([x, 0, plate_t + 0.6])
            rotate([-4, 0, 0]) linear_extrude(4)
                offset(r = 1) square([decora_w - 6, decora_h - 8], center = true);
    }
}

// -------------------------------------------------------------- outputs
if (part == "scene") {
    // Wall turned upright (Y up) for presentation renders
    rotate([90, 0, 0]) {
        wall_and_switches();
        color("WhiteSmoke") hood();
        color("#e9e6e0") lid_posed(lid_angle);
        color("LightGray") translate([lx, hy1 - cap_t, bolt_z]) rotate([-90, 0, 0]) cap();
        if (show_hardware) { bolt(); rod(); }
    }
} else if (part == "assembly") {
    color("WhiteSmoke") hood();
    color("Gainsboro") lid_posed(lid_angle);
    color("LightGray") translate([lx, hy1 - cap_t, bolt_z]) rotate([-90, 0, 0]) cap();
    if (show_hardware) { bolt(); rod(); }
} else if (part == "section") {
    // 3D cut-away through the centre of the latch
    rotate([90, 0, 0]) {
        color("#d9d6cf") intersection() { hood(); section_cut(); }
        color("#7fb3d5") intersection() { lid_posed(lid_angle); section_cut(); }
        color("#c9a227") intersection() { translate([lx, hy1 - cap_t, bolt_z]) rotate([-90, 0, 0]) cap(); section_cut(); }
        color("#4a4a4a") intersection() { bolt(); section_cut(); }
    }
} else if (part == "slice") {
    // 2D cut through the latch centre line: X = depth from wall, Y = height
    projection(cut = true) rotate([0, 90, 0]) translate([-lx, 0, 0]) {
        if (slice_of == "hood") hood();
        if (slice_of == "lid")  lid_posed(lid_angle);
        if (slice_of == "bolt") bolt(bolt_raised ? lift : 0);
        if (slice_of == "cap")  translate([lx, hy1 - cap_t, bolt_z]) rotate([-90, 0, 0]) cap();
    }
} else if (part == "check_lid") {          // should be empty at every angle
    intersection() { hood(); lid_posed(lid_angle); }
} else if (part == "check_bolt") {         // should be empty with the lid shut
    intersection() { union() { hood(); lid(); } bolt(); }
} else if (part == "hood") {
    hood();                                     // prints as modelled: plate on the bed
} else if (part == "lid") {
    rotate([180, 0, 0]) translate([0, 0, -(H + lid_t)]) lid();  // front face on the bed
} else if (part == "cap") {
    cap();
}
