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
    object      controlDict;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

application     rhoSimpleFoam;
startFrom       latestTime;
startTime       0;
stopAt          endTime;
endTime         5000;
deltaT          1;
writeControl    runTime;
writeInterval   5000;
purgeWrite      0;
writeFormat     binary;
writePrecision  6;
writeCompression off;
timeFormat      general;
timePrecision   6;
runTimeModifiable yes;

functions
{
    fieldMinMax
    {
        type                fieldMinMax;
        libs                ("libfieldFunctionObjects.so");
        log                 yes;
        writeControl        timeStep;
        writeInterval       1;
        mode                magnitude;
        fields              ( U p rho T );
    }

    fieldAverage1
    {
        type            fieldAverage;
        libs            ("libfieldFunctionObjects.so");
	timeStart	4000;
        writeControl    writeTime;

        fields
        (
            U
            {
                mean        on;
                prime2Mean  off;
                base        time;
            }

            p
            {
                mean        on;
                prime2Mean  off;
                base        time;
            }
        );
    }
}

// ************************************************************************* //
