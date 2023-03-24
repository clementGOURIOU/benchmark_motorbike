// Parametrized m4 script for the blockMeshDict generation for the ERCOFTAC 
// diffuser.
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
m4_dnl>
m4_dnl> ------------------------------------------------------------------------
m4_dnl> *** MATHEMATICAL CONSTANTS ***
m4_dnl>
m4_define(pi, 3.1415926536) m4_dnl>
m4_dnl>
m4_dnl>
m4_dnl> ------------------------------------------------------------------------
m4_dnl> *** CELL SIZING ***
m4_dnl>
m4_define(lWall, 5e-5) m4_dnl>  Radial length of the 1st cell at the wall
m4_define(lCore, 3.15e-3) m4_dnl>  Cell size of in the core region
m4_define(dzOutlet, 2e-1) m4_dnl>  Axial length of the cells at the outlet
m4_dnl>
m4_dnl>
m4_dnl> ------------------------------------------------------------------------
m4_dnl> *** GEOMETRY ***
m4_dnl>
m4_define(openingAngle, 10.0) m4_dnl>  Half of the divergence angle
m4_define(diffuserLength, 0.51) m4_dnl>
m4_define(rIn, 0.13) m4_dnl>
m4_define(rOut, calc(rIn+diffuserLength*tan(openingAngle*pi/180.0)))m4_dnl>
m4_define(dumpLength, calc(10*rOut)) m4_dnl>
m4_dnl>
m4_dnl> * Plane A *
m4_define(zA, -0.50) m4_dnl>
m4_define(rA, rIn) m4_dnl>
m4_dnl> * Radial coord. of the H-grid corner relative to the outer radius *
m4_define(rRelA, 0.5) m4_dnl>
m4_dnl> * Radial coordinate of the H-grid arc middle point relative to the
m4_dnl>   H-grid corner *
m4_define(rRelAc, 0.8) m4_dnl>
m4_dnl> * Inner radius of the outer O-grid rel. to the pipe radius *
m4_define(rRelAo, 0.7) m4_dnl>
m4_define(drAo1, calc(rA*(rRelAo - rRelA))) m4_dnl>
m4_define(rArcA, calc(rRelAc*rRelA*rA)) m4_dnl>
m4_define(rAo, calc(rRelAo*rA)) m4_dnl>
m4_define(rAh, calc(rRelA*rA)) m4_dnl>
m4_dnl>
m4_dnl> * Plane B *
m4_define(zB, -0.10) m4_dnl>
m4_define(rB, rIn) m4_dnl>
m4_define(rRelB, 0.5) m4_dnl>
m4_define(rRelBc, 0.8) m4_dnl>
m4_define(rRelBo, 0.7) m4_dnl>
m4_dnl>
m4_dnl> * Plane C *
m4_define(zC, -0.025) m4_dnl>
m4_define(rC, rIn) m4_dnl>
m4_define(rRelC, 0.5) m4_dnl>
m4_define(rRelCc, 0.8) m4_dnl>
m4_define(rRelCo, 0.7) m4_dnl>
m4_dnl>
m4_dnl> * Plane D *
m4_define(zD, 0) m4_dnl>
m4_define(rD, rIn) m4_dnl>
m4_define(rRelD, 0.5) m4_dnl>
m4_define(rRelDc, 0.8) m4_dnl>
m4_define(rRelDo, 0.7) m4_dnl>
m4_dnl>
m4_dnl> * Plane E *
m4_define(zE, diffuserLength) m4_dnl>
m4_define(rE, rOut) m4_dnl>
m4_define(rRelE, 0.5) m4_dnl>
m4_define(rRelEc, 0.8) m4_dnl>
m4_define(rRelEo, 0.7) m4_dnl>
m4_dnl>
m4_dnl> * Plane F *
m4_define(zF, calc(diffuserLength+dumpLength)) m4_dnl>
m4_define(rF, rOut) m4_dnl>
m4_define(rRelF, 0.5) m4_dnl>
m4_define(rRelFc, 0.8) m4_dnl>
m4_define(rRelFo, 0.7) m4_dnl>
m4_dnl>
m4_dnl>
m4_dnl> ------------------------------------------------------------------------
m4_dnl> *** MESH TOPOLOGY ***
m4_dnl>
m4_define(rGrading1, 1) m4_dnl>
m4_define(rGrading2, calc(lCore/lWall)) m4_dnl>
m4_define(zGradingCD, 0.6) m4_dnl>
m4_define(zGradingDE, 2) m4_dnl>
m4_dnl>
m4_dnl> * Length of the first elements in ax. direction of the corresp. blocks *
m4_define(l1DE, calc(zGradingCD*lCore)) m4_dnl>
m4_define(l1EF, calc(zGradingDE*l1DE)) m4_dnl>
m4_dnl>
m4_dnl> * Simple grading of the block at the outlet *
m4_define(zGradingEF, calc(dzOutlet/l1EF)) m4_dnl>
m4_dnl>
m4_dnl> * Axial number of cells *
m4_define(zABnumberOfCells, calcCellsNumber(lCore,zA,zB,1)) m4_dnl>
m4_define(zBCnumberOfCells, calcCellsNumber(lCore,zB,zC,1)) m4_dnl>
m4_define(zCDnumberOfCells, calcCellsNumber(lCore,zC,zD,zGradingCD)) m4_dnl>
m4_define(zDEnumberOfCells, calcCellsNumber(l1DE,zD,zE,zGradingDE)) m4_dnl>
m4_define(zEFnumberOfCells, calcCellsNumber(l1EF,zE,zF,zGradingEF)) m4_dnl>
m4_dnl>
m4_dnl> * Radial number of cells in the first, second O-grid and H-grid *
m4_define(rNumberOfCells1st, calcCellsNumberInnerOGrid(lCore,rAh,rArcA,drAo1)) m4_dnl>
m4_define(rNumberOfCells2nd, calcCellsNumber(lWall,rA,rAo,rGrading2)) m4_dnl>
m4_define(hNumberOfCells, calcCellsNumberHGrid(lCore,rAh,rArcA)) m4_dnl>
m4_dnl>
m4_dnl> ------------------------------------------------------------------------

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

