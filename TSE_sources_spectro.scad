// =====================================================================
// Projet TinyStar'Ex (TSE) / TinyStar'Ex (TSE) project
// Spectrographe / Spectrograph
// Sources OpenSCAD des fichiers STL / OpenSCAD sources of the STL files
// Auteur / Author : Christian Buil - STAROS Projects
// Version 1.4 - Nov. 17, 2026
// =====================================================================


$fn=150;  // Finesse des cercles / Circle resolution
epsilon = 0.01;     // Petite marge pour des soustractions propres
                    // Small margin for clean subtractions
                    
// =====================================================================
// FILETAGE MÉTRIQUE ISO (profil ISO 68-1, pas à droite)
// ISO METRIC THREAD (ISO 68-1 profile, right-hand)
// =====================================================================
//
// Profil ISO de base, sur un pas P :
// Basic ISO profile, over one pitch P:
//
//   - angle des flancs 60°            / flank angle 60°
//   - hauteur du triangle H = 0.866 P / fundamental triangle H = 0.866 P
//   - sommet plat de largeur P/8 au diamètre nominal D
//     flat crest, width P/8, at nominal diameter D
//   - fond plat de largeur P/4 au diamètre intérieur D - 1.0825 P
//     flat root, width P/4, at minor diameter D - 1.0825 P
//   - profondeur de filet = 5H/8 = 0.541 P (0.325 mm pour P = 0.6)
//     thread depth = 5H/8 = 0.541 P (0.325 mm for P = 0.6)
//
// Paramètres / Parameters :
//   diametre      : diamètre extérieur (nominal) du filet, en mm
//                   outside (major) diameter of the thread, mm
//   pas           : pas du filet, en mm       / thread pitch, mm
//   longueur      : longueur filetée, en mm   / threaded length, mm
//   chanfrein_bas : chanfrein à 45° en z = 0, profondeur radiale en mm (0 = aucun)
//                   45° chamfer at z = 0, radial depth in mm (0 = none)
//   chanfrein_haut: idem en z = longueur      / same at z = length
//
// La pièce part de z = 0 (sa base) et monte jusqu'à z = longueur.
// The part starts at z = 0 (its base) and goes up to z = length.
//
// Filetage extérieur (vis)  : utiliser tel quel dans un union().
// External thread (screw)   : use as is, inside a union().
// Filetage intérieur (écrou): le soustraire avec difference(),
//                             en augmentant un peu le diamètre (jeu).
// Internal thread (nut)     : subtract it with difference(),
//                             with a slightly larger diameter (clearance).
//
// Le filet est un seul solide (polyèdre fermé)
// The thread is one single closed solid
// =====================================================================
module filetage_iso(diametre, pas, longueur, chanfrein_bas = 0, chanfrein_haut = 0)
{
    r_ext = diametre / 2;                          // rayon au sommet / crest radius
    r_int = r_ext - 5/8 * (sqrt(3)/2) * pas;       // rayon au fond / root radius

    n_ang = 120;                                   // facettes sur un tour / facets per turn
    n_z   = ceil(longueur / (pas / 16));           // tranches en hauteur / slices along z
    dz    = longueur / n_z;

    // Rayon du profil ISO selon la phase dans le pas (u entre 0 et 1)
    // ISO profile radius versus phase within the pitch (u from 0 to 1)
    function profil(u) =
          u < 1/8   ? r_ext                                          // sommet / crest
        : u < 7/16  ? r_ext - (u - 1/8)   / (5/16) * (r_ext - r_int) // flanc / flank
        : u < 11/16 ? r_int                                          // fond / root
        :             r_int + (u - 11/16) / (5/16) * (r_ext - r_int);// flanc / flank

    // Rayon de la surface au point (angle a, hauteur z), chanfreins compris
    // Surface radius at (angle a, height z), chamfers included
    function rayon(a, z) =
        let(
            v  = z - a / 360 * pas,                // hélice à droite / right-hand helix
            u  = (v - pas * floor(v / pas)) / pas,
            rb = chanfrein_bas  > 0 ? r_ext - chanfrein_bas  + z              : 1e9,
            rh = chanfrein_haut > 0 ? r_ext - chanfrein_haut + (longueur - z) : 1e9
        )
        min(profil(u), rb, rh);

    points = concat(
        [ for (i = [0 : n_z], j = [0 : n_ang - 1])
            let(a = 360 * j / n_ang, z = i * dz, r = rayon(a, z))
            [r * cos(a), r * sin(a), z] ],
        [[0, 0, 0], [0, 0, longueur]]              // centres des faces / cap centres
    );

    function id(i, j) = i * n_ang + (j % n_ang);
    bas  = (n_z + 1) * n_ang;
    haut = bas + 1;

    faces = concat(
        [ for (i = [0 : n_z - 1], j = [0 : n_ang - 1], t = [0, 1])
            t == 0 ? [id(i, j), id(i + 1, j),     id(i + 1, j + 1)]
                   : [id(i, j), id(i + 1, j + 1), id(i, j + 1)] ],
        [ for (j = [0 : n_ang - 1]) [bas,  id(0, j),       id(0, j + 1)] ],
        [ for (j = [0 : n_ang - 1]) [haut, id(n_z, j + 1), id(n_z, j)] ]
    );

    polyhedron(points = points, faces = faces, convexity = 4);
}                   


// ----- Rayon des arêtes verticales extérieures / Radius of the outer vertical edges -----
rayon_arete = 3.0;

// Utilitaire CAPOT / COVER Utility
// Contour extérieur en 2D, identique au bloc de base recoupé par les deux pans,
// avec les angles convexes arrondis au rayon voulu
// 2D outer outline, same as the base block trimmed by the two faces,
// with the convex corners rounded to the chosen radius
module contour_exterieur_arrondi()
{
    offset(delta = 0.01) offset(r = rayon_arete) offset(delta = -rayon_arete)
        difference()
        {
            translate([-88, -73]) square([115, 105]);
            // Pan parallèle à l'axe objectif / Face parallel to the objective axis
            rotate(40) translate([-80.9, -86.9]) square([120, 60]);
            // Pan perpendiculaire à l'axe objectif / Face perpendicular to the objective axis
            rotate(40) translate([-120.9, -30]) square([40, 80]);
        }
}

// =====================================================================
// CAPOT INFÉRIEUR / BOTTOM COVER
// Pièce / Part : 1-2-capot-inferieur
// =====================================================================

