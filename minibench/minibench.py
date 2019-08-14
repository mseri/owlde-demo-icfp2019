import numpy as np
import matplotlib.pylab as plb
from scipy.integrate import solve_ivp
from time import time

mu = 0.0122771
nu = 1 - mu

t0 = 0
tf = 34
y0 = [0.994, 0, 0, -2.00158510637908252240537862224]

def f(t, y):
    D1 = ((y[0] + mu)**2 + y[1]**2) ** 1.5
    D2 = ((y[0] - nu)**2 + y[1]**2) ** 1.5

    return np.array([
        y[2],
        y[3],
        y[0] + 2 * y[3] - nu * (y[0] + mu) / D1 - mu * (y[0] - nu) / D2,
        y[1] - 2 * y[2] - nu * y[1] / D1 - mu * y[1] / D2
    ])

def fswap(y, t): return f(t, y)

start = time()
res = solve_ivp(f, [t0, tf], y0, method='RK45', atol=1e-6, rtol=1e-3)
end = time()
print(f"RK45\t{end-start}: {np.shape(res.y)}")
np.savetxt("rk45p.txt",np.vstack([res.t, res.y]).T)

start = time()
tspan = np.arange(t0, tf, 1E-3)
res = plb.rk4(fswap, y0, tspan)
end = time()
print(f"RK4\t{end-start}: {np.shape(res)}")
np.savetxt("rk4p.txt", np.array([ [tspan[i], *r] for i,r in enumerate(res)]))

start = time()
res = solve_ivp(f, [t0, tf], y0, t_eval=np.arange(t0, tf, 1E-3), method='LSODA')
end = time()
print(f"LSODA\t{end-start}: {np.shape(res.y)}")
np.savetxt("lsodap.txt",np.vstack([res.t, res.y]).T)