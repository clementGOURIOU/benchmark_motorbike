#!/usr/bin/env python3

### Script for calculating the profiles of the mean velocity UMean 
### and the Reynolds stress tensor R and write them in the 
### constant/boundaryData folder. These profiles are used by the 
### turbulentDigitalFilterInlet velocity boundary condition.
### HLRS, 2022-2023

# This application has been developed as part of the exaFOAM project
# https://www.exafoam.eu, which has received funding from
# the European High-Performance Computing Joint Undertaking Joint
# Undertaking (JU) under grant agreement No 956416. The JU receives
# support from the European Union's Horizon 2020 research and
# innovation programme and France, United Kingdom, Germany, Italy,
# Croatia, Spain, Greece, Portugal


import math
import re
import glob
import numpy as np
import os

runDir = "."

# Read parameters from initialConditions

print("Reading parameters from system/initialConditions")
filePath = "system/initialConditions"
with open(filePath) as f:
    for line in f:
        ULine = re.match(r'WindSpeed\W+(\d+(\.\d*)?)', line)
        if ULine:
            Uinitial = float(ULine.group(1))
        TILine = re.match(r'TurbIntensity\W+(\d+(\.\d*)?)', line)
        if TILine:
           TurbIntensity = float(TILine.group(1))
        WLine = re.match(r'WindDirMeteo\W+(\d+(\.\d*)?)', line)
        if WLine:
            WindDirectionMeteo = float(WLine.group(1))
print(f"Uinitial {Uinitial}")
print(f"TurbIntensity {TurbIntensity}")
print(f"WindDirectionMeteo {WindDirectionMeteo}")

#Direction in Standard Meteorological Terms is the parameters influencing the measured wind directions expressed in terms of azimuth angle from which winds come.
#Direction in Cartesian Coordinate system with the zero angle wind blowing towards the east.
WindDirectionCart = 270 - WindDirectionMeteo

ustar       = 0           # [m/s]
k_roughness = 0.41        # -
z_zero      = 0.05        # [m]


#ustar calculated to give Uinitial at 105 m
ustar = Uinitial * k_roughness / math.log(( 105 + z_zero) / z_zero)

points = np.array([5,15,25,35,45,55,65,75,85,95,102,105,115,125,135,145,155,165,175,185,195,250,300,350,400,450,500,1500])
Ux = np.empty([0],dtype=float)
Uy = np.empty([0],dtype=float)
Rxx = np.empty([0],dtype=float)
Ryy = np.empty([0],dtype=float)
Rzz = np.empty([0],dtype=float)

pointsBuffer = "(\n"
UBuffer = "(\n"
RBuffer = "(\n"

for point in points:
    #print(f"point {point}")
    pointsBuffer = pointsBuffer + f"( 0 0 {point} )\n"
    U = ustar / k_roughness * math.log(( point + z_zero) / z_zero) 
    Ux = U * math.cos(WindDirectionCart * math.pi / 180)
    Uy = U * math.sin(WindDirectionCart * math.pi / 180)
    Uz = 0
    UBuffer = UBuffer +  f"( {Ux} {Uy} {Uz} )\n"
    Rxx = (U * (TurbIntensity / 100) ) ** 2
    Ryy = (U * (TurbIntensity / 100) ) ** 2
    Rzz = (U * (TurbIntensity / 100) ) ** 2
    RBuffer = RBuffer + f"( {Rxx} 0 0 {Ryy} 0 {Rzz} )\n"
pointsBuffer = pointsBuffer + ")\n"
UBuffer = UBuffer + ")\n"
RBuffer = RBuffer + ")\n"
#print(pointsBuffer)
#print(UBuffer)
#print(RBuffer)

outFiles = ("constant/boundaryData/inlet/points","constant/boundaryData/inlet/0/UMean","constant/boundaryData/inlet/0/R")

if not os.path.exists('constant/boundaryData/inlet'): os.makedirs('constant/boundaryData/inlet')
if not os.path.exists('constant/boundaryData/inlet/0'): os.makedirs('constant/boundaryData/inlet/0')

for outFile in outFiles:
    with open(outFile,'w') as f:
      if outFile == "constant/boundaryData/inlet/points" : f.write(pointsBuffer)   
      if outFile == "constant/boundaryData/inlet/0/UMean" : f.write(UBuffer)
      if outFile == "constant/boundaryData/inlet/0/R" : f.write(RBuffer) 
      print(f"{outFile} been written")