module capot_inferieur()
{
    // ----- Languette du bord de jonction / Joining edge tongue -----
    largeur_languette = 1.5;
    hauteur_languette = 1.5;
    e = 0.01;                   // petit débord pour des soustractions propres
                                // small overlap for clean subtractions
    union()
    {
        difference()
        {
            // Bloc extérieur recoupé par le contour arrondi (arêtes verticales R1)
            // Outer block trimmed by the rounded outline (vertical edges R1)
            intersection()
            {
                union()
                {
                    // Bloc de base / Base block
                    translate([-88, -73, 0])
                        cube([115, 105, 30]);

                    // Languette sur la face de jonction // Tongue on the joining face
                    // Face y = 32
                    translate([-88, 32 - largeur_languette, 30 - e])
                        cube([115, largeur_languette, hauteur_languette]);
                    // Face x = 27
                    translate([27 - largeur_languette, -12.46, 30 - e])
                        cube([largeur_languette, 44.46, hauteur_languette]);
                    // Face x = -88
                    translate([-88, -20.983, 30 - e])
                        cube([largeur_languette, 52.9, hauteur_languette]);
                    // Pan parallèle à l'axe objectif / Face parallel to objective axis
                    rotate([0, 0, 40]) translate([-80.9, -26.9, 30 - e])
                        cube([93.57, largeur_languette, hauteur_languette]);
                    // Pan perpendiculaire à l'axe objectif / Face perpendicular to objective axis
                    rotate([0, 0, 130]) translate([-26.9, 79.4, 30 - e])
                        cube([67.391, largeur_languette, hauteur_languette]);
                }

                // Contour extérieur à angles arrondis, de la base au sommet des languettes
                // Rounded-corner outline, from the base to the top of the tongues
                translate([0, 0, -e])
                    linear_extrude(height = 30 + hauteur_languette + 2 * e)
                        contour_exterieur_arrondi();
            }

            // Pan parallèle à l'axe objectif
            // Face parallel to the objective axis
            // (60 + e : la coupe mord de 0.01 mm sur la languette pour éviter les faces confondues)
            // (60 + e: the cut bites 0.01 mm into the tongue to avoid coincident faces)
            rotate([0, 0, 40]) translate([-80.9, -86.9, -e])
                cube([120, 60 + e, 35]);

            // Pan perpendiculaire à l'axe objectif
            // Face perpendicular to the objective axis
            rotate([0, 0, 40]) translate([-120.9, -30, -e])
                cube([40 + e, 80, 35]);
           
            // Cavités intérieures / Inner cavities, 
            rotate([0, 0, 40]) translate([-50, -16.9, 9])
                cube([58, 32.75, 25]);
            translate([-48.5, -20, 9])           
                cube([51, 42, 25]);
            translate([0, -8, 9])   
                cube([16.9, 30, 25]);
           
            // Logement du tube collimateur / Collimator tube seat
            translate([-98.7, 0, 30]) rotate([0, 90, 0])
                cylinder(h = 40, d = 39.58);      
            translate([-80, 0, 30]) rotate([0, 90, 0])
                cylinder(h = 45, d = 36);         
                
            // Logement du coulant caméra 31.75 / Camera 31.75 barrel seat 
            rotate([0, 0, 40]) translate([-85.9, 0, 30]) rotate([0, 90, 0])
                cylinder(h = 40, d = 31.72);  
                
            // Détourage de la trappe réseau / Grating hatch cut-out
            difference()
            {
                rotate([0, 0, 205]) translate([-18, -14.15, -e])
                    cube([56, 28.3, 35]);
                translate([15.9, -25, -2*e])      
                    cube([20, 40, 36]);
                translate([-15, 16.9, -2*e])      
                    cube([40, 20, 36]);
            }

            // Fixation de la trappe réseau  / Grating hatch fastening: 3 holes Ø4.2
            rotate([0, 0, 205])
            {
                // Borgne, 8.5 mm de profondeur depuis le plancher
                // Blind, 8.5 mm deep from the floor
                translate([-21.7, 0, -e])
                    cylinder(h = 8.5 + e, d = 4.2);
                // Traversants, espacés de 22 mm / Through, 22 mm apart
                for (y = [-11, 11])
                    translate([41.8, y, -e])
                        cylinder(h = 35, d = 4.2);
            }
            
            // Inserts M4 Ø5.8 des tubes, traversants,  M4 inserts Ø5.8 for the tubes, through
            // Tube objectif, sur l'axe objectif / Objective tube, on objective axis
            for (x = [-63.5, -74.5])
                rotate([0, 0, 40]) translate([x, 0, -e])
                    cylinder(h = 35, d = 5.8);
 
            // Tube collimateur, sur l'axe X / Collimator tube, on X axis
            for (x = [-64, -82])
                translate([x, 0, -e])
                    cylinder(h = 35, d = 5.8);
            
            
            // Fixation du capot : 5 perçages traversants Ø4.6    
            // Cover fastening: 5 through holes Ø4.6
            for (p = [[21.5, 27], [-82.5, 27], [-75.5, -27], [-44, -64.7], [21.5, -10.3]])
                translate([p[0], p[1], -e])
                    cylinder(h = 35, d = 4.6);
           
            // Vis Kodak (1/4") / Kodak screw (1/4")
            translate([-40, 32.2, 9]) rotate([90, 0, 0])
                cylinder(h = 10.1, d = 8.3);

            // Trappe de mise au point / Focus hatch
            translate([-8.15, -48, 18.51]) rotate([0, 0, -140]) translate([0, -20, 0])
                cube([10, 20, 13]);
            translate([-7.5, -49.25, 12.51]) rotate([0, 0, -140]) translate([4.7, 6, 0])
                rotate([90, 0, 0]) cylinder(h = 20, d = 5.7);
        }

        // Bossage Ø15 derrière la vis Kodak / Ø15 boss behind the Kodak screw
        translate([-40, 22.1, 9]) rotate([90, 0, 0])
            cylinder(h = 7, d = 15);
    }
}


// =====================================================================
// CAPOT SUPÉRIEUR / TOP COVER
// Pièce / Part : 2-2-capot-superieur
// =====================================================================

module capot_superieur()
{
    // ----- Feuillure du bord de jonction / Joining edge rabbet -----
    largeur_feuillure    = 1.8;   // 1.5 + 0.3 de jeu / 1.5 + 0.3 clearance
    profondeur_feuillure = 1.5;
    e = 0.01;                   // petit débord pour des soustractions propres
                                // small overlap for clean subtractions
   
