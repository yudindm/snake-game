defmodule ControllerTest do
  use ExUnit.Case

  setup do
    {:ok, manager} = GenEvent.start_link([])
    GenEvent.add_handler(manager, SnakeGame.Controller, %SnakeGame.Controller.State{})
    {:ok, manager: manager}
  end

  test "remember keys events from window", %{manager: manager} do
    GenEvent.sync_notify manager, {:dir_cmd, :up}
    GenEvent.sync_notify manager, {:dir_cmd, :left}
    next_dir = GenEvent.call manager, SnakeGame.Controller, :next_dir
    assert :up = next_dir
    next_dir = GenEvent.call manager, SnakeGame.Controller, :next_dir
    assert :left = next_dir
  end

  test "remember pause event from window", %{manager: manager} do
    GenEvent.sync_notify manager, :pause_cmd
    paused? = GenEvent.call manager, SnakeGame.Controller, :pause
    assert true == paused?

    GenEvent.sync_notify manager, :pause_cmd
    paused? = GenEvent.call manager, SnakeGame.Controller, :pause
    assert false == paused?
  end
end
