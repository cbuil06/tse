// =====================================================================
// Projet TinyStar'Ex (TSE) / TinyStar'Ex (TSE) project
// Système guide / Guiding system
// Sources OpenSCAD des fichiers STL / OpenSCAD sources of the STL files
// Christian Buil - STAROS Projects
// Version 1.0
// =====================================================================


$fn=150;  // Finesse des cercles / Circle resolution
epsilon = 0.01;     // Petite marge pour des soustractions propres
                    // Small margin for clean subtractions
                    

// =====================================================================
// CUBE DE GUIDAGE / GUIDING CUBE
// Pièce / Part : 1G-1-cube-guidage
// =====================================================================

module cube_guidage()
{
    z_axe     = 26;       // Hauteur de l'axe optique / Optical axis height
    x_arriere = -22.95;   // Face arrière / Back face
    x_avant   = 55;       // Face avant (côté caméra) / Front face (camera side)
   
    // Cylindre sur l'axe optique, de x1 à x2 / Cylinder on the optical axis, from x1 to x2
    module cyl_axe(x1, x2, d)
        translate([x1, 0, z_axe]) rotate([0, 90, 0]) cylinder(h = x2 - x1, d = d);

    difference()
    {
        union()
        {
            // Corps principal / Main body
            translate([x_arriere, -52.5/2, 0]) cube([x_avant - x_arriere, 52.5, 42]);

            // Bossage / Boss
            translate([25.2, -46.5/2, 41.99]) cube([x_avant - 25.2, 46.5, 10.01]);

            // Pince / Clamp
            difference()
            {
                translate([39, -19/2, 51.99]) cube([x_avant - 39, 19, 14.01]);
                translate([47, -4, 59]) rotate([ 90, 0, 0]) cylinder(h = 20, d = 5.9, $fn = 24); // Ø5.9 insert
                translate([47, -8, 59]) rotate([-90, 0, 0]) cylinder(h = 20, d = 4.3, $fn = 24); // Ø4.3 vis / screw
            }
        }

        // Alésages sur l'axe caméra / Bores on the camera axis
        cyl_axe(44.8,          x_avant + 1, 46.2);  // Ø46.2 logement interface caméra / camera interace bore
        cyl_axe(30.2,          x_avant + 1, 43);    // Ø43   épaulement caméra / camera shoulder
        cyl_axe(17.15,         x_avant + 1, 17.2);  // Ø17.2 lentilles / lenses
        cyl_axe(x_arriere - 1, 20,          13);    // Ø13   épaulement lentilles / lens shoulder

        // Ouverture miroir 18.4 x 18.4 / Mirror opening
        translate([x_arriere - 1, -18.4/2, z_axe - 18.4/2]) cube([15 - x_arriere + 1, 18.4, 18.4]);

        // 3 inserts Ø4.2 de la rondelle, sur un rayon de 12.1 / 3 washer inserts, radius 12.1
        for (a = [60, 180, 300])
            translate([0, 0, z_axe]) rotate([a, 0, 0])
                translate([21.18, 0, 12.1]) rotate([0, 90, 0]) cylinder(h = 10, d = 4.2, $fn = 24);

        // 4 inserts Ø4.2 du support miroir, carré de 24 / 4 mirror holder inserts, 24 square
        for (y = [-12, 12], z = [-12, 12])
            translate([x_arriere - 1, y, z_axe + z]) rotate([0, 90, 0])
                cylinder(h = -13 - x_arriere, d = 4.2, $fn = 24);

        // --- Trous verticaux / Vertical holes ---
        translate([0, 0, -1])   cylinder(h = 44,  d = 30);   // Ø30 trou central / central hole
        translate([0, 0, 35.5]) cylinder(h = 7.5, d = 40);   // Ø40 dégagement fente, profondeur / slit clearance

        // 4 trous Ø4.3 fixation spectro / télescope, carré de 40 / mounting holes, 40 square
        for (x = [-20, 20], y = [-20, 20])
            translate([x, y, -1]) cylinder(h = 44, d = 4.3, $fn = 26);

        // Fente de 2 mm (bossage + pince) / 2 mm slot (boss + clamp)
        translate([31, -1, 42]) cube([x_avant - 30, 2, 25]);
    }
}