    union()
    {
        difference()
        {
            // ---------------------------------------------------------
            // Bloc de base recoupé par le contour arrondi (arêtes verticales R1)
            // Base block trimmed by the rounded outline (vertical edges R1)
            // ---------------------------------------------------------
            intersection()
            {
                translate([-88, -73, 0])
                    cube([115, 105, 30]);

                translate([0, 0, -e])
                    linear_extrude(height = 30 + 2 * e)
                        contour_exterieur_arrondi();
            }

            // ---------------------------------------------------------
            // Contour : pans coupés
            // Outline: cut faces
            // ---------------------------------------------------------
            rotate([0, 0, 40]) translate([-80.9, -86.9, -e])
                cube([120, 60, 30 + 2*e]);
            rotate([0, 0, 40]) translate([-120.89, -30, -e])
                cube([40, 80, 30 + 2*e]);

            // ---------------------------------------------------------
            // Feuillure le long du bord, de z = 0 à 1.5
            // Rabbet along the edge, from z = 0 to 1.5
            // ---------------------------------------------------------
            // Face y = 32
            translate([-88.5, 32 + e - largeur_feuillure, -e])
                cube([116, largeur_feuillure, profondeur_feuillure]);
            // Face x = 27
            translate([27 + e - largeur_feuillure, -12.96, -e])
                cube([largeur_feuillure, 45.46, profondeur_feuillure]);
            // Face x = -88
            translate([-88 - e, -20.983, -e])
                cube([largeur_feuillure, 53.9, profondeur_feuillure]);
            // Pan parallèle à l'axe objectif / Face parallel to objective axis
            rotate([0, 0, 40]) translate([-81.4, -26.91, -e])
                cube([94.57, largeur_feuillure, profondeur_feuillure]);
            // Pan perpendiculaire à l'axe objectif / Face perpendicular to objective axis
            rotate([0, 0, 130]) translate([-27.3, 79.11, -e])
                cube([68.891, largeur_feuillure, profondeur_feuillure]);

            // ---------------------------------------------------------
            // Cavités intérieures, de z = 0 à 21
            // Inner cavities, from z = 0 to 21
            // ---------------------------------------------------------
            rotate([0, 0, 40]) translate([-50, -16.9, -e])
                cube([58, 32.75, 21 + e]);
            translate([-48.5, -20, -e]) 
                cube([51, 42, 21 + e]);
            translate([0, -8, -e])
                cube([16.9, 30, 21 + e]);

            // ---------------------------------------------------------
            // Logement du tube collimateur
            // Collimator tube seat
            // ---------------------------------------------------------
            translate([-98.7, 0, 0]) rotate([0, 90, 0])
                cylinder(h = 40, d = 39.58);
            translate([-80, 0, 0]) rotate([0, 90, 0])
                cylinder(h = 45, d = 36);

            // ---------------------------------------------------------
            // Logement du coulant caméra 31.75
            // Camera 31.75 barrel seat
            // ---------------------------------------------------------
            rotate([0, 0, 40]) translate([-85.9, 0, 0]) rotate([0, 90, 0])
                cylinder(h = 40, d = 31.72);

            // ---------------------------------------------------------
            // Fixation du capot : 5 vis M4
            // Cover fastening: 5 M4 screws
            // ---------------------------------------------------------
            for (p = [[21.5, 27], [-82.5, 27], [-75.5, -27], [-44, -64.7], [21.5, -10.3]])
            {
                translate([p[0], p[1], 30 + e - 10.1])
                    cylinder(h = 10.1, d = 6.0);
                translate([p[0], p[1], -e])
                    cylinder(h = 30 + 2*e, d = 4.6);
            }

            // ---------------------------------------------------------
            // Vis Kodak (1/4")
            // Kodak screws (1/4")
            // ---------------------------------------------------------
            translate([-25.1, 20, 21])
                cylinder(h = 9 + e, d = 8.4);
            translate([-40, 32.2, 21]) rotate([90, 0, 0])
                cylinder(h = 10.1, d = 8.4);

            // ---------------------------------------------------------
            // Trappe de mise au point
            // Focus hatch
            // ---------------------------------------------------------
            translate([-8.15, -48, -1.51]) rotate([0, 0, -140]) translate([0, -20, 0])
                cube([10, 20, 13]);
            translate([-7.5, -49.25, 17.49]) rotate([0, 0, -140]) translate([4.7, 6, 0])
                rotate([90, 0, 0]) cylinder(h = 20, d = 5.7);
        }

        // -------------------------------------------------------------
        // Bossages Ø15 derrière les vis Kodak
        // Ø15 bosses behind the Kodak screws
        // -------------------------------------------------------------
        translate([-25.1, 20, 14 + e])
            cylinder(h = 7, d = 15);
        translate([-40, 22.1, 21]) rotate([90, 0, 0])
            cylinder(h = 7, d = 15);
    }
}


// =====================================================================
// TUBE COLLIMATEUR / COLLIMATOR TUBE
// Pièce / Part : 3-1-tube-collimateur
// =====================================================================

module tube_collimateur()
{
    // Hauteur totale du tube / Total tube height
    hauteur_tube = 54;

    // Profondeur du logement de la lentille, mesurée depuis le haut du
    // tube. COTE CRITIQUE : elle fixe la distance fente-lentille
    // (mise au point du collimateur)
    // Lens seat depth, measured from the top of the tube. CRITICAL
    // DIMENSION: it sets the slit-to-lens distance (collimator focus)
    profondeur_logement_lentille = 12.60;    

    // Épaisseur de la lentille prise pour le dessin
    // Lens thickness used for the design
    epaisseur_lentille = 7.9;

    // Diamètre du logement de la lentille = lentille Ø20 + 0.27 mm de jeu
    // Lens seat diameter = Ø20 lens + 0.27 mm clearance
    diametre_logement_lentille = 20.38;
    
    // Pas du filetage (mm) / Thread pitch (mm)
    pas_filetage = 1.0;

    // Diamètre ndu filetage de la bague (M22 x 1.0, filet extérieur).
    // Thread diameter of the ring (M22 x 1.0, external thread).
    diametre_filetage = 22.50;
      
    z_epaulement     = hauteur_tube - profondeur_logement_lentille; // appui lentille / lens shoulder
    z_haut_lentille  = z_epaulement + epaisseur_lentille;           // haut lentille / lens top
    z_debut_filetage = z_haut_lentille - 0.5;                       // début taraudage / thread start

    difference()
    {
        union()
        {
            // Corps du tube / Tube body
            cylinder(h = hauteur_tube - 2, d = 39.75);

            // Collerette, 2 mm de haut / Collar, 2 mm high
            translate([0, 0, hauteur_tube - 2 - epsilon])
                cylinder(h = 2 + epsilon, d = 27);
        }

        // Alésage traversant / Through bore
        translate([0, 0, -epsilon])
            cylinder(h = hauteur_tube + 2 * epsilon, d = 19.2);

        // Logement de la lentille / Lens seat
        translate([0, 0, z_epaulement])
            cylinder(h = z_debut_filetage - z_epaulement + 0.1,
                     d = diametre_logement_lentille);

        // Taraudage de la bague / Ring internal thread
        translate([0, 0, z_debut_filetage])
            filetage_iso(diametre = diametre_filetage,
                         pas      = pas_filetage,
                         longueur = hauteur_tube - z_debut_filetage + epsilon);

        // Chanfrein d'entrée du taraudage (0.6 mm à 45°)
        // Lead-in chamfer of the internal thread (0.6 mm at 45°)
        translate([0, 0, hauteur_tube - 0.6])
            cylinder(h = 0.6 + epsilon,
                     d1 = diametre_filetage - 0.9,
                     d2 = diametre_filetage + 0.3 + 2 * epsilon);

        // Trous pour inserts M2 / M2 insert holes
        for (angle = [0, 120, -120])
            rotate([0, 0, angle])
                translate([17, 0, -epsilon])
                    cylinder(h = 4.5 + epsilon, d = 3.3);

    }
}

// =====================================================================
// TUBE CAMERA / CAMERA TUBE
// Pièce / Part : 4-1-tube-camera
// =====================================================================

