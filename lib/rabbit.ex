defmodule SnakeGame.Rabbit do
  alias SnakeGame.Rabbit

  defstruct location: {0, 0}, age: 0, alive?: true

  def new(location) do
    %Rabbit{location: location}
  end
end