scale 1;

vertices
(
//Plane A:
(calc(rRelA*rA*cos(pi/4)) -calc(rRelA*rA*sin(pi/4)) zA) vlabel(A0)
(calc(rRelA*rA*cos(pi/4)) calc(rRelA*rA*sin(pi/4)) zA) vlabel(A1)
(calc(-rRelA*rA*cos(pi/4)) calc(rRelA*rA*sin(pi/4)) zA) vlabel(A2)
(calc(-rRelA*rA*cos(pi/4)) -calc(rRelA*rA*sin(pi/4)) zA) vlabel(A3)
(calc(rRelAo*rA*cos(pi/4)) -calc(rRelAo*rA*sin(pi/4)) zA) vlabel(A4)
(calc(rRelAo*rA*cos(pi/4)) calc(rRelAo*rA*sin(pi/4)) zA) vlabel(A5)
(calc(-rRelAo*rA*cos(pi/4)) calc(rRelAo*rA*sin(pi/4)) zA) vlabel(A6)
(calc(-rRelAo*rA*cos(pi/4)) -calc(rRelAo*rA*sin(pi/4)) zA) vlabel(A7)
(calc(rA*cos(pi/4)) -calc(rA*sin(pi/4)) zA) vlabel(A8)
(calc(rA*cos(pi/4)) calc(rA*sin(pi/4)) zA) vlabel(A9)
(calc(-rA*cos(pi/4)) calc(rA*sin(pi/4)) zA) vlabel(A10)
(calc(-rA*cos(pi/4)) -calc(rA*sin(pi/4)) zA) vlabel(A11)

//Plane B:
(calc(rRelB*rB*cos(pi/4)) -calc(rRelB*rB*sin(pi/4)) zB) vlabel(B0)
(calc(rRelB*rB*cos(pi/4)) calc(rRelB*rB*sin(pi/4)) zB) vlabel(B1)
(calc(-rRelB*rB*cos(pi/4)) calc(rRelB*rB*sin(pi/4)) zB) vlabel(B2)
(calc(-rRelB*rB*cos(pi/4)) -calc(rRelB*rB*sin(pi/4)) zB) vlabel(B3)
(calc(rRelBo*rB*cos(pi/4)) -calc(rRelBo*rB*sin(pi/4)) zB) vlabel(B4)
(calc(rRelBo*rB*cos(pi/4)) calc(rRelBo*rB*sin(pi/4)) zB) vlabel(B5)
(calc(-rRelBo*rB*cos(pi/4)) calc(rRelBo*rB*sin(pi/4)) zB) vlabel(B6)
(calc(-rRelBo*rB*cos(pi/4)) -calc(rRelBo*rB*sin(pi/4)) zB) vlabel(B7)
(calc(rB*cos(pi/4)) -calc(rB*sin(pi/4)) zB) vlabel(B8)
(calc(rB*cos(pi/4)) calc(rB*sin(pi/4)) zB) vlabel(B9)
(calc(-rB*cos(pi/4)) calc(rB*sin(pi/4)) zB) vlabel(B10)
(calc(-rB*cos(pi/4)) -calc(rB*sin(pi/4)) zB) vlabel(B11)

//Plane C:
(calc(rRelC*rC*cos(pi/4)) -calc(rRelC*rC*sin(pi/4)) zC) vlabel(C0)
(calc(rRelC*rC*cos(pi/4)) calc(rRelC*rC*sin(pi/4)) zC) vlabel(C1)
(calc(-rRelC*rC*cos(pi/4)) calc(rRelC*rC*sin(pi/4)) zC) vlabel(C2)
(calc(-rRelC*rC*cos(pi/4)) -calc(rRelC*rC*sin(pi/4)) zC) vlabel(C3)
(calc(rRelCo*rC*cos(pi/4)) -calc(rRelCo*rC*sin(pi/4)) zC) vlabel(C4)
(calc(rRelCo*rC*cos(pi/4)) calc(rRelCo*rC*sin(pi/4)) zC) vlabel(C5)
(calc(-rRelCo*rC*cos(pi/4)) calc(rRelCo*rC*sin(pi/4)) zC) vlabel(C6)
(calc(-rRelCo*rC*cos(pi/4)) -calc(rRelCo*rC*sin(pi/4)) zC) vlabel(C7)
(calc(rC*cos(pi/4)) -calc(rC*sin(pi/4)) zC) vlabel(C8)
(calc(rC*cos(pi/4)) calc(rC*sin(pi/4)) zC) vlabel(C9)
(calc(-rC*cos(pi/4)) calc(rC*sin(pi/4)) zC) vlabel(C10)
(calc(-rC*cos(pi/4)) -calc(rC*sin(pi/4)) zC) vlabel(C11)

//Plane D:
(calc(rRelD*rD*cos(pi/4)) -calc(rRelD*rD*sin(pi/4)) zD) vlabel(D0)
(calc(rRelD*rD*cos(pi/4)) calc(rRelD*rD*sin(pi/4)) zD) vlabel(D1)
(calc(-rRelD*rD*cos(pi/4)) calc(rRelD*rD*sin(pi/4)) zD) vlabel(D2)
(calc(-rRelD*rD*cos(pi/4)) -calc(rRelD*rD*sin(pi/4)) zD) vlabel(D3)
(calc(rRelDo*rD*cos(pi/4)) -calc(rRelDo*rD*sin(pi/4)) zD) vlabel(D4)
(calc(rRelDo*rD*cos(pi/4)) calc(rRelDo*rD*sin(pi/4)) zD) vlabel(D5)
(calc(-rRelDo*rD*cos(pi/4)) calc(rRelDo*rD*sin(pi/4)) zD) vlabel(D6)
(calc(-rRelDo*rD*cos(pi/4)) -calc(rRelDo*rD*sin(pi/4)) zD) vlabel(D7)
(calc(rD*cos(pi/4)) -calc(rD*sin(pi/4)) zD) vlabel(D8)
(calc(rD*cos(pi/4)) calc(rD*sin(pi/4)) zD) vlabel(D9)
(calc(-rD*cos(pi/4)) calc(rD*sin(pi/4)) zD) vlabel(D10)
(calc(-rD*cos(pi/4)) -calc(rD*sin(pi/4)) zD) vlabel(D11)

//Plane E:
(calc(rRelE*rE*cos(pi/4)) -calc(rRelE*rE*sin(pi/4)) zE) vlabel(E0)
(calc(rRelE*rE*cos(pi/4)) calc(rRelE*rE*sin(pi/4)) zE) vlabel(E1)
(calc(-rRelE*rE*cos(pi/4)) calc(rRelE*rE*sin(pi/4)) zE) vlabel(E2)
(calc(-rRelE*rE*cos(pi/4)) -calc(rRelE*rE*sin(pi/4)) zE) vlabel(E3)
(calc(rRelEo*rE*cos(pi/4)) -calc(rRelEo*rE*sin(pi/4)) zE) vlabel(E4)
(calc(rRelEo*rE*cos(pi/4)) calc(rRelEo*rE*sin(pi/4)) zE) vlabel(E5)
(calc(-rRelEo*rE*cos(pi/4)) calc(rRelEo*rE*sin(pi/4)) zE) vlabel(E6)
(calc(-rRelEo*rE*cos(pi/4)) -calc(rRelEo*rE*sin(pi/4)) zE) vlabel(E7)
(calc(rE*cos(pi/4)) -calc(rE*sin(pi/4)) zE) vlabel(E8)
(calc(rE*cos(pi/4)) calc(rE*sin(pi/4)) zE) vlabel(E9)
(calc(-rE*cos(pi/4)) calc(rE*sin(pi/4)) zE) vlabel(E10)
(calc(-rE*cos(pi/4)) -calc(rE*sin(pi/4)) zE) vlabel(E11)

//Plane F:
(calc(rRelF*rF*cos(pi/4)) -calc(rRelF*rF*sin(pi/4)) zF) vlabel(F0)
(calc(rRelF*rF*cos(pi/4)) calc(rRelF*rF*sin(pi/4)) zF) vlabel(F1)
(calc(-rRelF*rF*cos(pi/4)) calc(rRelF*rF*sin(pi/4)) zF) vlabel(F2)
(calc(-rRelF*rF*cos(pi/4)) -calc(rRelF*rF*sin(pi/4)) zF) vlabel(F3)
(calc(rRelFo*rF*cos(pi/4)) -calc(rRelFo*rF*sin(pi/4)) zF) vlabel(F4)
(calc(rRelFo*rF*cos(pi/4)) calc(rRelFo*rF*sin(pi/4)) zF) vlabel(F5)
(calc(-rRelFo*rF*cos(pi/4)) calc(rRelFo*rF*sin(pi/4)) zF) vlabel(F6)
(calc(-rRelFo*rF*cos(pi/4)) -calc(rRelFo*rF*sin(pi/4)) zF) vlabel(F7)
(calc(rF*cos(pi/4)) -calc(rF*sin(pi/4)) zF) vlabel(F8)
(calc(rF*cos(pi/4)) calc(rF*sin(pi/4)) zF) vlabel(F9)
(calc(-rF*cos(pi/4)) calc(rF*sin(pi/4)) zF) vlabel(F10)
(calc(-rF*cos(pi/4)) -calc(rF*sin(pi/4)) zF) vlabel(F11)
);