module tube_camera()
{
    // ----- Réglages d'impression / Printing adjustments -----
    correction_filetage = -0.16;    // sur le Ø du filet / on thread Ø
    correction_lentille = 0.30;     // sur le Ø du logement lentille / on lens seat Ø

    // ----- Diamètres / Diameters -----
    diametre_filetage = 28.48 + correction_filetage;   // Ø extérieur du filet (28.64)
                                                       // thread major Ø (28.64) 
    diametre_lisse    = 27.0;                          // Ø de la partie lisse
                                                       // smooth section Ø
    diametre_lentille = 20.0;                          // Ø de la lentille / lens Ø
    diametre_logement = diametre_lentille + correction_lentille;
                                                       // Ø du logement lentille (20.275)
                                                       // lens seat Ø (20.275)
    diametre_passage  = diametre_lentille - 0.8;       // Ø du passage de lumière (19.2),
                                                       // forme l'épaulement d'appui
                                                       // light path Ø (19.2),
                                                       // forms the seating shoulder

    // Taraudage de la bague, identique au tube collimateur
    // Ring internal thread, identical to the collimator tube
    pas_filetage_bague      = 1.0;     // pas / pitch
    diametre_filetage_bague = 22.50;

    // ----- Hauteurs depuis la base / Heights from the base -----
    hauteur_filetage   = 20.0;     // longueur filetée extérieure / external threaded length
    z_lentille         = 27.5;     // hauteur de l'épaulement d'appui (COTE CRITIQUE)
                                   // shoulder height (CRITICAL DIMENSION)
    hauteur_totale     = 39.7;     // hauteur totale de la pièce / overall height
    epaisseur_lentille = 7.9;      // épaisseur de dessin / design thickness

    z_haut_lentille    = z_lentille + epaisseur_lentille;  // 35.4
    z_debut_taraudage  = z_haut_lentille - 0.5;            // 34.9

    e = 0.01;                    // petit débord pour des soustractions propres
                                 // small overlap for clean subtractions
                                 
    difference()
    {
        union()
        {
            // Filetage ISO, pas 0.6 mm, chanfrein d'entrée 0.8 mm à 45°
            // ISO thread, 0.6 mm pitch, 0.8 mm 45° lead-in chamfer
            filetage_iso(
                diametre      = diametre_filetage,
                pas           = 0.6,
                longueur      = hauteur_filetage,
                chanfrein_bas = 0.8
            );

            // Partie lisse / Smooth section
            translate([0, 0, hauteur_filetage - 1])
                cylinder(h = hauteur_totale - hauteur_filetage + 1,
                         d = diametre_lisse, $fn = 140);
        }

        // Passage de lumière, traversant / Light path, through
        translate([0, 0, -e])
            cylinder(h = hauteur_totale + 2*e, d = diametre_passage, $fn = 120);

        // Logement de la lentille, de l'épaulement au début du taraudage
        // (+ 0.1 de recouvrement)
        // Lens seat, from the shoulder to the thread start (+ 0.1 overlap)
        translate([0, 0, z_lentille])
            cylinder(h = z_debut_taraudage - z_lentille + 0.1,
                     d = diametre_logement, $fn = 140);

        // Taraudage de la bague
        // Ring internal thread
        translate([0, 0, z_debut_taraudage])
            filetage_iso(diametre = diametre_filetage_bague,
                         pas      = pas_filetage_bague,
                         longueur = hauteur_totale - z_debut_taraudage + e);

        // Chanfrein d'entrée du taraudage (0.6 mm à 45°)
        // Lead-in chamfer of the internal thread (0.6 mm at 45°)
        translate([0, 0, hauteur_totale - 0.6])
            cylinder(h = 0.6 + e,
                     d1 = diametre_filetage_bague - 0.9,
                     d2 = diametre_filetage_bague + 0.3 + 2*e, $fn = 140);
    }
}


// =====================================================================
// BAGUE OBJECTIFS / LENS RETAINING RING
// Pièce / Part : 5-1-bague-objectifs
// =====================================================================

module bague_objectifs()
{
    
    // Pas du filetage (mm) / Thread pitch (mm)
    pas_filetage = 1.0;
    
    // Diamètre du filetage de la bague (M22 x 1.0, filet extérieur).
    // Thread diameter of the ring (M22 x 1.0, external thread).
    diametre_filetage_bague = 22.0;
     
    // Ouverture de la bague (passage de la lumière).
    // Ring aperture (light path).
    diametre_ouverture_bague = 18.65;

    // Hauteur bague / Ring height
    hauteur_bague = 6.5;

    difference()
    {
        // Corps fileté / Threaded body
        filetage_iso(diametre       = diametre_filetage_bague,
                     pas            = pas_filetage,
                     longueur       = hauteur_bague,
                     chanfrein_bas  = 0.4,
                     chanfrein_haut = 0.4);

        // Ouverture centrale / Central aperture
        translate([0, 0, -epsilon])
            cylinder(h = hauteur_bague + 2 * epsilon,
                     d = diametre_ouverture_bague);

        // Encoches de serrage / Tightening notches 
        translate([-15, -1.5/2, hauteur_bague - 1.5])
            cube([30, 1.5, 1.5 + epsilon]);
    }
}


// =====================================================================
// BAGUE DE RÉGLAGE DU FOCUS / FOCUS ADJUSTMENT RING
// Pièce / Part : 6-1-bague-focus
// =====================================================================

module bague_focus()
{
    hauteur = 7.5;  // Hauteur de la bague / Ring height
    diametre_alesage = 27.20;  // Alésage de la bague /  Ring bore

    difference()
    {
        // Anneau / Ring
        cylinder(h = hauteur, d = 40.4);

        // Alésage / Bore
        translate([0, 0, -epsilon])
            cylinder(h = hauteur + 2 * epsilon, d = diametre_alesage);

        // Trou radial pour insert M3 (côté +X, à mi-hauteur)
        // Radial hole for M3 insert (+X side, at mid-height)
        translate([0, 0, hauteur / 2])
            rotate([0, 90, 0])
                cylinder(h = 25, d = 4.3);

        // Méplat / Flat
        translate([20.0, -10, -epsilon])
            cube([5, 20, hauteur + 2 * epsilon]);

        // Trous de manoeuvre Ø2.4 / Turning holes Ø2.4
        for (angle = [0 : 20 : 340])
            rotate([0, 0, angle])
                translate([14.1, 0, hauteur / 2])
                    rotate([0, 90, 0])
                        cylinder(h = 10, d = 2.4);
    }
}


// =====================================================================
// PORTE-RÉSEAU 12.7 / GRATING HOLDER 12.7
// Taille / Size : 12.7 x 12.7 x 6 mm
// Pièce / Part : 7-1-porte-reseau-127
// =====================================================================

// Coupe d'un coin selon un triangle
// Corner cut along a triangle 
module coupe_coin2(points)
{
    translate([0, 0, -epsilon])
        linear_extrude(height = 10)
            polygon(points);
}

module porte_reseau_127()
{
    
