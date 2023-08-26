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
    object      fvSchemes;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

ddtSchemes
{
    default         steadyState;
}

gradSchemes
{
    default             cellLimited Gauss linear 1.0;
//    grad(p)             Gauss linear;
//    grad(U)             Gauss linear;
}

divSchemes
{
//    div(phi,U)      	bounded Gauss upwind;
    div(phi,U)      	bounded Gauss linearUpwindV grad(U);
    div(phi,e)      	bounded Gauss upwind;//limitedLinear 1.0;
    div(phi,h)      	bounded Gauss upwind;//limitedLinear 1.0;
    div(phi,omega)  	bounded Gauss upwind;//limitedLinear 1.0;
    div(phi,k)      	bounded Gauss upwind;//limitedLinear 1.0;
    div(phi,nuTilda)    bounded Gauss upwind;//limitedLinear 1.0;
    div(phi,K)      	bounded Gauss upwind;//linear;
    div(phi,Ekp)    	bounded Gauss upwind;//limitedLinear 1.0;
    div(((rho*nuEff)*dev2(T(grad(U))))) Gauss linear;
}

laplacianSchemes
{
    default         Gauss linear corrected limited 0.333;
}

interpolationSchemes
{
    default         linear;
}

snGradSchemes
{
    default         corrected limited 0.333;
}

wallDist
{
    method meshWave;
    nRequired false;
}
// ************************************************************************* //
