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


def main():
    args = parseArguments()
    df = readLogfile(args.logfile)

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

    # There are 3 linear solver calls for U and 1 call for p per time step
    nMeanUIter = np.mean(df.nUIter)/3
    nMeanUIterOuter = np.mean(df.nUIterOuter)/3
    nMeanPIter = np.mean(df.nPIter)
    nMeanPIterOuter = np.mean(df.nPIterOuter)

    # GAMG is only present in the log if the corresponding debug switch is on.
    nMeanPGAMGIter = np.mean(df.nPMGIter) if 'nPMGIter' in df else 0
    nMeanPGAMGIterOuter = \
        np.mean(df.nPMGIterOuter) if 'nPMGIterOuter' in df else 0

    print("nMeanUIter    =", int(round(nMeanUIter)),
            "evaluated from", len(df.nUIter), "time steps")
    print("nMeanPIter    =", int(round(nMeanPIter)),
            "evaluated from", len(df.nPIter), "time steps")
    if nMeanPGAMGIter:
        print("nMeanPGAMGIter =", int(round(nMeanPGAMGIter)),
                "evaluated from", len(df.nPMGIter), "time steps")
    print("nMeanUIterOuter =", int(round(nMeanUIterOuter)),
            "with a standard deviation =", (np.std(df.nUIterOuter)))
    print("nMeanPIterOuter =", int(round(nMeanPIterOuter)),
            "with a standard deviation =", (np.std(df.nPIterOuter)))
    if nMeanPGAMGIterOuter:
        print("nMeanPGAMGIterOuter =", int(round(nMeanPGAMGIterOuter)),
                "with a standard deviation =", (np.std(df.nPMGIterOuter)))
    print("The iteration numbers per an outer iteration are (fixedIter setup)")
    print("  U nIter =", int(round(nMeanUIter/nMeanUIterOuter)))
    print("  p nIter =", int(round(nMeanPIter/nMeanPIterOuter)))
    if nMeanPGAMGIterOuter:
        print("  p GAMG preconditioner nIter =",
                int(round(nMeanPGAMGIter/nMeanPGAMGIterOuter)))
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


def readLogfile(log):
    # String dict for matches
    regexFloat = "([+-]?(\d+([.]\d*)?(e[+-]?\d+)?|[.]\d+(e[+-]?\d+)?))"
    matches = {
        "nUIter": r".+U.+No Iterations ([\w.]+)",
        "nPIter": r".+p.+No Iterations ([\w.]+)",
        "nPMGIter": r".+coarsestLevelCorr.+No Iterations ([\w.]+)",
        "clockDiff": r"^Wall clock time.+ = " + regexFloat,
        "execTime": r"^ExecutionTime = " + regexFloat,
        "runTime": r"^Time = " + regexFloat,
        "start": r"^Starting time loop",
    }

    # Data for a single time step is hold in a dictionary
    dictDt = {}
    # Time step dictionaries are appended to a list
    dictList = []

    # Get the endTime from system/controlDict
    started = False
    with open(log) as f:
        for line in f:
            for key, value in matches.items():
                match = re.match(value, line)
                if match:
                    # Make sure to skip everything in the log file which does
                    # not to the solver log
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

if (__name__ == "__main__"):
    main()
