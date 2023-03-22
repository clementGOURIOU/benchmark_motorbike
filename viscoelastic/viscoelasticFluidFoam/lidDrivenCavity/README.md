#########################################

Microbenchmark – Viscoelastic Lid Driven Cavity

#########################################

exaFOAM project


Author: Bruno Martins (UMinho)
Reviser: Miguel Nóbrega (UMinho)


# OpenFOAM Branch/Version
foam-extend 4.1

# Case Folders:

Notation:

- VLDCM1 - Mesh with 1000x1000 cells

- VLDCM2 - Mesh with 2000x2000 cells

- VLDCM3 - Mesh with 4000x4000 cells
    
# Boundary Condition:
    
This case benchmark requires a custom boundary condition, which should be compiled prior to run the case study.
Instructions for compiling the boundary condition:
- 1. Run ./Allwmake
    
# Running the simulations:
- 1. Change directory to the case folder
- 2. Run ./Allrun
    
# Additional Notes:
- 1. The case is prepared to run with 4 processors, to run the case with a different number of processors the following steps should be done:
          a. edit modify the dictionary entry #numberOfSubdomains of the file <case folder>/system/decomposeParDict to the desired number of processors;   	    
          b. edit file Allrun file in #runParallel viscoelasticFluidFoam X, where X is the number of desired processors.
   
- 2. All cases have a restart file to start the simulation in a specified timestep, for which the calculation procedure is more stable, being, thus more representative of the total run time. The complete case study with the calculation files can be obtained at  the E4 cluster in folder “/data/exafoam/wp2-validation/microbenchmarks/viscoelastic/viscoelasticLidDrivenCavity”
    
- 3. The version of the case study stored in this repository,  is prepared to generate the mesh, decompose the data and start the simulation from the beginning.
   


    
