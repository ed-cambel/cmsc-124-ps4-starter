<!--no-pdf-->
# Why Each Prediction Reads the Way It Does

Write one entry per case, before you run anything. Name the rule behind each
predicted field. One to three sentences is enough. The grader checks the
structure of this file only. It does not judge how good the reasoning is, and
it sets no word minimum.

For every case you predicted wrongly, add a short correction after you run
it: what you predicted, what the language printed, and which rule you
misread. Corrections belong in the correction commits, not the prediction
commit.

Commit this file together with `predictions.tsv`, before any case runs:

```bash
git add predictions.tsv REASONING.md
```

The example below uses a query that is not one of the 16 cases, so it gives
no answer away. `parent(pat, X)` reads `parent(pat, jim)` because the `parent`
facts are tried top to bottom and only that one has `pat` as its first
argument:

```text
## parent(pat, X)

The goal scans the parent facts in source order. Only parent(pat, jim) has
pat first, so X binds to jim. No second fact matches, so the first ; finds
nothing and the search ends after one answer.
```

## P01

The parents fact are scanned first. Only `parent(tom, liz)` and `parent(tom,bob)` have `tom` first, so `X` binds to `liz` and `bob` respectively. No other fact has `tom` first in its first argument, so the count returns `2`.

## P02

The parents fact are scanned first. `parent(tom,liz)` has `tom` in the first argument, but `liz` does not unify with the second argument `bob`, causing it to fail. It moves to the next fact with a matching `tom` argument, `parent(tom,bob)`, so it succeeds. All other facts fail on the first argument, leaving only the count as `1`.

## P03

The parents fact are scanned first, and no fact has `tom` as its first argument. So, every fact fails to unify and returns `false` with the count as `0`.

## P04

The goals are proven left to right: `X = f(Y,a)` binds `X` to `f(Y,a)` and `Y = b` binds `Y` to `b`. The newly binded `Y` inside `f(Y,a)` also updates, which results to `X = f(b,a)` and `Y = b`. No other clauses are tried, so it returns a count of `1`.

## P05

The case `f(X, b) = f(a, Y)` have the same functor and arity, so `f(X, b)` can unify with `f(a, Y)`. `X = a` binds `X` to `a` and `b = Y` binds `Y` to `b`. No other clauses are tried, so it returns a count of `1`.

## P06

Two constants can be unfied, but they have to be either the same atoms or same numbers. For this case, `a` and `b` are two different atoms. Som it fails to unify and returns `false` with count `0`.

## P07

`parent(tom, P)` matches `parent(tom, liz)` first, but `parent(liz, X)` matches no fact and fails, so we backtrack. `parent(tom, bob)` then matches with `P = bob`, and `parent(bob, X)` matches `parent(bob, ann)` `and parent(bob, pat)`. No more `bob` or `tom` facts match, and the scan ends with a count of `2`.

## P08

`parent(tom, X)` matches `parent(tom, liz)` and `parent(tom, bob)`, binding `X = liz` and `X = bob`. Then it solves `parent(tom, P), ancestor(P, X)`, where `P = liz` fails because no facts have `liz` as the first argument, and `P = bob gives ancestor(bob, X)`, which finds `parent(bob, X)` first and binds `ann` and `pat`. It then goes through `parent(ann, X)`, where it matches `parent(ann, sue)`, and `parent(pat, X)` which matches `parent(pat, jim)` only, so the scan ends with a count of `6`.

## P09

The recursive clause comes first, so the search dives down the first child before reading any base fact, and bob's base clause prints ann before the search returns upward. First is X=sue, second is X=ann, count 6.

## Correction for P09

I predicted X=ann second. The prompt printed X=jim second, because the recursive clause's parent(bob, P2) loop emits jim from pat's clause-2 answer before the recursive clause finishes and bob's clause-2 answer ann is emitted. I misread clause order: I assumed bob's base answer surfaces before the recursive descent continues through pat.

## P10

The base clause prints X=pat first, then the recursive clause climbs the family chain and the search tries X=bob directly before the deeper X=tom branch. First is X=pat, second is X=bob, count 3.

## Correction for P10

I predicted X=bob second. The prompt printed X=tom second, because the recursive clause succeeds via X=tom, P=bob, P2=pat as soon as it reaches pat, so tom pops out before X=bob is tried directly. I misread goal order: I assumed the direct X=bob branch is tried before the deeper X=tom branch, instead of after.

## P11

The recursive clause comes first and calls itself with the same first argument before any edge is read. It never gets back, so all three fields are unbounded.

## P12

The base clause fails, the recursive clause reaches edge(c, d) and answers true, then backtracking keeps looking for another path but the cycle traps the search before a second answer is found. First is true, second is unbounded, count is unbounded.

## Correction for P12

I predicted the second field as unbounded. The prompt printed true, because the same ground goal reach_r(a, d) is re-derived through the c-a-b-c cycle, and each successful derivation counts as a separate answer even though the bindings are identical. I misread backtracking: I assumed a ground goal succeeds only once, instead of once per successful derivation, with the search then diverging so the count stays unbounded.

## P13

Each list matches exactly one len clause, so the walk is deterministic down to []. First is N=3, second is none, count 1.

## P14

join splits [1, 2] at each position, giving a distinct answer per split. First is X=[],Y=[1,2], second is X=[1],Y=[2], count 3.

## P15

X is still unbound when X > 2 runs, so Prolog throws an instantiation error. All three fields are error.

## P16

elem binds X first, so 1 > 2 and 2 > 2 fail and 3 > 2 succeeds. First is X=3, second is none, count 1.