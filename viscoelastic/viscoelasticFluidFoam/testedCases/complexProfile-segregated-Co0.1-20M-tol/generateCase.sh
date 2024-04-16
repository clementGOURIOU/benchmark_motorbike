#!/bin/sh

###==================================================================
### User input parameters
###==================================================================
case2gen="complexProfile"   ## valid: complexProfile, profileExtrusion
                              ## and lidDrivenCavity
maxCo=0.1                     ## any value defined by user
solver="segregatedViscoelasticFoam" ## valid: 
                            ## segregatedViscoelasticFoam (segregated)
                            ## semiCoupledViscoelasticFoam (semi-coupled)
                            ## coupledViscoelasticFoam (fully-coupled)
mesh="20M"                  ## valid: 
                            ## profileExtrusion: 1M  (1 million) or
                            ##                   20M (20 millions)
                            ## complexProfile:   20M (20 millions) or
                            ##                   40M (40 millions)
                            ## profileExtrusion: 1M  (1 million) or
                            ##                   4M (4 millions) or
                            ##                   16M (16 millions)
control="tol"               ## valid: tol (tolerance) 
                            ## or iter (iterations)
nProcs=1536                    ## any integer value defined by user
## tolerances (for coupled solutions u tolerances are not used)
uTol="1e-10"
uRelTol=0.001 
pTol="1e-10"
pRelTol=0.001 
tauTol="1e-10"
tauRelTol=0.001 
#iterations (if control="iter" just MinIter value is used)
pMinIter=0
pMaxIter=10000
uMinIter=0
uMaxIter=10000
tauMinIter=0
tauMaxIter=10000

###==================================================================
### Default parameters
###==================================================================
uRelax=0.3          # velocity relaxation
solver_cut=`echo $solver | cut -c1-10`
folder="$case2gen-$solver_cut-Co$maxCo-$mesh-$control"

exitCase () {
    rm -rf "../$1"
    exit 0
}
###==================================================================
### Definitions dependent by the solver
###==================================================================
if [ "$solver" = "semiCoupledViscoelasticFoam" ]; then
    model="multiMode"
    entryUp="Up"
    if [ "$case2gen" = "profileExtrusion" ] || 
        [ "$case2gen" = "lidDrivenCavity" ]; then
        uRelax=0.85
    fi
elif [ "$solver" = "coupledViscoelasticFoam" ]; then
    model="multiModeCoupled;\n\tcoupledMode\tM6"
    if [ "$case2gen" = "complexProfile" ]; then
        model="multiModeCoupled;\n\tcoupledMode\tM5"
    fi
    entryUp="UpTau"
    if [ "$case2gen" = "profileExtrusion" ] || 
        [ "$case2gen" = "lidDrivenCavity" ]; then
        uRelax=0.85
    fi
elif [ "$solver" = "segregatedViscoelasticFoam" ]; then
    model="multiMode"
    entryUp="pU"
else
    echo "Invalid solver"
    exitCase $folder
fi

###==================================================================
### Case generation
###==================================================================

rm -rf $folder
cp -r $case2gen $folder
cd $folder

sed -i "s/&model/$model/g" constant/viscoelasticProperties

sed -i "s/&nProcs/$nProcs/g" system/decomposeParDict
sed -i "s/&nProcs/$nProcs/g" Allrun

sed -i "s/&maxCo/$maxCo/g" system/controlDict
sed -i "s/&solver/$solver/g" system/controlDict
sed -i "s/&UpSolver/$entryUp/g" system/fvSolution
sed -i "s/&uRelax/$uRelax/g" system/fvSolution

## solution parameters

## absolute tolerance
sed -i "s/&pTol/$pTol/g" system/entries/$entryUp
sed -i "s/&uTol/$uTol/g" system/entries/$entryUp
sed -i "s/&tauTol/$tauTol/g" system/fvSolution
## relative tolerance
sed -i "s/&pRelTol/$pRelTol/g" system/entries/$entryUp
sed -i "s/&uRelTol/$uRelTol/g" system/entries/$entryUp
sed -i "s/&tauRelTol/$tauRelTol/g" system/fvSolution
## minimum number of iterations
sed -i "s/&pMinIter/$pMinIter/g" system/entries/$entryUp
sed -i "s/&uMinIter/$uMinIter/g" system/entries/$entryUp
sed -i "s/&tauMinIter/$tauMinIter/g" system/fvSolution
## maximum number of iterations
if [ "$control" = "tol" ]; then
    sed -i "s/&pMaxIter/$pMaxIter/g" system/entries/$entryUp
    sed -i "s/&uMaxIter/$uMaxIter/g" system/entries/$entryUp
    sed -i "s/&tauMaxIter/$tauMaxIter/g" system/fvSolution
elif [ "$control" = "iter" ]; then
    sed -i "s/&pMaxIter/$pMinIter/g" system/entries/$entryUp
    sed -i "s/&uMaxIter/$uMinIter/g" system/entries/$entryUp
    sed -i "s/&tauMaxIter/$tauMinIter/g" system/fvSolution
else
    echo "Invalid control type"
    exitCase $folder
fi

## mesh parameters
if [ "$case2gen" = "profileExtrusion" ]; then
    pzCellSize=0
    if [ "$mesh" = "1M" ]; then
        maxCellSize=0.155
        pzCellSize=0.12
    elif [ "$mesh" = "20M" ]; then
        maxCellSize=0.057
        pzCellSize=0.045
    else
        echo "Invalid mesh option for $case2gen"
        exitCase $folder
    fi
elif [ "$case2gen" = "complexProfile" ]; then
    if [ "$mesh" = "20M" ]; then
        maxCellSize=0.38
        ppzCellSize=0.3
        pzCellSize=0.15
    elif [ "$mesh" = "40M" ]; then
        maxCellSize=0.30
        ppzCellSize=0.21
        pzCellSize=0.12
    else
        echo "Invalid mesh option for $case2gen"
        exitCase $folder
    fi
elif [ "$case2gen" = "lidDrivenCavity" ]; then
    if [ "$mesh" = "1M" ]; then
        nCells=1000
    elif [ "$mesh" = "4M" ]; then
        nCells=2000
    elif [ "$mesh" = "16M" ]; then
        nCells=4000
    else
        echo "Invalid mesh option for $case2gen"
        exitCase $folder
    fi
    sed -i "s/&nCells/$nCells $nCells/g" constant/polyMesh/blockMeshDict
else
    echo "Invalid case to generate"
    exitCase $folder
fi

if [ "$case2gen" != "lidDrivenCavity" ]; then
    sed -i "s/&maxCellSize/$maxCellSize/g" system/meshDict
    sed -i "s/&ppzCellSize/$ppzCellSize/g" system/meshDict
    sed -i "s/&pzCellSize/$pzCellSize/g" system/meshDict
fi

if [ "$solver" != "segregatedViscoelasticFoam" ]; then
    sed -i '/echo \"Running changeDictionary application\"/d' Allrun.pre
    sed -i '/runApplication changeDictionary/d' Allrun.pre
fi

# Printing the information inside the case folder
printf "maxCo:$maxCo\nsolver:$solver\nmesh:$mesh\nsolverControl:$control\nnProcs:$nProcs" >> info.txt

rm -r 0/ constant/ system/ src/ figures/ All* total.* README.md residuals.py
cp ../generateCase.sh .
mv ../$folder ../testedCases/$folder