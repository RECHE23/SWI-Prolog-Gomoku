% SWI-Prolog implementation of Gomoku
% René Chenard, 2023

%====================================================%
%                    Gomoku Board.                   %
%====================================================%


% Creates the board:
create_gomoku_board(N, Board) :-
    length(Board, N),
    maplist(create_row(N), Board).

% Creates a row:
create_row(N, Row) :-
    length(Row, N),
    maplist(=(e), Row), !.

% Get the content of a position on the board:
get_cell_content(Board, Row-Col, Content) :-
    nth0(Row, Board, RowList),
    nth0(Col, RowList, Content).

% Sets the content of a position on the board:
set_cell_content(Board, Row-Col, Content, NewBoard) :-
    nth0(Row, Board, OldRow),
    replace(OldRow, Col, Content, NewRow),
    replace(Board, Row, NewRow, NewBoard).

% Utilitary predicate for set_cell_content/4:
replace(List, Index, NewElem, NewList) :-
    nth0(Index, List, _, Rest),
    nth0(Index, NewList, NewElem, Rest).

% Checks if the cell is empty:
cell_is_empty(Board, Row-Col) :-
    get_cell_content(Board, Row-Col, e).

% Checks if at least one cell is empty:
has_an_empty_cell(Board) :-
    cell_is_empty(Board, _).

% Checks if all cells are empty:
contains_only_empty_cells(List) :-
    \+ (member(Element, List), Element \= e).

% Checks if the position exists on the board:
are_valid_coordinates(Board, Row-Col) :-
    get_cell_content(Board, Row-Col, _).

% Returns the last index on the board:
get_last_index(Board, LastIndex) :-
    length(Board, N),
    LastIndex is N - 1.
    
% Gets all possible moves (empty cells):
get_possible_moves(Board, Moves) :-
    findall(Move, cell_is_empty(Board, Move), Moves).

% Makes a move:
make_a_move(Board, Player, Move, NewBoard) :-
    set_cell_content(Board, Move, Player, NewBoard).
        
% Finds the indices of the start of a diagonal line down:
start_of_a_diagonal_line_down(Row-Col, Goal, LastIndex) :-
    LastUsefulIndex is LastIndex - Goal + 1,
    between(0, LastUsefulIndex, Row),
    between(0, LastUsefulIndex, Col),
    (
      (Row = 0 ; Col = 0) ->
      true
      ;
      (Row = 0)
      ;
      (Col = 0)
    ).

% Finds the indices of the start of a diagonal line up:
start_of_a_diagonal_line_up(Row-Col, Goal, LastIndex) :-
    Goal_1 is Goal - 1,
    LastUsefulIndex is LastIndex - Goal_1,
    between(Goal_1, LastIndex, Row),
    between(0, LastUsefulIndex, Col),
    (
      (Row = LastIndex ; Col = 0) ->
      true
      ;
      (Row = LastIndex)
      ;
      (Col = 0)
    ).

% Finds the indices of the start of an horizontal line:
start_of_an_horizontal_line(Row-Col, _, LastIndex) :-
    between(0, LastIndex, Row),
    Col = 0.

% Finds the indices of the start of a vertical line:
start_of_a_vertical_line(Row-Col, _, LastIndex) :-
    between(0, LastIndex, Col),
    Row = 0.

% Extract all lines in a given direction from given positions:
get_lines(Board, StartingIndices, Direction, [x|Line]) :-
    get_goal(Goal),
    get_last_index(Board, LastIndex),
    findall(Line, (
              call(StartingIndices, Row-Col, Goal, LastIndex),
              get_line(Board, Row-Col, Direction, [x], Line)
            ), Line).

% Extract a line in a given direction from a given position:
get_line(Board, R-C, StepR-StepC, Accumulator, Line) :-
    get_cell_content(Board, R-C, Content), !,
    NewAccumulator = [Content|Accumulator],
    NewR is R + StepR,
    NewC is C + StepC,
    get_line(Board, NewR-NewC, StepR-StepC, NewAccumulator, Line).
get_line(_, _, _, Line, Line).

% Extract all lines, vertical, horizontal or diagonal:
get_all_lines(Board, Lines) :-
    get_lines(Board, start_of_a_diagonal_line_down, 1-1, DiagonalLinesDown),
    get_lines(Board, start_of_a_diagonal_line_up, -1-1, DiagonalLinesUp),
    get_lines(Board, start_of_an_horizontal_line, 0-1, HorizontalLines),
    get_lines(Board, start_of_a_vertical_line, 1-0, VerticalLines),
    flatten([HorizontalLines, VerticalLines, DiagonalLinesUp, DiagonalLinesDown], Lines).
