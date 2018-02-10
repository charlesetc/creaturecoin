defmodule CreaturecoinTest do
  use ExUnit.Case
  doctest Creaturecoin

  test "greets the world" do
    assert Creaturecoin.hello() == :world
  end
end
