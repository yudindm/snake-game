defmodule SnakeGame.Model do
  defmodule Field do
    defstruct rabbits: %{}, snake: %SnakeGame.Snake{}, snake_dir: :none
  end
  defmodule Score do
    defstruct max_rabbits: 0, cur_rabbits: 0
  end
  defmodule State do
    defstruct score: %Score{}, field: %Field{}
  end
end
