%%%% rules.pl -- Part 2. Write the seven predicates below.
%%%%
%%%% The grader loads the facts and given rules in cases/kb.pl before this
%%%% file, so parent/2, edge/2, elem/2, join/3, and len/2 are yours to call.
%%%% The grader scores R1, R2, and R3 separately. Finish them in order. You
%%%% keep every group you get right.
%%%%
%%%% Each stub below throws, so a check you did not reach fails with a
%%%% message that identifies the predicate. Replace the whole stub, head and
%%%% body, with your own clauses. A stub left above your clauses runs first
%%%% and throws before Prolog tries yours.

%%% R1 -- the family.

% sibling(X, Y): X and Y share a parent and are not the same person.
%
% Order matters. X \= Y succeeds only when X and Y are already bound to
% different things, so put it after the goal that binds them.
sibling(X, Y) :-
    parent(Z, X),
    parent(Z, Y),
    X \= Y.

% cousin(X, Y): a parent of X and a parent of Y are siblings.
cousin(X, Y) :-
    parent(PX, X),
    parent(PY,Y),
    sibling(PX, PY).

% descendant(D, A): A is an ancestor of D.
%   
% Two clauses, the mirror image of ancestor/2 in cases/kb.pl. The base
% clause reads one parent fact. The recursive clause reads one parent fact
% and then asks a smaller question.

% base case
descendant(D, A) :-
    parent(A, D).

% recursive case
descendant(D, A) :-
    parent(P, D),
    descendant(P, A).

%%% R2 -- lists.

% count_of(X, List, N): X occurs N times in List. N is 0 for the empty
% list, which is your base case.

% base case: empty list
count_of(_, [], 0).

% case 1: X matches head
count_of(X, [X|T], N) :-
    count_of(X, T, M),
    N is M + 1.

% case 2: X does not match head
count_of(X, [H|T], N) :-   
    X \= H,
    count_of(X, T, N).

% rev(List, Reversed): Reversed holds the elements of List in the other
% order. Reverse the tail. Then use join/3 to put the head at the end.

% base case: empty list
rev([], []).

% recursive case: head is moved to other list
rev([H|T], R) :-
    rev(T, RR),
    join(RR, [H], R).

% last_of(List, X): X is the last element of List. The empty list has no
% last element, so last_of([], X) must fail.

% base case: one element
last_of([X], X).

% case 1:
last_of([_|T], X) :-
    last_of(T, X).

%%% R3 -- the graph.

% route(From, To, Path): Path is the list of nodes from From to To, in
% order, following edge/2 and never visiting a node twice. A route from a
% node to itself is [From].
%
% reach_r/2 in cases/kb.pl walks the same graph and never ends, because
% the cycle a -> b -> c -> a always offers one more edge. Carry the nodes
% you visited. Refuse to step onto one again. \+ Goal is true when Goal
% cannot be proved. That is how you say "not yet visited."

% entry point: start the walk with an empty visited list.
route(From, To, Path) :-
    route_help(From, To, Path, []).

% base: arrived at the destination, path is just [To].
route_help(To, To, [To], _Visited).

% step: take one edge to a neighbour not yet in Visited.
route_help(From, To, [From|Rest], Visited) :-
    edge(From, Next),
    \+ elem(Next, Visited),
    route_help(Next, To, Rest, [From|Visited]).