    // Angle du bras (degrés) selon le réseau utilisé :
    // Arm angle (degrees) depending on the grating used:
    //
    //     150 traits/mm VIS  :  +3.0       1200 traits/mm Ha  : -18.8
    //     300 traits/mm VIS  :   0.0       1200 traits/mm UV  : -13.5
    //     300 traits/mm IR   :  -1.7       1800 traits/mm Ha  : -34.0
    //     600 traits/mm UV   :  -3.6       2400 traits/mm Ha  : -52.8
    //     600 traits/mm VIS  :  -7.0       2400 traits/mm UV  : -25.6
    //     600 traits/mm IR   : -10.7
    //   (traits/mm = lines/mm)
    angle_bras = 0;
    
    difference()
    {
        union()
        {
            // Tour / Tower
            difference()
            {
                translate([-14, -6, 0])
                    cube([20, 12, 27.25]);
                translate([-6, -7, 15.2])
                    cube([20, 14, 17]);
                translate([-6.3, -12.7/2, 14.7])
                    cube([6.3, 12.7, 12.7]);
                translate([-5, -8/2, 14.7])
                    cube([20, 8, 5]);
            }

            
            // Bras, tourné de angle_bras autour du pivot
            // Aarm, rotated by angle_bras around the pivot
            rotate([0, 0, angle_bras])
            difference()
            {
                union()
                {
                    translate([0, -8, 0])
                        cube([25 + epsilon, 16, 5.8]);
                    translate([25, -10.5, 0])
                        cube([10, 21, 5.8]);
                    translate([17, -8, 0])
                        cube([8, 16, 6.8]);
                }

                // Trou avant Ø5.8 / Front hole Ø5.8
                translate([29.5, 0, -epsilon])
                    cylinder(h = 6.8, d = 5.8);

                // Vis du bossage  / Boss screw
                translate([21, 0, -epsilon]) cylinder(h = 5, d = 4.3);
                translate([21, 0, -epsilon]) cylinder(h = 7, d = 3.5);

                // Chanfreins des coins avant // Front corner chamfers
                coupe_coin2([[31.5, 11.5], [36, 7], [36, 11.5]]);
                coupe_coin2([[31.216, -11.5], [36, -6.716], [36, -11.5]]);
            }

            // Ailette arrière / Rear fin
            translate([-11, -25.5/2, 0])
                cube([8, 25.5, 8]);
        }

        // Trou Ø4.3 dans le mur arrière / Ø4.3 hole in the rear wall
        translate([-10, 0, 20.3])
            cylinder(h = 10, d = 4.3);

        // Pivot : trou Ø5.8 / Pivot: Ø5.8 hole 
        translate([0, 0, -epsilon])
            cylinder(h = 12, d = 5.8);

        // Vis de l'ailette arrière / Rear fin screws
        for (y = [-8.9, 8.9])
        {
            translate([-7, y, -epsilon]) cylinder(h = 5, d = 4.3);
            translate([-7, y, -epsilon]) cylinder(h = 12, d = 3.5);
        }

        // Chanfreins des coins arrière / Rear corner chamfers
        coupe_coin2([[-7.25, 13.75], [-12, 9], [-12, 13.75]]);
        coupe_coin2([[-6.966, -13.75], [-12, -8.716], [-12, -13.75]]);
    }
}


// =====================================================================
// PORTE-RÉSEAU 25 / GRATING HOLDER 25
// Taille / Size : 25.0 x 25.0 x 6 mm
// Pièce / Part : 8-1-porte-reseau-250
// =====================================================================

module porte_reseau_250()
{

    // Angle du bras (degrés) selon le réseau utilisé :
    // Arm angle (degrees) depending on the grating used:
    //
    //     150 traits/mm VIS  :  +3.0       1200 traits/mm Ha  : -18.8
    //     300 traits/mm VIS  :   0.0       1200 traits/mm UV  : -13.5
    //     300 traits/mm IR   :  -1.7       1800 traits/mm Ha  : -34.0
    //     600 traits/mm UV   :  -3.6       2400 traits/mm Ha  : -52.8
    //     600 traits/mm VIS  :  -7.0       2400 traits/mm UV  : -25.6
    //     600 traits/mm IR   : -10.7
    //   (traits/mm = lines/mm)
    angle_bras = -52.8;

    difference()
    {
        union()
        {
            
            // Tour / Tower
            difference()
            {
                translate([-14, -6, 0])
                    cube([20, 12, 33.4]);
                translate([-6, -7, 9.05])
                    cube([20, 14, 25]);
                translate([-6.4, -24.9/2, 8.55])
                    cube([6.4, 24.9, 24.9 + epsilon]);
                translate([-5, -8/2, 8.55])
                    cube([20, 8, 5]);
            }

            // ---------------------------------------------------------
            // Bras, tourné de angle_bras autour du pivot
            // Arm, rotated by angle_bras around the pivot
            // ---------------------------------------------------------
            rotate([0, 0, angle_bras])
            difference()
            {
                union()
                {
                    translate([0, -8, 0])
                        cube([25 + epsilon, 16, 5.2]);
                    translate([25, -10.5, 0])
                        cube([10, 21, 5.2]);
                    translate([17, -8, 0])
                        cube([8, 16, 6.8]);
                }

                // Trou avant Ø5.8 / Front hole Ø5.8
                translate([29.5, 0, -epsilon])
                    cylinder(h = 5.2 + 2 * epsilon, d = 5.8);

                // Vis du bossage / Boss screw
                translate([21, 0, -epsilon]) cylinder(h = 5, d = 4.3);
                translate([21, 0, -epsilon]) cylinder(h = 7, d = 3.5);

                // Chanfreins des coins avant / Front corner chamfers
                coupe_coin2([[31.5, 11.5], [36, 7], [36, 11.5]]);
                coupe_coin2([[31.216, -11.5], [36, -6.716], [36, -11.5]]);
            }

            // Ailette arrière / Rear fin
            translate([-11, -25.5/2, 0])
                cube([8, 25.5, 8]);
        }

        // Trou Ø4.3 dans le mur arrière / Ø4.3 hole in the rear wall
        translate([-10, 0, 26.45])
            cylinder(h = 10, d = 4.3);

        // Pivot : trou Ø5.8 / Pivot: Ø5.8 hole
        translate([0, 0, -epsilon])
            cylinder(h = 12, d = 5.8);

        // Vis de l'ailette arrière / Rear fin screws
        for (y = [-8.9, 8.9])
        {
            translate([-7, y, -epsilon]) cylinder(h = 5, d = 4.3);
            translate([-7, y, -epsilon]) cylinder(h = 12, d = 3.5);
        }

        // Chanfrein du coin arrière côté +Y
        // Rear corner chamfer on the +Y side
        coupe_coin2([[-7.25, 13.75], [-12, 9], [-12, 13.75]]);

        // Dégagement 2400 traits/mm / 2400 lines/mm clearance:
        // 13.85 mm from the pivot, over the full height
        rotate([0, 0, -52.8])
            translate([-25.7, -13.85 - 20, -epsilon])
                cube([40, 20, 33.4 + 2 * epsilon]);
    }
}


