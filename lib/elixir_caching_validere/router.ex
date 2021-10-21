defmodule ElixirCachingValidere.Router do

  alias ElixirCachingValidere.LruCache
  alias ElixirCachingValidere.ServiceUtils

  use Plug.Router

  plug(Plug.Logger)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  get "/api/get/:key" do
    send_resp(conn, 200, to_string(LruCache.get_value(key)))
  end

  post "api/value" do
    case conn.body_params do
      %{"key" => key} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, ServiceUtils.endpoint_success(LruCache.get_value(key)))

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, "no key found")

    end
  end

  post "api/post" do
    case conn.body_params do
      %{"key" => key, "value" => value} ->
        LruCache.post_value(key, value)
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, ServiceUtils.endpoint_success(LruCache.get_value(key)))

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, "incorrect request")

    end
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
