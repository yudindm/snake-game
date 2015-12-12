defmodule Vector do
  defstruct dir: :none, len: 0

  def grow(vector, len) do
    %Vector{vector | len: vector.len + len}
  end

  def shrink(vector, len) do
    if vector.len < len do
      len - vector.len
    else
      %Vector{vector | len: vector.len - len}
    end
  end
end