// =====================================================================
// BRIDE DE RÉSEAU / GRATING CLAMP
// Pièce / Part : 9-1-bride-reseau
// =====================================================================

module bride_reseau()
{
    difference()
    {
        translate([-14, -6, 0])
            cube([16, 12, 3.3]);
        translate([-14 - epsilon, -6 - epsilon, 3.3 - 0.8])
            cube([14.5 + epsilon, 12 + 2 * epsilon, 0.8 + epsilon]);
        translate([0.5 - epsilon, -4, 3.3 - 0.5])
            cube([1.5 + 2 * epsilon, 8, 0.5 + epsilon]);
        translate([-10, 0, -epsilon])
            cylinder(h = 3.3 + 2 * epsilon, d = 3.3);
    }
}


// =====================================================================
// INTERFACE RÉSEAU / CAPOT - GRATING / COVER INTERFACE
// Pièce / Part : 10-1-interface-reseau
// =====================================================================

// Coupe d'un coin selon un triangle 
// Corner cut along a triangle
module coupe_coin(points, z0, hauteur)
{
    translate([0, 0, z0])
        linear_extrude(height = hauteur)
            polygon(points);
}

module interface_reseau()
{
    difference()
    {
        union()
        {
            linear_extrude(height = 10.2)
                polygon([[-26.3, -15.45], [46.1, -15.45], [46.1, 15.45],
                         [-19.387, 15.45], [-26.3, 0.625]]);
            translate([23.5,  15, 0]) cube([12, 3, 10.2]);
            translate([23.5, -18, 0]) cube([12, 3, 10.2]);
            
            // Deux coins coupés / Two corners cut
            translate([0, 0, 10.2 - epsilon])
                linear_extrude(height = 19.39 - 10.2 + epsilon)
                    polygon([[-9.351, -14], [37.84, -14], [37.84, 14],
                             [-10.987, 14], [-17.74, -0.482], [-17.74, -10.088]]);
        }

        // Coupes de coin de la collerette, Flange corner cuts, over its full height
        coupe_coin([[-9.479, -15.661], [-26.753, -7.607], [-27.3, -16.45]],
                   -epsilon, 10.2 + 2 * epsilon);
        coupe_coin([[-26.683, 2.152], [-10.452, 15.771], [-27.3, 16.45]],
                   -epsilon, 10.2 + 2 * epsilon);

        // Trous Ø3.4 traversants + lamages Ø5.9
        // Ø3.5 through holes + Ø6.0 counterbores
        for (p = [[-21.7, 0], [41.8, -11], [41.8, 11]])
        {
            translate([p[0], p[1], -epsilon]) cylinder(h = 20, d = 3.5);
            translate([p[0], p[1], -epsilon]) cylinder(h = 4.1 + epsilon, d = 6.0);
        }

        // Trou d'outillage M4 Ø5.85 / M4 tooling hole Ø5.85
        translate([29.5, 24.5, 5.4])
            rotate([90, 0, 0])
                cylinder(h = 46, d = 5.85);

        // Trou de pivot Ø4.4 du porte-réseau
        // Grating holder pivot hole Ø4.4
        translate([0, 0, -epsilon])
            cylinder(h = 20, d = 4.4);

        // Lumière du bras du porte-réseau : arc de cercle de 5.5 mm de
        // large, de rayon 29.5 centré sur le pivot, de -4.67° à +4.67°
        // Grating holder arm slot: 5.5 mm wide circular arc, radius
        // 29.5 centred on the pivot, from -4.67° to +4.67°
        angle = 5.0;
        translate([0, 0, -epsilon])
        {
            // Partie courbe / Curved part
            rotate([0, 0, -angle])
                rotate_extrude(angle = 2 * 4.67)
                    translate([29.5 - 5.5/2, 0])
                        square([5.5, 20]);

            // Extrémités arrondies / Rounded ends
            for (a = [-angle, angle])
                rotate([0, 0, a])
                    translate([29.5, 0, 0])
                        cylinder(h = 20, d = 5.5);
        }  
    }
}

// =====================================================================
// SUPPORT FENTE / SLIT SUPPORT
// Pièce / Part : 11-2-support-fente
// =====================================================================

module support_fente()
{
    // Petit débord pour des soustractions propres
    // Small overlap for clean subtractions
    epsilon = 0.01;

    // Diamètre de la rondelle, inférieur au diamètre du tube collimateur (40 mm)
    // Washer diameter smaller than the diameter of the collimator tube (40 mm)
    diametre_rondelle = 39.7;

    // Hauteur du plan de la fente au-dessus de la base (cote fondamentale)
    // Height of the slit plane above the base (fundamental dimension)
    hauteur_plan_fente = 8.98;

    // Inclinaison du plan de la fente autour de l'axe X (degrés)
    // Tilt of the slit plane about the X axis (degrees)
    inclinaison = -15;

    // Décalage en X de la glissière (et de ses épaulements) par rapport à
    // la position centrale (X = 0)
    // X shift of the slide (and of its shoulders) relative to the central position (X = 0)
    // Par exemple, pour mieux centrer la zone photométrique : decalage_x = 1.0;
    // For example, to better centre the photometric zone: decalage_x = 1.0;
    decalage_x = 0.0;

    // ----- Glissière de la plaque / Plate slide -----
    // Côté de la plaque (carrée) et jeu de guidage
    // Plate side (square) and guiding clearance
    cote_plaque = 16;
    jeu = 0.2;
    largeur_guidage = cote_plaque + jeu;        // entre épaulements / between shoulders

    // Épaulements : épaisseur et hauteur au-dessus du plan de fente
    // (la plaque, épaisse de 2 mm, dépasse de 0.4 mm pour être plaquée par la bride)
    // Shoulders: thickness and height above the slit plane
    // (the 2 mm thick plate protrudes 0.4 mm so the clamp presses on it)
    epaisseur_epaulement = 1.8;
    hauteur_epaulement = 1.6;

    // Position de la butée en Y (plan incliné) et longueur de la glissière
    // Stop position in Y (tilted plane) and slide length
    butee_y = -4;
    longueur_glissiere = 28;

    // Longueur des épaulements à partir de la butée : ils guident la plaque
    // sur cette longueur seulement, sans empiéter sur les trous d'inserts
    // (Y = 8, Ø4.2, donc pas au-delà de Y = 5.95)
    // Shoulder length from the stop: they guide the plate over this length
    // only, without encroaching on the insert holes
    // (Y = 8, Ø4.2, hence not beyond Y = 5.95)
    longueur_epaulements = 10;
    fin_epaulements_y = butee_y + longueur_epaulements;   // Y = 4

    // Demi-largeur extérieure, épaulements compris (9.9 mm)
    // Outer half-width, shoulders included (9.9 mm)
    demi_largeur_ext = largeur_guidage / 2 + epaisseur_epaulement;

