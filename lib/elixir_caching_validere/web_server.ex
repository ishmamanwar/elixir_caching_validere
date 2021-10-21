defmodule ElixirCachingValidere.WebServer do
  import Plug.Conn

  def init(options) do
    IO.inspect("Plug init...")
    options
  end

  def call(conn, _opts) do
    IO.inspect(conn)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "Hello World")
  end
end
