import numpy as np
import matplotlib.pylab as plb
from scipy.integrate import solve_ivp
from timeit import timeit

mu = 0.0122771
nu = 1 - mu

t0 = 0
tf = 20
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


def rk4(derivs, y0, t):
    """
    Integrate 1D or ND system of ODEs using 4-th order Runge-Kutta.
    This is a toy implementation which may be useful if you find
    yourself stranded on a system w/o scipy.  Otherwise use
    :func:`scipy.integrate`.

    From matplotlib.pylab

    Parameters
    ----------
    y0
        initial state vector

    t
        sample times

    derivs
        returns the derivative of the system and has the
        signature ``dy = derivs(ti, yi)``
    """

    try:
        Ny = len(y0)
    except TypeError:
        yout = np.zeros((len(t),), float)
    else:
        yout = np.zeros((len(t), Ny), float)

    yout[0] = y0
    i = 0

    for i in range(len(t)-1):
        thist = t[i]
        dt = t[i+1] - thist
        dt2 = dt/2.0
        y0 = yout[i]

        k1 = np.asarray(derivs(thist, y0))
        k2 = np.asarray(derivs(thist+dt2, y0 + dt2*k1))
        k3 = np.asarray(derivs(thist+dt2, y0 + dt2*k2))
        k4 = np.asarray(derivs(thist+dt, y0 + dt*k3))
        yout[i+1] = y0 + dt/6.0*(k1 + 2*k2 + 2*k3 + k4)
    return yout


################### From cPython/timeit.py ###################
units = {"nsec": 1e-9, "usec": 1e-6, "msec": 1e-3, "sec": 1.0}
precision = 3
time_unit = None


def format_time(dt):
    unit = time_unit

    if unit is not None:
        scale = units[unit]
    else:
        scales = [(scale, unit) for unit, scale in units.items()]
        scales.sort(reverse=True)
        for scale, unit in scales:
            if dt >= scale:
                break

    return "%.*g %s" % (precision, dt / scale, unit)
############### ############### ############### ###############


if __name__ == "__main__":

    rk45 = timeit(
        "solve_ivp(f, [t0, tf], y0, method='RK45', atol=1e-6, rtol=1e-3)", globals=globals(), number=50)
    rk4 = timeit("rk4(f, y0, np.arange(t0, tf, 1E-3))",
                 globals=globals(), number=30)
    lsoda = timeit(
        "solve_ivp(f, [t0, tf], y0, t_eval=np.arange(t0, tf, 1E-3), method='LSODA')", globals=globals(), number=50)

    print(f"RK45:\t{format_time(rk45/50)}")
    print(f"RK4:\t{format_time(rk4/30)}")
    print(f"LSODA:\t{format_time(lsoda/50)}")
