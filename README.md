# HPC

**OpenFOAM HPC Benchmark suite**

The respository is intended to be a shared repository with relevant data-sets and information created in order to:

*  provide user guides and initial scripts to set-up and run different data-sets on different HPC architectures
*  provide to the community an homogeneous term of reference to compare different hardware architectures, software environments, configurations, etc. 
*  define a common set of metrics/KPI (Key Performance Indicators) to measure performances

*  **3-D Lid Driven cavity flow**

Code repository for the High Performance Computing Technical Committee

The  first test-case chosen is the a 3-D version of the [Lid-driven cavity flow tutorial](https://www.openfoam.com/documentation/tutorial-guide/tutorialse2.php). 

This test-case has simple geometry and boundary conditions, involving transient, isothermal, incompressible laminar flow in a three-dimensional box domain. The *icoFoam* solver is used in this test-case

It is intended to be a stress test for the linear algebra solver, being most of the time spent in the pressure equation

* **HPC motorbike**