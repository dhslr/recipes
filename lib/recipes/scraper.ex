defmodule Recipes.Scraper do
  @moduledoc """
  A scraper takes a url of a recipe on the internet, parses it and creates a recipe entity out of it.
  """

  @typedoc """
  The url encoded as string
  """
  @type url() :: String.t()

  @doc """
  Scrapes the recipe from the given url and returns it as a recipe.
  """
  @callback scrape(url()) :: {:ok, Recipe.t()} | {:error, String.t()}

  def scrape(url), do: impl().scrape(url)

  defp impl(), do: Application.get_env(:recipes, :recipe_scraper)
end
