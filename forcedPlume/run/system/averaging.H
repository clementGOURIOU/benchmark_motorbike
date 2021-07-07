    fieldAverage1
    {
        type            fieldAverage;
        functionObjectLibs ( "libfieldFunctionObjects.so" );
        enabled         true;
        outputControl   outputTime;

        fields
        (
            U
            {
                mean        on;
                prime2Mean  on;
                base        time;
            }

            T
            {
                mean        on;
                prime2Mean  on;
                base        time;
            }
        );
    }
