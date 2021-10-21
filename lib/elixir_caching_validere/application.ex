defmodule ElixirCachingValidere.Application do

  use Application

  def start(_type, _args) do

    children = [
      # List all child processes to be supervised

      # Start HTTP servers
      {Plug.Cowboy, scheme: :http, plug: ElixirCachingValidere.WebServer, options: [port: 4000]},
      {Plug.Cowboy, scheme: :http, plug: ElixirCachingValidere.Router, options: [port: 4001]},

      # Initialize cache under supervision tree
      # ElixirCachingValidere.LruCache, [1000]

    ]

    opts = [strategy: :one_for_one, name: ElixirCachingValidere.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
