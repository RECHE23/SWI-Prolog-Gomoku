% SWI-Prolog implementation of Gomoku
% René Chenard, 2023


%====================================================%
%                  Intelligent agent.                %
%====================================================%


% The agent selects the best move:
agent(Board, Player, Move) :-
    other(Player, LastPlayer),
    (
        % Checks if it is possible to win this turn:
        winning_move(Board, Player, Move)
        ;
        % Checks if it is possible to lose this turn:
        winning_move(Board, LastPlayer, Move)
        ;
        (
            length(Board, 3) ->
            % Alpha-Beta search:
            alphabeta(Board-LastPlayer-nil, -inf, inf, _-_-Move, _)
            ;
            % Bounded (in time and depth) Alpha-Beta search:
            (
                get_time(Time),
                bounded_alphabeta(Board-LastPlayer-nil, -inf, inf, _-_-Move, _, 1, Time, 10)
            )
        )
    ).

% Returns the possible moves for this turn:
moves(Board-LastPlayer-_, PosList) :-
    not(game_over(Board, _)),
    % Gets the all the emptys cells on the board:
    get_possible_moves(Board, PossibleMoves),
    % Shuffles the order of exploration for some unpredictability:
    random_permutation(PossibleMoves, PossibleMovesShuffled),
    % Checks who's turn it is:
    other(Player, LastPlayer),
    % Build the possible transitions:
    bagof(NewBoard-Player-Move,
        (
            member(Move, PossibleMovesShuffled),
            make_a_move(Board, Player, Move, NewBoard)
        ), PosList).

% Evaluates the static score:
staticval(Board-_-_, Value) :-
    game_over(Board, Winner), !,
    (
        Winner = nil ->
        Value is 0
        ;
        (
            Winner = b ->
            Value is 1
            ;
            Value is -1
        )
    ).

% Evaluates the heuristic score:
heuristicval(Pos, Value) :-
    heuristic_score(Pos, Value), !.

% Checks who's turn it is:
min_to_move(_-b-_).   % -> White player's turn (Preceeded by the black player).
max_to_move(_-w-_).   % -> Black player's turn (Preceeded by the white player).
max_to_move(_-nil-_). % -> Black player's turn (Is the first to play).
