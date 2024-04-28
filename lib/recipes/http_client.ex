defmodule Recipes.HttpClient do
  @moduledoc """
  A behaviour for implementing a HTTP client.
  """

  @typedoc """
  The url encoded as string
  """
  @type url() :: String.t()

  @doc """
  Executes a GET request for the given url.
  """
  @callback get(url()) :: {:ok, map()} | {:error, binary() | map()}

  def get(url), do: impl().get(url)

  defp impl(), do: Application.get_env(:recipes, :http_client)
end
