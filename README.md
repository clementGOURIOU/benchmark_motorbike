# HPC

Code repository for the High Performance Computing Technical Committee

**OpenFOAM HPC Benchmark suite**

The repository is intended to be a shared repository with relevant data-sets and information created in order to:

*  provide user guides and initial scripts to set-up and run different data-sets on different HPC architectures
*  provide to the community an homogeneous term of reference to compare different hardware architectures, software environments, configurations, etc. 
*  define a common set of metrics/KPI (Key Performance Indicators) to measure performances

*  **3-D Lid Driven cavity flow**


The  first test-case chosen is the a 3-D version of the [Lid-driven cavity flow tutorial](https://www.openfoam.com/documentation/tutorial-guide/tutorialse2.php). 

This test-case has simple geometry and boundary conditions, involving transient, isothermal, incompressible laminar flow in a three-dimensional box domain. The *icoFoam* solver is used in such test-case.

It is intended to be a stress test for the linear algebra solver, being most of the time spent in the pressure equation.

***Definition of geometrical and physical properties***

In such simple geometry all the boundaries of the box are walls. The top wall moves in the x-direction at the speed of 1 m/s while the other five are stationary.
Three different sizes have been selected:

*  Small (S)
*  Medium (M) 
*  eXtraLarge (XL)

The following Table shows the geometrical and physical properties of the different test-cases, which have an increasing number of cells: 1 million(m) (S), 8 m (M) and 64 m (XL) of cells, obtained by halving ∆x when moving from the smaller to the bigger test-case. 
The Courant number Co=(U ∆t)/∆x is kept under stability limit, and it is halved when moving to bigger test-cases. 
The time step ∆t is reduced proportionally to Co and ∆x, by 4 times. The physical time to reach the steady state in laminar flow is T= 0.5. 



| Parameters \ Test-case     |    **S**  | **M** | **XL** |
|----------------------------|-----------|-------|--------|
|   ∆x (m.)                  |  0.001    | 0.0005| 0.00025|
| N. of cells tot. (m)       | 1         | 8     |  64    |
| N. of cells lin. (m)       | 100       | 200   | 400    |
| kinematic viscosity ν (m^2/s)| 0.01    | 0.01  | 0.01   | 
| d (m)                      | 0.1       | 0.1   | 0.1    |
| Co                         | 1         | 0.5   | 0.25   |
| ∆t (s)                     | 0.001     |0.00025|0.0000625|
| Reynolds number            | 10        | 10    | 10     |
| U (m/s)                    | 1         | 1     | 1      |
| n. of iter.                | 500       | 2000  | 8000 (100) |
| Final physical Time (s.)   | 0.5       | 0.5   | 0.5 (0.00625)|

The test-case XL is used with a number of iteration equal to 100 to reduce the computational time.

***Set-up of linear algebra solvers***

The set-up for the linear algebra solvers consists of: 


*  Pressure: 
*  DIC-PCG is an iterativer solver that combins a Diagonal-based Incomplete-Cholesky (DIC) preconditioner with a Conjugate Gradient (PCG) solver. DIC is a common preconditioner in OpenFOAM forits easy configuration and high efficiency 
*  GAMG-PCG is an  iterative  solver  implemented  in  OpenFOAM  that  uses  aConjugate  Gradient  (CG)  accelerated  by  a  generalized  geometric-algebraic  multigrid(GAMG) method that supports both geometrical and algebraic multigrid.
*  Velocity: DILU-PBiCGStab that is combination of Diagonal Incomplete LU (asymmetric) factorization for the preconditioner with a Stabilized Preconditioned (bi-)conjugate gradient solver

The iterative method can be run using two different convergence criteria:   


1.   FIXEDITER: In this case the computational load is fixed, when running with the given solver. This case is useful for comparing different hardware configurations
by keeping constant the computational load.  
2.   FIXEDNORM: in this case the exit norm is fixed.

The two different options are selected by choosing one of the two configurations files: 

1.  `system/fvSolution.fixedITER`, with a constant number of iteration per time step for the pressure solver, different according to the test-case size. The velocity solver is set to 5 iteration per time step for the different test-cases. 
2.  `system/fvSolution.fixedNORM`, with a fixed exit norm value of 10^{-4} for the pressure solver. 

***Post-process of the results***
To get the figures reported below, please use these [scripts](https://gitlab.com/amemmolo/png_tecplot)

Figures shows the residual for pressure and velocity for the two different options. 

* **HPC motorbike**