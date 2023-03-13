% SWI-Prolog implementation of Gomoku
% René Chenard, 2023


:- set_prolog_flag(verbose, silent).

% Load all the components:
:- ['./src/game_components/game_engine'].

% Starts the game with custom parameters:
play :-
    set_board_size(BoardSize),
    request_goal(BoardSize, Goal),
    request_players_color,
    begin_game(Firstplayer, Goal, BoardSize, Board).

% Starts the game with the standard parameters:
gomoku(Size) :-
    request_players_color,
    begin_game(Firstplayer, 5, Size, Board).

% Start a game of Tic-Tac-Toe:
tictactoe :-
    request_players_color,
    begin_game(Firstplayer, 3, 3, Board).

% Displays the welcome screen with the menu:
:- initialization welcome_screen.
