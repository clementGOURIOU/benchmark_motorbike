#!/bin/bash
# PBS -l walltime=12:00:00    
# PBS -l nodes=02:ppn=16
# PBS -l pmem=               
# PBS -N forcedPlume
# PBS -q small # small, large, full, default

#SBATCH -t 12:00:00
#SBATCH -N 2
#SBATCH --ntasks-per-node 28
#SBATCH -J forcedPlume
#SBATCH -p small # small, large


# remove previous run files
rm forcedPlume.*

# MPI version must be the same (and same configuration) on the host and in the container (singularity image)
module purge
module load openFOAM-v1912

# DP for double precision, SPDP  for mixed precision
source $FOAM_BASHRC #  WM_PRECISION_OPTION=SPDP

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
./Allrun.pre -r 3 -p 32 > log.preProcessing 2>&1  

# Run app in standard way (no singularity)
# for collated I/O: -fileHandler collated
mpirun rhoPimpleFoam -parallel > log.rhoPimpleFoam
