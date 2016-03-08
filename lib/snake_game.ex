defmodule SnakeGame do
  alias SnakeGame.Snake
  alias SnakeGame.Window
  alias SnakeGame.Model
  alias SnakeGame.Controller

  def start do
    state = %Model.State{}
    snake = Snake.new [{10, 10}, {10, 20}, {20, 20}, {20, 29}, {29, 29}]
    state = put_in(state.field.snake, snake)

    {:ok, controller} = GenEvent.start_link([])
    GenEvent.add_handler(controller, Controller, %Controller.State{})

    window = Window.start_link controller
    Window.show window

    :timer.start

    loop state, window, controller
  end

  def loop(state, window, controller) do
    t_start = :erlang.monotonic_time

    control = read_controller controller
    state = update_state state, control
    Window.draw window, Snake.points(state.field.snake)

    elapsed = :erlang.monotonic_time - t_start
    delay = div(1000, 30) - :erlang.convert_time_unit(elapsed, :native, :milli_seconds)
    if delay > 0, do: :timer.sleep(delay)

    loop state, window, controller
  end

  def read_controller(controller) do
    dir = GenEvent.call controller, SnakeGame.Controller, :next_dir
    paused? = GenEvent.call controller, SnakeGame.Controller, :pause
    {dir, paused?}
  end

  def update_state(state, {_dir, true}) do
    state
  end
  def update_state(state, {dir, _paused?}) do
    put_in(state.field.snake, Snake.move(state.field.snake, dir))
  end
end
