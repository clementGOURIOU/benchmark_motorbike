# I9 DRIVAER ExtAero DERIVATIVE


## Authors
ESI-Group, 2023
case provided by Stakeholder Audi AG, 2022-23


## Copyright
Copyright (c) 2022-2023 ESI-Group

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons Licence" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.


## Description
This benchmark is a standalone – without supporting microbenchmarks, here justified by the fact of there being two other DrivAer cases names in this Workpackage, both which are for transient flows dealing with external aerodynamics and Aeroacoustics, respectively.
This derivative, provided by the exaFOAM Stakeholder Audi, is a production ready case in geometry detail. The vehicle is placed in an “open” wind-tunnel, and contains production-ready design-level details in respect of external surface resolution, under-hood and underbody detail, brake and suspension, wheels with spokes and treaded tyres.
We specifically reserve this production-ready design-level configuration to the execution, profiling and performance of any new solvers developed and released during this project. In particular we target new steady-state solvers (specifically excluding transient solvers) for the interest, benefit and downstream exploitation of the named Stakeholder, their sector and other OEMs in that industry.
The case is 193M cells external aerodynamics model with MRF modelling for wheel rotation.


![figures/Figure1.png](figures/Figure1.png)

Figure 1: DrivAer AUDI derivative. Wind-tunnel domain (left), vehicle surface representation (centre) and brake-detail (right)


## Bottlenecks
The bottlenecks and HPC challenges towards exa-scale computing are restated below:
  - Scalability of the mesher using volume and surface-layer refinement.
    - I/O
    - Re-composition and decomposition
  - Application to rotating or non-rotating wheels using any MRF methodologies which may be available


## Run acceptance criteria
  - Targeting execution with several hundreds-of-million cells, qualitative comparisons with existing solvers in respect of
    - Raw turn-around time
    - Scalability on several hundreds and thousands of cores.
  - Optionally, scalability and load balancing profiling and performance for steady-state rotating wheel methodologies


## Instructions to run the case
The setup is tested in OpenFOAM v2306 in 144 cores. Please change core count as needed for scalability tests.

Allrun script has instructions to copy geometry aerodynamicsDrivAer/constant/triSurface.
However, if they are missing in "$FOAM_TUTORIALS/resources/geometry/I9_aerodynamics_DrivAer" please fetch them first from link (TBD) 

Execution is typically a call to Allrun script at top level directory e.g. ./Allrun

This should generate mesh and solve steady state part inside aerodynamicsDrivAer direcotry. Solver runs 4000 iterations.

This should be followed by transient solver taking steady state solution as starting point.

Any post-processing (like gnuplot) could be evaluated separately at either steady or transient part.


## Acknowledgment
This application has been developed as part of the exaFOAM Project https://www.exafoam.eu, which has received funding from the European High-Performance Computing Joint Undertaking (JU) under grant agreement No 956416. The JU receives support from the European Union's Horizon 2020 research and innovation programme and France, Germany, Italy, Croatia, Spain, Greece, and Portugal.

<img src="figures/Footer_Logos.jpg" alt="footer" height="100">

