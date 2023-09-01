# Instructions

This benchmark requires a custom viscoelastic constitutive model, where a stabilization procedure (improved both sides diffusion) is implemented, which should be compiled before running the case study.

## Instructions for compiling the custom viscoelastic constitutive model:

1. Source a foam-extend 4.1 installation.
2. Change the directory to "src".
2. Execute "./Allwmake".

## Running the simulations:

1. Change the directory to the desired case folder.
2. Execute "./Allrun.pre".
3. Execute "./Allrun".

## Additional notes:

1. The case is prepared to run with four processors. To run the case with a different number of processors, the following steps should be done:
      a. Edit the dictionary entry "numberOfSubdomains" in the "system/decomposeParDict" file to the desired number of processors.
      b. Edit the command "runParallel viscoelasticFluidFoam X" in the "Allrun" file, where X is the previously defined number of processors.

2. All cases have a restart file to start the simulation in a specified timestep, for which the calculation procedure is more stable and thus more representative of the total run time. The complete case study with the calculation files can be obtained at the E4 cluster in folder “/data/exafoam/wp2-validation/macrobenchmarks/viscoelastic/complexProfileExtrusion”.

3. The version of the case study stored in this repository is prepared to generate the mesh, decompose the data and start the simulation from the beginning.