// Defining blocks:
blocks
(
    //Blocks between plane A and plane B:
    // block0 - positive x O-grid block
    hex (A5 A1 A0 A4 B5 B1 B0 B4 ) AB
    (rNumberOfCells1st hNumberOfCells zABnumberOfCells)
    simpleGrading (rGrading1 1 1)
    // block1 - positive y O-grid block
    hex (A6 A2 A1 A5 B6 B2 B1 B5 ) AB
    (rNumberOfCells1st hNumberOfCells zABnumberOfCells)
    simpleGrading (rGrading1 1 1)
    // block2 - negative x O-grid block
    hex (A7 A3 A2 A6 B7 B3 B2 B6 ) AB
    (rNumberOfCells1st hNumberOfCells zABnumberOfCells)
    simpleGrading (rGrading1 1 1)
    // block3 - negative y O-grid block
    hex (A4 A0 A3 A7 B4 B0 B3 B7 ) AB
    (rNumberOfCells1st hNumberOfCells zABnumberOfCells)
    simpleGrading (rGrading1 1 1)
    // block4 - central O-grid block
    hex (A0 A1 A2 A3 B0 B1 B2 B3 ) AB
    (hNumberOfCells hNumberOfCells zABnumberOfCells)
    simpleGrading (1 1 1)
    // block5 - positive x O-grid block 2nd belt 
    hex (A9 A5 A4 A8 B9 B5 B4 B8 ) AB
    (rNumberOfCells2nd hNumberOfCells zABnumberOfCells)
    simpleGrading (rGrading2 1 1)
    // block6 - positive y O-grid block 2nd belt
    hex (A10 A6 A5 A9 B10 B6 B5 B9 ) AB
    (rNumberOfCells2nd hNumberOfCells zABnumberOfCells)
    simpleGrading (rGrading2 1 1)
    // block7 - negative x O-grid block 2nd belt
    hex (A11 A7 A6 A10 B11 B7 B6 B10 ) AB
    (rNumberOfCells2nd hNumberOfCells zABnumberOfCells)
    simpleGrading (rGrading2 1 1)
    // block8 - negative y O-grid block 2nd belt
    hex (A8 A4 A7 A11 B8 B4 B7 B11 ) AB
    (rNumberOfCells2nd hNumberOfCells zABnumberOfCells)
    simpleGrading (rGrading2 1 1)

    //Blocks between plane B and plane C:
    // block0 - positive x O-grid block
    hex (B5 B1 B0 B4 C5 C1 C0 C4 ) BC
    (rNumberOfCells1st hNumberOfCells zBCnumberOfCells)
    simpleGrading (rGrading1 1 1)
    // block1 - positive y O-grid block
    hex (B6 B2 B1 B5 C6 C2 C1 C5 ) BC
    (rNumberOfCells1st hNumberOfCells zBCnumberOfCells)
    simpleGrading (rGrading1 1 1)
    // block2 - negative x O-grid block
    hex (B7 B3 B2 B6 C7 C3 C2 C6 ) BC
    (rNumberOfCells1st hNumberOfCells zBCnumberOfCells)
    simpleGrading (rGrading1 1 1)
    // block3 - negative y O-grid block
    hex (B4 B0 B3 B7 C4 C0 C3 C7 ) BC
    (rNumberOfCells1st hNumberOfCells zBCnumberOfCells)
    simpleGrading (rGrading1 1 1)
    // block4 - central O-grid block
    hex (B0 B1 B2 B3 C0 C1 C2 C3 ) BC
    (hNumberOfCells hNumberOfCells zBCnumberOfCells)
    simpleGrading (1 1 1)
    // block5 - positive x O-grid block 2nd belt 
    hex (B9 B5 B4 B8 C9 C5 C4 C8 ) BC
    (rNumberOfCells2nd hNumberOfCells zBCnumberOfCells)
    simpleGrading (rGrading2 1 1)
    // block6 - positive y O-grid block 2nd belt
    hex (B10 B6 B5 B9 C10 C6 C5 C9 ) BC
    (rNumberOfCells2nd hNumberOfCells zBCnumberOfCells)
    simpleGrading (rGrading2 1 1)
    // block7 - negative x O-grid block 2nd belt
    hex (B11 B7 B6 B10 C11 C7 C6 C10 ) BC
    (rNumberOfCells2nd hNumberOfCells zBCnumberOfCells)
    simpleGrading (rGrading2 1 1)
    // block8 - negative y O-grid block 2nd belt
    hex (B8 B4 B7 B11 C8 C4 C7 C11 ) BC
    (rNumberOfCells2nd hNumberOfCells zBCnumberOfCells)
    simpleGrading (rGrading2 1 1)

    //Blocks between plane C and plane D:
    // block0 - positive x O-grid block
    hex (C5 C1 C0 C4 D5 D1 D0 D4 ) CD
    (rNumberOfCells1st hNumberOfCells zCDnumberOfCells)
    simpleGrading (rGrading1 1 zGradingCD)
    // block1 - positive y O-grid block
    hex (C6 C2 C1 C5 D6 D2 D1 D5 ) CD
    (rNumberOfCells1st hNumberOfCells zCDnumberOfCells)
    simpleGrading (rGrading1 1 zGradingCD)
    // block2 - negative x O-grid block
    hex (C7 C3 C2 C6 D7 D3 D2 D6 ) CD
    (rNumberOfCells1st hNumberOfCells zCDnumberOfCells)
    simpleGrading (rGrading1 1 zGradingCD)
    // block3 - negative y O-grid block
    hex (C4 C0 C3 C7 D4 D0 D3 D7 ) CD
    (rNumberOfCells1st hNumberOfCells zCDnumberOfCells)
    simpleGrading (rGrading1 1 zGradingCD)
    // block4 - central O-grid block
    hex (C0 C1 C2 C3 D0 D1 D2 D3 ) CD
    (hNumberOfCells hNumberOfCells zCDnumberOfCells)
    simpleGrading (1 1 zGradingCD)
    // block5 - positive x O-grid block 2nd belt 
    hex (C9 C5 C4 C8 D9 D5 D4 D8 ) CD
    (rNumberOfCells2nd hNumberOfCells zCDnumberOfCells)
    simpleGrading (rGrading2 1 zGradingCD)
    // block6 - positive y O-grid block 2nd belt
    hex (C10 C6 C5 C9 D10 D6 D5 D9 ) CD
    (rNumberOfCells2nd hNumberOfCells zCDnumberOfCells)
    simpleGrading (rGrading2 1 zGradingCD)
    // block7 - negative x O-grid block 2nd belt
    hex (C11 C7 C6 C10 D11 D7 D6 D10 ) CD
    (rNumberOfCells2nd hNumberOfCells zCDnumberOfCells)
    simpleGrading (rGrading2 1 zGradingCD)
    // block8 - negative y O-grid block 2nd belt
    hex (C8 C4 C7 C11 D8 D4 D7 D11 ) CD
    (rNumberOfCells2nd hNumberOfCells zCDnumberOfCells)
    simpleGrading (rGrading2 1 zGradingCD)

    //Blocks between plane D and plane E:
    // block0 - positive x O-grid block
    hex (D5 D1 D0 D4 E5 E1 E0 E4 ) DE
    (rNumberOfCells1st hNumberOfCells zDEnumberOfCells)
    simpleGrading (rGrading1 1 zGradingDE)
    // block1 - positive y O-grid block
    hex (D6 D2 D1 D5 E6 E2 E1 E5 ) DE
    (rNumberOfCells1st hNumberOfCells zDEnumberOfCells)
    simpleGrading (rGrading1 1 zGradingDE)
    // block2 - negative x O-grid block
    hex (D7 D3 D2 D6 E7 E3 E2 E6 ) DE
    (rNumberOfCells1st hNumberOfCells zDEnumberOfCells)
    simpleGrading (rGrading1 1 zGradingDE)
    // block3 - negative y O-grid block
    hex (D4 D0 D3 D7 E4 E0 E3 E7 ) DE
    (rNumberOfCells1st hNumberOfCells zDEnumberOfCells)
    simpleGrading (rGrading1 1 zGradingDE)
    // block4 - central O-grid block
    hex (D0 D1 D2 D3 E0 E1 E2 E3 ) DE
    (hNumberOfCells hNumberOfCells zDEnumberOfCells)
    simpleGrading (1 1 zGradingDE)
    // block5 - positive x O-grid block 2nd belt 
    hex (D9 D5 D4 D8 E9 E5 E4 E8 ) DE
    (rNumberOfCells2nd hNumberOfCells zDEnumberOfCells)
    simpleGrading (rGrading2 1 zGradingDE)
    // block6 - positive y O-grid block 2nd belt
    hex (D10 D6 D5 D9 E10 E6 E5 E9 ) DE
    (rNumberOfCells2nd hNumberOfCells zDEnumberOfCells)
    simpleGrading (rGrading2 1 zGradingDE)
    // block7 - negative x O-grid block 2nd belt
    hex (D11 D7 D6 D10 E11 E7 E6 E10 ) DE
    (rNumberOfCells2nd hNumberOfCells zDEnumberOfCells)
    simpleGrading (rGrading2 1 zGradingDE)
    // block8 - negative y O-grid block 2nd belt
    hex (D8 D4 D7 D11 E8 E4 E7 E11 ) DE
    (rNumberOfCells2nd hNumberOfCells zDEnumberOfCells)
    simpleGrading (rGrading2 1 zGradingDE)

    //Blocks between plane E and plane F:
    // block0 - positive x O-grid block 1st belt
    hex (E5 E1 E0 E4 F5 F1 F0 F4 ) EF
    (rNumberOfCells1st hNumberOfCells zEFnumberOfCells)
    simpleGrading (rGrading1 1 zGradingEF)
    // block1 - positive y O-grid block 1st belt
    hex (E6 E2 E1 E5 F6 F2 F1 F5 ) EF
    (rNumberOfCells1st hNumberOfCells zEFnumberOfCells)
    simpleGrading (rGrading1 1 zGradingEF)
    // block2 - negative x O-grid block 1st belt
    hex (E7 E3 E2 E6 F7 F3 F2 F6 ) EF
    (rNumberOfCells1st hNumberOfCells zEFnumberOfCells)
    simpleGrading (rGrading1 1 zGradingEF)
    // block3 - negative y O-grid block 1st belt
    hex (E4 E0 E3 E7 F4 F0 F3 F7 ) EF
    (rNumberOfCells1st hNumberOfCells zEFnumberOfCells)
    simpleGrading (rGrading1 1 zGradingEF)
    // block4 - central O-grid block 
    hex (E0 E1 E2 E3 F0 F1 F2 F3 ) EF
    (hNumberOfCells hNumberOfCells zEFnumberOfCells)
    simpleGrading (1 1 zGradingEF)
    // block5 - positive x O-grid block 2nd belt 
    hex (E9 E5 E4 E8 F9 F5 F4 F8 ) EF
    (rNumberOfCells2nd hNumberOfCells zEFnumberOfCells)
    simpleGrading (rGrading2 1 zGradingEF)
    // block6 - positive y O-grid block 2nd belt
    hex (E10 E6 E5 E9 F10 F6 F5 F9 ) EF
    (rNumberOfCells2nd hNumberOfCells zEFnumberOfCells)
    simpleGrading (rGrading2 1 zGradingEF)
    // block7 - negative x O-grid block 2nd belt
    hex (E11 E7 E6 E10 F11 F7 F6 F10 ) EF
    (rNumberOfCells2nd hNumberOfCells zEFnumberOfCells)
    simpleGrading (rGrading2 1 zGradingEF)
    // block8 - negative y O-grid block 2nd belt
    hex (E8 E4 E7 E11 F8 F4 F7 F11 ) EF
    (rNumberOfCells2nd hNumberOfCells zEFnumberOfCells)
    simpleGrading (rGrading2 1 zGradingEF)
);

