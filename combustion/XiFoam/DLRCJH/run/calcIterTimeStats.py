"""
/*---------------------------------------------------------------------------*\
  =========                 |
  \\      /  F ield         | foam-extend: Open Source CFD
   \\    /   O peration     | Version:     4.1
    \\  /    A nd           | Web:         http://www.foam-extend.org
     \\/     M anipulation  | For copyright notice see file Copyright
-------------------------------------------------------------------------------
License
    This file is part of foam-extend.

    foam-extend is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the
    Free Software Foundation, either version 3 of the License, or (at your
    option) any later version.

    foam-extend is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with foam-extend.  If not, see <http://www.gnu.org/licenses/>.

Description
    Analyze log files in order to determine iteration numbers of linear solvers
    for a run with fixed iterations. Compute mean and standard deviation of the
    wall clock time per time step.
    Provide a suggestion for the number of time steps for resonable statistics
    (this is expected to be used on a log file from a fixed iterations run).

    Usage: 
    python3 calcIterTimeStats.py <logFile>

Author
    Sergey Lesnik, Wikki GmbH, 2022

\*---------------------------------------------------------------------------*/
"""

import os
import subprocess
import sys
import re
import numpy as np
import pandas as pd
from argparse import ArgumentParser
import pprint


def main():
    # Variable names whose iteration numbers need to be exctracted
    varIterList = ["U", "p", "rho", "k", "b", "Xi", "hau", "ha", "ft"]

    args = parseArguments()
    df = readLogfile(args.logfile, varIterList)

    if args.timeStart:
        df = df[df.runTime >= args.timeStart]
    if args.timeEnd:
        df = df[df.runTime <= args.timeEnd]

    # Evaluate timings
    # Check whether the log contains high precission timings
    if 'clockDiff' in df.columns:
        # Exclude first entry since no data is provided for the first time step
        mean = np.mean(df.clockDiff[1:-1])
        stdDev = np.std(df.clockDiff[1:-1])
    else:
        print("Warning:\n"
            "  The custom function object for timings was not employed.\n"
            "  The time precision in the log file may be insufficient.\n")
        # First time value is used as starting point
        timeDiffs = []
        timePrev = df.execTime.iloc[1]
        for time in df.execTime.iloc[1:-1]:
            timeDiffs.append(time - timePrev)
            timePrev = time
        mean = np.mean(timeDiffs)
        stdDev = np.std(timeDiffs)

    # Number of time steps for 0.95 confidence and the given error
    err = args.statError/100*mean
    # Add 1 because the first time step is omitted from the measurement
    n = int(np.round((1.96*stdDev/err)**2) + 1)

    meansDf = computeMeans(df, varIterList)

    print("Iteration numbers based on", len(df.runTime), "time steps:")
    print(meansDf.to_string(index=False))
    print("")
    print("Average wall clock time per time step =", mean)
    print("Standard deviation of wall clock time per time step =", stdDev)
    print("Number of time steps for 0.95 confidence and", args.statError,
          "% error =", n)

    if args.saveEval:
        df.to_csv(args.logfile+'.csv')


def parseArguments():
    parser = ArgumentParser()
    parser.add_argument("logfile", metavar="logfile", type=str,
                        help="path to the log file to analyze")
    parser.add_argument("-tS", "--timeStart", metavar="timeStart", type=float,
                        help="runTime from which the evaluation is performed")
    parser.add_argument("-tE", "--timeEnd", metavar="timeEnd", type=float,
                        help="runTime up to which the evaluation is performed")
    parser.add_argument("-e", "--statError", metavar="statError", type=float,
                        default=1, help="evaluate for the given statistical "
                        "error in percent (default is 1")
    parser.add_argument("-s", "--saveEval", action='store_true',
                        help="save evaluation to a CSV file")
    return parser.parse_args()


def addMatch(nIterArr, match):
    nIterArr[-1] += float(match.groups()[0])


def updateDictDt(dictDt, key, match):
    # Handle iteration numbers separately since linear solvers may be called
    # several times per time step for a certain variable.
    if (key.endswith("Iter")):
        keyOuter = key + "Outer"
        if key not in dictDt:
            dictDt.update({key: int(match.groups()[0])})
            dictDt.update({keyOuter: 1})
        else:
            dictDt[key] += int(match.groups()[0])
            dictDt[keyOuter] += 1
    # Assume that everything else is present only once per time step in the log
    else:
        dictDt.update({key: float(match.groups()[0])})


def readLogfile(log, varIterList):
    # String dict for matches
    regexFloat = "([+-]?(\d+([.]\d*)?(e[+-]?\d+)?|[.]\d+(e[+-]?\d+)?))"
    matches = {
        "clockDiff": r"^Wall clock time.+ = " + regexFloat,
        "execTime": r"^ExecutionTime = " + regexFloat,
        "runTime": r"^Time = " + regexFloat,
        "start": r"^Starting time loop",
    }
    # Fill in matches for iteration numbers given a list of variables
    for var in varIterList:
        varName = "n" + var + "Iter"
        # Handle velocity separatly since vectors are solved once per direction
        # but fixing iteration is possible only for all 3 components at once.
        if (var == "U"):
            matches.update( {
                    varName:
                        r".+Solving for " + var +
                        r"(?:x|y|z),.+No Iterations ([\w.]+)"
                }
            )
        else:
            matches.update( {
                    varName:
                        r".+Solving for " + var + r",.+No Iterations ([\w.]+)"
                }
            )

    # Data for a single time step is hold in a dictionary
    dictDt = {}
    # Time step dictionaries are appended to a list
    dictList = []

    started = False
    with open(log) as f:
        for line in f:
            for key, value in matches.items():
                match = re.match(value, line)
                if match:
                    # Make sure to skip everything in the log file which does
                    # not belong to the solver log
                    if (started == False):
                        if (key == "start"):
                            started = True
                            continue
                    else:
                        if (key == "runTime") and not dictDt:
                            dictDt = {key: float(match.groups()[0])}
                        elif (key == "runTime"):  # A new time step
                            dictList.append(dictDt)
                            dictDt = {key: float(match.groups()[0])}
                        else:
                            updateDictDt(dictDt, key, match)

    # Append the last produced time step dictionary
    dictList.append(dictDt)

    return pd.DataFrame(dictList)


def computeMeans(df, varList):
    # Build a list of lists with the mean iteration numbers and convert it to a
    # dataframe for simpler handling.
    meansList= []
    for var in varList:
        nameIter = "n" + var + "Iter"
        nameIterOuter = nameIter + "Outer"
        nMeanIter = np.mean(df[nameIter])
        nMeanIterOuter = np.mean(df[nameIterOuter])
        meansList.append([var, nMeanIter, nMeanIterOuter])

    meansDf = pd.DataFrame(meansList,
        columns=["Quantity", "InnerItPerDt", "OuterItPerDt"])

    # Has to be rounded in order for downcast to work
    meansDf['fixedIterSetup'] = pd.to_numeric(
        round(meansDf.InnerItPerDt/meansDf.OuterItPerDt),
        downcast='integer'
    )

    return meansDf


if (__name__ == "__main__"):
    main()
