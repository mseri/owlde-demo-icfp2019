# Adapted from talk material of:
# N-Body Simulation with Python & Numba
# Dr. Yves J. Hilpisch
# The Python Quants GmbH

import numpy as np

nplanets = 1000

planet = np.random.standard_normal((nplanets, 3))
planetv = np.zeros_like(planet)


def nbody_np(planet, planetv):
    nSteps = 200
    dt = 0.01
    for _step in range(nSteps):
        Fp = np.zeros((nplanets, 3))
        for i in range(nplanets):
            dp = planet - planet[i]
            drSquared = np.sum(dp ** 2, axis=1)
            drPowerN32 = 1. / np.maximum(drSquared + np.sqrt(drSquared), 1E-10)
            Fp += -(dp.T * drPowerN32).T
            planetv += dt * Fp
        planet += planetv * dt
    return planet, planetv


def energy(planets, planetvs):
    e = np.sum(0.5 * np.sum(planetvs ** 2, axis=1))
    for i in range(nplanets):
        dp = planet - planet[i]
        drSquared = np.sum(dp ** 2, axis=1)
        drPowerN32 = 1. / np.maximum(drSquared + np.sqrt(drSquared), 1E-10)
        e -= np.sum(drPowerN32)
    return e

e0 = energy(planet, planetv)
planet, planetv = nbody_np(planet, planetv)
print(f"Error on reference energy: {abs(1 - energy(planet, planetv)/e0)}")
