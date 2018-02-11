
defmodule Utils do

  def random_binary(length) do
    Enum.reduce(1..length, <<>>, fn(_, acc) -> acc <> <<:rand.uniform(127)>> end)
  end

  def binary_to_list(<<>>) do
    []
  end

  def binary_to_list(<<i :: size(8), rest :: binary>>) do
    [i] ++ binary_to_list(rest)
  end

end

