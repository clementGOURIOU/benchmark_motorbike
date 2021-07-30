# Motivation
## Why cavity?
Key reasons for using the lid driven cavity (referred to as "cavity" in the following) as a microbenchmark are
* Cavity is one of the most basic and popular cases in OpenFOAM and for the validation in CFD
* Results for scaling are available because the present setup is based on the white paper: 
	“PETSc4FOAM : A Library to plug-in PETSc into the OpenFOAM Framework”, Simone Bnà, Ivan Spisso, Mark Olesen, Giacomo Rossi

## Standard case
The standard cavity case setup does not meet the microbenchmark requirements because of the following issues.
* The case is not stationary. It deals with the start-up of the flow meaning that the flow starts to develop from 0m/s at t=0s until it reaches a stationary state. The stationary state is reached after 1s, which corresponds to the lid 10 times passing by, according to the white paper mentioned above. For the smallest mesh with 1 Mio cells (1M) with the Courant number 1 (Co=1) this leads to 1000 time steps, which is not feasible for a microbenchmark.
* The iteration number of the linear solver per time step n_iter differs for every time step if tolerance is setup as the convergence criterion. The iteration number also fluctuates significantly, whereby on average it decreases during the run and reaches a certain plateau at some point (for 1M case after 0.34s).
* The iteration number n_iter is also dependent on the mesh size and the decomposition.

## Adjusting to a microbenchmark
Considering the above arguments the case is altered. It has to be adapted to the profiling requirements meaning that a compromise between the fast execution, representativeness, repeatability and simple handling needs to be achieved:
* Fast execution: A single run consists of 15 time steps.
* Repeatability: During the profiling run the iteration number of the linear solver is fixed.
* Simple handling:
	* Start at t=0s, no restart file.
	*  The iteration number is the same for a mesh of a certain size independent of the decomposition.
* Representativeness: The present cavity case aims to reproduce the solver behavior from t=0s up to the point where the iteration number reaches the plateau mentioned above. This time point differs for different mesh sizes, which is accounted for in the provided benchmark. In this way, the case is representative for the initial transient of the cavity case.


# General overview
Important characteristics of the case are summarized here.
* The case is 3D. The original 2D case is extruded up to a cube, the front and the back boundaries are walls.
* The Reynolds number is 10.
* The momentum predictor is switched off since it is counterproductive for low Reynolds number flows when the PISO algorithm is used.
* The cases are setup to run at Co=1 (CFL number). If mesh size is changed, adjust the time step in 'controlDict' to keep Co=1.
* The cases are setup to run for 15 time steps, which produces meaningful statistics for the wall clock time (see section "Methodology" for details).
* Three cases are provided. These differ in the time step and mesh size (the name provides the number of cells, e.g. "8M" stands for 8 Mio cells).
* Each case includes two setups:
	* *fixedTol* : the tolerance of the linear solver is fixed
	* *fixedIter* : the iteration number of the linear solver is fixed	
* Only *fixedIter* setup should be used for profiling.
* `renumberMesh` utility is used to reduce the bandwidth of the matrix.


# Instructions
One of the major issues of the cavity test case is the fact that the  iteration number of the linear solver grows with increasing mesh size if the linear solver tolerance is set. Thus, the two following approaches are possible.

## Mesh size unchanged
If one of the provided cases is used without changes, only *fixedIter* setup is utilized. Simply run the Allrun script. For example:
1. `cd 1M/fixedIter`
2. `./Allrun`

## Mesh size changed
If the mesh size is changed an additional run with *fixedTol* needs to be performed to determine an iteration number which is representative for the case. The procedure is the following.
1. Adjust the time step in 'controlDict' of bothe setups *fixedTol* and *fixedIter* to keep Co=1.
2. Run with the fixed tolerance for p: 1e-5 (*fixedTol*). The solver will run for 15 time steps. A python script analyzes the solver log file and computes the extrapolated representative mean iteration number `iter_run` needed for the next step, which is saved in 'log.python3'. E.g. for 1M case:
	1. `cd 1M/fixedTol`
	2. `./Allrun`
	3. `cat log.python3`
3. Run with fixed number of iterations (*fixedIter*). Only this setup should be used for the profiling.
	1. Go to the 'fixedIter' directory of the current case
	2. Adjust `maxIter` in the 'system/fvSolution' to the value `iter_run` read from the 'log.python3' of the *fixedTol* setup
	3. `./Allrun`

## Remark
Besides the mesh size the iteration number also depends on the number of partitions the case is decomposed into (it grows with the increasing partition number) and on the decomposition method. In our experiments, e.g. for 64M case, the iteration number with 1024 partitions was 50% higher than with 32 partitions. The `maxIter` of the *fixedIter* setups of 1M and 8M cases are setup according to the *fixedTol* runs with 32 partitions and in case of 64M with 1024 partitions. In all cases scotch was used as the decomposition method.
The general recommendation is to follow the procedure above. Then, for a strong scaling analysis the `maxIter` stays constant, which simplifies
Optionally, adjusting `maxIter` for every run (when the decomposition method or number of partitions alters) accordingly to the 2nd approach described above may be considered.


# Methodology
This section describes how the cases were setup. It serves for informative purposes only and is not a part of the microbenchmark.
* The three cases were first run up to t=0.5s. For each case the following procedure was performed.
	* Find out averaged initial residual $r_c$ at the end of the run: [0.4s, 0.5s]. 
	* The initial residual reaches a plateau (not decreasing anymore) at some point before t=0.4s. Find out this point in time by finding at which time $1.2 r_c$ of the initial residual is reached (e.g. for the 1M case $t_c$=0.34s). Put differently, it is assumed that the 
	* Calculate the averaged iteration number $iter_{run}$ from $t$ up to $t_c$.
	* Calculate the averaged iteration number $iter_{start}$ from the first *15* time steps.
	* Build a factor $a_{case}=iter_{start}/iter_{run}$.
* An average factor $a$ was build based on the three cases. It is used for the extrapolation from *fixedTol* setup to *fixedIter* setup giving a mean iteration number, which is representative for the whole run of the initial transient. In this way there is no need to run a case for the complete duration of 0.5s.
* Run the cases with the fixed iteration number $iter_{run}$ for 1000 time steps.
	* Analyze the wall clock time per time step $dt_{wc}$. 
	* Compute its average $dt_{wcAv}$ and standard deviation $dt_{wcStd}$
	* Compute the sample size of time steps needed for 95% confidence level with 1% error and given $dt_{wcAv}$, $dt_{wcStd}$ according to this formula:
	$n_{dt} = 1.96^2*dt_{wcStd}^2/(dt_{wcAv}*0.01)^2$
* Several runs to evaluate $n_{dt}$ on both a workstation and on a HPC were performed. The highest $n_{dt}$ was found to be 13. Finally, it is set to 15 to be aligned with the *fixedTol* setup.

	
# Remarks
* Fixing the iteration number per time step n_iter is not based on a fixed tolerance run up to the stationary state (t=1s), which may be argued to be the actual representative case. During the run with fixed tolerance, n_iter decreases and the average value n_iterAv of the complete run would be relatively low. If the same case is run with a fixed iteration number of n_iterAv, which is too low to achieve the needed convergence, the run might end in a failure.
* CFL number of 1 is too high for the cases to depict the start-up process of the flow correctly, which may be seen when mean Co of two cases with different mesh sizes is analyzed. Co=1 is chosen because this is closer to the industrial setups.
