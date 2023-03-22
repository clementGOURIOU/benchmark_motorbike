 
    Info << "\nReading swirlAndRotationProperties dictionary\n" << endl;
    IOdictionary swirlAndRotationProperties
    (
         IOobject
         (
            "swirlAndRotationProperties",
            runTime.constant(),
            mesh,
            IOobject::MUST_READ,
            IOobject::NO_WRITE
          )
    );

    Switch modifyBoundaries
    (
        swirlAndRotationProperties.lookup("modifyBoundaries")
    );

    Switch modifyInterior
    (
        swirlAndRotationProperties.lookup("modifyInterior")
    );

    dimensionedVector omega
    (
        "omega",
        swirlAndRotationProperties
    );

    dimensionedVector center
    (
        "center",
        swirlAndRotationProperties
    );

    wordList rotPatches(swirlAndRotationProperties.lookup("rotatingPatches"));

