# Viscoelastic Benchmark Cases

## Authors

Authors: Gabriel Magalhães and Ricardo Costa (UMinho)

Reviser: Miguel Nóbrega (UMinho)

## Copyright

Copyright (c) 2022-2023 University of Minho

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons Licence" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.

## OpenFOAM branch/version

foam-extend 5.0

## Solvers

All the solvers bellow are in the WP4 public repository that has a specific README.

### segregatedViscoelasticFoam

The segregated solver (*segregatedViscoelasticFoam*) is just a copy of *viscoelasticFluidFoam* with small adjustments to use the new implementation of the viscoelastic transport model. 

### semiCoupledViscoelasticFoam

The semi-coupled solver is named *semiCoupledViscoelasticFoam*.When using the semi-coupled approach it exists a coupling for pressure-velocity, resulting in a 4 x 4 coefficient matrix in each cell. This solver is based on the other coupled solvers in foam-extend-5.0, like the *pUCoupledFoam* and *transientFoam*. A segregated solution is used for the viscoelastic tensor (all the modes when it is multi-mode).

### coupledViscoelasticFoam

The fully-coupled solver is called *coupledViscoelasticFoam*. In the fully-coupled approach, coupling occurs between pressure, velocity, and tau, resulting in a 10 x 10 coefficient matrix in each cell. This matrix accounts for tau's consideration as a symmetric tensor with 6 components. When using a multi-mode viscoelastic law, just one mode is solved in the block-system, a segregated solution is used for the other modes of the viscoelastic tensor.

## Cases

### Viscoelastic Lid Driven Cavity

The basis for the viscoelastic lid driven cavity is in the folder [lidDrivenCavity](./lidDrivenCavity/). The folder contains a specific [README](./lidDrivenCavity/README.md) for the case

### Viscoelastic Profile Extrusion

The basis for the viscoelastic complex profile extrusion is in the folder [profileExtrusion](./profileExtrusion/). The folder contains a specific [README](./profileExtrusion/README.md) for the case

### Viscoelastic Complex Profile Extrusion

The basis for the viscoelastic complex profile extrusion is in the folder [complexProfile](./complexProfile/). The folder contains a specific [README](./complexProfile/README.md) for the case

## How to generate the cases

The cases are generated using the script [generateCase.sh](./generateCase.sh). The user just need to define the parameters in the section "User input parameters" and then execute the command

`./generateCase.sh`

After the execution a new folder is generated with a specific name containing the case, the solver used, the Co, the mesh and the control (tolerance or iterations), e.g. `complexProfile-segregated-Co5-40M-tol`. Inside this folder the case is prepared to run following the instructions on the specific README.

If the script is executed again using the same configuration, the old folder is deleted and a new is generated.

### The "User input parameters"

- case2gen: three valid values are **complexProfile**, **profileExtrusion** and **lidDrivenCavity**. Corrensponds to the desired benchmark case.
- maxCo: any value defined by user for the maximum Courant number.
- solver: three valid entries are **segregatedViscoelasticFoam** (segregated), **semiCoupledViscoelasticFoam** (semi-coupled) or **coupledViscoelasticFoam** (fully-coupled).
- mesh: the avaliable meshes for each case can be found in the specific README.
    - profileExtrusion: **1M**  (1 million) or **20M** (20 million).
    - complexProfile:   **20M** (20 million) or **40M** (40 million).
    - profileExtrusion: **1M**  (1 million) or **4M** (4 million) or **16M** (16 million).
- control: two valid values. **tol** for the control by tolerance or **iter** for the control by iterations.
- nProcs: any integer value defined by user for the number of processes to be used in the parallel execution.
- Tol: absolute tolerance. There are three entries *uTol*, *pTol* and *tauTol*, respectivelly for velocity, pressure and tau. For coupled solutions u tolerances are not used, the *pTol* is applied for the block-coupled system solution.
- RelTol: absolute tolerance. There are three entries *uRelTol*, *pRelTol* and *tauRelTol*, respectivelly for velocity, pressure and tau. For coupled solutions u tolerances are not used, the *pTol* is applied for the block-coupled system solution.
- MinIter: minimum number of iterations for the solver. There are three entries *uMinIter*, *pMinIter* and *tauMinIter*, respectivelly for velocity, pressure and tau. If `control="iter"` just MinIter value is used.
- MaxIter: maximum number of iterations for the solver. There are three entries *uMaxIter*, *pMaxIter* and *tauMaxIter*, respectivelly for velocity, pressure and tau. If `control="iter"` just MinIter value is used.

