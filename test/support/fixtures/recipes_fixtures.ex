defmodule Recipes.RecipesFixtures do
  def recipe_fixture(attrs \\ %{}) do
    {:ok, recipe} =
      attrs
      |> Enum.into(%{description: "Hmm... lecker Currywurst.", title: "Currywurst"})
      |> Recipes.create_recipe()

    recipe
  end

  def food_fixture(attrs \\ %{}) do
    {:ok, food} =
      attrs
      |> Enum.into(%{name: "Ketchup"})
      |> Recipes.create_food()

    food
  end

  def ingredient_fixture(attrs \\ %{}) do
    {:ok, ingredient} =
      attrs
      |> Enum.into(%{quantity: 1, description: "kg"})
      |> Recipes.create_ingredient()

    ingredient
  end
end
