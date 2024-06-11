defmodule Recipes.DataFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Recipes.Data` context.
  """

  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        icon: "some icon",
        name: "some name"
      })
      |> Recipes.Data.create_tag()

    tag
  end

  def recipe_fixture(attrs \\ %{}) do
    {:ok, recipe} =
      attrs
      |> Enum.into(%{description: "Hmm... lecker Currywurst.", title: "Currywurst", servings: 1})
      |> Recipes.Data.create_recipe()

    recipe
  end

  def ingredient_fixture(attrs \\ %{}) do
    {:ok, ingredient} =
      attrs
      |> Enum.into(%{quantity: 1, description: "kg"})
      |> Recipes.Data.create_ingredient()

    ingredient
  end
end