edges
(
    //Plane A
    arc A0 A1 (calc(rRelAc*rRelA*rA) 0 zA)
    arc A1 A2 (0 calc(rRelAc*rRelA*rA) zA)
    arc A2 A3 (-calc(rRelAc*rRelA*rA) 0 zA)
    arc A3 A0 (0 -calc(rRelAc*rRelA*rA) zA)
    arc A4 A5 (calc(rRelAo*rA) 0 zA)
    arc A5 A6 (0 calc(rRelAo*rA) zA)
    arc A6 A7 (-calc(rRelAo*rA) 0 zA)
    arc A7 A4 (0 -calc(rRelAo*rA) zA)
    arc A8  A9  (rA 0 zA) 
    arc A9  A10 (0 rA zA) 
    arc A10 A11 (-rA 0 zA)
    arc A11 A8  (0 -rA zA)

    //Plane B
    arc B0 B1 (calc(rRelBc*rRelB*rB) 0 zB)
    arc B1 B2 (0 calc(rRelBc*rRelB*rB) zB)
    arc B2 B3 (-calc(rRelBc*rRelB*rB) 0 zB)
    arc B3 B0 (0 -calc(rRelBc*rRelB*rB) zB)
    arc B4 B5 (calc(rRelBo*rB) 0 zB)
    arc B5 B6 (0 calc(rRelBo*rB) zB)
    arc B6 B7 (-calc(rRelBo*rB) 0 zB)
    arc B7 B4 (0 -calc(rRelBo*rB) zB)
    arc B8 B9 (rB 0 zB)
    arc B9 B10 (0 rB zB)
    arc B10 B11 (-rB 0 zB)
    arc B11 B8 (0 -rB zB)

    //Plane C
    arc C0 C1 (calc(rRelCc*rRelC*rC) 0 zC)
    arc C1 C2 (0 calc(rRelCc*rRelC*rC) zC)
    arc C2 C3 (-calc(rRelCc*rRelC*rC) 0 zC)
    arc C3 C0 (0 -calc(rRelCc*rRelC*rC) zC)
    arc C4 C5 (calc(rRelCo*rC) 0 zC)
    arc C5 C6 (0 calc(rRelCo*rC) zC)
    arc C6 C7 (-calc(rRelCo*rC) 0 zC)
    arc C7 C4 (0 -calc(rRelCo*rC) zC)
    arc C8 C9 (rC 0 zC)
    arc C9 C10 (0 rC zC)
    arc C10 C11 (-rC 0 zC)
    arc C11 C8 (0 -rC zC)

    //Plane D
    arc D0 D1 (calc(rRelDc*rRelD*rD) 0 zD)
    arc D1 D2 (0 calc(rRelDc*rRelD*rD) zD)
    arc D2 D3 (-calc(rRelDc*rRelD*rD) 0 zD)
    arc D3 D0 (0 -calc(rRelDc*rRelD*rD) zD)
    arc D4 D5 (calc(rRelDo*rD) 0 zD)
    arc D5 D6 (0 calc(rRelDo*rD) zD)
    arc D6 D7 (-calc(rRelDo*rD) 0 zD)
    arc D7 D4 (0 -calc(rRelDo*rD) zD)
    arc D8 D9 (rD 0 zD)
    arc D9 D10 (0 rD zD)
    arc D10 D11 (-rD 0 zD)
    arc D11 D8 (0 -rD zD)

    //Plane E
    arc E0 E1 (calc(rRelEc*rRelE*rE) 0 zE)
    arc E1 E2 (0 calc(rRelEc*rRelE*rE) zE)
    arc E2 E3 (-calc(rRelEc*rRelE*rE) 0 zE)
    arc E3 E0 (0 -calc(rRelEc*rRelE*rE) zE)
    arc E4 E5 (calc(rRelEo*rE) 0 zE)
    arc E5 E6 (0 calc(rRelEo*rE) zE)
    arc E6 E7 (-calc(rRelEo*rE) 0 zE)
    arc E7 E4 (0 -calc(rRelEo*rE) zE)
    arc E8 E9 (rE 0 zE)
    arc E9 E10 (0 rE zE)
    arc E10 E11 (-rE 0 zE)
    arc E11 E8 (0 -rE zE)

    //Plane F
    arc F0 F1 (calc(rRelFc*rRelF*rF) 0 zF)
    arc F1 F2 (0 calc(rRelFc*rRelF*rF) zF)
    arc F2 F3 (-calc(rRelFc*rRelF*rF) 0 zF)
    arc F3 F0 (0 -calc(rRelFc*rRelF*rF) zF)
    arc F4 F5 (calc(rRelFo*rF) 0 zF)
    arc F5 F6 (0 calc(rRelFo*rF) zF)
    arc F6 F7 (-calc(rRelFo*rF) 0 zF)
    arc F7 F4 (0 -calc(rRelFo*rF) zF)
    arc F8 F9 (rF 0 zF)
    arc F9 F10 (0 rF zF)
    arc F10 F11 (-rF 0 zF)
    arc F11 F8 (0 -rF zF)
);

