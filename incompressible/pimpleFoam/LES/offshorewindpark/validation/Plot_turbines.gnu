### Script for ploting the power of wind turbine B01 over time
### HLRS, 2022-2023

# This application has been developed as part of the exaFOAM project
# # https://www.exafoam.eu, which has received funding from
# the European High-Performance Computing Joint Undertaking Joint
# Undertaking (JU) under grant agreement No 956416. The JU receives
# support from the European Union's Horizon 2020 research and
# innovation programme and France, United Kingdom, Germany, Italy,
# Croatia, Spain, Greece, Portugal

set datafile separator ","
set xlabel "Time [s]"
set ylabel "Wind turbine power [W]"
plot "< cat ../run_314/postProcessing/turbines/0/turbineB01.csv" using 1:14 title "Wind angle 314",\
"< cat ../run_319/postProcessing/turbines/0/turbineB01.csv" using 1:14 title "Wind angle 319",\
"< cat ../run_324/postProcessing/turbines/0/turbineB01.csv" using 1:14 title "Wind angle 324",\
"< cat ../run_329/postProcessing/turbines/0/turbineB01.csv" using 1:14 title "Wind angle 329",\
"< cat ../run_334/postProcessing/turbines/0/turbineB01.csv" using 1:14 title "Wind angle 334",\
"< cat ../run_339/postProcessing/turbines/0/turbineB01.csv" using 1:14 title "Wind angle 339"
pause 3

#set term png             
#set output "Plot_turbines.png"
#replot

reread

