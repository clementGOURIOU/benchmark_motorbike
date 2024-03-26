/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\    /   O peration     | Version:  v2212                                 |
|   \\  /    A nd           | Website:  www.openfoam.com                      |
|    \\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
    version     2.0;
    format      ascii;
    class       dictionary;
    object      fvSchemes;
}
ddtSchemes
{
    default         steadyState;
}

divSchemes
{
    default          none;
    div(phi,U)       bounded Gauss linearUpwindV unlimitedGrad(U);
    div(phi,k)       bounded Gauss limitedLinear 1.0;
    div(phi,h)       bounded Gauss limitedLinear 1.0;
    div(phi,e)       bounded Gauss limitedLinear 1.0;
    div(phi,epsilon) bounded Gauss limitedLinear 1.0;
    div(phi,v2)      bounded Gauss limitedLinear 1.0;
    div(phi,f)       bounded Gauss limitedLinear 1.0;
    div(phi,Ekp)     bounded Gauss limitedLinear 1.0;
    div(phi,omega)   bounded Gauss limitedLinear 1.0;
    div(phi,nuTilda) bounded Gauss limitedLinear 1.0;
    div(phi,K)       bounded Gauss linear;
    div(((rho*nuEff)*dev2(T(grad(U)))))      Gauss linear;
    div((nuEff*dev2(T(grad(U))))) Gauss linear;
}

laplacianSchemes
{
    default         Gauss linear limited corrected 0.33;
}

interpolationSchemes
{
    default         linear;
}

snGradSchemes
{
    default         limited corrected 0.33;
}

gradSchemes
{
    default         cellLimited Gauss linear 1;
    grad(p)         Gauss linear;
}

fluxRequired
{
    default         no;
    p               ;
    Phi             ;
}

wallDist
{
    method          meshWave;
    nRequired       false;
}
