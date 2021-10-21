defmodule ElixirCachingValidere.Application do

  use Application

  def start(_type, _args) do

    children = [
      {Plug.Cowboy, scheme: :http, plug: ElixirCachingValidere.WebServer, options: [port: 4000]},
      {Plug.Cowboy, scheme: :http, plug: ElixirCachingValidere.Router, options: [port: 4001]}
    ]

    opts = [strategy: :one_for_one, name: ElixirCachingValidere.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
