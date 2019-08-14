# Adapted from talk material of:
# N-Body Simulation with Python & Numba
# Dr. Yves J. Hilpisch
# The Python Quants GmbH

import numpy as np

nParticles = 1000

particle = np.random.standard_normal((nParticles, 3))
particlev = np.zeros_like(particle)

def nbody_np(particle, particlev):  # NumPy arrays as input
    nSteps = 200; dt = 0.01
    for _step in range(1, nSteps + 1, 1):
        Fp = np.zeros((nParticles, 3))
        for i in range(nParticles):
            dp = particle - particle[i]
            drSquared = np.sum(dp ** 2, axis=1)
            h = drSquared + np.sqrt(drSquared)
            drPowerN32 = 1. / np.maximum(h, 1E-10)
            Fp += -(dp.T * drPowerN32).T
            particlev += dt * Fp
        particle += particlev * dt
    return particle, particlev

nbody_np(particle, particlev)