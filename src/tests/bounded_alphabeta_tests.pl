% SWI-Prolog implementation of Gomoku
% René Chenard, 2023

%====================================================%
%    Unit tests for bounded_alphabeta.pl.            %
%                                                    %
%    To run tests: ?- run_tests.                     %
%====================================================%


:- ['../game_components/game_engine'].

:- begin_tests(bounded_alphabeta).

test(prevent_open_four) :-
    set_goal(5),
    Pos = [
        [e,e,e,e,e,e,e,e,e,e,e],
        [e,e,e,e,e,e,e,e,e,e,e],
        [e,e,e,e,e,e,e,e,e,e,e],
        [e,e,e,e,e,e,e,w,e,e,e],
        [e,e,e,b,e,e,b,e,w,e,e],
        [e,e,e,e,w,b,b,b,b,w,e],
        [e,e,e,e,e,w,b,w,e,e,e],
        [e,e,e,e,e,b,w,w,e,e,e],
        [e,e,e,e,b,e,e,w,e,e,e],
        [e,e,e,w,e,e,e,e,b,e,e],
        [e,e,e,e,e,e,e,e,e,e,e]]-w-(3-7),
    Alpha = -inf,
    Beta = inf,
    
    Depth is 1,
    get_time(TimeStamp),
    TimeLimit is 1.5,

    profile(bounded_alphabeta(Pos, Alpha, Beta, GoodPos, Val, Depth, TimeStamp, TimeLimit)),

    GoodPos = _-_-MoveDone,
    
    IdealMove = 2-6,
    show_heuristic_values(Pos, GoodPos, IdealMove, IdealMoveScore),
    
    assertion(MoveDone = IdealMove),
    assertion(Val = IdealMoveScore).

test(prevent_closed_four) :-
    set_goal(5),
    Pos = [
        [e,e,e,e,e,e,e,e,e,e,e],
        [e,e,e,e,e,e,e,e,e,e,e],
        [e,e,e,e,e,e,e,e,e,e,e],
        [e,e,e,e,w,e,e,e,e,e,e],
        [e,e,e,e,b,e,b,e,e,e,e],
        [e,e,e,e,w,b,e,e,e,e,e],
        [e,e,e,e,w,w,b,e,e,e,e],
        [e,e,e,b,w,b,b,e,e,e,e],
        [e,e,e,e,w,e,e,w,e,e,e],
        [e,e,e,e,e,e,e,e,e,e,e],
        [e,e,e,e,e,e,e,e,e,e,e]]-w-(8-4),
    Alpha = -inf,
    Beta = inf,
    
    Depth is 1,
    get_time(TimeStamp),
    TimeLimit is 1.5,

    profile(bounded_alphabeta(Pos, Alpha, Beta, GoodPos, Val, Depth, TimeStamp, TimeLimit)),
    GoodPos = _-_-MoveDone,
    
    IdealMove = 9-4,
    show_heuristic_values(Pos, GoodPos, IdealMove, IdealMoveScore),
    
    assertion(MoveDone = IdealMove),
    assertion(Val = IdealMoveScore).

test(prevent_semi3_four) :-
    set_goal(5),
    Pos = [
        [e,e,e,e,e,e,e,e,e,e,e],
        [e,e,e,e,e,e,e,e,e,e,e],
        [e,e,e,e,e,e,e,e,e,e,e],
        [e,e,e,e,e,e,e,e,e,e,e],
        [e,e,e,e,e,e,b,e,e,e,e],
        [e,e,e,e,e,e,w,e,e,e,e],
        [e,e,w,b,e,w,w,e,e,e,e],
        [e,e,e,b,w,e,w,e,e,e,e],
        [e,e,e,e,b,w,w,e,e,e,e],
        [e,e,b,e,b,b,b,e,e,e,e],
        [e,e,e,e,b,e,e,e,e,e,e]]-b-(9-2),
    Alpha = -inf,
    Beta = inf,
    
    Depth is 1,
    get_time(TimeStamp),
    TimeLimit is 1.5,

    profile(bounded_alphabeta(Pos, Alpha, Beta, GoodPos, Val, Depth, TimeStamp, TimeLimit)),
    GoodPos = _-_-MoveDone,
    
    IdealMove = 9-3,
    show_heuristic_values(Pos, GoodPos, IdealMove, IdealMoveScore),
    
    assertion(MoveDone = IdealMove),
    assertion(Val = IdealMoveScore).

test(win_next_turn) :-
    set_goal(5),
    Pos = [
        [e,b,e,e,e,e,w,e,e,b,e],
        [e,e,w,b,e,b,b,e,w,e,e],
        [w,e,b,w,b,e,w,w,w,w,b],
        [e,b,b,b,w,e,w,b,b,b,e],
        [w,e,b,w,w,w,w,b,e,e,e],
        [e,w,b,b,b,w,b,b,w,e,e],
        [e,e,w,e,b,b,w,w,b,e,e],
        [e,e,e,b,w,w,b,w,e,e,e],
        [e,e,e,e,e,e,w,b,b,e,e],
        [e,e,e,e,e,e,e,e,w,e,e],
        [e,e,e,e,e,e,e,e,e,e,e]]-b-(2-10),
    Alpha = -inf,
    Beta = inf,
    
    Depth is 1,
    get_time(TimeStamp),
    TimeLimit is 1.5,

    profile(bounded_alphabeta(Pos, Alpha, Beta, GoodPos, Val, Depth, TimeStamp, TimeLimit)),
    GoodPos = _-_-MoveDone,
    
    IdealMove = 2-5,
    show_heuristic_values(Pos, GoodPos, IdealMove, IdealMoveScore),
    
    assertion(MoveDone = IdealMove),
    assertion(Val = IdealMoveScore).
    
:- end_tests(bounded_alphabeta).

show_heuristic_values(Board-_-_, MoveDoneBoard-Player-MoveDone, IdealMove, IdealMoveScore) :-
    heuristic_score(MoveDoneBoard-Player-_, MoveDoneScore),
    make_a_move(Board, Player, IdealMove, IdealMoveBoard),
    heuristic_score(IdealMoveBoard-Player-_, IdealMoveScore),
    coordinates_to_id(MoveDone, MD_ID),
    format('~nMove played:  ~w;  Heuristic value: ~w~n', [MD_ID, MoveDoneScore]),
    display_gomoku_board(MoveDoneBoard),
    coordinates_to_id(IdealMove, IM_ID),
    format('Ideal move: ~w;  Heuristic value: ~w~n', [IM_ID, IdealMoveScore]),
    display_gomoku_board(IdealMoveBoard).
