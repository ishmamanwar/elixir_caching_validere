defmodule ElixirCachingValidere.Router do

  alias ElixirCachingValidere.LruCache

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/api/get-all" do
    send_resp(conn, 200, to_string(LruCache.get_all()))
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
