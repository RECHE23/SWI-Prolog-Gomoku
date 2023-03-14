% SWI-Prolog implementation of Gomoku
% René Chenard, 2023

%====================================================%
%                   User interface.                  %
%====================================================%


% Identifies the player:
players_name(b, 'black').   % Black player (b).
players_name(w, 'white').   % White player (w).

% Visual representation of a cell's content:
cell_to_char(e, '┼').       % Empty cell (e).
cell_to_char(b, '●').       % Black player (b).
cell_to_char(w, '◯').       % White player (w).

% Convert a column index to a corresponding letter:
column_nb_to_id(C, ID) :-
    Code is C + 65,     % The character is encoded as an integer (65 = A, ..., Z = 90).
    char_code(ID, Code).

% Converts the indices to a more readable format:
coordinates_to_id(R-C, ID) :-
    column_nb_to_id(C, ColID),
    RowID is R + 1,
    format(atom(ID), '~w~w', [ColID, RowID]).

% Displays the board:
display_gomoku_board(Board) :-
    get_last_index(Board, LastIndex),
    Alignement is 32 - LastIndex,
    format('~*|   ', [Alignement]),
    forall(
        between(0, LastIndex, C),
        (
            column_nb_to_id(C, ID),
            format(' ~w', [ID])
        )
    ),
    nl,
    forall(
        nth1(Y, Board, Row),
        (
            format('~*|~|~t~d~2+ ', [Alignement, Y]),
            maplist([C]>>(cell_to_char(C, Char), format('─~w', [Char])), Row),
            write('─\n')
        )
    ),
    nl.
    
% Asks the user to choose the board size:
request_board_size(N) :-
    request_valid_integer(3, 26, 'Choose the size of the board: (min: 3, max: 26)', N).

% Asks the user to choose the goal:
request_goal(N, Goal) :-
    (
        N > 3 ->
        (
            format(atom(Prompt), 'Choose the number of stones to align in order to win: (min: 3, max: ~d)', N),
            request_valid_integer(3, N, Prompt, Goal)
        )
        ;
        Goal is 3
    ).

% Asks the user to choose a color:
request_players_color :-
    writeln('Which color do you wish to play? Press Enter for an AI vs AI match.'),
    writeln('[b: black ●, w: white ◯, ⏎: AI vs AI]'),
    repeat,
    read_line_to_string(user_input, Input),
    (
        Input = "" ->
        assertz(player(nil))
        ;
        string_lower(Input, Input_Lower),
        atom_string(Color, Input_Lower),
        (
            member(Color, [b, w]) ->
            assertz(player(Color)),
            true
            ;
            writeln('You have to choose a valid option!'),
            fail
        )
    ).

% Asks the user to choose a number between Min and Max:
request_valid_integer(Min, Max, Prompt, Value) :-
    write(Prompt),
    repeat,
    nl,
    read_line_to_string(user_input, Input),
    string_upper(Input, Input_Upper),
    string_chars(Input_Upper, [C|_]),
    ( C = 'Q' -> (cls, halt) ; true),
    (
        catch(number_chars(Value, Input), _, false), integer(Value), between(Min, Max, Value) ->
        true
        ;
        format('You have to choose a number between ~d and ~d.', [Min, Max]),
        fail
    ).

% Asks the user to choose a cell coordinates:
request_cell_coordinates(Board, Row-Col) :-
    writeln('Choose your next move: (i.e. A1)'),
    repeat,
    read_line_to_string(user_input, Input),
    (
        string_upper(Input, Input_Upper),
        string_chars(Input_Upper, [ColChar|RowChars]),
        (
            char_code(ColChar, Code),
            catch(number_chars(Row1, RowChars), _, false),
            Col is Code - 65,
            Row is Row1 - 1,
            are_valid_coordinates(Board, Row-Col) -> true;
            writeln('You have to choose a valid position!'),
            fail
        )
    ).

% Asks the user to choose a next move:
request_next_move(Board, Move) :-
    repeat,
    request_cell_coordinates(Board, Move),
    (
        cell_is_empty(Board, Move) ->
        true
        ;
        writeln('You have to choose an empty cell!'),
        fail
    ).

% Draws a separator:
draw_line :-
    writeln('──────────────────────────────────────────────────────────────────────').

% Clears the screen:
cls :- write('\33\[2J\n').

% Introduces the turn:
introduce_turn(Player, StartTime) :-
    draw_line,
    players_name(Player, PlayersName),
    cell_to_char(Player, PlayersSymbol),
    format('The ~w player (~w) is playing:\n\n', [PlayersName, PlayersSymbol]),
    get_time(StartTime).

