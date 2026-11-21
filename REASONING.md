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

The parent facts are tried top to bottom and the two with tom first give X=liz then X=bob. No more tom facts remain, so the count is 2.

## P02

parent(tom, bob) is a fact, so the first answer is true. No other fact matches, so there is no second and the count is 1.

## P03

No parent fact has tom as its child, so nothing unifies. The first answer is false, there is no second, and the count is 0.

## P04

X = f(Y, a) binds X with Y still free, then Y = b fills it in so X=f(b, a). Unification is deterministic here, so there is one answer and no second.

## P05

The two compound terms match argument by argument, binding X=a and Y=b. One clause head satisfies the goal, so there is one answer and no second.

## P06

a and b are different atoms, so they cannot unify. The first answer is false, there is no second, and the count is 0.

## P07

parent(tom, P) gives liz, which fails, then bob, whose children ann and pat become the answers. First is X=ann, second is X=pat, count 2.

## P08

The base clause comes first, so liz and bob are printed before any recursion, then ann, pat, sue, jim follow. First is X=liz, second is X=bob, count 6.

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