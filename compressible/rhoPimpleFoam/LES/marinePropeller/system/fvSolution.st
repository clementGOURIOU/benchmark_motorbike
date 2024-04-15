/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\    /   O peration     | Version:  v2206                                 |
|   \\  /    A nd           | Website:  www.openfoam.com                      |
|    \\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
    version     2.0;
    format      ascii;
    class       dictionary;
    object      fvSolution;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

solvers
{

    "(rho|rhoFinal)"
    {
        solver          diagonal;
    }

    "(p|Phi)"
    {
        solver          GAMG;
        tolerance       1e-20;
        relTol          0.01;
        smoother        symGaussSeidel;
        cacheAgglomeration true;
        nCellsInCoarsestLevel 200;
        agglomerator    faceAreaPair;
        nPreSweeps      0;
        nPostSweeps     2;
        mergeLevels     1;
    }

    a
    {
        solver          PCG;
        preconditioner  FDIC;
        tolerance       1e-20;
        relTol          0.01;
        maxIter         600;
    }

    "(U|k|omega|nuTilda)"
    {
//        solver          smoothSolver;
//        smoother        symGaussSeidel;
        solver          PBiCGStab;
        preconditioner  DILU;
        tolerance       1e-20;
        relTol          0.1;
    }

    "(h|e)"
    {
        $U;
        tolerance       1.0e-020;
        relTol          0.1;
    }
}

potentialFlow
{
    nNonOrthogonalCorrectors 10;
}

SIMPLE
{
    nNonOrthogonalCorrectors 1;
//consistent yes;
//    pMax 		1.0e+09;
//    pMin 		-1.0e+09;
pMinFactor  0.5;
pMaxFactor  1.3;
}

PIMPLE
{
    momentumPredictor   yes;
    transonic           no;
    nOuterCorrectors    1;
    nCorrectors         4;
    nNonOrthogonalCorrectors 0;
    correctPhi          yes;
}

relaxationFactors
{
 fields
    {
        p               0.3;
//        rho 0.1;
    }

    equations
    {
        U               0.7;
        k               0.5;
        omega           0.5;
        h		0.95;
        e 		0.95;
        
    }
}

// ************************************************************************* //