// =====================================================================
// INTERFACE GUIDAGE / GUIDING INTERFACE
// Pièce / Part : 2G-1-interface-guidage
// =====================================================================

module interface_guidage()
{
    difference()
    {
        union()
        {
            // Carré de fixation 50 x 50 x 9 / 50 x 50 x 9 mounting square
            translate([-25, -25, 0])
                cube([50, 50, 9]);

            // Collier Ø46.8 / Ø46.8 collar
            translate([0, 0, 8])
                cylinder(h = 24, d = 46.8);

            // Oreille de serrage / Clamping ear
            translate([0, -9.5, 16])
                cube([36, 19, 16]);
        }

        // Alésage central Ø39.95 mm / Central bore Ø39.95 mm
        translate([0, 0, -epsilon])
            cylinder(h = 32 + 2 * epsilon, d = 39.95);

        // Fente de serrage de 2.5 mm / 2.5 mm clamping slot
        translate([0, -1.25, 10.5])
            cube([38, 2.5, 21.5 + epsilon]);

        // Vis de serrage M4 : trou Ø4.3 traversant
        // M4 clamping screw: Ø4.3 through hole
        translate([29, -9.5 - epsilon, 24])
            rotate([-90, 0, 0])
                cylinder(h = 19 + 2 * epsilon, d = 4.3);

        // Logement Ø5.7 de l'insert M4
        // Ø5.7 M4 insert hole
        translate([29, -9.5 - epsilon, 24])
            rotate([-90, 0, 0])
                cylinder(h = 6 + epsilon, d = 5.7);

        // 4 trous Ø4.4 pour vis M4 + logements Ø5.8 d'inserts M4
        // 4 Ø4.4 holes for M4 screws + Ø5.8 M4 insert holes
        for (x = [-20, 20], y = [-20, 20])
        {
            translate([x, y, -epsilon])
                cylinder(h = 9 + 2 * epsilon, d = 4.4);
            translate([x, y, 9 - 5])
                cylinder(h = 5 + epsilon, d = 5.8);
        }
    }
}


// =====================================================================
// SUPPORT MIROIR PLAN / FLAT MIRROR HOLDER
// Pièce / Part : 3G-1-support-miroir
// =====================================================================

