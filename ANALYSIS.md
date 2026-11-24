# The Search and the Stack

== trace P07 ==
Call: grandparent(tom,X)
Call: parent(tom,_)
Exit: parent(tom,liz)
Call: parent(liz,X)
Fail: parent(liz,X)
Redo: parent(tom,liz)
Exit: parent(tom,bob)
Call: parent(bob,X)
Exit: parent(bob,ann)
Exit: grandparent(tom,ann)
answer 1: X=ann
Redo: grandparent(tom,ann)
Redo: parent(bob,ann)
Exit: parent(bob,pat)
Exit: grandparent(tom,pat)
answer 2: X=pat
Redo: grandparent(tom,pat)
Redo: parent(bob,pat)
Fail: parent(bob,X)
Redo: parent(tom,bob)
Fail: parent(tom,_)
Fail: grandparent(tom,X)
== 2 answers ==

A new stack frame is pushed whenever a goal invokes a Call. In the given trace, this happens at Call: grandparent(tom,X), Call: parent(tom,\_), Call: parent(liz,X), and Call: parent(bob,X). Popping a stack frame is mainly handled by Fail, not Exit. On Fail, no other matching clauses remain for that goal, so Prolog destroys its stack frame and backtracks. As for Exit, it does not destroy the frame because untried clauses may still remain, meaning Prolog needs to keep the frame on the stack to backtrack into them via Redo.

A Redo line resumes a choice point: the record of which clause matched and that more clauses remain. Activity 15's returned frames stored only a return address, so once a frame returned its bindings were gone and the caller had no way to ask for another answer. Redo: parent(tom,liz) undoes the binding P=liz, advances parent(tom,\_) to its next fact, and re-enters the goal; Redo: grandparent(tom,ann) undoes X=ann at the top level.

Swapping ancestor/2's clauses only reorders answers because the family graph is acyclic: every recursive call reads a parent fact and asks a smaller question, so both orders stop, and clause order only changes which answer comes out first. Swapping reach/2's clauses changes whether the search answers at all, because the graph has a cycle. Recursive clause first: reach(X,Z) calls itself with the same X before any edge fact is read, so nothing fails, nothing backtracks, and the stack grows forever. Base clause first: each recursive call reads an edge fact, the search reaches edge(c,d) and answers true, then backtracking re-derives the same ground goal through the cycle and prints a second true before diverging, so the count stays unbounded but the search does answer. Clause order only reorders a finite search tree; it changes whether the search answers only when the relation can call itself with a goal that unifies with itself and no fact-read shrink it.
