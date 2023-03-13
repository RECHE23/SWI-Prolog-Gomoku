% SWI-Prolog implementation of Gomoku
% René Chenard, 2023

%====================================================%
%       Heuristic evaluation of the score.           %
%====================================================%


% Associates a sign to a player (white minimizes; black maximizes):
players_sign(b, 1) :- !.
players_sign(w, -1) :- !.

% Takes into account the advantage of the next move:
advantage(Playing, Player, Factor) :- dif(Playing, Player) -> Factor is 10 ; Factor is 1, !.

% Evaluates the heuristic score of a board:
heuristic_score(Board-Player-_, Score) :-
    get_all_lines(Board, Lines),
    clumped(Lines, RLE),
    sum_score(Player, RLE, Score), !.

% Evaluates the heuristic score on a line:
sum_score(Player, Line, Score) :-
    sum_score(Player, x, Line, 0, Score).
sum_score(Player, PS, [S1-N1, S2-N2, S3-N3|Rest], PreviousScore, Score) :-
    (
        (
            get_goal(Goal),
            (
                ( length(Rest, L), L >= 1 ) ->
                Rest = [NS-_|_]
                ;
                NS = x
            ),
            (
                is_a_winning_row(Goal, PS, S1-N1, S2-N2, S3-N3, NS), value(win, N2, Value), Playing = S2
                ;
                is_an_opened_row(Goal, PS, S1-N1, S2-N2, S3-N3, NS), value(opened, N2, Value), Playing = S2
                ;
                is_a_closed_row(Goal, PS, S1-N1, S2-N2, S3-N3, NS), value(closed, N2, Value), Playing = S2
                ;
                is_a_semi_opened_row_3(Goal, PS, S1-N1, S2-N2, S3-N3, NS), value(semi_opened3, Goal, Value), Playing = S1
                ;
                is_a_semi_opened_row_2(Goal, PS, S1-N1, S2-N2, S3-N3, NS), value(semi_opened2, Goal, Value), Playing = S1
                ;
                is_a_semi_opened_row_1(Goal, PS, S1-N1, S2-N2, S3-N3, NS), value(semi_opened1, Goal, Value), Playing = S1
            ),
            players_sign(Playing, Sign),
            advantage(Playing, Player, Factor),
            NewScore is PreviousScore + Sign * Factor * Value
        )
        ;
        (
            NewScore is PreviousScore
        )
    ), !,
    sum_score(Player, S1, [S2-N2, S3-N3|Rest], NewScore, Score).
sum_score(_, _, _, Score, Score) :- !.

% Pattern recognition for alignements:
is_a_winning_row(Goal, _, _, S2-N2, _, _) :- member(S2, [b, w]), Goal =< N2, !.                                                     % Winning alignement.

is_an_opened_row(Goal, _, e-N1, S2-N2, e-N3, _) :- member(S2, [b, w]), dif(N1, 1), dif(N3, 1), Goal =< N1 + N2 + N3, !.             % Opened row with at least two free spaces on each sides.
is_an_opened_row(Goal, PS, e-1, S2-N2, e-N3, _) :- member(S2, [b, w]), dif(PS, S2), dif(N3, 1), Goal =< 1 + N2 + N3, !.             % Opened row with one free space on the left and at least two free spaces on each sides on the right.
is_an_opened_row(Goal, _, e-N1, S2-N2, e-1, NS) :- member(S2, [b, w]), dif(N1, 1), dif(NS, S2), Goal =< N1 + N2 + 1, !.             % Opened row with at least two free spaces on each sides on the left and one free space on the right.
is_an_opened_row(Goal, PS, e-1, S2-N2, e-1, NS) :- member(S2, [b, w]), dif(PS, S2), dif(NS, S2), Goal =< N2 + 2, !.                 % Opened row with a single free space on each side.

is_a_closed_row(Goal, _, e-N1, S2-N2, S3-_, _) :- member(S2, [b, w]), dif(N1, 1), dif(S3, e), Goal =< N1 + N2, !.                   % Closed row with at least two free spaces on the left.
is_a_closed_row(Goal, _, S1-_, S2-N2, e-N3, _) :- member(S2, [b, w]), dif(S1, e), dif(N3, 1), Goal =< N2 + N3, !.                   % Closed row with at least two free spaces on the right.
is_a_closed_row(Goal, PS, e-1, S2-N2, S3-_, _) :- member(S2, [b, w]), dif(PS, S2), dif(S3, e), Goal =< 1 + N2, !.                   % Closed row with a single free spaces on the left.
is_a_closed_row(Goal, _, S1-_, S2-N2, e-1, NS) :- member(S2, [b, w]), dif(S1, e), dif(NS, S2), Goal =< 1 + N2, !.                   % Closed row with a single free spaces on the right.

is_a_semi_opened_row_3(Goal, e, P-N1, e-1, P-N3, e) :- member(P, [b, w]), Goal =< N1 + 1 + N3, !.                                   % Semi-opened row with free spaces on both sides.
is_a_semi_opened_row_2(Goal, PS, P-N1, e-1, P-N3, NS) :- member(P, [b, w]), ( dif(PS, e) ; dif(NS, e) ), Goal =< N1 + 1 + N3, !.    % Semi-opened row with free spaces on one side.
is_a_semi_opened_row_1(Goal, PS, P-N1, e-1, P-N3, NS) :- member(P, [b, w]), dif(PS, e), dif(NS, e), Goal =< N1 + 1 + N3, !.         % Semi-opened row with no free space on both sides.

% Alignment score of a specified pattern:
value(win, N, Value) :-          Value is 3 * 10**(N - 1), !.
value(opened, N, Value) :-       Value is 3 * 10**(N - 1), !.
value(closed, N, Value) :-       Value is 1 * 10**(N - 1), !.
value(semi_opened3, N, Value) :- Value is 4 * 10**(N - 2), !.
value(semi_opened2, N, Value) :- Value is 2 * 10**(N - 2), !.
value(semi_opened1, N, Value) :- Value is 1 * 10**(N - 2), !.
