defmodule Creaturecoin do

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
