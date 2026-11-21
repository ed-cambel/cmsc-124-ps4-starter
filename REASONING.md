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

`ancestor_r(tom, X)` runs its recursive clause first and calls `parent(tom, P)`, matching `parent(tom, liz)` and `parent(tom, bob)`. Next, it recurses: `ancestor_r(liz, X)` has no matching facts because no fact have `liz` as the first argument, while `ancestor_r(bob, X)` recurses again, calling `ancestor_r(ann, X)`, which gives `sue`, and `ancestor_r(pat, X)`, which gives `jim`. Then the base clauses return `parent(bob, X)`, giving `ann` and `pat`, and `parent(tom, X)`, giving liz and bob, so the scan ends with a count of `6`.

## P10

`ancestor(X, jim)` runs its base clause first and calls `parent(X, jim)`, which looks for facts that jave `jim` as the second argument. The fact `parent(pat, jim)` matches binding `X` to `pat`, where it then runs the recursive clause now `parent(X, P), ancestor(P, jim)`, where it matches `parent(tom, bob): ancestor(bob, jim)` binding `X = tom` and `parent(bob, pat): ancestor(pat, jim)` biding `X = bob`. All other facts fail, sor it returns with a count of `3`.

## P11

`reach(a, d)` is called and calls itself infinitely because it must solve `reach(a, Z)`, which in turn just calls `reach(a, Z)` again. It never terminates and reaches edge, so nothing is returned and Prolog triggers an error.

## P12

`reach_r(a, d)` calls the edge first `edge(a, d)`, which fails as no facts have match it and then, it goes to the recursive clause and finds `edge(a, Z)` matching `edge(a, b)`, binding `Z` to `b`. `reach_r(b, d)` runs the base case, which has no matching so it proceeds to the recursive cause `reach_r(b, Z)` unfying with `edge(b, c)`. Lastly, `reach_r(c, d)` runs and finally has a matching edge fact `edge(c, d)`, so it returns true with a count of `1`.

Correction: After unifying with `edge(c,d)`, it still checked for other facts with c in its first argument. This matches `edge(c, a)`, but based on case P11, it never terminates so Prolog triggers an error. 

## P13

`len([], 0).` fails because it is a non-empty list, so it instead runs the predicate `len([_|T], N)`, where `T = [b, c]` as the tail. It recursively calls the list and splits it each time until it calls `len([], M)` binding `M = 0`. It then backtracks for each element in the list, which results in `N = 3` and count of `1`.

## P14

`[]` is bounded to `X` and `[1, 2]` is bound to `Y`. Then, it splits recursively, and each step moves one element from the front of the third list onto `X`, so `X` grows and `Y` shrinks.

## P15

The goals are proven from left to right, so `X > 2` is checked first. At that point, `X` is still not bounded with anything so the comparison has a lacking argument to compare to. This returns an error and `elem(X, [1, 2, 3])` is never reached nor returns anything.

## P16

Similar case as before, but `elem(X, [1, 2, 3])` runs first so `X` is actually bounded this time before the comparison. `elem(X, [X|_])` runs which splits the list into its head and tail, where `X` then binds to the head `1`, and is compared to `2`, returning false. On the next pass, it recurses and splits the remaining list into its head and tail, which binds `X` to `2`and compared to `2` but fails. It only suceeds on the last pass where `X=3` and a  count of 1 is returned.
