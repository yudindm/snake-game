defmodule SnakeGame.Model do
  defmodule Field do
    defstruct cur_tick: 0, rabbits: [], snake: %SnakeGame.Snake{}, dir_queue: :queue.new, cur_dir: :none, partial_move: {0, 1}
  end
  defmodule Score do
    defstruct max_rabbits: 0, cur_rabbits: 0
  end
  defmodule State do
    defstruct score: %Score{}, field: %Field{}
  end
end
