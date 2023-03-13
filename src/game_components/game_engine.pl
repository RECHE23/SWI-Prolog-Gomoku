% SWI-Prolog implementation of Gomoku
% René Chenard, 2023

%====================================================%
%                     Game engine .                  %
%====================================================%


% Loads every component of the game:
:- [board].
:- [user_interface].
:- [agent].
:- ['../evaluation_algorithms/static_evaluation'].
:- ['../evaluation_algorithms/heuristic_evaluation'].
:- ['../search_algorithms/alphabeta'].
:- ['../search_algorithms/bounded_alphabeta'].

% Specify which color is playing the user, if any:
:- dynamic player/1.

% Help switching player's turn:
other(b, w).
other(w, b).

% Start of game routine:
begin_game(Firstplayer, Goal, BoardSize, Board) :-
    % Sets the goal:
    set_goal(Goal),
    % Creates the board:
    create_gomoku_board(BoardSize, Board),
    % Sets who's the first to play:
    Firstplayer = b,
    % Clears the screen:
    cls,
    % Displays the board:
    display_gomoku_board(Board),
    % Start the first turn:
    turn(Board, Firstplayer, _).

% End of game routine:
end_game :-
    % Reset the goal:
    retractall(goal(_)),
    % Asks the player if we should return to the menu:
    request_continue_playing.

% Establish a turn:
turn(Board, Player, NewBoard) :-
    % Introduces the turn:
    introduce_turn(Player, StartTime),
    (   % Checks if there is a an empty cell:
        has_an_empty_cell(Board) ->
        (
            (   % Checks if it is the user's turn:
                player(Player) ->
                (   % It is the user's turn; queries the next move:
                    request_next_move(Board, Move)
                )
                ;
                (   % The AI plays a turn:
                    agent(Board, Player, Move)
                )
            ),
            % Returns the new board resulting from a move:
            make_a_move(Board, Player, Move, NewBoard)
        )
        ;
        % There is no empty cell left; it is a tie:
        display_tie
    ),
    % Concludes the turn:
    conclude_turn(NewBoard-Player-Move, NextPlayer, StartTime),
    % Recursive call to turn/3:
    turn(NewBoard, NextPlayer, _).
