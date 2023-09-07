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
    object      controlDict;
}
application     simpleFoam;
startFrom       latestTime;
startTime       0;
stopAt          endTime;
endTime         2000;
deltaT          1;
writeControl    timeStep;
writeInterval   2000;
purgeWrite      10;
writeFormat     binary;
writePrecision  8;
writeCompression no;
timeFormat      general;
timePrecision   8;
runTimeModifiable yes;

functions
{
    #include "readFields"
    #include "fieldMinMaxFile"
    #include "derivedPressure"
    #include "fieldAverage"
    #include "writeDictionary"

    #includeFunc wallShearStress

    #include "pressureProbes"
}

// ************************************************************************* //
