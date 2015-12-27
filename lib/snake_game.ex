defmodule SnakeGame do
  def start do
    s = Snake.new [{0, 0}, {0, 10}, {10, 10}, {10, 20}, {20, 20}, {20, 29}, {29, 29}]
    w = Window.start_link
    Window.show w
    Window.draw w, Snake.points(s)
  end
end
