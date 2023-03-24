// Parametrized m4 script for the blockMeshDict generation of the Pitz&Daily
// combustion chamber.
//
// The development was originaly done by:
//   Hakan Nilsson, Chalmers University of Technology, Sweden
//   Maryse Page, IREQ, Hydro Quebec, Canada
//   Martin Beaudoin, IREQ, Hydro Quebec, Canada
//   Omar Bounous, Chalmers University of Technology, Sweden
//
// The m4 script was modified to simplify the refinement procedure. The main
// inputs are cell sizes at the wall lWall and in the core region lCore. For
// mesh refinement, change the two parameters lWall and lCore as desired. The
// number of cells for the corresponding blocks will be calculated by an
// iterative procedure. The modification was introduced by
//   Sergey Lesnik, Wikki GmbH, Germany
//   Henrik Rusche, Wikki GmbH, Germany
//
// Run using
// m4 -P blockMeshDict.m4 > blockMeshDict
//
m4_dnl> ------------------------------------------------------------------------
m4_dnl> *** CELL SIZING ***
m4_dnl> 100K: 7e-1; 2e-0
m4_dnl> 3M: 1e-1; 74e-2
m4_dnl> 62M: 2e-2; 3e-1
m4_define(lWall, 2e-2) m4_dnl>  Radial length of the 1st cell at the wall
m4_define(lCore, 3e-1) m4_dnl>  Cell size in the core region
m4_dnl>
m4_dnl>
m4_dnl> ------------------------------------------------------------------------
m4_dnl> *** m4 DEFINITIONS ***
m4_dnl>
m4_changecom(//)m4_changequote([,]) m4_dnl>
m4_define(calc, [m4_esyscmd(perl -e 'use Math::Trig; printf ($1)')]) m4_dnl>
m4_define(VCOUNT, 0) m4_dnl>
m4_define(
    vlabel,
    [ m4_dnl>
        [// ]Vertex $1 = VCOUNT m4_define($1, VCOUNT) m4_define([VCOUNT],
        m4_incr(VCOUNT)) m4_dnl>
    ] m4_dnl>
) m4_dnl>
m4_dnl>
m4_dnl>
m4_dnl> ------------------------------------------------------------------------
m4_dnl> *** AUXILLARY PERL SCRIPTS ***
m4_dnl>
m4_define(calcCellsNumber, [m4_esyscmd(perl -e '
    # Compute number of cells iteratively.
    # Arguments:
    #   1 - length of the first cell
    #   2 - Start coordinate of the block of the considered axis
    #   3 - End coordinate of the block of the considered axis
    #   4 - simpleGrading coefficient
    # a - cell-to-cell expansion ratio; n - number of cells along the axis.
    $n = 10;  # Start value
    $l1 = $1;
    $L = abs($3 - $2);  # Length of the block
    $g = $4;
    # Check whether the simpleGrading equals 1
    if (abs($g - 1.0) < 1e-6)
    {
        $n = $L/$l1;
    }
    else
    {
        do
        {
            $n_prev = $n;
            $a = $g**(1/($n - 1));
            $n = log(abs(1 + ($a - 1)*$L/$l1))/log($a);
            $err = abs($n - $n_prev);
        }
        while($err > 1e-2);
    }
    print(int($n + 0.5));
')]) m4_dnl>
m4_dnl>
m4_define(calcCellsNumberInnerOGrid, [m4_esyscmd(perl -e '
    # Calculate number of cells in the radial direction of an O-block which
    # has an rectangular block with arcs on the inner side.
    # Arguments:
    #   1 - length of the last cell of the outer O-grid
    #   2 - radial inner corner coordinate
    #   3 - radial arc center coordinate
    #   4 - radial outer corner coordinate
    # n - number of cells along the considered axis;
    $lLastOuterO = $1;
    $drArc = $2 - $3;  # Radial delta between the inner corner and arc center
    $L = $4; # - $2;  # Radial length of the block
    $n = ($L + $drArc/2)/$lLastOuterO;
    print(int($n + 0.5));
')]) m4_dnl>
m4_dnl>
m4_define(calcCellsNumberHGrid, [m4_esyscmd(perl -e '
    # Calculate number of cells in the radial direction of the H-block whose
    # edges are arcs neighboring to an outer O-grid.
    # Arguments:
    #   1 - length of the last cell of the outer O-grid
    #   2 - radial inner corner coordinate
    #   3 - radial arc center coordinate
    # a - cell-to-cell expansion ratio; n - number of cells along the axis.
    $lLastOuterO = $1;
    $drArc = $2 - $3;  # Radial delta between the inner corner and arc center
    $L = 2*$3; # - $2;  # Radial length of the block
    $n = ($L - $drArc)/$lLastOuterO;
    print(int($n + 0.5));
')]) m4_dnl>
m4_dnl>
m4_dnl> * Not used here. Kept as a backup. *
m4_define(calcCellsNumberBisect, [m4_esyscmd(perl -e '
    $b = 0; $l = 0; $h = 1; $err = 1;
    do
    {
        $m = ($l + $h)/2;
        $a = 1/$m;
        $n = log(1 + ($a - 1)*$2/$1)/log($a);
        $L
        $b = 1/($3**(1/($n - 1)));
        if ($b > $m)
        {
            $l = $m;
        }
        else
        {
            $h = $m;
        }
        $err = abs($b - $m);
    }
    while($err > 1e-6);
    print(int($n + 0.5))
')]) m4_dnl>
m4_dnl>
m4_define(calcCellsNumberY, [m4_esyscmd(perl -e '
    # Compute number of cells iteratively.
    # Arguments:
    #   1 - length of the first cell
    #   2 - Start coordinate of the block of the considered axis
    #   3 - End coordinate of the block of the considered axis
    #   4 - simpleGrading coefficient
    # a - cell-to-cell expansion ratio; n - number of cells along the axis.
    # 0; 25; 60 - % dir; 2 - simpleGrading; 0.1 - lCore; 1e-3 - l1;
    $yStart = $1;
    $yEnd = $2;
    $LFracCore = $3;
    $g = $4;
    $dyCore = $5;
    $l1 = $6;
    $nCoreOnly = $7;

    # Core
    $L = abs($yEnd - $yStart);
    $LCore = $LFracCore*$L;
    $nCore = $LCore/$dyCore;

    # Edges
    $LEdge = ($L - $LCore)/2;
    $LFracEdge = $LEdge/($yEnd - $yStart);
    $n = 10;  # Start value
    do
    {
        $n_prev = $n;
        $a = $g**(1/($n - 1));
        $n = log(abs(1 + ($a - 1)*$LEdge/$l1))/log($a);
        $err = abs($n - $n_prev);
    }
    while($err > 1e-2);
    $nTotal = int($nCore + 2*$n + 0.5);
    $nCoreFrac = $nCore/$nTotal;
    $nEdgeFrac = $n/$nTotal;

    if ($nCoreOnly)
    {
        print($nTotal);
    }
    else
    {
        print("\n\x5B\x28\x5D\n");
        print("    \x5B\x28\x5D", $LFracEdge, " ", $n, " ", $g, "\x5B\x29\x5D\n");
        print("    \x5B\x28\x5D", $LFracCore, " ", $nCore, " ", 1,
            "\x5B\x29\x5D\n");
        print("    \x5B\x28\x5D", $LFracEdge, " ", $n, " ", 1/$g,
            "\x5B\x29\x5D\n");
        print("\x5B\x29\x5D\n");
    }
')]) m4_dnl>

m4_dnl>
m4_dnl> ------------------------------------------------------------------------
m4_dnl> *** MATHEMATICAL CONSTANTS ***
m4_dnl>
m4_define(pi, 3.1415926536) m4_dnl>
m4_dnl>
m4_dnl>
m4_dnl> ------------------------------------------------------------------------
m4_dnl> *** GEOMETRY ***
m4_dnl>
m4_define(width, 38.1) m4_dnl>  Chamber width
m4_define(zBack, calc(-width/2)) m4_dnl>
m4_define(zFront, calc(width/2)) m4_dnl>
m4_define(stepHeight, 25.4) m4_dnl>
m4_define(chamberHeight, 50.8) m4_dnl>
m4_define(mid, 0) m4_dnl>
m4_define(bot, calc(mid-stepHeight)) m4_dnl>
m4_define(top, calc(bot+chamberHeight)) m4_dnl>u
m4_dnl> * Height of the outlet taken from the original OpenFOAM case *
m4_define(outletHeight, 33.2) m4_dnl>
m4_dnl>
m4_dnl> * Plane A *
m4_define(xA, -140) m4_dnl>
m4_define(yABot, bot) m4_dnl>
m4_define(yATop, top) m4_dnl>
m4_dnl>
m4_dnl> * Plane B *
m4_define(xB, 0) m4_dnl>
m4_define(yBBot, bot) m4_dnl>
m4_define(yBMid, mid) m4_dnl>
m4_define(yBTop, top) m4_dnl>
m4_dnl>
m4_dnl> * Plane C *
m4_define(xC, 206) m4_dnl>
m4_define(yCBot, bot) m4_dnl>
m4_define(yCMid, mid) m4_dnl>
m4_define(yCTop, top) m4_dnl>
m4_dnl>
m4_dnl> * Plane D *
m4_define(xD, 290) m4_dnl>
m4_define(yDBot, calc(mid-outletHeight/2)) m4_dnl>
m4_define(yDMid, mid) m4_dnl>
m4_define(yDTop, calc(mid+outletHeight/2)) m4_dnl>
m4_dnl>
m4_dnl>
m4_dnl> ------------------------------------------------------------------------
m4_dnl> *** MESH TOPOLOGY ***
m4_dnl>
m4_dnl> * Number of cells in y direction *
m4_define(grading, calc(lCore/lWall)) m4_dnl>
m4_define(yTopNCells,
    calcCellsNumberY(yBMid, yBTop, 0.25, grading, lCore, lWall, 1)) m4_dnl>
m4_define(yBotNCells,
    calcCellsNumberY(yBBot, yBMid, 0.25, grading, lCore, lWall, 1)) m4_dnl>
m4_dnl>
m4_dnl> * Grading coefficents *
m4_define(multiGradingPosY,
    calcCellsNumberY(yBMid, yBTop, 0.25, grading, lCore, lWall, 0)) m4_dnl>
m4_define(multiGradingNegY,
    calcCellsNumberY(yBBot, yBMid, 0.25, grading, lCore, lWall, 0)) m4_dnl>
m4_define(xGradingOutlet, 1) m4_dnl>
m4_dnl>
m4_dnl> * Number of cells in x direction *
m4_define(lXCore, calc(lCore)) m4_dnl>
m4_define(xABNCells, calcCellsNumber(lXCore, xA, xB, 1)) m4_dnl>
m4_define(xBCNCells, calcCellsNumber(lXCore, xB, xC, 1)) m4_dnl>
m4_define(xCDNCells, calcCellsNumber(lXCore, xC, xD, xGradingOutlet)) m4_dnl>
m4_dnl>
m4_dnl> * Number of cells in z direction *
m4_define(zNCells, calcCellsNumber(lCore, zBack, zFront, 1)) m4_dnl>
m4_dnl>
m4_dnl>
/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\    /   O peration     | Version:  v2106                                 |
|   \\  /    A nd           | Website:  www.openfoam.com                      |
|    \\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
    version     2.0;
    format      ascii;
    class       dictionary;
    object      blockMeshDict;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

scale 0.001;

vertices
(
// Back
    (xA yABot zBack) vlabel(A0)
    (xA yATop zBack) vlabel(A1)

    (xB yBBot zBack) vlabel(B0)
    (xB yBMid zBack) vlabel(B1)
    (xB yBTop zBack) vlabel(B2)

    (xC yCBot zBack) vlabel(C0)
    (xC yCMid zBack) vlabel(C1)
    (xC yCTop zBack) vlabel(C2)

    (xD yDBot zBack) vlabel(D0)
    (xD yDMid zBack) vlabel(D1)
    (xD yDTop zBack) vlabel(D2)

// Front
    (xA yABot zFront) vlabel(A2)
    (xA yATop zFront) vlabel(A3)

    (xB yBBot zFront) vlabel(B3)
    (xB yBMid zFront) vlabel(B4)
    (xB yBTop zFront) vlabel(B5)

    (xC yBBot zFront) vlabel(C3)
    (xC yCMid zFront) vlabel(C4)
    (xC yCTop zFront) vlabel(C5)

    (xD yDBot zFront) vlabel(D3)
    (xD yDMid zFront) vlabel(D4)
    (xD yDTop zFront) vlabel(D5)
);

posY
(
    (20 25 2)
    (60 50 1)
    (20 25 0.5)
);

blocks
(
    // Blocks between plane A and plane B:
    hex (A0 B1 B2 A1 A2 B4 B5 A3) AB
    (xABNCells yTopNCells zNCells)
    simpleGrading (1 multiGradingPosY 1)

    // Blocks between plane B and plane C:
    // Bottom
    hex (B0 C0 C1 B1 B3 C3 C4 B4) BC
    (xBCNCells yBotNCells zNCells)
    simpleGrading (1 multiGradingNegY 1)
    // Top
    hex (B1 C1 C2 B2 B4 C4 C5 B5) BC
    (xBCNCells yTopNCells zNCells)
    simpleGrading (1 multiGradingPosY 1)

    // Blocks between plane C and plane D:
    // Bottom
    hex (C0 D0 D1 C1 C3 D3 D4 C4) CD
    (xCDNCells yBotNCells zNCells)
    simpleGrading (xGradingOutlet multiGradingNegY 1)
    // Top
    hex (C1 D1 D2 C2 C4 D4 D5 C5) CD
    (xCDNCells yTopNCells zNCells)
    simpleGrading (xGradingOutlet multiGradingPosY 1)
);

edges
(
    // Definition according to Libby&Reiss 1951 (see attached python script)
    spline A0 B1
    (
        ( -140.00   -25.40   zBack )
        ( -136.09   -25.25   zBack )
        ( -132.30   -25.08   zBack )
        ( -128.50   -24.89   zBack )
        ( -124.71   -24.68   zBack )
        ( -120.92   -24.45   zBack )
        ( -117.13   -24.18   zBack )
        ( -113.35   -23.89   zBack )
        ( -109.57   -23.56   zBack )
        ( -105.80   -23.20   zBack )
        ( -102.04   -22.79   zBack )
        (  -98.29   -22.34   zBack )
        (  -94.55   -21.83   zBack )
        (  -90.83   -21.28   zBack )
        (  -87.13   -20.67   zBack )
        (  -83.46   -20.01   zBack )
        (  -79.82   -19.29   zBack )
        (  -76.21   -18.50   zBack )
        (  -72.66   -17.67   zBack )
        (  -69.16   -16.78   zBack )
        (  -65.72   -15.84   zBack )
        (  -62.36   -14.87   zBack )
        (  -59.08   -13.88   zBack )
        (  -55.90   -12.87   zBack )
        (  -52.82   -11.86   zBack )
        (  -49.85   -10.86   zBack )
        (  -47.00    -9.89   zBack )
        (  -44.26    -8.96   zBack )
        (  -41.64    -8.07   zBack )
        (  -39.13    -7.23   zBack )
        (  -36.72    -6.45   zBack )
        (  -34.41    -5.73   zBack )
        (  -32.19    -5.07   zBack )
        (  -30.04    -4.46   zBack )
        (  -27.95    -3.91   zBack )
        (  -25.92    -3.41   zBack )
        (  -23.94    -2.96   zBack )
        (  -21.99    -2.55   zBack )
        (  -20.08    -2.19   zBack )
        (  -18.19    -1.86   zBack )
        (  -16.32    -1.57   zBack )
        (  -14.47    -1.31   zBack )
        (  -12.64    -1.07   zBack )
        (  -10.81    -0.86   zBack )
        (   -9.00    -0.67   zBack )
        (   -7.19    -0.51   zBack )
        (   -5.39    -0.36   zBack )
        (   -3.59    -0.23   zBack )
        (   -1.79    -0.11   zBack )
        (    0.00     0.00   zBack )
    )
    spline A2 B4
    (
        ( -140.00   -25.40   zFront )
        ( -136.09   -25.25   zFront )
        ( -132.30   -25.08   zFront )
        ( -128.50   -24.89   zFront )
        ( -124.71   -24.68   zFront )
        ( -120.92   -24.45   zFront )
        ( -117.13   -24.18   zFront )
        ( -113.35   -23.89   zFront )
        ( -109.57   -23.56   zFront )
        ( -105.80   -23.20   zFront )
        ( -102.04   -22.79   zFront )
        (  -98.29   -22.34   zFront )
        (  -94.55   -21.83   zFront )
        (  -90.83   -21.28   zFront )
        (  -87.13   -20.67   zFront )
        (  -83.46   -20.01   zFront )
        (  -79.82   -19.29   zFront )
        (  -76.21   -18.50   zFront )
        (  -72.66   -17.67   zFront )
        (  -69.16   -16.78   zFront )
        (  -65.72   -15.84   zFront )
        (  -62.36   -14.87   zFront )
        (  -59.08   -13.88   zFront )
        (  -55.90   -12.87   zFront )
        (  -52.82   -11.86   zFront )
        (  -49.85   -10.86   zFront )
        (  -47.00    -9.89   zFront )
        (  -44.26    -8.96   zFront )
        (  -41.64    -8.07   zFront )
        (  -39.13    -7.23   zFront )
        (  -36.72    -6.45   zFront )
        (  -34.41    -5.73   zFront )
        (  -32.19    -5.07   zFront )
        (  -30.04    -4.46   zFront )
        (  -27.95    -3.91   zFront )
        (  -25.92    -3.41   zFront )
        (  -23.94    -2.96   zFront )
        (  -21.99    -2.55   zFront )
        (  -20.08    -2.19   zFront )
        (  -18.19    -1.86   zFront )
        (  -16.32    -1.57   zFront )
        (  -14.47    -1.31   zFront )
        (  -12.64    -1.07   zFront )
        (  -10.81    -0.86   zFront )
        (   -9.00    -0.67   zFront )
        (   -7.19    -0.51   zFront )
        (   -5.39    -0.36   zFront )
        (   -3.59    -0.23   zFront )
        (   -1.79    -0.11   zFront )
        (    0.00     0.00   zFront )
    )
);

boundary
(
    inlet
    {
        type patch;
        faces
        (
            (0 1 12 11)
        );
    }
    outlet
    {
        type patch;
        faces
        (
            (8 9 20 19)
            (9 10 21 20)
        );
    }
    upperWall
    {
        type wall;
        faces
        (
            (1 4 15 12)
            (4 7 18 15)
            (7 10 21 18)
        );
    }
    lowerWall
    {
        type wall;
        faces
        (
            (0 3 14 11)
            (3 2 13 14)
            (2 5 16 13)
            (5 8 19 16)
        );
    }
    back
    {
        type cyclic;
        neighbourPatch front;
        faces
        (
            (0 3 4 1)
            (2 5 6 3)
            (3 6 7 4)
            (5 8 9 6)
            (6 9 10 7)
        );
    }
    front
    {
        type cyclic;
        neighbourPatch back;
        faces
        (
            (11 14 15 12)
            (13 16 17 14)
            (14 17 18 15)
            (16 19 20 17)
            (17 20 21 18)
        );
    }
);
