#!/bin/sh
cd "${0%/*}" || exit                                # Run from this directory
#------------------------------------------------------------------------------
# Script
#     createGraphs
#
# Description
#     Creates .png graphs of OpenFOAM results vs experiment for the Steckler
#       case, exp. 14
#     Nothing to change except the log file name if other than
#       log.fireFoam from current execution direcotry
#
#------------------------------------------------------------------------------
cd ${0%/*} || exit 1    # run from this directory

. $WM_PROJECT_DIR/bin/tools/RunFunctions    # Tutorial run functions

#set -x


plotTvTimeDoor() {
    graphNameTempTime="temp_probe_door.png"
    echo "Ploting temperature probe at the door to $graphNameTempTime"
    gnuplot<<PLT_TTIME
    set terminal pngcairo font "helvetica,20" size 1000, 1000
    ## set xrange [0:61]
    ##  set yrange [290:360]
    set grid
    set key top right
    set xlabel "Time [s]"
    set ylabel "Temp [K]"
    set title "Temperature probes in time - Door"
    set output "$graphNameTempTime"

    set lmargin 10
    set rmargin 1.5
    set bmargin 3.2

    plot \
      "postProcessing/probeDoors/0/T" u 1:2 t "p1" w l lw 2 lc rgb "black", \
       "postProcessing/probeDoors/0/T" u 1:3 t "p2" w l lw 2 lc rgb "blue", \
       "postProcessing/probeDoors/0/T" u 1:4 t "p3" w l lw 2 lc rgb "red", \
       "postProcessing/probeDoors/0/T" u 1:5 t "p4" w l lw 2 lc rgb "green"


PLT_TTIME
}

plotTvTimeBurner() {
    graphNameTempTime="temp_probe_burner.png"
    echo "Ploting temperature probe above the burner to $graphNameTempTime"
    gnuplot<<PLT_TTIME
    set terminal pngcairo font "helvetica,20" size 1000, 1000
    ## set xrange [0:61]
    ## set yrange [290:2000]
    set grid
    set key top right
    set xlabel "Time [s]"
    set ylabel "Temp [K]"
    set title "Temperature probes in time - Burner"
    set output "$graphNameTempTime"

    set lmargin 10
    set rmargin 1.5
    set bmargin 3.2

    plot \
      "postProcessing/puTprobes/0/T" u 1:2 t "p1" w l lw 2 lc rgb "black", \
       "postProcessing/puTprobes/0/T" u 1:3 t "p2" w l lw 2 lc rgb "blue", \
       "postProcessing/puTprobes/0/T" u 1:4 t "p3" w l lw 2 lc rgb "red", \
       "postProcessing/puTprobes/0/T" u 1:5 t "p4" w l lw 2 lc rgb "green"


PLT_TTIME
}

plotFluxAcrossDoors() {
    graphNameTempTimeB="fluxAcrossDoors.png"
    echo "Ploting flux across the door to $graphNameTempTimeB"
    gnuplot<<PLT_TTIME
    set terminal pngcairo font "helvetica,20" size 1000, 1000
    ## set xrange [10:80]
    ##  set yrange [290:400]
    set grid
    set key top right
    set xlabel "Time [s]"
    set ylabel "Flux [kg/s]"
    set title "Flux history across door"
    set output "$graphNameTempTimeB"

    set lmargin 10
    set rmargin 1.5
    set bmargin 3.2

    plot \
      "postProcessing/fluxSummaryDoors/0/doorOpening.dat" u 1:2 t "FluxIn" w l lw 2 lc rgb "red", \
       "postProcessing/fluxSummaryDoors/0/doorOpening.dat" u 1:3 t "FluxOut" w l lw 2 lc rgb "blue", 

PLT_TTIME
}



###############  validation plot Temp  #######
plotValidTdoor() {
    graphValidTdoor="temp_ValidTdoor.png"
    echo "Ploting temperature profile at the door to $graphValidTdoor"
    gnuplot<<PLT_TDOOR
    set terminal pngcairo font "helvetica,20" size 1000, 1000
    ## set xrange [0:61]
    ## set yrange [290:400]
    set grid
    set key top right
    set xlabel "Temperature [K]"
    set ylabel "height [m]"
    set title "Average (window 20s) Temperature door profile"
    set output "$graphValidTdoor"

    set lmargin 10
    set rmargin 1.5
    set bmargin 3.2
    set key left top

    plot \
       "postProcessing/sampleDict/80/door_TMean_UMean.xy" u 2:1 t "CFD" w l lw 2 lc rgb "green", \
       "validation/experimental14_temperatureDoors" u 2:1 t "Exp #14 (no spray)" w p lt 4 ps 4 lc rgb "red", \
       "postProcessing/sampleDict/120/door_TMean_UMean.xy" u 2:1 t "CFD with spray" w l lw 2 lc rgb "blue"
       
PLT_TDOOR
}


plotValidUdoor() {
    graphValidUdoor="temp_ValidUdoor.png"
    echo "Ploting velocity profile at the door to $graphValidUdoor"
    gnuplot<<PLT_TDOOR
    set terminal pngcairo font "helvetica,20" size 1000, 1000
    set xrange [-1:2.5]
    set yrange [0:1.8]
    set grid
    set key top right
    set xlabel "Velocity [m/s]"
    set ylabel "height [m]"
    set title "Average (window 20s) Velocity door profile"
    set output "$graphValidUdoor"

    set lmargin 10
    set rmargin 1.5
    set bmargin 3.2
    set key left top

    plot \
       "postProcessing/sampleDict/80/door_TMean_UMean.xy" u 3:1 t "CFD" w l lw 2 lc rgb "green", \
       "validation/experimental14_velocityDoors" u 2:1 t "Exp #14 (no spray)" w p lt 4 ps 4 lc rgb "red", \
       "postProcessing/sampleDict/120/door_TMean_UMean.xy" u 3:1 t "CFD with spray" w l lw 2 lc rgb "blue"

PLT_TDOOR
}

plotMassInSystem() {
    graphSysMass="massInSystem.png"
    gnuplot<<PLT_M
    set terminal pngcairo font "helvetica,20" size 1000, 1000
    set title "Mass in system"
    set ylabel 'Mass [kg]'
    set xlabel 'Time [s]'
    set grid
    set output "$graphSysMass"

    plot "massSystem.txt" u 1:2 t "mass" w l lw 2 lc rgb "black"
PLT_M
}

prepare_plot_data() {
    cat ./log.fireFoam | grep -e "\<Time = " -e "Current mass in system" > massSystem.txt
    sed -i -e '/Time =/N;s/\n    Current mass in system          =/ /' massSystem.txt
    sed -i 's/Time = //g' massSystem.txt
}

#------------------------------------------------------------------------------

echo "Creating time probe graphs"

    # Create validation plots

    # Test if gnuplot exists on the system
    command -v gnuplot >/dev/null 2>&1 || {
        echo "gnuplot not found - skipping graph creation" 1>&2
        exit 1
    }
    
    plotTvTimeDoor

    plotTvTimeBurner
	
    plotFluxAcrossDoors
	
echo "Create validation graphs"

    plotValidTdoor
    plotValidUdoor

echo "Creating mass in system graph"
    prepare_plot_data
    plotMassInSystem
