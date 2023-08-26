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

\*---------------------------------------------------------------------------*/

#include "GiesekusIBSD.H"
#include "addToRunTimeSelectionTable.H"

// * * * * * * * * * * * * * * Static Data Members * * * * * * * * * * * * * //

namespace Foam
{
    defineTypeNameAndDebug(GiesekusIBSD, 0);
    addToRunTimeSelectionTable(viscoelasticLaw, GiesekusIBSD, dictionary);
}


// * * * * * * * * * * * * * * * * Constructors  * * * * * * * * * * * * * * //

Foam::GiesekusIBSD::GiesekusIBSD
(
    const word& name,
    const volVectorField& U,
    const surfaceScalarField& phi,
    const dictionary& dict
)
:
    viscoelasticLaw(name, U, phi),
    tau_
    (
        IOobject
        (
            "tau" + name,
            U.time().timeName(),
            U.mesh(),
            IOobject::MUST_READ,
            IOobject::AUTO_WRITE
        ),
        U.mesh()
    ),
    rho_(dict.lookup("rho")),
    etaS_(dict.lookup("etaS")),
    etaP_(dict.lookup("etaP")),
    alpha_(dict.lookup("alpha")),
    lambda_(dict.lookup("lambda")),
    etaStab_(dimensionedScalar::lookupOrDefault("etaStab", dict, 0.0, dimMass/(dimLength*dimTime)))
{}


// * * * * * * * * * * * * * * * Member Functions  * * * * * * * * * * * * * //

Foam::tmp<Foam::fvVectorMatrix> Foam::GiesekusIBSD::divTau(volVectorField& U) const
{
    if(etaStab_.value() < SMALL)
    {
        // RC: corresponds to BDS stabilization procedure
        dimensionedScalar etaPEff = etaP_;

        return
        (
            fvc::div(tau_/rho_, "div(tau)")
          - fvc::laplacian(etaPEff/rho_, U, "laplacian(etaPEff,U)")
          + fvm::laplacian( (etaPEff + etaS_)/rho_, U, "laplacian(etaPEff+etaS,U)")
        );
    }
    // RC: added coupling stabilization procedure
    else
    {
        return
        (
            fvc::div(tau_/rho_, "div(tau)")
            //- fvc::div((etaStab_/rho_)*fvc::grad(U), "div(tau)")
            - (etaStab_/rho_) * fvc::div(fvc::grad(U), "div(tau)")
          + fvm::laplacian( (etaStab_ + etaS_)/rho_, U, "laplacian(etaPEff+etaS,U)")
        );
    }
}


void Foam::GiesekusIBSD::correct()
{
    // Velocity gradient tensor
    const tmp<volTensorField> tL = fvc::grad(U());
    const volTensorField& L = tL();

    // Convected derivate term
    volTensorField C = tau_ & L;

    // Twice the rate of deformation tensor
    volSymmTensorField twoD = twoSymm(L);


    // Stress transport equation
    fvSymmTensorMatrix tauEqn
    (
        fvm::ddt(tau_)
      + fvm::div(phi(), tau_)
     ==
        etaP_/lambda_*twoD
      + twoSymm(C)
      - (alpha_/etaP_)*symm(tau_ & tau_)
      - fvm::Sp(1/lambda_, tau_)
    );

    tauEqn.relax();
    tauEqn.solve();
}


// ************************************************************************* //
