% SWI-Prolog implementation of Gomoku
% René Chenard, 2023

%====================================================%
%    Unit tests for heuristic_evaluation.pl.         %
%                                                    %
%    To run tests: ?- run_tests.                     %
%====================================================%


:- ['../game_components/game_engine'].

:- begin_tests(heuristic_evaluation).

test(line_score) :-
    writeln(''),
    set_goal(5),

    % ==================== Empty row =====================

    time(check_line_score(xeeeeeeeeeex, b, EmptyRowScore)),
    assertion(EmptyRowScore =:= 0),

    % =================== Opened rows ====================

    time(check_line_score(xeeeebeeeeex, b, Opened1NScore)),
    assertion(Opened1NScore =:= 3),

    time(check_line_score(xeeeebbeeeex, b, Opened2NScore)),
    assertion(Opened2NScore =:= 30),

    time(check_line_score(xeeebbbeeeex, b, Opened3NScore)),
    assertion(Opened3NScore =:= 300),

    time(check_line_score(xeeebbbbeeex, b, Opened4NScore)),
    assertion(Opened4NScore =:= 3000),

    time(check_line_score(xeeeeweeeeex, b, Opened1BScore)),
    assertion(Opened1BScore =:= -30),

    time(check_line_score(xeeeewweeeex, b, Opened2BScore)),
    assertion(Opened2BScore =:= -300),

    time(check_line_score(xeeewwweeeex, b, Opened3BScore)),
    assertion(Opened3BScore =:= -3000),

    time(check_line_score(xeeewwwweeex, b, Opened4BScore)),
    assertion(Opened4BScore =:= -30000),

    % =================== Closed rows ====================

    time(check_line_score(xbeeeeeeeeex, b, ClosedNLeft1Score)),
    assertion(ClosedNLeft1Score =:= 1),

    time(check_line_score(xwbeeeeeeeex, b, ClosedNLeft2Score)),
    assertion(ClosedNLeft2Score =:= 1),

    time(check_line_score(xeeeeeeeeebx, b, ClosedNRight1Score)),
    assertion(ClosedNRight1Score =:= 1),

    time(check_line_score(xeeeeeeeebwx, b, ClosedNRight2Score)),
    assertion(ClosedNRight2Score =:= 1),

    time(check_line_score(xeeewbbeeeex, b, Closed2NScore_1)),
    assertion(Closed2NScore_1 =:= 10),
    
    time(check_line_score(xeeebbweeeex, b, Closed2NScore_2)),
    assertion(Closed2NScore_2 =:= 0),

    time(check_line_score(xeeewbbbeeex, b, Closed3NScore_1)),
    assertion(Closed3NScore_1 =:= 100),
    
    time(check_line_score(xeeebbbweeex, b, Closed3NScore_2)),
    assertion(Closed3NScore_2 =:= 100),

    time(check_line_score(xeeewbbbbeex, b, Closed4NScore_1)),
    assertion(Closed4NScore_1 =:= 1000),

    time(check_line_score(xeeebbbbweex, b, Closed4NScore_2)),
    assertion(Closed4NScore_2 =:= 1000),

    time(check_line_score(xeeebwweeeex, b, Closed2BScore)),
    assertion(Closed2BScore =:= -100),

    time(check_line_score(xeeebwwweeex, b, Closed3BScore)),
    assertion(Closed3BScore =:= -1000),

    time(check_line_score(xeeebwwwweex, b, Closed4BScore)),
    assertion(Closed4BScore =:= -10000),

    % ================== Winning rows ====================

    time(check_line_score(xeeebbbbbeex, b, Opened5NScore)),
    assertion(Opened5NScore =:= 30000),
    
    time(check_line_score(xeeewbbbbbex, b, Closed5NScore)),
    assertion(Closed5NScore =:= 30000),
    
    time(check_line_score(xeeewwwwweex, b, Opened5BScore)),
    assertion(Opened5BScore =:= -300000),
    
    time(check_line_score(xeeebwwwwwex, b, Closed5BScore)),
    assertion(Closed5BScore =:= -300000),

    % ================ Semi-opened rows ==================

    time(check_line_score(xebbebbbbeex, b, SemiOpened3NScore_1)),
    assertion(SemiOpened3NScore_1 =:= 4000),

    time(check_line_score(xeebebbbbeex, b, SemiOpened3NScore_2)),
    assertion(SemiOpened3NScore_2 =:= 4000),

    time(check_line_score(xeebbbebbeex, b, SemiOpened3NScore_3)),
    assertion(SemiOpened3NScore_3 =:= 4000),

    time(check_line_score(xeeebebbbeex, b, SemiOpened3NScore_4)),
    assertion(SemiOpened3NScore_4 =:= 4000),

    time(check_line_score(xeeebbebbeex, b, SemiOpened3NScore_5)),
    assertion(SemiOpened3NScore_5 =:= 4000),

    time(check_line_score(xeewbbebbeex, b, SemiOpened2NScore)),
    assertion(SemiOpened2NScore =:= 2000),

    time(check_line_score(xeewbbebbwex, b, SemiOpened1NScore)),
    assertion(SemiOpened1NScore =:= 2000),

    time(check_line_score(xewwewwwweex, b, SemiOpened3BScore_1)),
    assertion(SemiOpened3BScore_1 =:= -40000),

    time(check_line_score(xeewewwwweex, b, SemiOpened3BScore_2)),
    assertion(SemiOpened3BScore_2 =:= -40000),

    time(check_line_score(xeewwwewweex, b, SemiOpened3BScore_3)),
    assertion(SemiOpened3BScore_3 =:= -40000),

    time(check_line_score(xeeewewwweex, b, SemiOpened3BScore_4)),
    assertion(SemiOpened3BScore_4 =:= -40000),

    time(check_line_score(xeeewwewweex, b, SemiOpened3BScore_5)),
    assertion(SemiOpened3BScore_5 =:= -40000),

    time(check_line_score(xeebwwewweex, b, SemiOpened2BScore)),
    assertion(SemiOpened2BScore =:= -20000),

    time(check_line_score(xeebwwewwbex, b, SemiOpened1BScore)),
    assertion(SemiOpened1BScore =:= -20000).

test(line_score_misc) :-
    writeln(''),
    set_goal(5),
    
    time(check_line_score(xeeebwwweeexxeeebbbbweex, b, Score1)),
    assertion(Score1 =:= 0).

:- end_tests(heuristic_evaluation).

check_line_score(Line, Player, Score) :-
    atom_chars(Line, LineList),
    clumped(LineList, RLE),
    sum_score(Player, RLE, Score),
    format('Line = ~w, Player = ~w, Score = ~w\n', [Line, Player, Score]).
    