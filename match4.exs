defmodule Match4 do
  #7 horizontal, 6 vertical
  # 0, 0 is bottom left, 6, 5 is top right
  defp print_board(map, -1) do
    IO.puts "\t--0-1-2-3-4-5-6-"
    map
  end

  defp print_board(map, vert_row) do
    IO.puts "\t"<>Integer.to_string(vert_row) <> "|" <>
      Map.get(map, {0, vert_row}, " ") <> "|" <>
      Map.get(map, {1, vert_row}, " ") <> "|" <>
      Map.get(map, {2, vert_row}, " ") <> "|" <>
      Map.get(map, {3, vert_row}, " ") <> "|" <>
      Map.get(map, {4, vert_row}, " ") <> "|" <>
      Map.get(map, {5, vert_row}, " ") <> "|" <>
      Map.get(map, {6, vert_row}, " ") <> "|" 
    print_board(map, vert_row-1)
  end

  defp get_player_token(id) do
    case id do
      1 -> IO.ANSI.blue() <> "O" <> IO.ANSI.default_color()
      _ -> IO.ANSI.red() <> "#" <> IO.ANSI.default_color()
    end
  end

  defp find_highest(map, col) do
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

  defp find_valid_moves(valid, _map, -1) do valid end

  defp find_valid_moves(valid, map, col) do
    found_highest = find_highest(map, col)
    if found_highest <= 5 do #only reasonable moves
    #valid -> {turn - 0 current, 1 next, column}->{x, y}
      Map.update(valid, {0, col}, {col, found_highest}, fn(_x)->{col, found_highest} end)
      |> find_valid_moves(map, col-1)
    else
      find_valid_moves(valid, map, col-1)
    end
  end

  defp next_move(map, 3) do #AI controlled playah
    res = find_valid_moves(%{}, map, 6) |> Map.values |> Enum.random
    token = get_player_token(3)
    Map.update(map, res, token, fn(_x)->token end)
    |> check_game_end(res, 3)
    |> next_move(1) #if 3==1 do 3 else 1 end
  end

  defp next_move(map, player) do
    print_board(map, 5)
    input = case IO.getn("Player " <> Integer.to_string(player) <> " move: ", 1) |> Integer.parse do
      {int, _} when int >= 0 and int <= 6 -> int
      _ -> -1
    end

    IO.gets("")  # since reading only 1 byte we must read the rest to empty stdin

    # validation of the move
    if input != -1 do
      highest = find_highest(map, input)
      if highest > 5 do
        IO.puts "Column full! Input another"
        next_move(map, player)
      end
      pos = {input, highest}
      token = get_player_token(player)
      Map.update(map, pos, token, fn(_x)->token end)
      |> check_game_end(pos, player)
      |> next_move(if player==1 do 3 else 1 end)
    else
      IO.puts "Move not valid! You must input a number that is in range 0-6"
      next_move(map, player)
    end
  end

  defp validate_move(map, res) do
    x = elem(res, 0)
    y = elem(res, 1)
    if (x >= 0 and x <= 6) and (y >= 0 and y <= 5) and (Map.get(map, res, "0") == "0") and (
      (y==0 and Map.get(map, {x, y+1}, "0") == "0") or
      (y==4 and Map.get(map, {x, y+1}, "0") != "0") or
      (Map.get(map, {x, y-1}, "0") != "0" and Map.get(map, {x, y+1}, "0") == "0")) do
        true
    else
        false
    end
  end

  defp check_game_end(map, res, player) do
    x = elem(res, 0)
    y = elem(res, 1)
    pl = get_player_token(player)
    if(if(Map.get(map, {x-1, y}) == pl) do
      if(Map.get(map, {x-2, y}) == pl) do
        if(Map.get(map, {x-3, y}) == pl) do 3 else 2 end
      else 1 end
    else 0 end +
      if(Map.get(map, {x+1, y}) == pl) do
        if(Map.get(map, {x+2, y}) == pl) do
          if(Map.get(map, {x+3, y}) == pl) do 3 else 2 end
        else 1 end
      else 0 end >= 3 or
    if(Map.get(map, {x, y-1}) == pl) do
      if(Map.get(map, {x, y-2}) == pl) do
        if(Map.get(map, {x, y-3}) == pl) do 3 else 2 end
      else 1 end
    else 0 end +
      if(Map.get(map, {x, y+1}) == pl) do
        if(Map.get(map, {x, y+2}) == pl) do
          if(Map.get(map, {x, y+3}) == pl) do 3 else 2 end
        else 1 end
      else 0 end >= 3 or
    if(Map.get(map, {x+1, y+1}) == pl) do
      if(Map.get(map, {x+2, y+2}) == pl) do
        if(Map.get(map, {x+3, y+3}) == pl) do 3 else 2 end
      else 1 end
    else 0 end +
      if(Map.get(map, {x-1, y-1}) == pl) do
        if(Map.get(map, {x-2, y-2}) == pl) do
          if(Map.get(map, {x-3, y-3}) == pl) do 3 else 2 end
        else 1 end
      else 0 end >= 3 or
    if(Map.get(map, {x-1, y+1}) == pl) do
      if(Map.get(map, {x-2, y+2}) == pl) do
        if(Map.get(map, {x-3, y+3}) == pl) do 3 else 2 end
      else 1 end
    else 0 end +
      if(Map.get(map, {x+1, y-1}) == pl) do
        if(Map.get(map, {x+2, y-2}) == pl) do
          if(Map.get(map, {x+3, y-3}) == pl) do 3 else 2 end
        else 1 end
      else 0 end >= 3)
    do
      print_board(map, 5)
      IO.puts "Player "<>Integer.to_string(player)<>" won the game!\n------------------\nStarting new game!"
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
