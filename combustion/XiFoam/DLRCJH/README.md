# DLR Confined Jet High Pressure Combustor
## Authors
Sergey Lesnik and Henrik Rusche, Wikki GmbH, Germany

## Copyright
Copyright (c) 2022-2023 Wikki GmbH

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons Licence" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />

Except where otherwise noted, this work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.

## Introduction
The considered combustor stems from an experimental setup constructed by Severin[^SeverinPhD] at the Institute of Combustion Technology of the German Aerospace Center (abbreviated as DLR in German). The burner is based on the Recirculation-Stabilized Jet Flame (RSJF) concept, which is better known as FLOX. Initially developed for the industrial furnaces, this technology has a great potential in the application to the gas turbines. Compared to widespread swirl burners, RSJF combustors feature low NOx emissions, homogeneous temperature distribution, and operate with a wide range of fuels and loads. The main goal of the experimental work was to clarify how the recirculation contributes to the flow stabilization. Apart from the experiments, a number of numerical investigations with the same geometry was performed, e.g. by Ax et. al.[^Ax2020] and Gruhlke et. al.[^Gruhlke2020][^Gruhlke2021].

![renderingDLRCJH.png](figures/renderingDLRCJH.png)

Figure: Rendering of the DLRCJH combustor flame with fuel.

## Experimental Setup
![geometry_3D.svg](figures/geometry_3D.svg)

Figure: Geometry of the combustor DLRCJH. The dimensions are in mm.

A typical RSJF combustor consists of several nozzles arranged in a ring around a central pilot swirl-burner. The test rig considered here represents a segment of such an RSJF combustor with a single nozzle[^SeverinPhD]. It consists of a rectangular chamber with the dimensions of 95 x 95 x 843 mm³, a cylindrical inlet with 40 mm diameter, a fuel injector placed 400 mm upstream of the chamber and an outlet at the end of the chamber. The main inlet pipe axis is offset to the chamber center line by 10 mm in order to allow for the recirculation zone to develop. The effect of the swirl-burner is simulated by seven pilot burners inclined to the main inlet axis and placed above the main inlet pipe. In this way, the impact of the swirl flow on the jet can be reproduced, whereby the tangential component is ignored. A premixed mixture of air and natural gas is injected through the main and the pilot nozzles, whereby the overall mass flow of the pilots corresponds to 10 % of the main nozzle.

## Measurements
Severin[^SeverinPhD] applied following measurement techniques: OH*-chemiluminescence (identification of the flame position), Particle Image Velocimetry (PIV, flow speed determination), Laser Induced Fluorescence of the OH radical (LIF, temperature determination). The temperature and velocity fields from the middle slice (x-y plane) of the chamber were evaluated and are used here for validation.

## Flow parameters
- Reynolds number: 497 000
- Average velocity at the main inlet: $`U_i`$ = 113 m/s
- Chamber pressure: 8 bar
- Air-fuel ratio: 1.7
- Inlet temperature of the mixture: $`T_i`$ = 725 K
- Adiabatic flame temperature: 1950 K


# Numerical Setup
## Geometry
The geometry parameters shown in the table below are taken from Severin[^SeverinPhD].

| Dimension            | Description                                                     |
|----------------------|-----------------------------------------------------------------|
| $`d_i`$ = 40 mm        | Inlet nozzle diameter                                           |
| $`y_i`$ = -10 mm       | Vertical offset of the nozzle mounting point                    |
| $`a`$ = 95 mm          | Lateral, top and bottom wall width of the chamber               |
| $`l`$ = 843 mm         | Chamber length                                                  |
| $`x_{inj}`$ = -400 mm  | Location of the fuel injection                                  |
| $`d_o`$ = 58.8 mm      | Outlet nozzle diameter                                          |
| $`d_p`$ = 4.7 mm       | Pilot nozzle diameter                                           |
| $`\alpha`$ = 60°       | Inclination angle of the pilot nozzles to the inlet nozzle axis |
| $`\Delta z_p`$ = 10 mm | Distance between the neighboring pilot nozzles                  |
| $`y_p`$ = 25 mm        | Vertical offset of the pilot nozzles mounts                     |

