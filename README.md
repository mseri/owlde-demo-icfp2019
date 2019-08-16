# Demo material for ICFP 2019 talk

You can build all examples with
```
dune build @examples --profile=release
```

# Teaching material

It has become possible only recently to export jupyter notebooks to interactive html-based widgets by means of `nbinteract` and the `binder` API (see University of California, Berkeley,
Technical Report No. UCB/EECS-2018-57). However in many courses, we would like to be able to share interactive demonstrations with the students by minimising (or completely removing) the visible code, and by providing something that works out of the box and does not require to install a Mathematica viewer, a python distribution, matlab, ...

If you build the examples, and open `_build/default/teaching_material/index.html` in a browser, you can see an example of this at work.

The javascript included in the page, generates all the content and live-integrates the demonstration. It can be provided to the students as is, even via github pages, and does not require any specific knowledge or hardware to be used.

This currently requires the `js` branch of `owl-ode`.

# N-Body problem with a large number of bodies

```
# OCaml 4.08.1 + flambda
$ dune build @example --profile=release
$ bench _build/default/planets/bench.exe
benchmarking _build/default/planets/bench.exe
time                 8.340 s    (8.242 s .. 8.439 s)
                     1.000 R²   (1.000 R² .. 1.000 R²)
mean                 8.282 s    (8.261 s .. 8.312 s)
std dev              29.18 ms   (9.034 ms .. 38.84 ms)
variance introduced by outliers: 19% (moderately inflated)

# OCaml 4.08.1
$ bench _build/default/planets/bench.exe
benchmarking _build/default/planets/bench.exe
time                 10.07 s    (9.419 s .. 11.27 s)
                     0.998 R²   (0.997 R² .. 1.000 R²)
mean                 10.28 s    (10.08 s .. 10.52 s)
std dev              278.6 ms   (113.4 ms .. 352.8 ms)
variance introduced by outliers: 19% (moderately inflated)
```

This is, of course, not a real benchmark. The implementations below are more aggressive in reusing memory and mutation, a feature that is planned but not yet supported by `OwlDE`.

```
$ bench "python3 planets/bench.py"
benchmarking python3 planets/bench.py
time                 9.609 s    (8.724 s .. 11.06 s)
                     0.997 R²   (0.996 R² .. 1.000 R²)
mean                 9.763 s    (9.461 s .. 10.19 s)
std dev              404.1 ms   (175.1 ms .. 521.6 ms)
variance introduced by outliers: 19% (moderately inflated)
```

Pure python implementation, only doing 10 iterations (instead of the 200 of the runs above):
```
$ bench "python3 planets/bench_pure.py"
benchmarking python3 planets/bench_pure.py
time                 7.001 s    (6.913 s .. 7.176 s)
                     1.000 R²   (1.000 R² .. 1.000 R²)
mean                 7.303 s    (7.171 s .. 7.435 s)
std dev              169.9 ms   (83.88 ms .. 220.8 ms)
variance introduced by outliers: 19% (moderately inflated)
```

A pure OCaml implementation can severely outperform the others though, at least for these "small" dimensional examples.
```
# OCaml 4.08.1 + flambda
$ bench _build/default/planets/bench_pure.exe
benchmarking _build/default/planets/bench_pure.exe
time                 998.3 ms   (971.2 ms .. 1.027 s)
                     1.000 R²   (1.000 R² .. 1.000 R²)
mean                 993.1 ms   (988.8 ms .. 999.3 ms)
std dev              5.854 ms   (2.102 ms .. 7.500 ms)
variance introduced by outliers: 19% (moderately inflated)

# OCaml 4.08.1
$ bench _build/default/planets/bench_pure.exe
benchmarking _build/default/planets/bench_pure.exe
time                 983.8 ms   (963.3 ms .. 1.013 s)
                     1.000 R²   (1.000 R² .. 1.000 R²)
mean                 1.004 s    (993.8 ms .. 1.013 s)
std dev              10.78 ms   (8.465 ms .. 11.81 ms)
variance introduced by outliers: 19% (moderately inflated)
```

# Minibench

Benchmarking different algorithms over an integration of the restricted three body problem.
In the RK45 case we are comparing an OCaml+Owl implementation with a C implementation, nevertheless the ocaml implementation is doing a good job and is almost as fast as the C implementation.
In the RK4 case we are comparing OCaml+Owl to python+numpy, in this case we are twice as fast.
In the LSODA, the underlying FORTRAN library is the same but we are twice as slow. This will be investigated in the future.

``` 
# OCaml 4.08.1 + flambda
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

# OCaml 4.08.1
$ _build/default/minibench/minibench.exe
Estimated testing time 30s (3 benchmarks x 10s). Change using '-quota'.
┌───────┬──────────┬─────────────┬──────────┬──────────┬────────────┐
│ Name  │ Time/Run │     mWd/Run │ mjWd/Run │ Prom/Run │ Percentage │
├───────┼──────────┼─────────────┼──────────┼──────────┼────────────┤
│ RK45  │  11.26ms │    778.47kw │   6.72kw │   5.94kw │      3.38% │
│ RK4   │ 333.18ms │ 32_062.78kw │ 233.07kw │ 199.07kw │    100.00% │
│ LSODA │  39.62ms │  5_204.75kw │ 224.58kw │ 190.58kw │     11.89% │
└───────┴──────────┴─────────────┴──────────┴──────────┴────────────┘
Benchmarks that take 1ns to 100ms can be estimated precisely. For more reliable 
estimates, redesign your benchmark to have a shorter execution time.

# Python 3.7.4
$ python3 minibench/minibench.py
RK45:	8.65 msec
RK4:	656 msec
LSODA:	19.2 msec
```

# Adjoint problem and Neural ODE

Based on https://github.com/tachukao/adjoint_ode/
