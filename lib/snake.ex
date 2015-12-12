defmodule Snake do
  defstruct head: %Vector{}, tail: [] 

  def grow(snake, dir, len \\ 1) when dir != :none do
    if dir == snake.head.dir do
      %Snake{snake | head: Vector.grow(snake.head, len)}
    else
      %Snake{head: %Vector{dir: dir, len: len}, tail: push_segment(snake.tail, snake.head)}
    end
  end

  def move(snake, dir, len \\ 1) when dir != :none do
    snake |> grow(dir, len) |> shrink(len)
  end

  def shrink(%Snake{head: head, tail: tail}, len \\ 1) do
    do_shrink(head, tail, len)
  end

  defp do_shrink(head, [], len) do
    %Snake{head: %Vector{} = Vector.shrink(head, len)}
  end
  defp do_shrink(head, [tail | body], len) do
    case Vector.shrink(tail, len) do
      left when is_integer(left) -> do_shrink(head, body, left)
      tail -> %Snake{head: head, tail: [tail | body]}
    end
  end

  @empty_vector %Vector{}

  defp push_segment(tail, @empty_vector), do: tail
  defp push_segment(tail, vector), do: tail ++ [vector]
end
