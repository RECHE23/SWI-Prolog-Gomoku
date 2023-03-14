% SWI-Prolog implementation of Gomoku
% René Chenard, 2023

%====================================================%
%           Static evaluation of the score.          %
%====================================================%


% Static evaluation of the longest alignement:
static_score(Board, Player, Score) :-
    get_last_index(Board, LastIndex),
    LastIndex_1 is LastIndex - 1,
    member(Player, [b, w]),
    setof(Streak,
        (R)^(
            between(0, LastIndex, R),
            check_direction(Board, Player, R-0, 0-1, 0, 0, Streak)
        ),
        HorizontalStreaks),
    setof(Streak,
        (C)^(
            between(0, LastIndex, C),
            check_direction(Board, Player, 0-C, 1-0, 0, 0, Streak)
        ),
        VerticalStreaks),
    setof(Streak,
        (R, C)^(
            between(0, LastIndex_1, R),
            between(0, LastIndex_1, C),
            (
                (R = 0 ; C = 0) ->
                true
                ;
                (R = 0)
                ;
                (C = 0)
        ),
        check_direction(Board, Player, R-C, 1-1, 0, 0, Streak)
    ),
    DiagonalDownStreaks),
    setof(Streak,
        (R, C)^(
            between(1, LastIndex, R),
            between(0, LastIndex_1, C),
            (
                (R = LastIndex ; C = 0) ->
                true
                ;
                (R = LastIndex)
                ;
                (C = 0)
            ),
            check_direction(Board, Player, R-C, -1-1, 0, 0, Streak)
        ),
        DiagonalUpStreaks),
    flatten([HorizontalStreaks, VerticalStreaks, DiagonalDownStreaks, DiagonalUpStreaks], Streaks),
    max_list(Streaks, Score), !.

% Find the longest streak in a given direction from a specified cell:
check_direction(Board, Player, R-C, StepR-StepC, Streak, PreviousLongestStreak, LongestStreak) :-
    (
        get_cell_content(Board, R-C, Content),
        (
            Content = Player ->
            (
                CurrentStreak is Streak + 1,
                (
                    CurrentStreak > PreviousLongestStreak ->
                    NewLongestStreak = CurrentStreak
                    ;
                    NewLongestStreak = PreviousLongestStreak
                )
            )
            ;
            (
                CurrentStreak is 0,
                NewLongestStreak = PreviousLongestStreak
            )
        ),
        NewR is R + StepR,
        NewC is C + StepC,
        !,
        check_direction(Board, Player, NewR-NewC, StepR-StepC, CurrentStreak, NewLongestStreak, LongestStreak)
    ).
check_direction(_, _, _, _, _, PreviousLongestStreak, PreviousLongestStreak) :- !.

% Checks if a move results in a winning alignment:
winning_move(Board, Player, Move) :-
    get_goal(Goal),
    cell_is_empty(Board, Move),
    set_cell_content(Board, Move, Player, NewBoard),
    static_score(NewBoard, Player, Score),
    Score >= Goal.

% Checks if the game is over:
game_over(Board, Winner) :-
    get_goal(Goal),
    member(Winner, [b, w]),
    static_score(Board, Winner, Score),
    Score >= Goal, !
    ;
    not(has_an_empty_cell(Board)) -> Winner = nil.
