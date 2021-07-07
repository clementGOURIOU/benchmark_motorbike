
GENERAL INFO:
=====================================================

-  run with openFoam: of5, of6,  of7, ofv1906, ofv1912   

-  case setup is controlled using only one dict "system/myDict". If you want to change something
   please edit "system/myDict" and then use "option=u" (see below). 

- store your personal run in a 'previous' directory since is ignored by git 

- ATTENTION: Do not edit "system/myDictDebug" or "system/myDictTest" or any other dict 
 

HOW TO RUN on Local machine:
====================================================

1- select precision (double scalar by default, see how to select precision)

2- enter the "run" directory and type one of the following

	-- on single core
	./Allclean; ./Allrun -option

	-- in parallel
	./Allclean; ./Allrun-parallel -option  

// option 
option=    (run default test with ~ 2e6 cells on 10 cores)
opiton=d   (to run a small debug test  )
opiton=u   (to run using myDict which can be edited by the  user)

 
HOW TO RUN on remote cluster:
===================================================

1- select precision (see how to select precision)

2- enter run dir and type

	./Allclean; ./Allrun.pre -option;   

3- prepare pbs/slurm scheduler script with the following command:

mpirun -np numberOfCores

4-  submit job to scheduler


HOW TO SELECT PRECISION
=====================================================

To check what compiled OF are you using there are 2 ways:

	- type "echo $FOAM_APPBIN " e  "echo $FOAM_LIBBIN "
         e.g: "/home/fede/OpenFOAM/OpenFOAM-v1912/platforms/linux64GccDPInt32Opt/bin"  
         (the inforrmation is all  given by "linux64GccDPInt32Opt" that is architecture 64 , Gcc compiler, Double Precision scalar,
          Int 32 for integer)

	- check the header of any log files of the applications (e.g. log.blockMesh) 


To set scalar precision there are 3 terminal commands to link to different compiled bin and lib of the same OF version:

	- "wmDP" for  double scalars (default setting)

	- "wmSPDP" for mixed scalars

        - "wmSP" for single precision

Let us note that mixed workflows are posssible, for instance using double for preprocessing and mixed for processing.


To be able to select scalar precision you  need to compile OF with that precision at least once, typing:

	- "cd $WM_PROJECT_DIR && wmDP && ./Allwmake" for double scalars
	- "cd $WM_PROJECT_DIR && wmSPDP && ./Allwmake" for mixed scalars
	- "cd $WM_PROJECT_DIR && wmSP && ./Allwmake" for single scalars

Label precision (of int) is also optional,  by default is single (32). In case, you need double int
you neeed to compile with the option "WM_LABEL_SIZE=64".



HOW TO SWITCH ON/OFF WRITE OUTPUT 
===================================================

- no output: in "system/myDict" set "writeTime" larger than "endTime" & comment also functions in controlDict to avoid probe sampliing and output
- with output: in "system/myDict" set "writeTime" smaller than "endTime"



POSTPROCESSING DESCRIPTION:
===================================================

plotProbe* scripts:  set terminal type according to machine gnuplot settings/version inside plotProbe* scripts 

how to plot all probes type:
          - ./plotProbe

how to plot all probes run with another run as reference:

          - edit script plotProbeRef  setting  path to the reference simulation and eventually keys for legend in plot

          - ./plotProbeRef

how to plot computational speed type:

          - ./plotComputationalSpeed

how to plot computational speed type with a reference simulation:
          
          - edit script plotComputationalSpeedRef  setting  path to the reference simulation and eventually keys for legend in plot

          - ./plotComputationalSpeedRef

how to plot  scaling test:
          1- enter scaling test dir

          2- fill file.dat with execution times

          3- ./plotScaling example.dat


Visualization with paraview:

          1- run paraview in the run dir

          2- in paraview select: file/load state file 
  
          3- select any of the state files in run/paraview/stateFiles/*.pvsm 


WORKFLOW FOR PARAMETER TESTS and SCALING TESTS TO CHECK PARALLEL EFFICIENCY
==========================================================================

How to run parameter/scaling (strong or weak) test:

          1- enter scalingTest directory and follow the instructions/tutorial in Alltest

          2- first time select  the 'example' multitest to become familiar with workflow usage.

          3- postprocess/monitor results of the multi test  (also when it is still running) with;

                 ./Allclen,post; ./Alltest.post 

          3- check log.*, test.dat,  *.png files

How to run your own strong and weak scaling workflow:

          1- edit "run/system/infoDict" with your parameters for strong/weak scaling 

          2-  run "foamDictionary system/infoDict" and check values
               for optimal choice of mesh size and computational resources 
         
          3-  edit scalingTest/Alltest script adapting strong/weak scaling subsections parameters

          4-  ./Allclean.post; ./Alltest.post to check results

HOW TO SOLVE POSSIBLE PROBLEMS:
=====================================================

-  plotProbe* scripts:  set terminal type according to machine gnuplot settings/version 

-  plotProbe* scripts may sometimes give segmentation fault just run one more time 


TODO LIST:
===================================================


- speed up mesh generation and decomposition:

 ->  this for now has been solved with refineMesh and it is working fine. For future versions check for parallel blockMesh
developments. For more complex mesh use snappyHexMesh  which works also in parallel 

link:
https://openfoamwiki.net/index.php/SnappyHexMesh
https://www.cfd-online.com/Forums/openfoam/84546-blockmesh-parallel-mesh-generation.html

