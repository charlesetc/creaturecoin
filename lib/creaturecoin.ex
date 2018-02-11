defmodule Creaturecoin do

  def get_keys() do

    private = if File.exists?("./keys/private_key.pem") do
        File.read!("./keys/private_key.pem")
    else
        {:ok, private} = RsaEx.generate_private_key
        File.write("./keys/private_key.pem", private)
        private
    end
       
    public = if File.exists?("./keys/public_key.pem") do
        File.read!("./keys/public_key.pem")
    else
        {:ok, public} = RsaEx.generate_public_key(private)
        File.write("./keys/public_key.pem", public)
        public
    end

    {private, public}
  end

  def start do
    {:ok, ledger_pid} = Task.start(Ledger, :loop, [[]])
    Process.register ledger_pid, :ledger
    send ledger_pid, :initialize

    {public, private} = get_keys()

    initial_state = %{
      :owner_id => Base.encode16(public),
      :last_block => nil,
      :transactions => []
    }
    {:ok, miner_pid} = Task.start(Miner, :loop, [initial_state])
    Process.register miner_pid, :miner
  end

end
