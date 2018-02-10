
import IO

defmodule Utils do

  def random_binary(length) do
    Enum.reduce(1..length, <<>>, fn(_, acc) -> acc <> <<:rand.uniform(127)>> end)
  end

end

defmodule Miner do
  @zeros 5

  def listen do
    receive do
      {:found_block, hash, block} ->
        # TODO: broadcast to rest of peoples
        puts("found a block! " <> hash)
    end
    listen()
  end

  def mine(miner_pid, owner, last_block, extra_data) do
    block = %{
      :owner => owner,
      :last_block => last_block,
      :extra_data => extra_data,
      :random_bits => Utils.random_binary(128),
    }
    hash = Base.encode16(:crypto.hash(:sha256, Poison.encode!(block)))

    # recurse unless we have a valid block
    if String.slice(hash, 0..@zeros-1) == String.duplicate("0", @zeros) do
      send(miner_pid, {:found_block, hash, block})
    else
      mine(miner_pid, owner, last_block, extra_data)
    end
  end

  def start do
    pid = spawn(Miner, :listen, [])
    mine(pid, "charles chamberlain!", "no last block", "nope")
  end
end
