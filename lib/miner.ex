
defmodule Miner do

  def loop(state) do
    start_pickaxe(state)

    receive do
      {:we_found_block, block} ->
        {hash, data} = block

        # print block
        encoded_hash = Base.encode16(hash)
        IO.puts("found a block! " <> encoded_hash)

        # record block
        record_block(block)

        # send block to others
        Node.list() |> Enum.map(fn node -> Miner.broadcast_block(node, block) end)

        # keep mining
        loop(Map.put(state, :last_block, encoded_hash))

      {:transaction_took_place} -> nil
      {:someone_found_block, block} ->
        {hash, data} = block
        encoded_hash = Base.encode16(hash)

        IO.puts("Damn! someone found a block before me " <> encoded_hash)
        record_block(block)
        # TODO stop miner

        # keep mining
        loop(Map.put(state, :last_block, encoded_hash))
    end
  end

  def record_block(block) do
    send Process.whereis(:ledger), {:new_block, block}
  end

  def broadcast_block(node, block) do
    Node.spawn node, fn ->
      miner_pid = Process.whereis(:miner)
      if miner_pid == nil do
        IO.puts("NOOOO")
      else
        send(miner_pid, {:someone_found_block, block})
      end
    end
  end

  def start_pickaxe(state) do
    pickaxe_state = Map.put(state, :miner_pid, :erlang.self())
    {:ok, _} = Task.start(Pickaxe, :mine, [pickaxe_state])
  end

end
