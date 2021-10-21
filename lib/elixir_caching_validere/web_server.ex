defmodule ElixirCachingValidere.WebServer do
  import Plug.Conn

  def init(options) do
    IO.inspect("Plug init...")
    options
  end

  def call(conn, _opts) do
    conn = put_resp_content_type(conn, "text/plain")
    send_resp(conn, 200, "Hello World")
  end
end
