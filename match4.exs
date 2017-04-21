defmodule Match4 do
  #7 horizontal, 6 vertical
  # 0,0 is bottom left, 6,5 is top right
  defp print_board(map,-1) do
    IO.puts "--0-1-2-3-4-5-6-"
    map
  end

  defp print_board(map,vert_row) do
    IO.puts Integer.to_string(vert_row)<>"|"<>Map.get(map, {0,vert_row}, " ")<>"|"<>Map.get(map, {1,vert_row}, " " )<>"|"<>Map.get(map, {2,vert_row}, " ")<>"|"<>Map.get(map, {3,vert_row}, " ")<>"|"<>Map.get(map, {4,vert_row}, " " )<>"|"<>Map.get(map, {5,vert_row}, " ")<>"|"<>Map.get(map, {6,vert_row}, " ")<>"|"
    print_board(map,vert_row-1)
  end

  defp find_highest(map,col,0) do
    if Map.get(map,{col,0},"0") == "0" do 0 else 1 end
  end
  defp find_highest(map,col,row) do
    if Map.get(map,{col,row},"0") == "0" do
      find_highest(map,col,row-1)
    else
      row+1
    end
  end

  defp find_valid_moves(valid,_map,-1) do valid end
  defp find_valid_moves(valid,map,col) do
    found_highest = find_highest(map,col,5)
    if found_highest <= 5 do #only reasonable moves
    #valid -> {turn - 0 current, 1 next, column}->{x,y}
      Map.update(valid,{0,col},{col,found_highest},fn(_x)->{col,found_highest} end)
      |> find_valid_moves(map,col-1)
    else
      find_valid_moves(valid,map,col-1)
    end
  end

  defp next_move(map,3) do #AI controlled playah
    res = find_valid_moves(%{},map,6) |> Map.values |> Enum.random
    Map.update(map,res, Integer.to_string(3),fn(_x)->Integer.to_string(3) end)
    |> check_game_end(res,3)
    |> next_move(1) #if 3==1 do 3 else 1 end
  end

  defp next_move(map,player) do
    print_board(map,5)
    res = List.to_tuple(Enum.map(String.split(IO.gets("Player " <> Integer.to_string(player) <> " Make a move i.e. 5 5\n")), fn(x) -> String.to_integer(x) end))
    #validation of the move,
    if tuple_size(res)==2 and validate_move(map,res)
    do
      Map.update(map,res, Integer.to_string(player),fn(_x)->Integer.to_string(player) end)
      |> check_game_end(res,player)
      |> next_move(if player==1 do 3 else 1 end) #3 for pc controlled after do
      else
        IO.puts "Move not valid! Put your pieces on the bottom line or on top of already existing ones"
        next_move(map,player)
      end
    end

    defp validate_move(map,res) do
      x = elem(res, 0)
      y = elem(res, 1)
      if (x >= 0 and x <= 6) and (y>=0 and y<= 5) and (Map.get(map,res,"0")=="0") and (
      (y==0 and Map.get(map,{x,y+1},"0")=="0") or
      (y==4 and Map.get(map,{x,y+1},"0")!="0") or
      (Map.get(map,{x,y-1,},"0")!="0" and Map.get(map,{x,y+1},"0")=="0"))
      do true
    else false  end
  end

  defp check_game_end(map,res,player) do
    x = elem(res, 0)
    y = elem(res, 1)
    pl = Integer.to_string(player)
    if(if(Map.get(map,{x-1,y})==pl) do
      if(Map.get(map,{x-2,y})==pl) do
        if(Map.get(map,{x-3,y})==pl) do 3 else 2 end
      else 1 end
    else 0 end +
    if(Map.get(map,{x+1,y})==pl) do
      if(Map.get(map,{x+2,y})==pl) do
        if(Map.get(map,{x+3,y})==pl) do 3 else 2 end
      else 1 end
    else 0 end >= 3 or
    if(Map.get(map,{x,y-1})==pl) do
      if(Map.get(map,{x,y-2})==pl) do
        if(Map.get(map,{x,y-3})==pl) do 3 else 2 end
      else 1 end
    else 0 end +
    if(Map.get(map,{x,y+1})==pl) do
      if(Map.get(map,{x,y+2})==pl) do
        if(Map.get(map,{x,y+3})==pl) do 3 else 2 end
      else 1 end
    else 0 end >= 3 or
    if(Map.get(map,{x+1,y+1})==pl) do
      if(Map.get(map,{x+2,y+2})==pl) do
        if(Map.get(map,{x+3,y+3})==pl) do 3 else 2 end
      else 1 end
    else 0 end +
    if(Map.get(map,{x-1,y-1})==pl) do
      if(Map.get(map,{x-2,y-2})==pl) do
        if(Map.get(map,{x-3,y-3})==pl) do 3 else 2 end
      else 1 end
    else 0 end >= 3 or
    if(Map.get(map,{x-1,y+1})==pl) do
      if(Map.get(map,{x-2,y+2})==pl) do
        if(Map.get(map,{x-3,y+3})==pl) do 3 else 2 end
      else 1 end
    else 0 end +
    if(Map.get(map,{x+1,y-1})==pl) do
      if(Map.get(map,{x+2,y-2})==pl) do
        if(Map.get(map,{x+3,y-3})==pl) do 3 else 2 end
      else 1 end
    else 0 end >= 3)
    do
      print_board(map,5)
      IO.puts "Player "<>Integer.to_string(player)<>" won the game!\n------------------\nStarting new game!"
      start_game()
    else
      if (Map.get(map,{0,5},"0")!="0" and Map.get(map,{1,5},"0")!="0" and Map.get(map,{2,5},"0")!="0" and Map.get(map,{3,5},"0")!="0" and Map.get(map,{4,5},"0")!="0" and Map.get(map,{5,5},"0")!="0" and Map.get(map,{6,5},"0")!="0") do
        IO.puts "Game ends, no more moves available "
        start_game()
      else
        map
      end
    end
  end

  def start_game() do
    next_move(%{},1)
  end

end

IO.puts "Welcome in Connect 4 game"
Match4.start_game()