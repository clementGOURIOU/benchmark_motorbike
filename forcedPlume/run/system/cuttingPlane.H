/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\    /   O peration     | Version:  2.1.1                                 |
|   \\  /    A nd           | Web:      www.OpenFOAM.org                      |
|    \\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/

cuttingPlane
{
    type            surfaces;
    functionObjectLibs ("libsampling.so");
    outputControl   outputTime;

    surfaceFormat   ensight;
    fields          (T U rho);

    formatOptions
    {
        ensight
        {
            format  binary;
        }
    }

    interpolationScheme cellPoint;

    surfaces
    (
        xNormal
        {
            type            cuttingPlane;
            planeType       pointAndNormal;
            pointAndNormalDict
            {
                basePoint       (0 0 0.57);
                normalVector    (1 0 0);
            }
            interpolate     true;
        }

    );
}


// ************************************************************************* //
