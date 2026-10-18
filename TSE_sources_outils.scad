// =====================================================================
// Projet TinyStar'Ex (TSE) / TinyStar'Ex (TSE) project
// Spectrographe / Spectrograph
// Sources OpenSCAD des fichiers STL / OpenSCAD sources of the STL files
// Christian Buil - STAROS Projects
// Version 1.0
// =====================================================================


$fn=150;  // Finesse des cercles / Circle resolution
epsilon = 0.01;     // Petite marge pour des soustractions propres
                    // Small margin for clean subtractions
                    
// =====================================================================
// FOURCHE DE RÉGLAGE / ADJUSTMENT FORK
// Pièce / Part : 1A-fourche-reglage
// =====================================================================

module fourche_reglage()
{
    difference()
    {
        translate([0, -16, 0])
            cube([41, 32, 18]);
        translate([12, -16 - epsilon, 5])
            cube([29 + epsilon, 32 + 2 * epsilon, 13 + epsilon]);
        translate([-epsilon, -4, -epsilon])
            cube([12 + 2 * epsilon, 8, 18 + 2 * epsilon]);
        translate([6, -16 - epsilon, 12])
            rotate([-90, 0, 0])
                cylinder(h = 32 + 2 * epsilon, d = 5.9);
        for (x = [17, 35])
            translate([x, 0, -epsilon])
                cylinder(h = 5 + 2 * epsilon, d = 4.4);
    }
}


// =====================================================================
// MANETTE DE RÉGLAGE / ADJUSTMENT LEVER
// Pièce / Part : 2A-manette-reglage
// =====================================================================

module manette_reglage()
{
    difference()
    {
        union()
        {       
            cylinder(h = 12, d = 46.8);
            translate([-50, -2.5, 0])
                cube([29, 5, 12]);
            translate([0, -9.5, 0])
                cube([36, 19, 12]);
        }

        // Alésage Ø40.05 du tube collimateur
        // Ø40.05 bore for the collimator tube
        translate([0, 0, -epsilon])
            cylinder(h = 12 + 2 * epsilon, d = 40.05);

        // Fente de serrage de 2.5 mm, de X = 0 à 38
        // 2.5 mm clamping slot, from X = 0 to 38
        translate([0, -1.25, -epsilon])
            cube([38, 2.5, 12 + 2 * epsilon]);

        // Trou Ø4.3 traversant pour la vis M4
        // Ø4.3 through hole for the M4 screw
        translate([29, -9.5 - epsilon, 6])
            rotate([-90, 0, 0])
                cylinder(h = 19 + 2 * epsilon, d = 4.3);

        // Logement Ø5.7 de l'insert M4
        // Ø5.7 M4 insert hole
        translate([29, -9.5 - epsilon, 6])
            rotate([-90, 0, 0])
                cylinder(h = 6 + epsilon, d = 5.7);
    }
}

// =====================================================================
// AFFICHAGE / DISPLAY
// =====================================================================
// fourche_reglage();
// manette_reglage();