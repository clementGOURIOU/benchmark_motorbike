/*---------------------------------------------------------------------------*\
  =========                 |
  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
   \\    /   O peration     |
    \\  /    A nd           | www.openfoam.com
     \\/     M anipulation  |
-------------------------------------------------------------------------------
    Copyright (C) 2022 OpenCFD Ltd.
-------------------------------------------------------------------------------
License
    This file is part of OpenFOAM.

    OpenFOAM is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    OpenFOAM is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
    for more details.

    You should have received a copy of the GNU General Public License
    along with OpenFOAM.  If not, see <http://www.gnu.org/licenses/>.

\*---------------------------------------------------------------------------*/

#include "linearCylRadial.H"
#include "addToRunTimeSelectionTable.H"

namespace Foam
{
namespace extrudeModels
{

// * * * * * * * * * * * * * * Static Data Members * * * * * * * * * * * * * //

defineTypeNameAndDebug(linearCylRadial, 0);

addToRunTimeSelectionTable(extrudeModel, linearCylRadial, dictionary);


// * * * * * * * * * * * * * * * * Constructors  * * * * * * * * * * * * * * //

linearCylRadial::linearCylRadial(const dictionary& dict)
:
    extrudeModel(typeName, dict),
    R_(coeffDict_.get<scalar>("R")),
    Rsurface_(coeffDict_.getOrDefault<scalar>("Rsurface", -1)),
    refPoint_(coeffDict_.get<point>("point")),
    axis_(coeffDict_.get<vector>("axis").normalise())
{}


// * * * * * * * * * * * * * * * * Operators * * * * * * * * * * * * * * * * //

point linearCylRadial::operator()
(
    const point& surfacePoint,
    const vector& surfaceNormal,
    const label layer
) const
{

    point projectedPt = surfacePoint - (axis_ & surfacePoint)*axis_;
    vector d = projectedPt - refPoint_;

    // start at surface point
    vector startPt = surfacePoint;

    // or at defined radius
    if (Rsurface_ >= 0) startPt += Rsurface_*d.normalise();

    vector finalPt = startPt
        + (R_-mag(projectedPt))*sumThickness(layer)*d.normalise();

    if (debug)
    {
        Info <<" surfacePoint: " << surfacePoint
             <<" projectedPt: " << projectedPt
             <<" startPt: " << startPt
             <<" sumThickness: " << sumThickness(layer)
             <<" finalPt: " << finalPt
             <<endl;
    }
    return finalPt;
}


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

} // End namespace extrudeModels
} // End namespace Foam

// ************************************************************************* //