// Defining patches:
patches
(
    patch inlet
    (
        (A1 A5 A4 A0)
        (A2 A6 A5 A1)
        (A3 A7 A6 A2)
        (A0 A4 A7 A3)
        (A3 A2 A1 A0)
        (A5 A9 A8 A4)
        (A6 A10 A9 A5)
        (A7 A11 A10 A6)
        (A4 A8 A11 A7)
    )
    wall rotSwirlWall
    (
        (A8 A9 B9 B8)
        (A9 A10 B10 B9)
        (A10 A11 B11 B10)
        (A11 A8 B8 B11)
    )
    wall statSwirlWall
    (
        (B8 B9 C9 C8)
        (B9 B10 C10 C9)
        (B10 B11 C11 C10)
        (B11 B8 C8 C11)
        (C8 C9 D9 D8)
        (C9 C10 D10 D9)
        (C10 C11 D11 D10)
        (C11 C8 D8 D11)
    )
    wall wallDiffuser
    (
        (D8 D9 E9 E8)
        (D9 D10 E10 E9)
        (D10 D11 E11 E10)
        (D11 D8 E8 E11)
    )
    wall wallOutletPipe
    (
        (E8 E9 F9 F8)
        (E9 E10 F10 F9)
        (E10 E11 F11 F10)
        (E11 E8 F8 F11)
    )
    patch outlet
    (
        (F0 F4 F5 F1)
        (F1 F5 F6 F2)
        (F2 F6 F7 F3)
        (F3 F7 F4 F0)
        (F0 F1 F2 F3)
        (F4 F8 F9 F5)
        (F5 F9 F10 F6)
        (F6 F10 F11 F7)
        (F7 F11 F8 F4)
    )
);

mergePatchPairs
(
);

// ************************************************************************* //
