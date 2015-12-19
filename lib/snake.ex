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

  def shrink(snake, len \\ 1) do
    do_shrink(snake.h, snake.tail, len)
  end

  def move(snake, dir, len \\ 1) do
    snake |> grow(dir, len) |> shrink(len)
  end

  defp do_shrink(h, [l], len) do
    tail_len = len(h, l)
    if tail_len > len do
      %Snake{h: h, tail: [move_point(l, dir(l, h), len)]}
    else
      %Snake{h: h, tail: [h]}
    end
  end
  defp do_shrink(h, [l, p | body], len) do
    tail_len = len(l, p)
    if tail_len > len do
      %Snake{h: h, tail: [move_point(l, dir(l, p), len), p | body]}
    else
      do_shrink(h, [p | body], len - tail_len)
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

  defp len({x1, y1}, {x2, y2}), do: abs((x2 - x1) + (y2 - y1))

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
