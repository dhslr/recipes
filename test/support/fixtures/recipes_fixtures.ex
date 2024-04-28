defmodule Recipes.RecipesFixtures do
  @moduledoc false

  alias Recipes.Data

  def recipe_fixture(attrs \\ %{}) do
    {:ok, recipe} =
      attrs
      |> Enum.into(%{description: "Hmm... lecker Currywurst.", title: "Currywurst", servings: 1})
      |> Data.create_recipe()

    recipe
  end

  def ingredient_fixture(attrs \\ %{}) do
    {:ok, ingredient} =
      attrs
      |> Enum.into(%{quantity: 1, description: "kg"})
      |> Data.create_ingredient()

    ingredient
  end
end