Several dimensions regarding the inlet and outlet pipes could not be found in the literature and approximations based on the available description and figures are introduced. The original outlet is not reproduced. The outlet in the numerical setup is represented by the complete cross-section of the chamber. Primarily, this is done to avoid the wave reflection (mostly originating from the flow initialization or mapping from a mesh of lower resolution) at the walls. The boundary condition for pressure at the outlet is non-reflective. The length of the main inlet pipe is chosen to be 10 times the diameter in order for the flow to develop until the entry into the chamber. The final dimensions are given in x-y and y-z cross-sections below in addition to figure from section [Experimental Setup](#experimental-setup).

| Plane y-z | Plane x-y |
|--|--|
| ![geometry_yz.svg](figures/geometry_yz.svg) | ![geometry_xy_pilots.svg](figures/geometry_xy_pilots.svg) |

Figure: Geometry of the DLRCJH combustor for the numerical setup. The dimensions are in mm.

## Initialization
The flow is initialized either by means of *setFields* or *mapFieldsPar* tool. The former is used when no field data from a run of lower resolution is available. In this case, the velocity, temperature and regress variable fields of the complete inlet duct and an additional cylindrical volume formed by extrapolating the duct into the chamber are set to the conditions of the main inlet, see section [Boundary Conditions](boundary-conditions). Similar conditions are applied to the pilots. The rest of the domain is initialized to zero velocity, burnt state and the temperature is set to 1900 K to allow the reactants to ignite. In this way, no artificial ignition applied to the energy equation (*ignitionSites*) is needed.

Utility *mapFieldsPar* is used for propagation of the developed flow from the cases with lower mesh resolution to higher one lowering the cost-to-solution.

## Models
- Solver: **XiFoam** is used as the top-level solver. It handles an unsteady compressible flow, incorporates combustion relevant models and is controlled by a PIMPLE loop allowing CFL number to be higher than 1.
- Turbulence: LES kinetic energy equation model (*kEqn*) with van Driest damping function for the treatment of the near-wall regions.
- Combustion: the fuel mixture is inhomogeneous since the main and pilot nozzles are operated with the different air-to-fuel ratios. The laminar flame speed Su is assumed to be unstrained and a transport equation is solved for the flame wrinkling Xi.

## Numerics
LES modeling relies on high accuracy of the discretization and thus higher order schemes are utilized. These are *linear*, *limitedLinear*, *limitedLinear01* etc. For the velocity convection *filteredLinear* is used. For the temporal discretization a blending between Euler and Crank-Nicolson with a ratio 30:70 (*crankNicolson 0.7*) is utilized.  In the case of non-initialized fields, the calculation needs further stabilization and thus the Euler scheme should be used at the beginning and then transitioned by a linear ramp during a certain time period to the final blending value of 0.7. Pure second order time schemes such as *crankNicolson 1* and *backward* proved to be unstable in the present case.

Linear solvers utilized are based on the conjugate gradients method. The PIMPLE loop has 2 outer and 1 inner corrections with 0 non-orthogonal corrections. Utility *renumberMesh* is used to reduce the bandwidth of the resulting matrix and accelerate the linear solver execution.

## Surface Mesh
Surface mesh is created from scratch using CAD software FreeCAD 0.20[^freecad]. The resulting mesh is water proof meaning that vertices of different regions coincide at the region boundaries.

## Mesh
The meshing has been accomplished with tool snappyHexMesh (sHM), which allows semi-automatic meshing of complex geometries with refinement zones. Four surface meshes are provided:
- an .obj file with the complete geometry with regions corresponding to the boundaries - used by sHM to define regions;
- an .stl file with the complete geometry without regions - used by surfaceFeatureExtract to extract features and provide them to sHM for snapping;
- two additional .stl files with the surface meshes of the inlet pipe and pilots - used by sHM for distance based regions refinements.
This configuration is due to limited capabilities of FreeCAD export and sHM import. The number of files may be reduced further by manual editing.

During the definition of the mesh topology, the focus has lied on ensuring a high resolution in the upstream half of the chamber, where the main jet mixes with those from the pilots and a recirculation occurs. Furthermore, a high mesh resolution has been prescribed in the shear and boundary layers of the inlet and pilot pipes. A particular attention has been paid to ensure that none of the mesh parts results in a locally high Courant number which would limit the time step. For instance, the Courant number in the chamber is targeted to be under 0.25, whereas in a pilot pipe it is allowed to be as high as 1.5 due to the fact the the pilot flow is of minor interest with the respect to the final results and the validation. Four meshes with resolutions of 3, 24, 189, 489 million cells have been produced successively. For each resolution, the quality of the mesh has been assessed and a calculation with XiFoam has been performed. The results have been validated by comparing time-averaged velocity and temperature fields between the calculation and the experiment.

## Boundary Conditions
| Quantity | Description                    | Units    |
|----------|--------------------------------|----------|
| alphat   | Turbulence thermal diffusivity | kg/(m s) |
| b        | Regress variable               | -        |
| k        | Turbulence kinetic energy      | m²/s²    |
| ft       | Fuel fraction                  | -        |
| nut      | Turbulence viscosity           | m²/s     |
| p        | Pressure                       | kg/(m s²)|
| Su       | Laminar flame speed            | m/s      |
| T        | Temperature                    | K        |
| Tu       | Unburnt Temperature            | K        |
| U        | Velocity                       | m/s      |
| Xi       | Flame-wrinkling St/Su          | -        |

The set of variables from the table above need to be defined at the boundaries in order to start the case. The values for the corresponding boundary conditions (BC) are taken from Severin's piloted case CJH2[^SeverinPhD]. Gruhlke et. al.[^Gruhlke2020] estimated the wall temperatures for a numerical setup.

| Quantity | Main inlet  | Pilot inlet | Walls                             | Outlet     |
|----------|-------------|-------------|-----------------------------------|------------|
| alphat   | zG          | zG          | wF                                | c          |
| b        | fV 1        | fV 1        | zG                                | iO 0       |
| ft       | fV 0.03344  | fV 0.06084  | zG                                | iO 0.03344 |
| k        | fV 1e-5     | fV 1e-5     | wF                                | iO 1e-5    |
| nut      | c           | c           | zG                                | c          |
| p        | zG          | zG          | zG                                | wT 8e5 5   |
| Su       | c           | c           | zG                                | c          |
| T        | fV 725      | fV 633      | CF: fV 600; CL: fV 800; other: zG | iO 1000    |
| Tu       | fV 725      | fV 633      | CF: fV 600; CL: fV 800; other: zG | iO 1000    |
| U        | fRIV 0.5563 | fRIV 0.0558 | fV (0 0 0)                        | iO (0 0 0) |
| Xi       | fV 1        | fV 1        | zG                                | iO 20      |

The abbreviations used above are:

| Abbreviation         | Meaning                   |
|----------------------|---------------------------|
| c                    | calculated BC             |
| CF                   | Chamber Front (baseplate) |
| CL                   | Chamber Lateral walls     |
| fRIV *massFlowRate*  | flowRateInletVelocity BC  |
| fV *value*           | fixedValue BC             |
| iO *inletValue*      | inletOutlet BC            |
| wF                   | wallFunction BC           |
| wT *fieldInf* *lInf* | waveTransmissive BC       |
| zG                   | zeroGradient BC           |

Due to high turbulence in the chamber, the flow at the outlet may reverse. Therefore, "inletOutlet" BC is chosen for the affected quantities. The corresponding inlet values, which are applied in the case of a flow reversal, are chosen to be close to the actual state of the flow at the outlet apart from the velocity, which is set to zero.


# Validation
A validation was performed with the results from Severin[^SeverinPhD] using the case with 24 million cells. Temperature and velocity profiles were averaged for 0.05 s of physical time and are provided below. Both, side and top view slices, contain the center axis of the main inlet pipe. The velocity distribution and the position of the recirculation zone from the calculation are in good agreement with the experiment. Temperature in the range above 1700 K is depicted correctly by the calculation. The region with temperature below 1400 K in the center of the chamber is larger than the one from the experiment. This is probably caused by the insufficient turbulence intensity in the computation.

## Velocity
| | Side View | Top View |
|--|--|--|
| Computation | ![7608d6e2c381894c3303bca616371060.png](figures/7608d6e2c381894c3303bca616371060.png) | ![51644120d739a61abc68e3079e6e5033.png](figures/51644120d739a61abc68e3079e6e5033.png) |
| Experiment from Severin[^SeverinPhD] | ![7a424d29c5d083be782031a3963db313.png](figures/7a424d29c5d083be782031a3963db313.png) | ![e05105c79b9a8d100ce5ce5c5c1046ea.png](figures/e05105c79b9a8d100ce5ce5c5c1046ea.png) |

## Temperature
| | Side View | Top View |
|--|--|--|
| Computation | ![1b814655d691e01ee5a526df94326caf.png](figures/1b814655d691e01ee5a526df94326caf.png) | ![e4805163fbd0e9933d8414d16cb79c56.png](figures/e4805163fbd0e9933d8414d16cb79c56.png) |
| Experiment from Severin[^SeverinPhD] | ![9939484cab3ca8d241b79a2d582580f3.png](figures/9939484cab3ca8d241b79a2d582580f3.png) | ![b029fd070a1be7e278c2da4873ab4974.png](figures/b029fd070a1be7e278c2da4873ab4974.png) |

## 489M Case Impressions
| | |
|--|--|
| Pressure | ![e3519667ce761ab9c5d606ea7ae2dc18.png](figures/e3519667ce761ab9c5d606ea7ae2dc18.png) |
| Velocity | ![4ef79b6b5fbde1909c12098234e230b1.png](figures/4ef79b6b5fbde1909c12098234e230b1.png) |
| Temperature | ![424b8972006cbddbef83ec4f5fa52866.png](figures/424b8972006cbddbef83ec4f5fa52866.png) |

Figures: pressure, velocity and temperature slices from the case with 489 million cells.


# Grand Challenge
- Known to run with OpenFOAM-v2106 and -v2112.
- Three cases are provided: 3M, 24M and 489M, where the number describes the cell count in millions (an additional setup with 189 million cells may be shipped upon request).
- Two setups for each mesh size are provided
	- *fixedTol*: the tolerances of the linear solvers are fixed. This is a usual setup for a production run. The execution time fluctuations between the time steps are large and are not only dependent on the mesh size but also on the decomposition (e.g. number of processors). In the context of the benchmarking, it is used to provide mean iteration numbers for the *fixedIter* setup.
	- *fixedIter*: the iteration numbers of the linear solvers are fixed. The execution time fluctuations between the time steps are due to hardware load (e.g. MPI communication). This setup is meant to be used for benchmarking.
- Utility *renumberMesh* is utilized to reduce the bandwidth of the resulting matrix and speed up the sparse matrix-vector multiplication.
- Decomposition is performed with the *multiLevel* method and the *scotch* decomposer.

## Recommendations
- The larger meshes (189M, 489M) require single thread utilities such as *decomposePar*, *reconstructPar* to be compiled with the 64-bit integer (WM_LABEL_SIZE).
- Use collated fileHandler to reduce the number of files for runs with a large number of MPI ranks.
  - When using collated format, try to switch on threading in order to enable writing in a separate thread, e.g.
  ```
  decomposePar -opt-switch maxThreadFileBufferSize=2000000000 \
      -opt-switch maxMasterFileBufferSize=2000000000 -fileHandler collated
  ```
  - Collated format produces a single `processorsXX` folder by default, which is then read by a single IO rank. This may be problematic for read performance when running benchmarks with a large number of ranks. Use `ioRanks` option in order to increase number of folders (reading ranks), e.g. by using bash command substitution and brace expansion to enable 32 IO ranks (evenly spaced apart) for a decomposition with 32768 partitions:
  ```
  decomposePar -opt-switch maxThreadFileBufferSize=2000000000 \
      -opt-switch maxMasterFileBufferSize=2000000000 -fileHandler collated \
      -ioRanks "( $(echo {0..32767..1024}) )"
  ```
- A decomposition of the largest case (489M) onto high number of partitions (> 10,000) may take a lot of time (> 48h). Thus, it is expedient first to decompose only the fields required for a restart (see list of quantities from section [Boundary Conditions](#boundary-conditions)).
- Experience with *decomposePar* for the 489M case and only required fields:
	- decomposing both mesh and fields: min. 4 h wall time (strongly depends on the number of partitions); 450 GB RAM
    - decomposing fields only: min. 3 h wall time; 200 GB RAM
- Utility *mapFieldsPar* failed to map from 189M to 489M while using collated fileHandler in several attempts. Problems were also observed when mapping on several nodes. Thus, it is recommended
	- to use the utility on the decomposed case with the uncollated fileHandler
	- to map on a single node
	- to fulfill the memory requirement of total 1.5 TB RAM for the 489M case

## Instructions
Most of the setups contain symbolic links in order to reduce file duplication. Thus, preferably copy cases by using "rsync -L" or "cp -R -L".

### Surface Mesh Generation
A FreeCAD script is given in order to reproduce the geometry construction and surface mesh export. Unfortunately, the python interface does not provide the complete functionality of the GUI. Therefore, additional manual steps are needed to obtain the surface meshes. The complete steps are:
- Run the macro as an argument to the FreeCAD executable, e.g.:
  `freecad DLRCJH_onlyGeom.FCMacro`
  The FreeCAD GUI should open displaying the combustor geometry.
- Export DLRCJH mesh as an .obj file in the "Mesh Design" workbench (NOT File->Export).
- Export DLRCJH mesh as an ASCII .stl file in "Mesh Design" workbench (NOT File->Export). Needed for edge mesh extraction.
- Load the .obj file and view which "patch*" correspond to which boundary.
- Rename the patches in the .obj file with the correct boundary names in a text editor.
- Export meshes of the pipe and pilot walls separately as ASCII .stl via "Mesh Design". Needed for region refinement.

### Mesh and Restart Files
In order to enable restarts, meshes and developed fields are provided on the e4 platform (see access instructions at https://team.exafoam.eu/projects/exafoam/wiki) under:

`/data/exafoam/wp2-validation/grandChallenges/DLRCJH`

All the data is written in ASCII format with a precision of 10. Binary format is not used in order to avoid problems with different endianness on HPC systems.

If a new mesh is desired, the meshing setups including surface meshes are provided.
- Choose a case with the cell number closest to the targeted one and alter it (blockMeshDict, snappyHexMeshDict).
- Follow the procedure documented in the Allrun script.

### Preparation
- *fixedIter* is meant to be used for profiling. The mesh and the restart fields need to be downloaded, extracted and placed into the "constant" and "0" folders. Iteration numbers are set according to *fixedTol* runs with the following properties:
	- 3M, run on 64 cores, 2 nodes;
	- 24M, run on 512 cores, 4 nodes;
	- 489M, run on 4096 cores, 32 nodes.
- *fixedTol* setup is needed to determine iteration numbers for the *fixedIter* setup, if the number of cores or mesh size significantly differs from the provided above.
	- Restart files may be used if only the decomposition is changed (significantly).
	- If a new mesh is generated, the case should be mapped using the restart fields and it needs to be run for at least 0.05 s of physical time in order to obtain characteristic iteration numbers.
	- Included script "calcIterTimeStats.py" analyzes the solver log file and provides a recommendation for the *fixedIter* setup.

### Case run
- In *system/decomposeParDict* alter "numberOfSubdomains" and "multiLevelCoeffs" according to your setup.
- Run *Allpre* bash script or setup an HPC job.
- Run *Allrun* or setup an HPC job using the procedure from the script.
- Consider to use function object *FOwallClockTimeStatistics* to check the statistics of the run printed at the end. Note that the coded function object may cause problems at start-up (see [Known Issues](#known-issues)).


# Known Issues
- During the meshing a bug has been encountered. The meshing process for higher number of cells is stuck at the same stage and does not advance further. The presence of the issue depends on the compilation options. In fact, the problem is correlated to FMA instructions (Fused Multiply-Accumulate). See the corresponding [bug report](https://develop.openfoam.com/Development/openfoam/-/issues/2537) and [proposed patch](https://develop.openfoam.com/Development/openfoam/-/commit/cf818a653b9c4b5c4d7a2c17872c662eee5db566).
- Utility *mapFieldsPar* failed to map from 189M to 489M while using collated fileHandler (see [Recommendations](#recommendations)).
- Provided coded function object *FOwallClockTimeStatistics* needs a compilation to be executed on the first run. Sometimes on large cases with many nodes (responsible for IO), this leads to an error "No such file or directory". This can be fixed by executing a single rank run with a small mesh in order to compile the function object, which is stored in *dynamicCode* folder.

# Acknowledgment
This application has been developed as part of the exaFOAM Project https://www.exafoam.eu, which has received funding from the European High-Performance Computing Joint Undertaking (JU) under grant agreement No 956416. The JU receives support from the European Union's Horizon 2020 research and innovation programme and France, Germany, Italy, Croatia, Spain, Greece, and Portugal.

<img src="figures/Footer_Logos.jpg" alt="footer" height="100">


# References
[^SeverinPhD]: Severin, M., 2019. Analyse der Flammenstabilisierung intensiv mischender Jetflammen für Gasturbinenbrennkammern (PhD Thesis). Universität Stuttgart.
[^Ax2020]: Ax, H., Lammel, O., Lückerath, R., Severin, M., 2020. High-Momentum Jet Flames at Elevated Pressure, C: Statistical Distribution of Thermochemical States Obtained From Laser-Raman Measurements. Journal of Engineering for Gas Turbines and Power 142, 071011.  https://doi.org/10.1115/1.4045483
[^Gruhlke2020]: Gruhlke, P., Janbazi, H., Wlokas, I., Beck, C., Kempf, A.M., 2020. Investigation of a High Karlovitz, High Pressure Premixed Jet Flame with Heat Losses by LES. Combustion Science and Technology 192, 2138–2170. https://doi.org/10.1080/00102202.2020.1781101
[^Gruhlke2021]: Gruhlke, P., Janbazi, H., Wollny, P., Wlokas, I., Beck, C., Janus, B., Kempf, A.M., 2021. Large-Eddy Simulation of a Lifted High-Pressure Jet-Flame with Direct Chemistry. Combustion Science and Technology 1–25. https://doi.org/10.1080/00102202.2021.1903886
[^freecad]: https://wiki.freecad.org/Release_notes_0.20
