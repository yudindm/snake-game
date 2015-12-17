defmodule SnakeTest do
  use ExUnit.Case

  test "create snake at any position" do
    s = Snake.new(10, 20) 
    assert ^s = %Snake{h: {10, 20}, tail: [{10, 20}]}
  end

  test "create snake from point array" do
    s = Snake.new([{10, 20}, {10, 25}, {15, 25}]) 
    assert ^s = %Snake{h: {10, 20}, tail: [{15, 25}, {10, 25}]}
  end

  test "snake must be orthogonal" do
    assert_raise RuntimeError, "Segments must be vertical or horizontal.", fn ->
      Snake.new([{10, 20}, {11, 21}])
    end
  end

  test "grow snake by one up" do
    s = Snake.new(10, 20) |> Snake.grow(:up)
    assert ^s = %Snake{h: {10, 19}, tail: [{10, 20}]}
  end
end
