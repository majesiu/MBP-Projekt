defmodule Match4 do
  defmodule AI do
    def minimax(map, depth, player) do
      minimax(map, nil, depth, player)
    end

    defp minimax(map, move, depth, player) do
      cond do
        Match4.is_winning_move(map, move, -player) ->
          case player do
            1 -> depth * 100
            -1 -> depth * -100
          end
        depth == 0 ->
          # sum
          List.foldl(Match4.calc_move_value(map, move, -player), 0,
                                            fn(x, y) -> x+y end)
        true ->  # else
          moves = find_valid_moves(map) |> Map.values
          if player == -1 do
            movesValues = Enum.map(moves, fn(mv) ->
              Map.update(map, mv, player, fn(_x) -> player end)
              |> minimax(mv, depth-1, -player)
            end)
            if move == nil do  # root call - zwróć ruch o maks wartości (najlepszy)
              maxValue = Enum.max(movesValues)
              Enum.at(moves, Enum.find_index(movesValues,
                                             fn(v) -> v == maxValue end))
            else
              Enum.max(movesValues, fn -> 0 end)
            end
          else
            Enum.map(moves, fn(mv) ->
              Map.update(map, mv, player, fn(_x) -> player end)
              |> minimax(mv, depth-1, -player)
            end)
            |> Enum.min(fn -> 0 end)
          end
      end
    end

    def find_valid_moves(map) do
      find_valid_moves(%{}, map, 6)
    end

    defp find_valid_moves(valid, _map, -1) do valid end

    defp find_valid_moves(valid, map, col) do
      found_highest = Match4.find_highest(map, col)
      if found_highest <= 5 do  # only reasonable moves
      # valid -> {turn - 0 current, 1 next, column}->{x, y}
        Map.update(valid, {0, col}, {col, found_highest},
                   fn(_x)->{col, found_highest} end)
                   |> find_valid_moves(map, col-1)
      else
        find_valid_moves(valid, map, col-1)
      end
    end
  end


  #7 horizontal, 6 vertical
  # (0, 0) is bottom left, (6, 5) is top right
  def print_board(map, -1) do
    IO.puts "\t  -----------------------------\n" <>
      "\t    0   1   2   3   4   5   6\n"
    map
  end

  def print_board(map, vert_row) do
    IO.puts "\t  -----------------------------\n" <>
      "\t"<>Integer.to_string(vert_row) <> " | " <>
      get_player_token(Map.get(map, {0, vert_row}, " ")) <> " | " <>
      get_player_token(Map.get(map, {1, vert_row}, " ")) <> " | " <>
      get_player_token(Map.get(map, {2, vert_row}, " ")) <> " | " <>
      get_player_token(Map.get(map, {3, vert_row}, " ")) <> " | " <>
      get_player_token(Map.get(map, {4, vert_row}, " ")) <> " | " <>
      get_player_token(Map.get(map, {5, vert_row}, " ")) <> " | " <>
      get_player_token(Map.get(map, {6, vert_row}, " ")) <> " | "
    print_board(map, vert_row-1)
  end

  defp get_player_token(id) do
    case id do
      1 -> IO.ANSI.blue() <> "@" <> IO.ANSI.default_color()
      -1 -> IO.ANSI.red() <> "#" <> IO.ANSI.default_color()
      _ -> " "
    end
  end

  def find_highest(map, col) do
    find_highest(map, col, 5)
  end

  defp find_highest(map, col, 0) do
    if Map.get(map, {col, 0}, "0") == "0" do 0 else 1 end
  end

  defp find_highest(map, col, row) do
    if Map.get(map, {col, row}, "0") == "0" do
      find_highest(map, col, row-1)
    else
      row+1
    end
  end

  defp next_move(map, -1) do #AI controlled playah
  # res = AI.find_valid_moves(map) |> Map.values |> Enum.random
    move = AI.minimax(map, 5, -1)
    Map.update(map, move, -1, fn(_x)->-1 end)
    |> check_game_end(move, -1)
    |> next_move(1)
  end

  defp next_move(map, player) do
    IO.puts ""
    print_board(map, 5)
    input = case IO.getn("Player " <> Integer.to_string(player) <> " move: ", 1) |> Integer.parse do
      {int, _} when int >= 0 and int <= 6 -> int
      _ -> -1
    end

    # since reading only 1 byte the newline is left out in stdin and must be cleared
    IO.gets("")

    # validation of the move
    if input != -1 do
      highest = find_highest(map, input)
      if highest > 5 do
        IO.puts "Column full! Input another"
        next_move(map, player)
      end
      pos = {input, highest}
      Map.update(map, pos, player, fn(_x)->player end)
      |> check_game_end(pos, player)
      |> next_move(-player)
    else
      IO.puts "Move not valid! You must input a number that is in range 0-6"
      next_move(map, player)
    end
  end

  def calc_move_value(map, move, player) do
    # Returns a list (!) containing number of tokens on every axis
    if move == nil do
      []
    else
      x = elem(move, 0)
      y = elem(move, 1)
      pl = player
      v = []
      v = v ++
        [if(Map.get(map, {x-1, y}) == pl) do
          if(Map.get(map, {x-2, y}) == pl) do
            if(Map.get(map, {x-3, y}) == pl) do 3 else 2 end
          else 1 end
        else 0 end +
          if(Map.get(map, {x+1, y}) == pl) do
            if(Map.get(map, {x+2, y}) == pl) do
              if(Map.get(map, {x+3, y}) == pl) do 3 else 2 end
            else 1 end
          else 0 end]

      v = v ++
        [if(Map.get(map, {x, y-1}) == pl) do
          if(Map.get(map, {x, y-2}) == pl) do
            if(Map.get(map, {x, y-3}) == pl) do 3 else 2 end
          else 1 end
        else 0 end +
          if(Map.get(map, {x, y+1}) == pl) do
            if(Map.get(map, {x, y+2}) == pl) do
              if(Map.get(map, {x, y+3}) == pl) do 3 else 2 end
            else 1 end
          else 0 end]

      v = v ++
        [if(Map.get(map, {x+1, y+1}) == pl) do
          if(Map.get(map, {x+2, y+2}) == pl) do
            if(Map.get(map, {x+3, y+3}) == pl) do 3 else 2 end
          else 1 end
        else 0 end +
          if(Map.get(map, {x-1, y-1}) == pl) do
            if(Map.get(map, {x-2, y-2}) == pl) do
              if(Map.get(map, {x-3, y-3}) == pl) do 3 else 2 end
            else 1 end
          else 0 end]

      v ++
        [if(Map.get(map, {x-1, y+1}) == pl) do
          if(Map.get(map, {x-2, y+2}) == pl) do
            if(Map.get(map, {x-3, y+3}) == pl) do 3 else 2 end
          else 1 end
        else 0 end +
          if(Map.get(map, {x+1, y-1}) == pl) do
            if(Map.get(map, {x+2, y-2}) == pl) do
              if(Map.get(map, {x+3, y-3}) == pl) do 3 else 2 end
            else 1 end
          else 0 end]
    end
  end

  def is_winning_move(map, move, player) do
    Enum.any?(calc_move_value(map, move, player), fn(x) -> x >= 3 end)
  end

  defp check_game_end(map, res, player) do
    if is_winning_move(map, res, player) do
      print_board(map, 5)
      IO.puts "Player " <> Integer.to_string(player) <> " won the game!\n" <>
        "========================================\nStarting new game!\n"
      start_game()
    else
      if (
        Map.get(map, {0, 5}, "0") != "0" and
        Map.get(map, {1, 5}, "0") != "0" and
        Map.get(map, {2, 5}, "0") != "0" and
        Map.get(map, {3, 5}, "0") != "0" and
        Map.get(map, {4, 5}, "0") != "0" and
        Map.get(map, {5, 5}, "0") != "0" and
        Map.get(map, {6, 5}, "0") != "0")
      do
        IO.puts "Game ends, no more moves available"
        start_game()
      else
        map
      end
    end
  end

  def start_game() do
    next_move(%{}, 1)
  end

end


IO.puts "=== Welcome in Connect 4 game ===\n"
Match4.start_game()
