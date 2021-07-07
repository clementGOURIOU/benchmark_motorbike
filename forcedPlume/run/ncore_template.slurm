#!/bin/bash
# PBS -l walltime=12:00:00    
#  PBS -l nodes=1:ppn=16 #  provided as argument
# PBS -l pmem=               
# PBS -N forcedPlume
# PBS -q large # small

#SBATCH -t 12:00:00
# SBATCH -N 2           # provided as argument
# SBATCH --ntasks-per-node 28  # provided as argument
#SBATCH -J forcedPlume
#SBATCH -p small # small, large # optionally provided as argument

# MPI version must be the same (and same configuration) on the host and in the container (singularity image)
module purge
module load openFOAM-v1912

# DP for double precision, SPDP  for mixed precision
source $FOAM_BASHRC # WM_PRECISION_OPTION=SPDP

cd $PBS_O_WORKDIR

# check mpi-gcc  versions
echo " " >  log.versions 
echo "gcc build" >> log.versions
gcc --version >>  log.versions 
echo " " >>  log.versions 
echo "mpi build" >> log.versions
mpirun -version >>  log.versions 
echo $WM_PROJECT_VERSION >>  log.versions  2>&1 
echo $FOAM_APPBIN >>  log.versions   2>&1

# clean case (delete mesh)
./Allclean

# pre-processing in parallel
# for collated I/O: -collated
./Allrun.pre $ALLOPTIONS > log.preProcessing 2>&1 # provided as argument 

# Run app in standard way (no singularity)
# for collated I/O: -fileHandler collated
mpirun rhoPimpleFoam -parallel > log.rhoPimpleFoam
