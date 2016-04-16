defmodule SnakeGame.Math do

  def add_partial(i, {num, denum}) do
    make_simpler(i * denum + num, denum)
  end

  def sub_partial(i, {num, denum}) do
    make_simpler(i * denum - num, denum)
  end

  def make_simpler(num, denum) do
    gcd = calc_gcd(num, denum)
    if gcd > 1 do
      {div(num, gcd), div(denum, gcd)}
    else
      {num, denum}
    end
  end
  
  defp calc_gcd(a,0), do: abs(a)
  defp calc_gcd(a,b), do: calc_gcd(b, rem(a,b))
end
