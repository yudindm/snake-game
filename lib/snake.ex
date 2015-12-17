defmodule Snake do
  defstruct h: {0, 0}, tail: [{0, 0}] 

  def new(x, y) when is_integer(x) and is_integer(y) do
    %Snake{h: {x, y}, tail: [{x, y}]}
  end

  def new([{x, y} | tail]) do
    %Snake{h: {x, y}, tail: parse_tail({x, y}, tail)}
  end

  defp parse_tail({x, y}, []), do: []
  defp parse_tail({x1, y1}, [{x2, y2} | tail]) do
    raise_if_skew {x1, y1}, {x2, y2}
    parse_tail({x2, y2}, tail) ++ [{x2, y2}]
  end

  defp raise_if_skew({x1, y1}, {x2, y2}) do
    unless x1 == x2 or y1 == y2, do: raise "Segments must be vertical or horizontal."
  end
end
