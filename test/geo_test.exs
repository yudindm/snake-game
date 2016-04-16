defmodule GeoTest do
  alias SnakeGame.Geo
  use ExUnit.Case

  test "check points intersection" do
    p1 = {10, 20} 
    p2 = {10, 20} 
    p3 = {10, 21} 
    assert Geo.intersected(p1, p2)
    assert not Geo.intersected(p1, p3)
  end

  test "check point and line intersection" do
    p1 = {10, 20}
    p2 = {11, 21}
    hl = {{5, 20}, {20, 20}}
    hl2 = {{20, 20}, {5, 20}}
    vl = {{10, 15}, {10, 25}}
    vl = {{10, 25}, {10, 15}}
    assert Geo.intersected(hl, p1)
    assert not Geo.intersected(hl, p2)
    assert Geo.intersected(hl2, p1)
    assert not Geo.intersected(hl2, p2)
    assert Geo.intersected(vl, p1)
    assert not Geo.intersected(vl, p2)
  end
end
