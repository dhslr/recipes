defmodule Recipes.RecipesFixtures do
  alias Recipes.Data

  def recipe_fixture(attrs \\ %{}) do
    {:ok, recipe} =
      attrs
      |> Enum.into(%{description: "Hmm... lecker Currywurst.", title: "Currywurst"})
      |> Data.create_recipe()

    recipe
  end

  def food_fixture(attrs \\ %{}) do
    {:ok, food} =
      attrs
      |> Enum.into(%{name: "Ketchup"})
      |> Data.create_food()

    food
  end

  def ingredient_fixture(attrs \\ %{}) do
    {:ok, ingredient} =
      attrs
      |> Enum.into(%{quantity: 1, description: "kg"})
      |> Data.create_ingredient()

    ingredient
  end
end
