defmodule Mix.Tasks.Mine do
  use Mix.Task

  @shortdoc "Mine some creaturecoin"
  def run(_) do
    Miner.start
  end
end
