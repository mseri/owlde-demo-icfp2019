

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