### Tested benchmark cases

- The folder [testedCases](./testedCases/) contain the scripts used to generate cases tested in the framework of the exaFOAM project, which are the following:
    - [lidDrivenCavity-segregated-Co0.1-1M-tol](./testedCases/lidDrivenCavity-segregated-Co0.1-1M-tol): [lidDrivenCavity](./lidDrivenCavity/) case using the *segregatedViscoelasticFoam* controlled by the tolerance with *Co = 0.1* in a mesh with 1 million cells. 
    - [profileExtrusion-segregated-Co5-1M-tol](./testedCases/profileExtrusion-segregated-Co5-1M-tol): [profileExtrusion](./profileExtrusion/) case using the *segregatedViscoelasticFoam* controlled by the tolerance with *Co = 5* in a mesh with 1 million cells. 
    - [profileExtrusion-semiCouple-Co5-1M-tol](./testedCases/profileExtrusion-semiCouple-Co5-1M-tol): [profileExtrusion](./profileExtrusion/) case using the *semiCoupledViscoelasticFoam* controlled by the tolerance with *Co = 5* in a mesh with 1 million cells. 
    - [profileExtrusion-coupledVis-Co5-1M-tol](./testedCases/profileExtrusion-coupledVis-Co5-1M-tol): [profileExtrusion](./profileExtrusion/) case using the *coupledViscoelasticFoam* controlled by the tolerance with *Co = 5* in a mesh with 1 million cells. 
    - [complexProfile-segregated-Co0.1-20M-tol](./testedCases/complexProfile-segregated-Co0.1-20M-tol): [complexProfile](./complexProfile/) case using the *segregatedViscoelasticFoam* controlled by the tolerance with *Co = 0.1* in a mesh with 20 million cells. 
    - [complexProfile-semiCouple-Co2-20M-tol](./testedCases/complexProfile-semiCouple-Co2-20M-tol): [complexProfile](./complexProfile/) case using the *semiCoupledViscoelasticFoam* controlled by the tolerance with *Co = 2* in a mesh with 20 million cells. 
    - [complexProfile-coupledVis-Co10-20M-tol](./testedCases/complexProfile-coupledVis-Co10-20M-tol): [complexProfile](./complexProfile/) case using the *coupledViscoelasticFoam* controlled by the tolerance with *Co = 10* in a mesh with 20 million cells. 
 
- All the cases details are in the file `info.txt` inside the folders.

## Instructions to build residuals from coupled solvers

As the standard application `foamLog` in OpenFOAM can not deal with the coupled solutions, the [residuals.py](./tools/residuals.py) was implemented a python script to avoid this problem. This script must be used in conjunct with the standard application. The code is present in all the case folders for an easier use. The only requirement to run the script is the package `pandas`.

First, the user needs to run the command

```
foamLog log.SOLVER
```
where `log.SOLVER` indicates the name of the log file.

After to use the standard application it is necessary to run the command
```
python residuals.py -l log.SOLVER
```
It will generate one CSV file for each property solved both segregated and coupled inside the folder `logs`.

The options avaliable for `residuals.py` can be shown using the command
```
python residuals.py -h
```

The procedure is the same for all the solvers, working inclusivelly for the segregated solver, where CSV files are generated. 

## Acknowledgment

This cases have been developed as part of the exaFOAM Project https://www.exafoam.eu, which has received funding from the European High-Performance Computing Joint Undertaking (JU) under grant agreement No 956416. The JU receives support from the European Union's Horizon 2020 research and innovation programme and France, Germany, Italy, Croatia, Spain, Greece, and Portugal.

<img src="./profileExtrusion/figures/footerLogos.jpg" alt="footer" height="100">