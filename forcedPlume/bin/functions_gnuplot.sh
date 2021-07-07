#!/bin/bash

# check this link: http://gnuplot.sourceforge.net/demo_5.0/layout.html
# ATTENTION: when performin operations on data remember to prevent bash
# variable expansion using backlash e.g: plot '$1' using 1:(\$2*2) with lines
#
# Improve the script following this link
# http://www1.udel.edu/it/research/training/bashio/bashio.html#echo
#
# Get keys from header
# keys=$(grep -E '^#' "$1" | tail -1)
# n_cols=$(tail -1 "$1" | awk '{ print NF }')
# echo $keys
# echo $n_cols
# echo $1


function check {

[ "$PERSIST" == "-p" ] && echo " WARNING: persist option '-p' working only with gnuplot terminal 'wxt'"

echo "check"
# [ -f "$imageFile" ] && rm "$imageFile"

}

function gnuCommands {

# terminal settings
if [ "$terminalSize" ]; then
   echo -n "\
   set terminal "$gnuplotTerminal" size "$terminalSize"
"
fi

#  output image to file
if [ $imageFile ]; then
   echo -n "\
   set output \"$imageFile\"
"
fi

# plot settings
# [ "$figTitle" ] && echo "set figTitle \"$figTitle\" "
if [ "$plotType" ]; then
   echo -n "\
   set tmargin 1.5
   set bmargin 0.5
   set lmargin 10
   set rmargin 4
   set xtics font \",9\" nomirror format ''
   set ytics font \",9\"
   # set xlabel font ",$labelsize"
   set ylabel offset 2,0,0   # ",$labelSize"
   # unset title
   set autoscale xfix
   set border 2
   set key left top font \",8\"
   set multiplot layout $(( nProbes + 1 )),1 title \"$figTitle\" font \",$titleSize\"
"
fi

# make plot
if [ "$plotType" ]; then
  
   for (( iProbe=1; iProbe<=nProbes; iProbe++ ))
   do
       iProbeZero=$(( iProbe - 1 ))
       
       [ $iProbe -eq $nProbes ] && echo "set xtics format $xTicFormat"
       [ "${yTics[$iProbeZero]}" ] && echo  "set ytics ${yTics[$iProbeZero]}"
       [ $iProbe -eq $nProbes ] && echo "set xlabel \"$xLabel\" "
       [ "${yLabel[$iProbeZero]}" ] && echo "set ylabel \"${yLabel[$iProbeZero]}\" " 
       [ "${legend[$iProbeZero]}" ] && key="${legend[$iProbeZero]}"  || key="Probe $iProbe"
        
       [ "${dataFile[$iProbeZero]}" ] && iDataFile="${dataFile[$iProbeZero]}" || iDataFile="$dataFile"
       [ "${columnOrder[$iProbeZero]}" ] && iColumn=${columnOrder[iProbeZero]} || iColumn=$(( iProbe + 1))

       echo -n "plot \"$iDataFile\" using 1:$iColumn  with lines lt 3 title \"$key $localKey\" "
       [ "$referenceDir" ] && echo -n ", \"$referenceDir/$iDataFile\" using 1:$iColumn with linespoints lt 3 pi -15 title \"$key $refKey\" "
       echo  " "
   done
fi
}

function printGnuCommands {
  gnuCommands
}

function makeFig {
  gnuCommands | gnuplot $PERSIST
}
