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

    case read_controller controller do
      {_, _, true} -> :ok
      control ->  
        state = update_state state, control
        Window.draw window, Snake.points(state.field.snake)

        elapsed = :erlang.monotonic_time - t_start
        delay = div(1000, 30) - :erlang.convert_time_unit(elapsed, :native, :milli_seconds)
        if delay > 0, do: :timer.sleep(delay)

        loop state, window, controller
    end
  end

  def read_controller(controller) do
    dir = GenEvent.call controller, SnakeGame.Controller, :next_dir
    paused? = GenEvent.call controller, SnakeGame.Controller, :pause
    stopped? = GenEvent.call controller, SnakeGame.Controller, :stop
    {dir, paused?, stopped?}
  end

  def update_state(state, {_dir, _paused?, true}) do
    state
  end
  def update_state(state, {_dir, true, _stopped?}) do
    state
  end
  def update_state(state, {dir, _paused?, _stopped?}) do
    {move_len, partial_move} = calc_move(state.field.partial_move, {1, 1}, {1, 30})
    state = put_in(state.field.partial_move, partial_move)

    if dir != :none do
      state = put_in(state.field.snake_dir, dir)
    end
    if move_len > 0 do
      state = put_in(state.field.snake, Snake.move(state.field.snake, state.field.snake_dir, move_len))
    end 
    state
  end

  def calc_move({num, denum}, {speed_num, speed_denum}, {tick_num, tick_denum}) do
    inc_num = tick_num * speed_num
    inc_denum = tick_denum * speed_denum
    num = num * inc_denum + inc_num * denum
    denum = denum * tick_denum
    gcd = calc_gcd(num, denum)
    if gcd > 1 do
      num = div(num, gcd)
      denum = div(denum, gcd)
    end
    {div(num, denum), {rem(num, denum), denum}}
  end

  defp calc_gcd(a,0), do: abs(a)
  defp calc_gcd(a,b), do: calc_gcd(b, rem(a,b))
end
