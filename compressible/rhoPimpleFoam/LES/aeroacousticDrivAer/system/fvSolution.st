/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\    /   O peration     | Version:  v2306                                 |
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
solvers
{
    "(p|Phi)"
    {
        solver          PCG;
        preconditioner  DIC;
        tolerance       1e-20;
        relTol          0.05;
    }
    
    "(U|nuTilda|k|epsilon|omega|e|h|v2|f)"
    {
        solver          smoothSolver;
        smoother        symGaussSeidel;
        tolerance       1e-20;
        relTol          0.1;
    }

    cellDisplacement
    {
        solver          PCG;
        preconditioner  DIC;
        tolerance       1e-08;
        relTol          0;
    }
}

SIMPLE
{
    nNonOrthogonalCorrectors 1;
    pMinFactor      0.5;
    pMaxFactor      1.3;
    transonic       no;
    consistant      no;
}

potentialFlow
{
    nNonOrthogonalCorrectors 10;
}

relaxationFactors
{
    fields
    {
        p               0.3;
       rho              0.1;
    }
    equations
    {
        U               0.7;
        nuTilda         0.7;
        k               0.7;
        epsilon         0.7;
        omega           0.7;
        h               0.95;
    }
}

cache
{
    grad(U)         ;
}
