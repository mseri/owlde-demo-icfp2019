# Adapted from talk material of:
# N-Body Simulation with Python & Numba
# Dr. Yves J. Hilpisch
# The Python Quants GmbH

import random

import numpy as np
from math import sqrt

nplanets = 1000

planet = []
for i in range(nplanets):
    planet.append([random.gauss(0.0, 1.0) for j in range(3)])
planetv = [[0, 0, 0] for x in planet]


def nbody(planet, planetv):
    nSteps = 15 # In the other code these are 200...
    dt = 0.01
    for _ in range(nSteps):
        for i in range(nplanets):
            Fx = 0.0
            Fy = 0.0
            Fz = 0.0
            for j in range(nplanets):
                if j != i:
                    dx = planet[j][0] - planet[i][0]
                    dy = planet[j][1] - planet[i][1]
                    dz = planet[j][2] - planet[i][2]
                    drSquared = dx * dx + dy * dy + dz * dz
                    drPowerN32 = 1.0 / (drSquared + sqrt(drSquared))
                    Fx += dx * drPowerN32
                    Fy += dy * drPowerN32
                    Fz += dz * drPowerN32
                planetv[i][0] += dt * Fx
                planetv[i][1] += dt * Fy
                planetv[i][2] += dt * Fz
        for i in range(nplanets):
            planet[i][0] += planetv[i][0] * dt
            planet[i][1] += planetv[i][1] * dt
            planet[i][2] += planetv[i][2] * dt
    return planet, planetv


def energy(planets, planetvs):
    e = 0.5 * sum(planetv[0] ** 2 + planetv[1] ** 2 + planetv[2] ** 2 for planetv in planetvs)
    for i in range(nplanets):
        for j in range(nplanets):
            if j != i:
                dx = planet[j][0] - planet[i][0]
                dy = planet[j][1] - planet[i][1]
                dz = planet[j][2] - planet[i][2]
                drSquared = dx * dx + dy * dy + dz * dz
                drPowerN32 = 1.0 / (drSquared + sqrt(drSquared))
                e -= drPowerN32
    return e

e0 = energy(planet, planetv)
planet, planetv = nbody(planet, planetv)
print(f"Error on reference energy: {abs(energy(planet, planetv)/e0)}")
