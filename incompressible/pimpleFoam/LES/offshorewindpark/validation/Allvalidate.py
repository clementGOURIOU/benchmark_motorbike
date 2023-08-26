#!/usr/bin/env python3

### Script for plotting the comparison between experiments and the 
### simulations of the relative power of a row of wind turbines 
### HLRS, 2022-2023

# This application has been developed as part of the exaFOAM project
# https://www.exafoam.eu, which has received funding from
# the European High-Performance Computing Joint Undertaking Joint
# Undertaking (JU) under grant agreement No 956416. The JU receives
# support from the European Union's Horizon 2020 research and
# innovation programme and France, United Kingdom, Germany, Italy,
# Croatia, Spain, Greece, Portugal

import numpy as np
import matplotlib
from matplotlib import pyplot


runDir = "."
startAveraging = 1000 

windAnglesNum = np.array([314,319,324,329,334,339])
windTurbines = np.array(["B07","B06","B05","B04","B03","B02","B01"])
expData = np.array([1, 0.783274007, 0.769118929, 0.787998966, 0.788964953, 0.726927018, 0.745211981]) # Pn/P1 from Nygaard et al. 2020
weights = np.array([0.1879, 0.1391, 0.1021, 0.1050, 0.2115, 0.2544]) # from Nygaard, private communication 

powerArray = np.empty([0],dtype=float)
avePower = np.zeros(windTurbines.size)
simData = np.zeros(windTurbines.size)

# convert float array into str array
windAngles = np.array(windAnglesNum, dtype=str)

for windAngle in windAngles:
    tempTime = np.empty([0],dtype=float)
    for windTurbine in windTurbines:
        timeStepsCounter = 0
        tempPower = 0
        file = f"{runDir}/../run_{windAngle}/postProcessing/turbines/0/turbine{windTurbine}.csv"
        with open(file) as f:
            print(file)
            for line in f:
                temp = line.split(",")
                if temp[0] != "time":
                    if float(temp[0]) > startAveraging:
                        tempPower += float(temp[13])
                        timeStepsCounter += 1
        powerArray = np.append(powerArray,tempPower/timeStepsCounter)

# create results array and csv file
with open("simulationresults.csv",'w') as f:
    f.write("Wind Angle, Wind Turbine, Average power [W]\n")
    for x, windAngle in enumerate(windAngles):
        for y, windTurbine in enumerate(windTurbines):
            f.write(f"{windAngle}, {windTurbine}, {powerArray[y + x * windTurbines.size]}\n")
            avePower[y] += powerArray[y + x * windTurbines.size] * weights[x]
print(avePower)

# calculate the realative wind turbine power
for y, windTurbine in enumerate(windTurbines):
    simData[y] = avePower[y] / avePower[0]
print(simData)

# plot the histogram and pdf
fig,ax = pyplot.subplots(figsize=(9,5))
ax.set_xlabel('Turbine number', fontsize='x-large')
ax.set_ylabel('Pn / P1', fontsize='x-large')
ax.set_title('Westermost Rough - Relative power along a row of turbines', fontsize='x-large')
ax.scatter(windTurbines, expData, marker='o', label='Nygaard et al. 2020')
ax.plot(windTurbines, simData, '-k', label='Simulation results')
ax.tick_params(axis='x', labelsize='large')
ax.tick_params(axis='y', labelsize='large')
legend = ax.legend(loc='upper right', shadow=True, fontsize='x-large')
fig.savefig("simulationresults.png", dpi=200)
pyplot.show()

