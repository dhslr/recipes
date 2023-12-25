defmodule Recipes.Scraper do
  @typedoc """
  The url encoded as string
  """
  @type url() :: String.t()

  @doc """
  Scrapes the recipe from the given url and returns it as map
  """
  @callback scrape(url()) :: {:ok, map()} | {:error, String.t()}

  def scrape(url), do: impl().scrape(url)

  defp impl(), do: Application.get_env(:recipes, :recipe_scraper)
end