module support_miroir(
    // Angle Miroir / Mirror angle
    angle_miroir        = 30,    // Inclinaison du miroir (degrés) / Mirror tilt (degrees)
    epaisseur_miroir    = 3.2,   // Épaisseur du miroir = profondeur du logement
                                 // Mirror thickness = pocket depth

    // Logement du miroir / Mirror pocket
    largeur_logement    = 15.5,  // Largeur / Width
    longueur_logement   = 21,    // Longueur le long de la pente / Length along the slope
    bas_logement        = -14.9, // Bord inférieur, mesuré le long de la pente depuis l'origine
                                 // Lower edge, measured along the slope from the origin

    // Réserve de colle (sous le miroir) / Glue recess (under mirror)
    largeur_colle       = 10,    // Largeur / Width
    longueur_colle      = 19.5,  // Longueur le long de la pente / Length along the slope
    bas_colle           = -15.8, // Bord inférieur, mesuré le long de la pente depuis l'origine
                                 // Lower edge, measured along the slope from the origin
    x_colle             = 1,     // Décalage suivant X / Offset along X

    // Bloc support / Holder block 
    section_support     = 18,    // Côté de la section carrée / Square section side
    recul_support       = 10,    // Débord du bloc devant le miroir / Block overhang in front of mirror
    limite_avancee      = -3.54, // Au-delà (X négatif), la partie haute est coupée
                                 // Beyond this (negative X), the top part is cut off
    // Épaulement de fixation / Mounting flange
    distance_epaulement = 14.01, // Distance surface miroir -> épaulement (14 + ajustement 0.01)
                                 // Mirror surface -> flange distance (14 + 0.01 adjustment)
    taille_epaulement   = 31.5,  // Côté de la platine / Flange side
    epaisseur_epaulement= 4,     // Épaisseur de la platine / Flange thickness
    entraxe_trous       = 24,    // Entraxe des 4 trous / Hole spacing
    diametre_trous      = 3.3,   // Trous lisses (3.3 = passage vis M3) / Clearance holes (M3)
)
{
    e = 0.01;  // Petit débord pour des soustractions propres / Tiny overlap for clean cuts

    // Place un objet dans le plan incliné du miroir
    // Places an object in the tilted mirror plane
    module plan_miroir() { rotate([0, -angle_miroir, 0]) children(); }

    union()
    {
        // Bloc support / Holder block
        difference()
        {
            // Bloc de section carrée, qui s'engage dans l'épaulement
            // Square-section block, merging into the flange
            translate([-recul_support, -section_support/2, -section_support/2])
                cube([recul_support + distance_epaulement + 0.5,
                      section_support, section_support]);

            // Coupe en biais : tout ce qui est devant le plan du miroir
            // Angled cut: everything in front of the mirror plane
            plan_miroir()
                translate([-100, -50, -50]) cube([100, 100, 100]);

            // Logement du miroir / Mirror pocket
            plan_miroir()
                translate([-e, -largeur_logement/2, bas_logement])
                    cube([epaisseur_miroir + e, largeur_logement, longueur_logement]);

            // Réserve de colle / Glue recess
            translate([x_colle, 0, 0])
                plan_miroir()
                    translate([0, -largeur_colle/2, bas_colle])
                        cube([epaisseur_miroir, largeur_colle, longueur_colle]);

            // Avancée cassée 
            // Broken-off overhang
            translate([limite_avancee - 50, -50, 0]) cube([50, 100, 100]);
        }

        // Epaulement de fixation / Mounting flage
        difference()
        {
            translate([distance_epaulement, -taille_epaulement/2, -taille_epaulement/2])
                cube([epaisseur_epaulement, taille_epaulement, taille_epaulement]);

            // 4 trous lisses aux coins / 4 corner clearance holes
            for (y = [-1, 1], z = [-1, 1])
                translate([distance_epaulement - 1, y * entraxe_trous/2, z * entraxe_trous/2])
                    rotate([0, 90, 0])
                        cylinder(h = epaisseur_epaulement + 2, d = diametre_trous, $fn = 26);
        }
    }
}

// =====================================================================
// TUBE LENTILLES / LENS TUBE
// Pièce / Part : 4G-1-tube-lentilles
// =====================================================================

module tube_lentilles()
{
    d1 = 17.1;   // Ø extérieur / Outer Ø
    d2 = 12.95;  // Ø logement des lentilles / Lens bore Ø
    d3 = 11.0;   // Ø passage dans l'épaulement / Shoulder hole Ø
                       
    difference()
    {
        cylinder(h = 15.9, d = d1);            
        translate([0, 0, 1.5]) cylinder(h = 15, d = d2);
        translate([0, 0, -1])  cylinder(h = 3,  d = d3);
    }
}

// =====================================================================
// BRIDE DES LENTILLES / LENS CLAMPING FLANCGE
// Pièce / Part : 5G-1-bride-lentilles
// =====================================================================

module bride_lentilles()
{
    difference()
    {
        cylinder(h = 3.5, d = 30); // Ø30 rondelle, épaisseur 3.5 / washer, 3.5 thick
        translate([0, 0, -1]) cylinder(h = 6, d = 11.5);  // Ø11.5 trou central / central hole
        translate([0, 0, 2])  cylinder(h = 2, d = 17.15); // Ø17.15 lamage, profondeur 1.5 / counterbore, 1.5 deep

        // 3 trous Ø3.4 de fixation, sur un rayon de 12.1
        // 3 Ø3.4 mounting holes, on a 12.1 radius
        for (a = [0, 120, 240])
            rotate([0, 0, a]) translate([12.1, 0, -1]) cylinder(h = 6, d = 3.4, $fn = 28);
    }
}

