
defmodule Pickaxe do
  @zeros 4

  def mine(state) do
    {:ok, _} = Task.start(Pickaxe, :loop, [state, self()])
    receive do
      :stop -> nil
      {:we_found_block, block} -> send state[:miner_pid], {:we_found_block, block}
    end
  end

  def loop(state, pickaxe_pid) do
    data = state
      |> Map.put(:random_bits, Utils.random_binary(64))
      |> Map.delete(:miner_pid)

    hash = :crypto.hash(:sha256, Poison.encode!(data))
    # recurse unless we have a valid block
    if String.slice(Base.encode16(hash), 0..@zeros-1) == String.duplicate("0", @zeros) do
      send(pickaxe_pid, {:we_found_block, {hash, data}})
    else
      loop(state, pickaxe_pid)
    end
  end
end

