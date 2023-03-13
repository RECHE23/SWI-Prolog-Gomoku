% SWI-Prolog implementation of Gomoku
% René Chenard, 2023

%====================================================%
%                 Alpha-Beta search.                 %
%====================================================%


:- module(alphabeta, [alphabeta/5]).

% Alpha-Beta search as suggested in the book
% "Prolog programming for artificial intelligence"
% by Ivan Bratko, 1986.
% Source: https://silp.iiita.ac.in/wp-content/uploads/PROLOG.pdf

alphabeta(Pos, Alpha, Beta, GoodPos, Val) :-
    moves(Pos, PosList), !,
    boundedbest(PosList, Alpha, Beta, GoodPos, Val);
    staticval(Pos, Val).
    
boundedbest([Pos|PosList], Alpha, Beta, GoodPos, GoodVal) :-
    alphabeta(Pos, Alpha, Beta, _, Val),
    goodenough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal).

goodenough([], _, _, Pos, Val, Pos, Val) :- !.

goodenough(_, Alpha, Beta, Pos, Val, Pos, Val) :-
    min_to_move(Pos), Val > Beta, !;
    max_to_move(Pos), Val < Alpha, !.

goodenough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal) :-
    newbounds(Alpha, Beta, Pos, Val, NewAlpha, NewBeta),
    boundedbest(PosList, NewAlpha, NewBeta, Pos1, Val1),
    betterof(Pos, Val, Pos1, Val1, GoodPos, GoodVal).

newbounds(Alpha, Beta, Pos, Val, Val, Beta) :-
    min_to_move(Pos), Val > Alpha, !.

newbounds(Alpha, Beta, Pos, Val, Alpha, Val) :-
    max_to_move(Pos), Val < Beta, !.

newbounds(Alpha, Beta, _, _, Alpha, Beta).

betterof(Pos, Val, _, Val1, Pos, Val) :-
    min_to_move(Pos), Val > Val1, !;
    max_to_move(Pos), Val < Val1, !.

betterof(_, _, Pos1, Val1, Pos1, Val1).
