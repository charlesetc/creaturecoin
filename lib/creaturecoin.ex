
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

defmodule Ledger do
  def loop(chain) do
    receive do
      :initialize ->
        if File.exists?("ledger.json") do
            new_chain = File.read!("ledger.json") |> :erlang.binary_to_term
            loop(new_chain)
        else
            loop([])
        end
      {:new_block, block} ->
        IO.inspect(chain |> Enum.map(fn {hash, block} -> Base.encode16(hash) end))
        new_chain = [block] ++ chain
        save(chain)
        loop(new_chain)
    end
  end

  def save(chain) do
    File.write("ledger.json", :erlang.term_to_binary chain)
  end 
end

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

  def start do
    {:ok, ledger_pid} = Task.start(Ledger, :loop, [[]])
    Process.register ledger_pid, :ledger
    send ledger_pid, :initialize

    initial_state = %{
      :owner_id => "Charles",
      :last_block => nil,
      :transactions => []
    }
    {:ok, miner_pid} = Task.start(Miner, :loop, [initial_state])
    Process.register miner_pid, :miner
  end
end
