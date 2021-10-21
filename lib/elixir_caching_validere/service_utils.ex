defmodule ElixirCachingValidere.ServiceUtils do
  @moduledoc """
  Services Utils
  """

  @doc """
  Format service success response
  """
  @spec endpoint_success(any) :: binary
  def endpoint_success(data) do
    Poison.encode!(%{
      "status" => 200,
      "value" => data
    })
  end
end
