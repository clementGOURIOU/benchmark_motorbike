# HPC

Code repository for the High Performance Computing Technical Committee

**OpenFOAM HPC Benchmark suite**

The respository is intended to be a shared repository with relevant data-sets and information created in order to:

*  provide user guides and initial scripts to set-up and run different data-sets on different HPC architectures
*  provide to the community an homogeneous term of reference to compare different hardware architectures, software environments, configurations, etc. 
*  define a common set of metrics/KPI (Key Performance Indicators) to measure performances

*  **3-D Lid Driven cavity flow**


The  first test-case chosen is the a 3-D version of the [Lid-driven cavity flow tutorial](https://www.openfoam.com/documentation/tutorial-guide/tutorialse2.php). 

This test-case has simple geometry and boundary conditions, involving transient, isothermal, incompressible laminar flow in a three-dimensional box domain. The *icoFoam* solver is used in such test-case.

It is intended to be a stress test for the linear algebra solver, being most of the time spent in the pressure equation.

The iterative method can be run using two different converge criterion:   


1.   FIXEDITER: In that case the computational load is fixed, when running with the given solver. This case is useful for comparing different hardware configurations
by keeping constant the computational load.  
2.   FIXEDNORM: in that case the the exit norm is fixed.

The two different options are selected by choosing one of the two configurations files: 

1.  `system/fvSolution.fixedITER` in that cases it has been fixed a constat number of iteration for the pressure solver equal to 250, and for the velocity solver equal to 5. 
2.  `system/fvSolution.fixedNORM` in that case it has been fixed an exit norm value of 10^{-4} for the pressure solver. 

Figures shows the 

* **HPC motorbike**