defmodule Snake do
  defstruct h: {0, 0}, tail: [{0, 0}] 

  def new(x, y) when is_integer(x) and is_integer(y) do
    %Snake{h: {x, y}, tail: [{x, y}]}
  end

  def new([h | tail]) do
    %Snake{h: h, tail: parse_tail(h, tail)}
  end

  def grow(snake, grow_dir, len \\ 1) do 
    cur_dir = dir(snake)
    if cur_dir == :none or cur_dir == grow_dir do
      %Snake{snake | h: move_point(snake.h, grow_dir, len)}
    else
      %Snake{h: move_point(snake.h, grow_dir, len), tail: snake.tail ++ [snake.h]}
    end
  end

  defp move_point({x, y}, :right, len), do: {x + len, y}
  defp move_point({x, y}, :left, len),  do: {x - len, y}
  defp move_point({x, y}, :down, len),  do: {x, y + len}
  defp move_point({x, y}, :up, len),    do: {x, y - len}
  defp move_point({x, y}, :none, _),    do: {x, y}

  defp parse_tail(_, []), do: []
  defp parse_tail(h, [p | tail]) do
    raise_if_skew h, p
    parse_tail(p, tail) ++ [p]
  end

  defp dir(%Snake{h: h, tail: tail}) do
    p = Enum.fetch!(tail, -1)
    dir(p, h)
  end
  defp dir({xs, ys}, {xe, ye}) do
    cond do
      xe > xs -> :right
      xe < xs -> :left
      ye > ys -> :down
      ye < ys -> :up
      true -> :none
    end
  end

  defp raise_if_skew({x1, y1}, {x2, y2}) do
    unless x1 == x2 or y1 == y2, do: raise "Segments must be vertical or horizontal."
  end
end
