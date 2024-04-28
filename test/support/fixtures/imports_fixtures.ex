defmodule Recipes.ImportsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Recipes.Imports` context.
  """

  @doc """
  Generate a import.
  """
  def import_fixture(attrs \\ %{}) do
    {:ok, import} =
      attrs
      |> Enum.into(%{
        url: "some url"
      })
      |> Recipes.Imports.create_import()

    import
  end
end
