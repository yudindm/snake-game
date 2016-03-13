defmodule SnakeGame.Controller do
  use GenEvent

  defmodule State do
    defstruct dir_queue: :queue.new, pause: false, stop: false
  end

  def handle_event({:dir_cmd, dir}, s = %State{}) do
    s = %State{s | dir_queue: :queue.in(dir, s.dir_queue)}
    {:ok, s}
  end

  def handle_event(:quit_cmd, s = %State{}) do
    s = %State{s | stop: true}
    {:ok, s}
  end

  def handle_event(:pause_cmd, s = %State{}) do
    s = %State{s | pause: not s.pause}
    {:ok, s}
  end

  def handle_call(:next_dir, s = %State{}) do
    case :queue.out s.dir_queue do
      {:empty, _} -> {:ok, :none, s}
      {{:value, v}, queue} -> {:ok, v, %State{s | dir_queue: queue}}
    end
  end

  def handle_call(:pause, s = %State{}) do
    {:ok, s.pause, s}
  end

  def handle_call(:stop, s = %State{}) do
    {:ok, s.stop, s}
  end
end
