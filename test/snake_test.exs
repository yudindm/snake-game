defmodule SnakeTest do
  use ExUnit.Case

  test "create snake at any position" do
    s = Snake.new(10, 20) 
    assert %Snake{h: {10, 20}, tail: [{10, 20}]} = s
  end

  test "create snake from point array" do
    s = Snake.new([{10, 20}, {10, 25}, {15, 25}]) 
    assert %Snake{h: {10, 20}, tail: [{15, 25}, {10, 25}]} = s
  end

  test "snake must be orthogonal" do
    assert_raise RuntimeError, "Segments must be vertical or horizontal.", fn ->
      Snake.new([{10, 20}, {11, 21}])
    end
  end

  test "grow snake" do
    s = Snake.new(10, 20)

    assert %Snake{h: {10, 19}, tail: [{10, 20}]} = Snake.grow(s, :up)
    assert %Snake{h: {10, 17}, tail: [{10, 20}]} = Snake.grow(s, :up, 3)
    assert %Snake{h: {10, 21}, tail: [{10, 20}]} = Snake.grow(s, :down)
    assert %Snake{h: {10, 23}, tail: [{10, 20}]} = Snake.grow(s, :down, 3)
    assert %Snake{h: { 9, 20}, tail: [{10, 20}]} = Snake.grow(s, :left)
    assert %Snake{h: { 7, 20}, tail: [{10, 20}]} = Snake.grow(s, :left, 3)
    assert %Snake{h: {11, 20}, tail: [{10, 20}]} = Snake.grow(s, :right)
    assert %Snake{h: {13, 20}, tail: [{10, 20}]} = Snake.grow(s, :right, 3)

    s = Snake.new([{10, 20}, {30, 20}])
    assert %Snake{h: {9, 20}, tail: [{30, 20}]} = Snake.grow(s, :left)
    assert %Snake{h: {10, 19}, tail: [{30, 20}, {10, 20}]} = Snake.grow(s, :up)

    s = Snake.new([{10, 20}, {30, 20}, {30, 40}])
    assert %Snake{h: {9, 20}, tail: [{30, 40}, {30, 20}]} = Snake.grow(s, :left)
    assert %Snake{h: {10, 19}, tail: [{30, 40}, {30, 20}, {10, 20}]} = Snake.grow(s, :up)
  end
end
