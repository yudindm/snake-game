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
        Window.draw window, get_snake_points(state.field)

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
    if dir != :none do
      state = update_in(state.field.dir_queue, &(:queue.in dir, &1))
    end

    if state.field.cur_dir == :none do
      case :queue.out state.field.dir_queue do
        {:empty, _} -> state
        {{:value, cur_dir}, dir_queue} ->
          state = put_in(state.field.cur_dir, cur_dir)
          state = put_in(state.field.dir_queue, dir_queue)
      end
    end

    if state.field.cur_dir != :none do
      {move_len, partial_move} = calc_move(state.field.partial_move, {1, 1}, {1, 30})
      state = put_in(state.field.partial_move, partial_move)
      if move_len > 0 do
        state = put_in(state.field.snake, Snake.move(state.field.snake, state.field.cur_dir, move_len))

        case :queue.out state.field.dir_queue do
          {:empty, _} -> state
          {{:value, cur_dir}, dir_queue} ->
            state = put_in(state.field.cur_dir, cur_dir)
            state = put_in(state.field.dir_queue, dir_queue)
        end
      end 
    end

    state
  end

  def get_snake_points(%Model.Field{snake: snake, partial_move: partial_move, cur_dir: cur_dir}) do
    {ts, te, t} = case snake do
      %Snake{h: h, tail: [ts]} -> {ts, h, []}
      %Snake{tail: [ts, te | t]} -> {ts, te, [te | t]}
    end
    t = [move_point(ts, partial_move, Snake.dir(ts, te)) | t]

    h = move_point(snake.h, partial_move, cur_dir)
    if (Snake.dir(snake) != cur_dir) do
      [h, snake.h | Enum.reverse(t)]
    else
      [h | Enum.reverse(t)]
    end
  end

  defp move_point({px, py}, dist, dir) do
    case dir do
      :left -> {sub_partial(px, dist), py}
      :right -> {add_partial(px, dist), py}
      :down -> {px, add_partial(py, dist)}
      :up -> {px, sub_partial(py, dist)}
      :none -> {px, py}
    end
  end

  defp add_partial(i, {num, denum}) do
    make_simpler(i * denum + num, denum)
  end

  defp sub_partial(i, {num, denum}) do
    make_simpler(i * denum - num, denum)
  end

  def calc_move({num, denum}, {speed_num, speed_denum}, {tick_num, tick_denum}) do
    inc_num = tick_num * speed_num
    inc_denum = tick_denum * speed_denum
    num = num * inc_denum + inc_num * denum
    denum = denum * tick_denum
    {num, denum} = make_simpler(num, denum)
    {div(num, denum), {rem(num, denum), denum}}
  end

  def make_simpler(num, denum) do
    gcd = calc_gcd(num, denum)
    if gcd > 1 do
      {div(num, gcd), div(denum, gcd)}
    else
      {num, denum}
    end
  end
  
  defp calc_gcd(a,0), do: abs(a)
  defp calc_gcd(a,b), do: calc_gcd(b, rem(a,b))
end
