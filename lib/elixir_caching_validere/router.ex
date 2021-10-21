defmodule ElixirCachingValidere.Router do

  @moduledoc """
  Cache endpoints :
  - /api/get/:key : GET request for getting the cache value for a specific `key`
  - /api/value : POST request for getting the cache value for a specific `key`
  - /api/post : POST request for creating/updating the ets table entry by the `key` and `value` provided. Responds to the request with the `value`
  """

  alias ElixirCachingValidere.LruCache
  alias ElixirCachingValidere.ServiceUtils


  @doc """
    Plug provides Plug.Router to dispatch incoming requests based on the path and method.
    When the router is called, it will invoke the :match plug, represented by a match/2function responsible
    for finding a matching route, and then forward it to the :dispatch plug which will execute the matched code.
  """

  use Plug.Router

  # This module is a Plug, that also implements it's own plug pipeline, below:

  # Using Plug.Logger for logging request information

  plug(Plug.Logger)

  # responsible for matching routes

  plug(:match)

  # Using Poison for JSON decoding
  # Note, order of plugs is important, by placing this _after_ the 'match' plug,
  # we will only parse the request AFTER there is a route match.

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  # responsible for dispatching responses

  plug(:dispatch)


  # Get value of a key using GET request

  get "/api/get/:key" do
    send_resp(conn, 200, to_string(LruCache.get(key)))
  end

  # Get value of a key using POST request

  post "/api/value" do
    case conn.body_params do
      %{"key" => key} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, ServiceUtils.endpoint_success(LruCache.get(key)))

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, "no key found")

    end
  end

  # Add or update cache entry in ets table using POST request

  post "/api/post" do
    case conn.body_params do
      %{"key" => key, "value" => value} ->
        LruCache.put(key, value)
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, ServiceUtils.endpoint_success(LruCache.get(key)))

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, "incorrect request")

    end
  end

  # A catchall route, 'match' will match no matter the request method,
  # so a response is always returned, even if there is no route to match.

  match _ do
    send_resp(conn, 404, "oops")
  end
end
