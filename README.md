# Teaching material

# N-Body problem with a large number of bodies

```
$ dune build @example --profile=release
$ bench _build/default/planets/bench.exe
benchmarking _build/default/planets/bench.exe
time                 8.340 s    (8.242 s .. 8.439 s)
                     1.000 R²   (1.000 R² .. 1.000 R²)
mean                 8.282 s    (8.261 s .. 8.312 s)
std dev              29.18 ms   (9.034 ms .. 38.84 ms)
variance introduced by outliers: 19% (moderately inflated)
```

```
$ bench "python3 planets/bench.py"
benchmarking python3 planets/bench.py
time                 9.609 s    (8.724 s .. 11.06 s)
                     0.997 R²   (0.996 R² .. 1.000 R²)
mean                 9.763 s    (9.461 s .. 10.19 s)
std dev              404.1 ms   (175.1 ms .. 521.6 ms)
variance introduced by outliers: 19% (moderately inflated)
```

# Minibench

On my laptop
```
$ dune build @example --profile=release
$ _build/default/minibench/minibench.exe 
Estimated testing time 30s (3 benchmarks x 10s). Change using '-quota'.
┌───────┬──────────┬─────────────┬──────────┬──────────┬────────────┐
│ Name  │ Time/Run │     mWd/Run │ mjWd/Run │ Prom/Run │ Percentage │
├───────┼──────────┼─────────────┼──────────┼──────────┼────────────┤
│ RK45  │  10.89ms │    766.50kw │   6.69kw │   5.91kw │      3.20% │
│ RK4   │ 340.29ms │ 30_634.95kw │ 219.02kw │ 185.02kw │    100.00% │
│ LSODA │  38.26ms │  4_997.82kw │ 223.20kw │ 189.20kw │     11.24% │
└───────┴──────────┴─────────────┴──────────┴──────────┴────────────┘
Benchmarks that take 1ns to 100ms can be estimated precisely. For more reliable 
estimates, redesign your benchmark to have a shorter execution time.

$ python3 minibench/minibench.py
RK45:	8.65 msec
RK4:	656 msec
LSODA:	19.2 msec
```