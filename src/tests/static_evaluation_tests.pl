% Travail pratique 1 : Gomoku
% Conception d'un jeu intelligent
%
% remis par
%   Omar Akrout    (NI: 111 165 246)
%   René Chenard   (NI: 111 232 277)
%   Vincent Martel (NI: 111 105 797)
%
% dans le cadre du cours
%   IFT-2003 - Intelligence artificielle I
%   Hiver 2023

%====================================================%
%    Tests unitaires pour static_evaluation.pl.      %
%                                                    %
%    Exécuter les tests: ?- run_tests.               %
%====================================================%


:- ['../game_components/game_engine'].

:- begin_tests(evaluation).

test(evaluate_score_3x3_empty) :-
    set_goal(3),
    Board = [[v,v,v],
             [v,v,v],
             [v,v,v]],
    
    static_score(Board, b, BestScoreB),
    static_score(Board, n, BestScoreN),
    
    assertion(BestScoreB = 0),
    assertion(BestScoreN = 0).

test(evaluate_score_3x3_one_each) :-
    set_goal(3),
    Board = [[v,v,n],
             [v,v,v],
             [b,v,v]],
    
    static_score(Board, b, BestScoreB),
    static_score(Board, n, BestScoreN),
    
    assertion(BestScoreB = 1),
    assertion(BestScoreN = 1).

test(evaluate_score_3x3_two_each) :-
    set_goal(3),
    Board = [[b,b,v],
             [n,v,v],
             [n,v,v]],
    
    static_score(Board, b, BestScoreB),
    static_score(Board, n, BestScoreN),
    
    assertion(BestScoreB = 2),
    assertion(BestScoreN = 2).

test(evaluate_score_3x3_horizontal) :-
    set_goal(3),
    Board = [[b,b,b],
             [v,v,v],
             [n,n,n]],
    
    static_score(Board, b, BestScoreB),
    static_score(Board, n, BestScoreN),
    
    assertion(BestScoreB = 3),
    assertion(BestScoreN = 3).

test(evaluate_score_3x3_vertical) :-
    set_goal(3),
    Board = [[b,v,n],
             [b,v,n],
             [b,v,n]],
    
    static_score(Board, b, BestScoreB),
    static_score(Board, n, BestScoreN),
    
    assertion(BestScoreB = 3),
    assertion(BestScoreN = 3).

test(evaluate_score_3x3_diagonal_1) :-
    set_goal(3),
    Board = [[b,v,n],
             [v,b,v],
             [n,v,b]],
    
    static_score(Board, b, BestScoreB),
    static_score(Board, n, BestScoreN),
    
    assertion(BestScoreB = 3),
    assertion(BestScoreN = 1).

test(evaluate_score_3x3_diagonal_2) :-
    set_goal(3),
    Board = [[b,v,n],
             [v,n,v],
             [n,v,b]],
    
    static_score(Board, b, BestScoreB),
    static_score(Board, n, BestScoreN),
    
    assertion(BestScoreB = 1),
    assertion(BestScoreN = 3).

test(evaluate_score_5x5) :-
    set_goal(5),
    Board = [[b,n,n,v,v],
             [v,n,v,v,v],
             [v,n,v,v,b],
             [v,n,v,b,v],
             [n,v,b,v,v]],

    static_score(Board, b, BestScoreB),
    static_score(Board, n, BestScoreN),
    
    assertion(BestScoreB = 3),
    assertion(BestScoreN = 4).
    
test(evaluate_game_over_not) :-
    set_goal(3),
    Board = [[v,v,v],
             [v,v,v],
             [v,v,v]],
    
    assertion(not(game_over(Board, _))).

test(evaluate_game_over_b) :-
    set_goal(3),
    Board = [[b,n,n],
             [v,b,n],
             [v,v,b]],
    
    game_over(Board, Winner),
    
    assertion(Winner = b).
    
test(evaluate_game_over_tie) :-
    set_goal(3),
    Board = [[b,b,n],
             [n,n,b],
             [b,n,n]],

    game_over(Board, Winner),
    
    assertion(Winner = nil).

:- end_tests(evaluation).