    translate([0, 0, hauteur_plan_fente])
    difference()
    {
        translate([0, 0, -hauteur_plan_fente])
            cylinder(h = hauteur_plan_fente + 2.5, d = diametre_rondelle);

        // -------------------------------------------------------------
        // Glissière de la plaque, dans le repère du plan incliné
        // Plate slide, in the tilted plane frame
        // -------------------------------------------------------------
        rotate([inclinaison, 0, 0])
        {
            // Rainure de guidage 16.2 mm, de la butée vers l'arrière :
            // la plaque s'y glisse par le côté arrière (Y croissant)
            // 16.2 mm guiding channel, from the stop towards the rear:
            // the plate is slid in from the rear side (increasing Y)
            translate([-largeur_guidage / 2 + decalage_x, butee_y, 0])
                cube([largeur_guidage, longueur_glissiere, 8]);

            // Flanc droit : tout est dégagé au-dessus du plan, à droite de l'épaulement droit
            // Right flank: everything above the plane is cleared, right of the right shoulder
            translate([demi_largeur_ext + decalage_x, -30, 0])
                cube([30, 60, 40]);

            // Flanc gauche : idem, à gauche de l'épaulement gauche
            // Left flank: same, left of the left shoulder
            translate([-demi_largeur_ext + decalage_x - 30, -30, 0])
                cube([30, 60, 40]);

            // Dégagement arrière : plus d'épaulement au-delà de la fin des guides
            // Rear clearance: no shoulder beyond the end of the guides
            translate([-30, fin_epaulements_y, 0])
                cube([60, 60, 40]);
        }

        // Coupe supérieure : plan incliné 1.6 mm au-dessus du plan de fente
        // (arase les épaulements à leur hauteur)
        // Top cut: tilted plane 1.6 mm above the slit plane
        // (trims the shoulders to their height)
        translate([0, 0, hauteur_epaulement])
            rotate([inclinaison, 0, 0])
                translate([-30, -30, 0]) cube([60, 60, 40]);

        // Trous Ø4.2 pour inserts de fixation de la bride, à X = ±12
        // Ø4.2 holes for the clamp inserts, at X = ±12
        for (x = [-12, 12])
            rotate([inclinaison, 0, 0])
                translate([x, 8, -15]) cylinder(h = 36, d = 4.2);

        // Flancs latéraux plats / Flat side flanks
        translate([demi_largeur_ext + decalage_x, -30, -1.3]) cube([30, 60, 40]);
        translate([-demi_largeur_ext + decalage_x - 30, -30, -1.3]) cube([30, 60, 40]);

        // Plan avant de la fente (derrière la butée) / Front plane of the slit (behind the stop)
        translate([-30, -45.5, -1.3]) cube([60, 40, 5]);

        // Cassages de coin 6 x 4, à droite et à gauche : la plaque appuyée
        // sur la butée ne risque pas de bavure dans les coins à 90°
        // 6 x 4 corner reliefs, right and left: the plate resting on the
        // stop cannot catch a burr in the 90° corners
        translate([6.8 + decalage_x, -6, -1.3]) cube([6, 4, 10]);
        translate([-12.8 + decalage_x, -6, -1.3]) cube([6, 4, 10]);

        // Fenêtre de fente traversante 5.5 x 3.8 mm, centrée sur l'axe
        // Through slit window 5.5 x 3.8 mm, centred on the axis
        translate([-5.5/2, -3.8/2, -25]) cube([5.5, 3.8, 30]);

        // Cône d'ouverture à 15° sous la fenêtre
        // 15° opening cone below the window
        translate([0, 0, -2])
        difference()
        {
            translate([-9, -9, -15]) cube([18, 18, 15]);

            // Flancs avant et arrière / Front and rear walls (3.8 mm sides)
            rotate([15, 0, 0])
                translate([-10, 3.8/2, -30 + epsilon]) cube([20, 8, 30]);
            rotate([-15, 0, 0])
                translate([-10, -(8 + 3.8/2), -30 + epsilon]) cube([20, 8, 30]);

            // Flancs gauche et droit / Left and right walls (5.5 mm sides)
            rotate([0, -15, 0])
                translate([5.5/2, -10, -30 + epsilon]) cube([14, 20, 30]);
            rotate([0, 15, 0])
                translate([-(14 + 5.5/2), -10, -30 + epsilon]) cube([14, 20, 30]);
        }

        // -------------------------------------------------------------
        // Fixation de la rondelle : 3 trous Ø2.4 traversants sur un
        // cercle Ø34
        // Washer fixing: 3 through holes Ø2.4 on a Ø34 circle
        // -------------------------------------------------------------
        for (angle = [90, 210, -30])
            rotate([0, 0, angle])
                translate([17, 0, -15 - epsilon]) cylinder(h = 20, d = 2.4);

        // Lamages Ø5.2 pour les têtes de vis
        // Ø5.2 counterbores for the screw heads
        rotate([0, 0, 90])
            translate([17, 0, -5.3 - epsilon]) cylinder(h = 20, d = 5.2);
        for (angle = [210, -30])
            rotate([0, 0, angle])
                translate([17, 0, -3.8 - epsilon]) cylinder(h = 20, d = 5.2);
    }
}

// =====================================================================
// PLAQUE FENTE 4 POSITIONS / 4-POSITION SLIT PLATE
// Pièce / Part : 11-2-plaque-fente (Shelyak OP0196B)
// =====================================================================
// Lame de 16 x 16 mm, épaisseur 2 mm, dont une face est
// chromée. Quatre fentes (14, 20, 26 et 32 µm) sont ménagées dans le
// chrome, chacune repérée par son numéro dans un coin. On change de
// fente en tournant la lame de 90°.
//
// JGS1 glass plate 16 x 16 mm, 2 mm thick, with one chromium-coated
// face. Four slits (14, 20, 26 and 32 µm) are masked in the coating,
// each one tagged with its number in a corner. The slit is changed by
// rotating the plate by 90°.
//
// Dessin allégé : les largeurs de fente ne sont PAS à l'échelle (traits
// élargis pour être visibles) et le motif traverse la lame de part en part.
// Lightened drawing: slit widths are NOT to scale (lines widened to be
// visible) and the pattern goes right through the plate.
//
// Le chrome est posé contre le PETG, les chiffres se lisent à travers le
// verre depuis le dessus.
// The chromium face rests on the PETG, the digits read through the glass
// from above.
//
// Utilisation / Use :
//   déjà inclinée et positionnée sur le support
//   already tilted and positioned on the support
// =====================================================================

fente_en_service = 20;      // 14, 20, 26 ou / or 32 : fente placée sur la fenêtre / slit placed over the window

// Doivent correspondre à 11-1-support-fente.scad
// Must match 11-1-support-fente.scad
hauteur_plan_fente = 8.98;
inclinaison = -15;
butee_y = -4;
decalage_x = 0.0;

// Rouge soutenu de la plaque / Deep red of the plate
rouge_plaque = [0.85, 0, 0];

