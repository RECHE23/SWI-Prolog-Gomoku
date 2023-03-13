% SWI-Prolog implementation of Gomoku
% René Chenard, 2023

%====================================================%
%    Unit tests for alphabeta.pl.                    %
%                                                    %
%    To run tests: ?- run_tests.                     %
%====================================================%


:- ['../game_components/game_engine'].

:- begin_tests(alphabeta).

test(alphabeta_tic_tac_toe_1) :-
    set_goal(3),
    Pos = [[w,w,b],
           [e,b,e],
           [w,b,e]]-w-(0-1),
    Alpha = -inf,
    Beta = inf,

    time(alphabeta(Pos, Alpha, Beta, GoodPos, Val)),
    GoodPos = _-_-MoveDone,
    
    IdealMove = 1-0,
    show_static_values(Pos, GoodPos, IdealMove),
    
    assertion(MoveDone = IdealMove),
    assertion(Val = 0).

test(alphabeta_tic_tac_toe_2) :-
    set_goal(3),
    Pos = [[w,b,w],
           [b,e,e],
           [b,w,e]]-b-(0-1),
    Alpha = -inf,
    Beta = inf,
    
    time(alphabeta(Pos, Alpha, Beta, GoodPos, Val)),
    GoodPos = _-_-MoveDone,
    
    IdealMove = 2-2,
    show_static_values(Pos, GoodPos, IdealMove),
    
    assertion(MoveDone = IdealMove),
    assertion(Val = -1).

test(alphabeta_tic_tac_toe_3) :-
    set_goal(3),
    Pos = [[w,w,b],
           [e,b,e],
           [w,b,e]]-w-(0-1),
    Alpha = -inf,
    Beta = inf,
    
    time(alphabeta(Pos, Alpha, Beta, GoodPos, Val)),
    GoodPos = _-_-MoveDone,
    
    IdealMove = 1-0,
    show_static_values(Pos, GoodPos, IdealMove),
    
    assertion(MoveDone = IdealMove),
    assertion(Val = 0).

test(alphabeta_tic_tac_toe_4) :-
    set_goal(3),
    Pos = [[w,w,b],
           [b,e,w],
           [e,e,b]]-w-(1-2),
    Alpha = -inf,
    Beta = inf,
    
    time(alphabeta(Pos, Alpha, Beta, GoodPos, Val)),
    GoodPos = _-_-MoveDone,
    
    IdealMove = 2-0,
    show_static_values(Pos, GoodPos, IdealMove),
    
    assertion(MoveDone = IdealMove),
    assertion(Val = 1).

test(alphabeta_tic_tac_toe_5) :-
    set_goal(3),
    Pos = [[e,w,w],
           [e,b,e],
           [b,e,e]]-w-(0-2),
    Alpha = -inf,
    Beta = inf,
    
    time(alphabeta(Pos, Alpha, Beta, GoodPos, Val)),
    GoodPos = _-_-MoveDone,
    
    IdealMove = 0-0,
    show_static_values(Pos, GoodPos, IdealMove),
    
    assertion(MoveDone = IdealMove),
    assertion(Val = 1).
    
:- end_tests(alphabeta).

show_static_values(Board-_-_, MoveDoneBoard-Player-MoveDone, IdealMove) :-
    static_score(MoveDoneBoard, Player, MoveDoneScore),
    make_a_move(Board, Player, IdealMove, IdealMoveBoard),
    static_score(IdealMoveBoard, Player, IdealMoveScore),
    coordinates_to_id(MoveDone, MD_ID),
    format('~nMove played:  ~w;  Static value: ~w~n', [MD_ID, MoveDoneScore]),
    display_gomoku_board(MoveDoneBoard),
    coordinates_to_id(IdealMove, IM_ID),
    format('Ideal move: ~w;  Static value: ~w~n', [IM_ID, IdealMoveScore]),
    display_gomoku_board(IdealMoveBoard).
