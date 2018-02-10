# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :creaturecoin, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:creaturecoin, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :libcluster,
  topologies: [
    cryptocreatures: [
      # The selected clustering strategy. Required.
      strategy: Cluster.Strategy.Gossip,
      # Configuration for the provided strategy. Optional.
      config: [
        # hosts: [],
        hosts: [:"beacon@127.0.0.1"],
        port: 6200,
      ],
      # config: [hosts: [:"beacon@127.0.0.1", :"b@127.0.0.1"]],
      # The function to use for connecting nodes. The node
      # name will be appended to the argument list. Optional
      connect: {:net_kernel, :connect, []},
      # The function to use for disconnecting nodes. The node
      # name will be appended to the argument list. Optional
      disconnect: {:net_kernel, :disconnect, []},
      # The function to use for listing nodes.
      # This function must return a list of node names. Optional
      list_nodes: {:erlang, :nodes, [:connected]},
      # A list of options for the supervisor child spec
      # of the selected strategy. Optional
      child_spec: [restart: :transient]
    ]
  ]