% Concludes the turn:
conclude_turn(NewBoard-Player-Move, NextPlayer, StartTime) :-
    other(Player, NextPlayer),
    display_gomoku_board(NewBoard),
    static_score(NewBoard, Player, StaticScore),
    heuristic_score(NewBoard-Player-_, HeuristicScore),
    players_name(Player, PlayersName),
    cell_to_char(Player, PlayersSymbol),
    coordinates_to_id(Move, MoveID),
    get_time(EndTime),
    Time is EndTime - StartTime,
    writeln('┏━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━┓'),
    format('┃ Player: ~w (~w) ~21|┃ Move: ~w ~43|┃ Turn\'s duration: ~3fs~69|┃\n', [PlayersName, PlayersSymbol, MoveID, Time]),
    writeln('┣━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━┳━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━┫'),
    format('┃ Longest streak: ~d ~32|┃ Heuristic score: ~d ~69|┃\n', [StaticScore, HeuristicScore]),
    writeln('┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛'),
    (
        get_goal(Goal),
        StaticScore >= Goal ->
        (
            draw_line,
            writeln('\n                  ╔════════════════════════════╗'),
            format('                  ║ The ~w player (~w) wins! ~47|║\n', [PlayersName, PlayersSymbol]),
            writeln('                  ╚════════════════════════════╝\n'),
            draw_line,
            end_game
        )
        ;
        true
    ).

% Asks the player if we should return to the main menu:
request_continue_playing :-
    writeln('Do you wish to return to the main menu?'),
    repeat,
    read_line_to_string(user_input, Input),
    (
        string_upper(Input, Input_Upper),
        string_chars(Input_Upper, [FirstLetter|_]),
        (
            (
                member(FirstLetter, ['Y', 'N', 'Q']) ->
                (
                    FirstLetter = 'Y' ->
                    welcome_screen
                    ;
                    halt
                )
                ;
                (
                    writeln('You have to choose a valid option!'),
                    fail
                )
            )
        )
    ).

% Informs the player that the game is a tie:
display_tie :-
    draw_line,
    writeln('\n                  ╔══════════════════════════════╗'),
    writeln('                  ║ The board is full!           ║'),
    writeln('                  ║ It\'s a tie!                  ║'),
    writeln('                  ╚══════════════════════════════╝\n'),
    draw_line,
    end_game.

% Some sort of switch/case implementation:
switch(X, [Val:Goal|Cases]) :-
    ( X=Val ->
        call(Goal)
    ;
        switch(X, Cases)
    ).

% Displays the welcome screen with the main menu:
welcome_screen :-
    cls,
    draw_line,
    writeln('        ██████   ██████  ███    ███  ██████  ██   ██ ██    ██'),
    writeln('       ██       ██    ██ ████  ████ ██    ██ ██  ██  ██    ██'),
    writeln('       ██   ███ ██    ██ ██ ████ ██ ██    ██ █████   ██    ██'),
    writeln('       ██    ██ ██    ██ ██  ██  ██ ██    ██ ██  ██  ██    ██'),
    writeln('        ██████   ██████  ██      ██  ██████  ██   ██  ██████ '),
    draw_line,
    writeln('\n Welcome to Gomoku!\n'),
    writeln(' Gomoku is a strategy game for two players.\n'),
    writeln(' The object of the game is to place five consecutive pawns in a line,'),
    writeln(' horizontally, vertically or diagonally, on the fence.\n'),
    writeln(' Each player takes turns placing a token on the board.'),
    writeln(' The player with the black pawns starts the game.'),
    writeln(' The first player to reach 5 consecutive pawns wins the game.\n'),
    writeln(' ╔══════════════════════════════════════════════════════════════════╗'),
    writeln(' ║ Here are your options:                                           ║'),
    writeln(' ║                                                                  ║'),
    writeln(' ║ 1 - Play Gomoku on a 11×11 board.                                ║'),
    writeln(' ║ 2 - Play Gomoku on a 15×15 board.                                ║'),
    writeln(' ║ 3 - Play Gomoku on a 19×19 board.                                ║'),
    writeln(' ║ 4 - Play to Gomoku with custom parameters.                       ║'),
    writeln(' ║ 5 - Play to Tic-Tac-Toe (Bonus).                                 ║'),
    writeln(' ║ Q - Quit the game.                                               ║'),
    writeln(' ║                                                                  ║'),
    writeln(' ╚══════════════════════════════════════════════════════════════════╝'),
    request_valid_integer(1, 6, '\nChoose an option:', Selection),
    switch(Selection, [
        1 : gomoku(11),
        2 : gomoku(15),
        3 : gomoku(19),
        4 : play,
        5 : tictactoe,
        6 : (cls, halt)
    ]).
