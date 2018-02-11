
defmodule Ledger do

  @binary_filename "ledger.binary"

  def loop(chain) do
    receive do
      :initialize ->
        if File.exists?(@binary_filename) do
            new_chain = File.read!(@binary_filename) |> :erlang.binary_to_term
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
    File.write(@binary_filename, :erlang.term_to_binary chain)
  end 

end
