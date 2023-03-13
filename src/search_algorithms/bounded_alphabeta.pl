% SWI-Prolog implementation of Gomoku
% René Chenard, 2023

%====================================================%
%      Algorithme Alpha-Bêta avec heuristique.       %
%====================================================%


:- module(bounded_alphabeta, [bounded_alphabeta/8]).

% A modification of the Alpha-Beta search suggested in the book
% "Prolog programming for artificial intelligence"
% by Ivan Bratko, 1986.
% Source: https://silp.iiita.ac.in/wp-content/uploads/PROLOG.pdf

% This modification limits the depth and the time of computation 
% and uses an heuristic score instead of a static score.

bounded_alphabeta(Pos, Alpha, Beta, GoodPos, Val, Depth, TimeStamp, TimeLimit) :-
    get_time(Time), Time - TimeStamp < TimeLimit,
    Depth > 0, moves(Pos, PosList), !,
    boundedbest(PosList, Alpha, Beta, GoodPos, Val, Depth, TimeStamp, TimeLimit);
    heuristicval(Pos, Val).

boundedbest([Pos|PosList], Alpha, Beta, GoodPos, GoodVal, Depth, TimeStamp, TimeLimit) :-
    Depth1 is Depth - 1,
    bounded_alphabeta(Pos, Alpha, Beta, _, Val, Depth1, TimeStamp, TimeLimit),
    goodenough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth, TimeStamp, TimeLimit).

goodenough([], _, _, Pos, Val, Pos, Val, _, _, _) :- !.

goodenough(_, Alpha, Beta, Pos, Val, Pos, Val, _, _, _) :-
    min_to_move(Pos), Val > Beta, !;
    max_to_move(Pos), Val < Alpha, !.

goodenough(PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth, TimeStamp, TimeLimit) :-
    newbounds(Alpha, Beta, Pos, Val, NewAlpha, NewBeta),
    boundedbest(PosList, NewAlpha, NewBeta, Pos1, Val1, Depth, TimeStamp, TimeLimit),
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