// =====================================================================
// ENTRETOISE LENTILLES / LENS SPACER
// Pièce / Part : 6G-1-entretoise-lentilles
// =====================================================================

module entretoise_lentilles()
{
    linear_extrude(height = 5.55)
    difference()
    {
        circle(d = 12.3);   // Ø12.3 extérieur / outer
        circle(d = 10);     // Ø10   intérieur / inner
    }
}

// =====================================================================
// ENTRETOISE MIROIR / MIRROR SPACER
// Pièce / Part : 7G-1-entretoise-miroir
// =====================================================================

module entretoise_miroir(
    epaisseur       = 0.8,   // Épaisseur de la cale (réglage de la position)
                             // Shim thickness (position adjustment)
    largeur         = 31.0,  // Côté extérieur du carré / Outer square side
    largeur_ouverture = 18.4,// Côté de l'ouverture centrale / Central opening side
    entraxe_trous   = 24.0,  // Distance entre centres de 2 trous voisins
                             // Centre-to-centre distance between adjacent holes
    diametre_trous  = 3.4    // Diamètre des trous (3.4 = passage vis M3)
                             // Hole diameter (3.4 = M3 screw clearance)
)
{
    linear_extrude(height = epaisseur)
    difference()
    {
        // Plaque carrée / Square plate
        square(largeur, center = true);

        // Ouverture centrale / Central opening
        square(largeur_ouverture, center = true);

        // 4 trous de fixation aux coins / 4 corner mounting holes
        for (x = [-1, 1], y = [-1, 1])
            translate([x * entraxe_trous / 2, y * entraxe_trous / 2])
                circle(d = diametre_trous);
    }
}

// =====================================================================
// INTERFACE TÉLESCOPE / TELESCOPE INTERFACE
// Pièce / Part : 8G-1-interface-telescope
// =====================================================================

module interface_telescope()
{
    // Diamètre de l'alésage central / Diameter of the central bore interface:
    diametre_alesage = 45.3;
        
    difference()
    {
        union()
        {
            translate([-25, -25, 0])
                cube([50, 50, 16.2]);
            for (a = [0, 90])
                rotate([0, 0, a])
                    translate([25 - epsilon, -7.5, 0])
                        cube([11 + epsilon, 15, 16.2]);
        }

        // Alésage central / Central bore
        translate([0, 0, -epsilon])
            cylinder(h = 16.2 + 2 * epsilon, d = diametre_alesage);

        // 4 trous Ø4.4 pour vis M4 + logements Ø7.2 d'inserts M4 longs
        // 4 Ø4.4 holes for M4 screws + Ø7.2 long M4 insert holes
        for (x = [-20, 20], y = [-20, 20])
        {
            translate([x, y, -epsilon])
                cylinder(h = 16.2 + 2 * epsilon, d = 4.4);
            translate([x, y, 16.2 - 4.5])
                cylinder(h = 4.5 + epsilon, d = 7.2);
        }

        // Vis de blocage radiales / Radial locking screws 
        for (a = [0, 90])
            rotate([0, 0, a])
            {
                translate([16, 0, 9.1])
                    rotate([0, 90, 0])
                        cylinder(h = 20 + epsilon, d = 4.3);
                translate([26.5, 0, 9.1])
                    rotate([0, 90, 0])
                        cylinder(h = 9.5 + epsilon, d = 5.8);
            }
    }
}

// =====================================================================
// COULANT 50 MM / 50 MM NOSEPIECE
// Pièce / Part : 9G-1-coulant-50mm
// =====================================================================

