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
    Contraction profile for a two-dimensional channel nozzle with the velocity
    pointing into the same direction before and after the nozzle using the
    hodograph method and potential theory according to
    "Libby, P. A., & Reiss, H. R. (1951). The design of two-dimensional
    contraction sections. Quarterly of Applied Mathematics, 9(1), 95-98."

    The script saves the profile splines as a text file and as an image.

Author
    Sergey Lesnik, Wikki GmbH, 2022

\*---------------------------------------------------------------------------*/
"""

import numpy as np
import matplotlib.pyplot as plt


def main():

    # Geometrical contraints
    upperBound = 50.8
    lowerBound = 25.4
    length = 140
    zRange = ["zBack", "zFront"]

    # Factor defining the shape of the contraction, has to be in range
    # [pi/2, pi)
    psi_0 = np.pi*0.5

    # Phi needs to depict range (0, inf). Log spacing results in equidistant
    # points for the spline.
    Phi = np.logspace(np.log(7e-2), np.log(20.28), num=50, base=np.e)

    # The asymptotes are tuned in order to conform to the experimental geometry
    # within the given length.
    alpha = 1.016929*upperBound
    beta = 0.951969*lowerBound

    # Compute
    x, y = getCoord(psi_0, Phi, alpha, beta)
    x = (x - x[0])
    x = np.flip(x)

    # Set the interval end points to the actual geometry dimensions
    x[0] = -length
    y[0] = lowerBound
    x[-1] = x[0] + length
    y[-1] = upperBound
    y = y - upperBound

    # Save a plot
    fig, ax = plt.subplots()
    ax.axis("equal")
    ax.plot(x, y)
    ax.grid()
    fig.savefig("rampProfile.png")

    # Save splines in a text file
    with open("rampProfile.txt", "w") as f:
        for z in zRange:
            print("Spline for z =", z, file=f)
            for i, xVal in enumerate(x):
                print("({0:8.2f} {1:8.2f}   {2} )".format(xVal, y[i], z),
                    file=f)
            print(file=f)

def getCoord(psi_0, Phi, alpha, beta):
    x = -alpha*( (beta/alpha)/(-psi_0 + np.pi) ) \
        *( \
            np.log(Phi) \
            + 0.5*(alpha/beta - 1) * np.log(1 + Phi**2 - 2*Phi*np.cos(psi_0)) \
        )
    y = alpha*( (beta/alpha)/(-psi_0 + np.pi)) \
        *( \
            -psi_0 \
            - (alpha/beta - 1)*np.arctan( \
                -Phi*np.sin(psi_0)/(1 - Phi*np.cos(psi_0)) \
            ) + np.pi \
        )
    return x, y

if (__name__ == '__main__'):
    main()