// ----- Réglages du motif / Pattern settings -----
largeur_fente = 0.08;       // largeur dessinée, identique pour les 4 fentes (20 µm x 4) / drawn width, same for the 4 slits (20 µm x 4)
longueur_repere = 0.5;      // longueur de l'élargissement en bout de fente / length of the widened end of the slit
facteur_repere = 10;        // élargissement du repère : 10 x la largeur de fente / tab widening: 10 x the slit width
diametre_trou = 0.1;        // trou central (réel : Ø0.025) / central hole (real: Ø0.025)
profondeur_motif = 2;       // motif traversant sur toute l'épaisseur de 2 mm / pattern cut through the full 2 mm thickness

e = 0.01;

// ---------------------------------------------------------------------
// Rectangle dans le repère du dessin (u, v), vu côté chrome
// Rectangle in the drawing frame (u, v), seen from the chromium side
// ---------------------------------------------------------------------
module rect(u0, u1, v0, v1)
{
    translate([u0, v0]) square([u1 - u0, v1 - v0]);
}

// Numéro de coin, en miroir comme sur le dessin (lisible à travers le verre),
// tourné de "angle" autour de son centre. L'angle est donné dans le repère du
// dessin (vu côté chrome) : vu du dessus à travers le verre, le sens est inversé.
// Corner number, mirrored as on the drawing (readable through the glass),
// rotated by "angle" about its centre. The angle is given in the drawing frame
// (seen from the chromium side): seen from above through the glass, the
// direction is reversed.
module numero(texte, u, v, angle = 0)
{
    translate([u, v])
        rotate(angle)
            mirror([1, 0])
                scale([0.7, 1])
                    text(texte, size = 1.05, font = "Liberation Sans:style=Bold",
                         halign = "center", valign = "center");
}

// Une fente : trait de 4 mm à 4 mm du centre (position haute), élargi à une
// extrémité sur 0.5 mm (repère de 10 x la largeur de fente)
// One slit: 4 mm line at 4 mm from the centre (top position), widened at one
// end over 0.5 mm (tab 10 x the slit width)
module fente_motif()
{
    w = largeur_fente;
    W = facteur_repere * largeur_fente;

    rect(-2.25 + longueur_repere, 2.25, 4 - w / 2, 4 + w / 2);   // trait / line
    rect(-2.25, -2.25 + longueur_repere, 4 - W / 2, 4 + W / 2);  // élargissement / widened end
}

// ---------------------------------------------------------------------
// Motif chromé dans le repère du dessin : 4 fentes, trou, numéros
// Chromium pattern in the drawing frame: 4 slits, hole, numbers
// ---------------------------------------------------------------------
module motif()
{
    // La même fente dupliquée 4 fois, tournée de 90° à chaque fois
    // The same slit duplicated 4 times, rotated by 90° each time
    for (i = [0 : 3])
        rotate(-90 * i)
            fente_motif();

    // Trou central Ø25 µm (élargi) / central hole Ø25 µm (widened)
    circle(d = diametre_trou, $fn = 24);

    // Numéros de coin, vus du dessus à travers le verre :
    // 14 tourné de 90° dans le sens horaire, 20 inchangé,
    // 26 tourné de 90° dans le sens antihoraire, 32 tourné de 180°
    // Corner numbers, seen from above through the glass:
    // 14 rotated 90° clockwise, 20 unchanged,
    // 26 rotated 90° counter-clockwise, 32 rotated 180°
    numero("14", -7.1,  7.1,  90);
    numero("20",  7.1,  7.1,   0);
    numero("32", -7.1, -7.1, 180);
    numero("26",  7.1, -7.1, -90);
}

// Rotation de la lame qui amène la fente voulue en bas (côté butée),
// là où elle se place sur la fenêtre du support
// Plate rotation that brings the wanted slit to the bottom (stop side),
// where it sits over the support window
function angle_fente(f) =
    f == 32 ? 0 :
    f == 20 ? 180 :
    f == 26 ? 90 : -90;

// ---------------------------------------------------------------------
// Lame à plat, centrée en X et Y, face chromée en Z = 0, face
// antireflet en Z = 2 (usage interne)
// Plate lying flat, centred in X and Y, chromium face at Z = 0,
// anti-reflective face at Z = 2 (internal use)
// ---------------------------------------------------------------------
module plaque_a_plat(fente = 32)
{
    rotate([0, 0, angle_fente(fente)])
    difference()
    {
        translate([-8, -8, 0]) cube([16, 16, 2]);

        mirror([1, 0, 0])
            translate([0, 0, -e])
                linear_extrude(height = profondeur_motif + 2 * e)
                    motif();
    }
}

// ---------------------------------------------------------------------
// PLAQUE FENTE : dessine uniquement la lame, en rouge soutenu, déjà
// inclinée de 15° et translatée pour reposer dans le support de fente :
// face chromée contre le PETG (plan incliné), poussée contre la butée en Y,
// entre les deux épaulements. À appeler après (ou avant) support_fente().
//
// SLIT PLATE: draws only the plate, in deep red, already tilted by 15° and
// translated to sit in the slit support: chromium face against the PETG
// (tilted plane), pushed against the stop in Y, between the two shoulders.
// Call it after (or before) support_fente().
// ---------------------------------------------------------------------
module plaque_fente(fente = fente_en_service)
{
    translate([0, 0, hauteur_plan_fente])
        rotate([inclinaison, 0, 0])
            translate([decalage_x, butee_y + 8, 0])
                color(rouge_plaque)
                    plaque_a_plat(fente);
}


// =====================================================================
// BRIDE DE FENTE / SLIT CLAMP
// Pièce / Part : 12-1-bride-fente
// =====================================================================

module bride_fente()
{
    difference()
    {
        linear_extrude(height = 2)
            polygon([[2, -14.75], [6.45, -14.75], [10, -11.20],
                     [10, 11.20], [6.45, 14.75], [2, 14.75]]);

        // Trous Ø3.4 pour vis M3
        // Ø3.4 holes for M3 screws
        for (y = [-12, 12])
            translate([5, y, -epsilon])
                cylinder(h = 2 + 2 * epsilon, d = 3.4);
    }
}

// =====================================================================
// TRAPPE FOCUS / FOCUS COVER
// Pièce / Part : 13-1-trappe-focus
// =====================================================================

module trappe_focus()
{
    difference()
    {
        union()
        {
            translate([-16/2, -46/2, 0])
                cube([16, 46, 3]);
            translate([-9.4/2, -22.4/2, 3 - epsilon])
                cube([9.4, 22.4, 3 + epsilon]);
        }

        // Trous de fixation Ø4.6
        // Fixing holes Ø4.6
        for (y = [-17.18, 17.18])
            translate([0, y, -epsilon])
                cylinder(h = 6 + 2 * epsilon, d = 4.6);
    }
}

// =====================================================================
// AFFICHAGE / DISPLAY
// =====================================================================
// capot_inferieur();
// capot_superieur();
// tube_collimateur();
// tube_camera();
// bague_objectifs();
// bague_focus();
// porte_reseau_127();
// porte_reseau_250();
// bride_reseau();
// interface_reseau();
// support_fente();
// plaque_fente();
// bride_fente();
// trappe_focus();