module coulant_50mm()
{
    // Diamètre extérieur du coulant, qui entre dans le porte-oculaire 2"
    // (50.8 mm). À ajuster selon l'imprimante pour un glissement sans jeu.
    // Outer diameter of the nosepiece, which slides into the 2" focuser
    // (50.8 mm). Adjust to your printer for a snug sliding fit.
    diametre_coulant = 50.85;
    
    difference()
    {
        union()
        {
            cylinder(h = 30, d = diametre_coulant);
            translate([0, 0, 30 - epsilon])
                cylinder(h = 15.8 + epsilon, d = 45.1);
        }
        translate([0, 0, -epsilon])
            cylinder(h = 45.8 + 2 * epsilon, d = 34);
    }
}



// =====================================================================
// IINTERFACE CAMERA (COULANT 31.75 mm) / CAMERA INTERFACE (1.25" barrel) 
// Pièce / Part : 10G-1-interface-camera
// =====================================================================

module interface_camera(
    rallonge          = 0,     // Longueur ajoutée au tube (0 = planétaire, 34 = guide)
                               // Extra tube length (0 = planetary, 34 = guide)
    hauteur_base      = 21,    // Hauteur du tube court / Short tube height
    diametre_ext      = 46.15, // Diamètre extérieur / Outer diameter
    diametre_coulant  = 31.75, // Diamètre du coulant caméra (1.25")
                               // Camera barrel diameter (1.25")
    jeu               = 0.12,  // Jeu ajouté à l'alésage (à ajuster selon l'imprimante)
                               // Clearance added to the bore (tune for your printer)
    chanfrein         = 0.5,   // Chanfrein des arêtes extérieures (haut et bas)
                               // Outer edge chamfer (top and bottom)
    hauteur_vis       = 4.85,  // Hauteur des trous de vis depuis la base
                               // Screw hole height from the base
    diametre_vis      = 4.0,   // Diamètre des trous de vis / Screw hole diameter
    angles_vis        = [0, 120], // Position angulaire des vis (degrés)
                                  // Angular position of screws (degrees)
    finesse           = 150    // Nombre de facettes du cercle (qualité / taille STL)
                               // Circle facet count (quality / STL size)
)
{
    hauteur  = hauteur_base + rallonge;
    r_ext    = diametre_ext / 2;
    r_int    = (diametre_coulant + jeu) / 2;
    c        = chanfrein;

    difference()
    {
        rotate_extrude($fn = finesse)
            polygon([
                [r_int,     0      ],
                [r_ext - c, 0      ],
                [r_ext,     c      ],
                [r_ext,     hauteur - c],
                [r_ext - c, hauteur],
                [r_int,     hauteur]
            ]);

        for (a = angles_vis)
            rotate([0, 0, a])
                translate([0, 0, hauteur_vis])
                    rotate([0, 90, 0])
                        cylinder(h = r_ext + 1, d = diametre_vis, $fn = 24);
    }
}

// =====================================================================
// SIMULATEUR F/4 / F/4 SIMULATOR
// =====================================================================

module simulateur_f4()
{
    difference()
    {
        // Coupelle Ø56, hauteur 10 / Ø56 cup, 10 mm high
        cylinder(h = 10, d = 56);

        // Diaphragme Ø21.5, traversant / Ø21.5 diaphragm, through
        // diameter = 86 / 4
        translate([0, 0, -epsilon])
            cylinder(h = 10 + 2 * epsilon, d = 21.5);

        // Alésage Ø51 / Ø51 bore
        translate([0, 0, 2])
            cylinder(h = 8 + epsilon, d = 51);
    }
}


// =====================================================================
// AFFICHAGE / DISPLAY
// =====================================================================
// cube_guidage();
// interface_guidage();
// support_miroir();
// tube_lentilles();
// bride_lentilles();
// entretoise_lentilles();
// entretoise_miroir(epaisseur = 0.8);
// interface_telescope();
// coulant_50mm();
// interface_camera(rallonge = 34);
// simulateur_f4();




