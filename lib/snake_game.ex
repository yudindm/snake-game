defmodule SnakeGame do
  def start do
    s = Snake.new [{10, 10}, {10, 60}, {60, 60}, {100, 60}]
    w = Window.start_link
    Window.show w
    Window.draw w, Snake.points(s)
  end
end
