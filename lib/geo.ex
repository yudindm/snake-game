defmodule SnakeGame.Geo do
  import SnakeGame.Math

  def move_point({px, py}, dist, dir) do
    case dir do
      :left -> {sub_partial(px, dist), py}
      :right -> {add_partial(px, dist), py}
      :down -> {px, add_partial(py, dist)}
      :up -> {px, sub_partial(py, dist)}
      :none -> {px, py}
    end
  end

  def intersected({{x11, y11}, {x12, y12}}, {x2, y2}) do
    cond do
      (x11 > x12) -> intersected({{x12, y11}, {x11, y12}}, {x2, y2})
      (y11 > y12) -> intersected({{x11, y12}, {x12, y11}}, {x2, y2})
      (x11 == x12) -> x11 == x2 and y11 <= y2 and y12 >= y2
      (y11 == y12) -> y11 == y2 and x11 <= x2 and x12 >= x2
    end
  end
  def intersected({x1, y1}, {x2, y2}), do: x1 == x2 and y1 == y2

end
