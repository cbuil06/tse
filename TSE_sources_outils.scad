// =====================================================================
// Projet TinyStar'Ex (TSE) / TinyStar'Ex (TSE) project
// Spectrographe / Spectrograph
// Sources OpenSCAD des fichiers STL / OpenSCAD sources of the STL files
// Auteur / Author : Christian Buil - STAROS Projects
// Version 1.2 - Nov. 4, 2026
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
// BOÎTE DE PROTECTION DE L'INTERFACE RÉSEAU
// GRATING INTERFACE PROTECTION BOX 
// Pièce / Part : 3A-boite-reseau-interface
// =====================================================================

// hauteur : hauteur totale de la boîte, plancher compris (mm)
//           46.0 pour un réseau de 12.5 mm de côté
//           52.5   pour un réseau de 25.0 mm de côté
// hauteur : total box height, floor included (mm)
//           46.0 for a 12.5 mm square grating
//           52.5   for a 25.0 mm square grating
module boite_reseau_interface(hauteur = 52.5)
{
    e = 0.01;   // petit débord pour des soustractions propres
                // small overlap for clean subtractions
    
    difference()
    {
        linear_extrude(height = hauteur)
            polygon([[-10.5,   18], [46.1,  18], [46.1, -18],
                     [-12.347, -18], [-26.3, -6.292], [-26.3, 10.633]]);
        translate([0, 0, 2.5])
            linear_extrude(height = hauteur - 2.5 + e)
                polygon([[ -9.645,  14.15], [38,  14.15], [38, -14.15],
                         [-10.946, -14.15], [-18, 0.977], [-18, 10.254]]);
        for (p = [[-21.7, 0], [41.8, -11], [41.8, 11]])
            translate([p[0], p[1], hauteur - 8.5])
                cylinder(h = 8.5 + e, d = 4.2);
    }
}

// =====================================================================
// BOÎTE RÉSEAU SIMPLE / SIMPLE GRATING BOX
// Pièce / Part : 4A-boite-reseau-simple
// =====================================================================
// Boîte pour réseau de 12.5 mm ou de 25.0 mm de côté, fermée par le
// couvercle (pièce 5A-boite-reseau-couvercle).
// Box for a 12.5 mm or 25.0 mm square grating, closed by the lid
// (part 5A-boite-reseau-couvercle).
// =====================================================================

// hauteur : hauteur totale de la boîte, plancher compris (mm)
//           38.0   pour un réseau de 12.5 mm de côté
//           44.5   pour un réseau de 25.0 mm de côté
// hauteur : total box height, floor included (mm)
//           38.0   for a 12.5 mm square grating
//           44.5   for a 25.0 mm square grating
module boite_reseau_simple(hauteur = 38.0)
{
    e = 0.01;   // petit débord pour des soustractions propres
                // small overlap for clean subtractions

    // Centres des 4 colonnettes de fixation du couvercle
    // Centres of the 4 lid fastening pillars
    colonnettes = [[28.9, 13.8], [-28.9, 13.8], [28.9, -13.8], [-28.9, -13.8]];

    difference()
    {
        union()
        {
            difference()
            {
                translate([-32.5, -19, 0])
                    cube([65, 38, hauteur]);
                translate([-29.5, -16, 3])
                    cube([59, 32, hauteur - 3 + e]);
            }
            for (p = colonnettes)
                translate([p[0], p[1], 0])
                    cylinder(h = hauteur, d = 7.2);
        }

        translate([19, 0, -e])
            cylinder(h = 3 + 2 * e, d = 4.7);

        for (p = colonnettes)
            translate([p[0], p[1], hauteur - 9])
                cylinder(h = 9 + e, d = 4.2);
    }
}

// =====================================================================
// COUVERCLE DE LA BOÎTE RÉSEAU / GRATING BOX LID
// Pièce / Part : 5A-boite-reseau-couvercle
// =====================================================================

module boite_reseau_couvercle()
{
    e = 0.01;   // petit débord pour des soustractions propres
                // small overlap for clean subtractions

    difference()
    {
        translate([-32.5, -19, 0])
            cube([65, 38, 3]);
        for (p = [[28.9, 13.8], [-28.9, 13.8], [28.9, -13.8], [-28.9, -13.8]])
            translate([p[0], p[1], -e])
                cylinder(h = 3 + 2 * e, d = 4.4);
    }
}

// =====================================================================
// AFFICHAGE / DISPLAY
// =====================================================================
// fourche_reglage();
// manette_reglage();
boite_reseau_interface();
// boite_reseau_simple();
// boite_reseau_couvercle();