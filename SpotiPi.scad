$fn=64;
include <BOSL/constants.scad>
use <BOSL/masks.scad>

/*
 * SpotiPi case design by Riley.
 *
 * Incredibly useful document:
 * <https://datasheets.raspberrypi.com/rpizero2/raspberry-pi-zero-2-w-mechanical-drawing.pdf>
 *
 * Requires BOSL <https://github.com/revarbat/BOSL>
 */

// change to match your hardware and preferences
    wall_thickness = 4; // thickness of the wall
    outer_border = 1; // distance between the wall and the raspi
    nut = [6, 3.2 / 2]; // height, radius of heatset nut thing
    fillet_radius = 2;

// raspi dimensions
    pi_board = [30,65,1.4];
    hole_board_offset = 3.5; // distance from the edge of the board to the center of each hole

    // cutouts
        cutout_margin = 2.75;

        hdmi_offset = 12.4;
        hdmi_size = [14+cutout_margin, 6+cutout_margin / 2]; // width, height
        usb_offsets = [41.4,54];
        usb_size = [10+cutout_margin, 4+cutout_margin / 2];

        sd_offset = 12.5;
        sd_size = [14+cutout_margin, 8+cutout_margin];

        pi_holes = [pi_board[2], 2.5 / 2];

// hat dimensions
    hat_elevation = 16;

    aux_margin = 1;
    rca_margin = 1;

    // cutouts
    aux_offset = 15.5;
    aux_size = [(aux_margin + 6.5) / 2, 4]; // radius, vertical offset from board

    rca_offsets = [31.5, 49];
    rca_size = [(rca_margin + 8.5) / 2, 8.5]; // radius, vertical offset from board

// calculated
    //// offset from the bounding box to the start of the board
    side_board_offset = outer_border + wall_thickness;
    min_internal_height = pi_board[2] * 2 + hat_elevation + rca_size[1] + rca_size[0] + 1; // temp var pls delete
    internal_height = min_internal_height;
    total_height = internal_height + nut[0];
    hat_board_start = pi_board[2] + hat_elevation;

    // cutouts
        door_cutin = wall_thickness / 2;
        right_side_offset = side_board_offset + pi_board[1] + outer_border;

        door_points = [
            [wall_thickness, wall_thickness, 0],                  // 0
            [wall_thickness, right_side_offset, 0],               // 1
            [0, right_side_offset + door_cutin, 0],               // 2
            [0, wall_thickness - door_cutin, 0],                  // 3
            [wall_thickness, wall_thickness, internal_height],    // 4
            [wall_thickness, right_side_offset, internal_height], // 5
            [0, right_side_offset + door_cutin, internal_height], // 6
            [0, wall_thickness - door_cutin, internal_height],    // 7
        ];

        door_faces = [
            [0,1,2,3],  // bottom
            [4,5,1,0],  // front
            [7,6,5,4],  // top
            [5,6,2,1],  // right
            [6,7,3,2],  // back
            [7,4,0,3]   // left
        ];

// holes with the seperation required to line up with the raspi holes
module holes(hole_size) {
    for (i = [hole_board_offset, pi_board[0] - hole_board_offset]) {
        for (j = [hole_board_offset, pi_board[1] - hole_board_offset]) {
            translate([
                i,
                j,
                hole_size[0] / 2
            ]) cylinder(
                h = hole_size[0],
                r = hole_size[1],
                center = true
            );
        };
    };
};

module pi() {
    color("red") translate([
        side_board_offset,
        side_board_offset,
        nut[0]
    ]) difference() {
        cube(pi_board);
        holes(pi_holes);
    };
};

module hdmi_hole() {
    translate([
        0,
        side_board_offset + hdmi_offset - hdmi_size[0] / 2,
        0
    ]) cube([
        wall_thickness,
        hdmi_size[0],
        pi_board[2] + nut[0] + hdmi_size[1]
    ]);
};

module usb_holes() {
    for (usb_offset = usb_offsets) {
        translate([
            0,
            side_board_offset + usb_offset - usb_size[0] / 2,
            0
        ]) cube([
            wall_thickness,
            usb_size[0],
            usb_size[1] + pi_board[2] + nut[0]
        ]);
    };
};

module sd_hole() {
    translate([
        side_board_offset + sd_offset - sd_size[0] / 2,
        0,
        0
    ]) cube([
        sd_size[0],
        wall_thickness,
        nut[0] + pi_board[2] + sd_size[1]
    ]);
};

module aux_hole() {
    translate([
        wall_thickness / 2,
        side_board_offset + aux_offset,
        hat_board_start + pi_board[2] + aux_size[1]
    ]) rotate([
        0,90,0
    ]) cylinder(
        h=wall_thickness,
        r=aux_size[0],
        center=true
    );
};

module rca_holes() {
    for (rca_offset = rca_offsets) {
        translate([
            wall_thickness / 2,
            side_board_offset + rca_offset,
            hat_board_start + pi_board[2] + rca_size[1]
        ]) rotate([
            0,90,0
        ]) cylinder(
            h=wall_thickness,
            r=rca_size[0],
            center=true
        );
    };
};

module center_chamber() {
    translate([
        wall_thickness,
        wall_thickness,
        nut[0]
    ]) cube([
        outer_border * 2 + pi_board[0],
        outer_border * 2 + pi_board[1],
        internal_height
    ]);
};

module door_slot() {
    translate([side_board_offset + outer_border + pi_board[0], 0, nut[0]])
        polyhedron(points = door_points, faces = door_faces);
};

module cut_holes() {
    hdmi_hole();
    usb_holes();
    aux_hole();
    rca_holes();
};

bottom_depth = side_board_offset * 2 + pi_board[0];
module bottom() {
    dims = [
        bottom_depth,
        side_board_offset * 2 + pi_board[1],
        total_height - 0.0001
    ];
    
    difference() {
        translate([
            dims[0] / 2, dims[1] / 2, dims[2] / 2
        ]) fillet(
            fillet=fillet_radius,
            size=dims,
            edges=EDGES_Z_ALL
        ) cube(dims, center=true);
        translate([
            side_board_offset,side_board_offset,0
        ]) holes(nut);
        center_chamber();
        sd_hole();
        translate([
            pi_board[0] + side_board_offset + outer_border,
            0,
            0
        ]) cut_holes();
        door_slot();
    };
};

module door() {
    translate([
        bottom_depth * 2,
        0,
        0
    ]) rotate([
        0,270,0
    ]) difference() {
        polyhedron(points = door_points, faces = door_faces);
        cut_holes();
    };
};

module top() {
    dims = [
        side_board_offset * 2 + pi_board[0],
        side_board_offset * 2 + pi_board[1],
        wall_thickness
    ];
    
    translate([
        bottom_depth + internal_height + 12,0,0
    ]) difference() {
        translate([
            dims[0] / 2,
            dims[1] / 2,
            dims[2] / 2
        ]) fillet(
            fillet=fillet_radius,
            size=dims,
            edges=EDGES_TOP + EDGES_Z_ALL
        ) cube(dims, center=true);
        
        translate([
            side_board_offset,side_board_offset,0
        ]) union() {
            holes([wall_thickness / 2, 3 / 2]);
            translate([
                0,0,wall_thickness / 2
            ]) holes([wall_thickness / 2, 3]);
        };
    };
};

bottom();
door();
top();