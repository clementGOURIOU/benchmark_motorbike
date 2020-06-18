#!/bin/bash
##SBATCH --error job.%j.err
#SBATCH --nodes=8
#SBATCH --ntasks-per-node=36
#SBATCH --exclusive
#SBATCH --threads-per-core=1
#SBATCH --time=30:00
#SBATCH --account=<your_account>
#SBATCH --partition=<your_partition>  # partition to be used
module purge

#load your module /env with openfoam 
module load autoload openfoam+/v1906/Icc19OptBDW

#load your module /env with petsc
module load autoload petsc/3.12.1+l1--hypre--2.17.0--intelmpi--2019--binary

#set-up for the selected PETSC include/libraries
source /cineca/prod/build/applications/openfoam+/PATCHES/site-Icc/etc/config.sh/petsc

# in that case the library is installed in FOAM_SITE_LIBBIN defined below:
export FOAM_SITE_LIBBIN=$WORK/lib
export FOAM_SITE_APPBIN=$WORK/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$FOAM_SITE_LIBBIN

solver=icoFoam
cat system/fvSolution 			>> out.log.$SLURM_NTASKS.$SLURM_JOBID
srun -n $SLURM_NTASKS $solver -parallel >> out.log.$SLURM_NTASKS.$SLURM_JOBID
