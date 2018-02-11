defmodule Ledger do

  @binary_filename "ledger.binary"
  @txt_filename "ledger.txt"

  def loop(chain, socket \\ nil) do
    receive do
      :initialize ->

        if File.exists?(@binary_filename) do
            new_chain = File.read!(@binary_filename) |> :erlang.binary_to_term
            loop(new_chain, socket)
        else
            loop([], socket)
        end
      {:new_block, block} ->
        IO.inspect(chain |> Enum.map(fn {hash, _} -> Base.encode16(hash) end))
        new_chain = [block] ++ chain
        save(chain)
        loop(new_chain, socket)
    end
  end

  def save(chain) do
    File.write(@binary_filename, :erlang.term_to_binary chain)
    File.write(
      @txt_filename,
      chain
      |> Enum.map(fn {hash, _} -> Base.encode16(hash) end)
      |> Enum.join("\n")
    )
  end 

end
