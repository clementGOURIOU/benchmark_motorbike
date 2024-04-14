# Authors

Roberto Da Via' (Scientifc Researcher @ ENEA, Bologna) and Raffaele Ponzini (CFD methodology engineer @ CINECA)  

# OpenFoam used version:
v1912

# rationale
Three different meshes are proposed, with increasing number of cells. The number of mesh
cells is increased not through a mesh refinement operation, but by increasing the size of
the domain.
Meshes are built as follows:
- S mesh is built using the motorbike tutorial setup, with the following characteristics:
    * the background mesh is finer than the one used in the tutorial: generated cells have
      a 0.4 meter side, instead of 1 meter
    * the snappyHexMeshDict is the same as in the tutorial
- M and L are obtained using the mirroMesh functionality starting from the S mesh so that
  M is 2xS and L is 2xM
- Mesh calculation is performed using snappyHexMesh in parallel, with 16 tasks

# how to build the S,M,L meshes
- load you OpenFOAM env
- get into the desired mesh dir
- launch ./AllmeshX script, with X=S,M,L

# how to run the case
- the cases can be run in the same folder where the meshes have been computed
- edit the decomposeParDict to change the number of tasks
- launch ./Allrun

# info on S,M,L meshes
- S: 8.5 mln cells
- M: 17 mln cells
- L: 34 mln cells

# notes
- consider an average execution time of about 35 minutes using 16 cores fro S mesh.
- M and L meshes will be done in few more minutes thanks to the mirroMesh function.
- if you like to activate the checkMesh option please consider more time as overall execution time
- Other larger meshes can be built using the same approach


