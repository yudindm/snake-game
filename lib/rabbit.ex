defmodule SnakeGame.Rabbit do
  alias SnakeGame.Rabbit

  defstruct location: {0, 0}, born_at: 0, alive?: true

  def new(location) do
    %Rabbit{location: location}
  end

  def new(location, time) do
    %Rabbit{location: location, born_at: time}
  end
end
