defmodule SnakeGame do
  alias SnakeGame.Snake
  alias SnakeGame.Window
  alias SnakeGame.Model
  alias SnakeGame.Controller
  alias SnakeGame.Rabbit
  alias SnakeGame.Geo
  alias SnakeGame.Math

  def start do
    state = %Model.State{}
    #snake = Snake.new [{10, 10}, {10, 20}, {20, 20}, {20, 29}, {29, 29}]
    snake = Snake.new 10, 10
    state = put_in(state.field.snake, snake)
    state = put_in(state.field.rabbits, [Rabbit.new({15, 15}), Rabbit.new({25, 25})])

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
        Window.draw(window,
          get_snake_points(state.field),
          Enum.map(state.field.rabbits, &(&1.location)))

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
    state = update_in(state.field.cur_tick, &(&1 + 1))

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
        if (state.field.grow_cnt > 0) do
          state = put_in(state.field.snake, Snake.grow(state.field.snake, state.field.cur_dir, move_len))
          state = update_in(state.field.grow_cnt, &(&1 - 1))
        else
          state = put_in(state.field.snake, Snake.move(state.field.snake, state.field.cur_dir, move_len))
        end

        case :queue.out state.field.dir_queue do
          {:empty, _} -> state
          {{:value, cur_dir}, dir_queue} ->
            state = put_in(state.field.cur_dir, cur_dir)
            state = put_in(state.field.dir_queue, dir_queue)
        end

        eaten_rabbit_pos = state.field.rabbits |>
          Enum.find_index(&(Geo.intersected(state.field.snake.h, &1.location)))
        if eaten_rabbit_pos != nil do
          state = update_in(state.field.rabbits, &(List.delete_at(&1, eaten_rabbit_pos)))
          state = update_in(state.field.grow_cnt, &(&1 + 1))
        end
      end 
    end

    keep_rabbit = &(&1.born_at > state.field.cur_tick - 30 * 30 * 2)
    state = update_in(state.field.rabbits,
      &(&1 |> Enum.filter(keep_rabbit) |> Enum.to_list()))

    if (Enum.count(state.field.rabbits, &(&1.alive?)) < 4 and
    Enum.all?(state.field.rabbits, &(&1.born_at < state.field.cur_tick - 150))) do
      state = update_in(state.field.rabbits, &(add_rabbit(state, &1)))
    end

    state
  end

  def get_snake_points(%Model.Field{snake: snake, partial_move: partial_move, cur_dir: cur_dir, grow_cnt: grow_cnt}) do
    {ts, te, t} = case snake do
      %Snake{h: h, tail: [ts]} -> {ts, h, []}
      %Snake{tail: [ts, te | t]} -> {ts, te, [te | t]}
    end
    if (grow_cnt == 0) do
      t = [Geo.move_point(ts, partial_move, Snake.dir(ts, te)) | t]
    else
      t = [ts | t]
    end

    h = Geo.move_point(snake.h, partial_move, cur_dir)
    if (Snake.dir(snake) != cur_dir) do
      [h, snake.h | Enum.reverse(t)]
    else
      [h | Enum.reverse(t)]
    end
  end

  defp add_rabbit(state, list) do
    [Rabbit.new(get_free_location(state.field), state.field.cur_tick) | list]
  end

  defp get_free_location(field) do
    x = find_free_x(field, :rand.uniform(30) - 1)
    y = find_free_y(field, x, :rand.uniform(30) - 1)
    {x, y}
  end
  defp find_free_x(field, x) do
    if (Enum.any?(0..29, &(is_free({x, &1}, field)))) do
      x
    else
      if (x < 29) do
        find_free_x(field, x + 1)
      else
        find_free_x(field, 0)
      end
    end
  end
  defp find_free_y(field, x, y) do
    if (is_free({x, y}, field)) do
      y
    else
      if (y < 29) do
        find_free_y(field, x, y + 1)
      else
        find_free_y(field, x, 0)
      end
    end
  end
  defp is_free(p, field) do
    Enum.all?(field.rabbits, &(not Geo.intersected(&1.location, p))) and
    Enum.all?(Snake.segments(field.snake), &(not Geo.intersected(&1, p)))
  end

  def calc_move({num, denum}, {speed_num, speed_denum}, {tick_num, tick_denum}) do
    inc_num = tick_num * speed_num
    inc_denum = tick_denum * speed_denum
    num = num * inc_denum + inc_num * denum
    denum = denum * tick_denum
    {num, denum} = Math.make_simpler(num, denum)
    {div(num, denum), {rem(num, denum), denum}}
  end
end
