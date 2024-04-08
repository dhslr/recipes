defmodule Recipes.Data.RecipeTest do
  use Recipes.DataCase

  alias Recipes.Data.Recipe

  describe "recipes" do
    test "recipe with valid title and descripton" do
      changeset = Recipe.changeset(%Recipe{}, %{title: "title", description: "description"})
      assert changeset.valid?
    end

    test "recipe with valid title but without descripton" do
      changeset = Recipe.changeset(%Recipe{}, %{title: "title"})
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset_1 = Recipe.changeset(%Recipe{}, %{})
      changeset_2 = Recipe.changeset(%Recipe{}, %{title: ""})
      refute changeset_1.valid?
      refute changeset_2.valid?
    end

    test "changeset with ingredients" do
      changeset =
        Recipe.changeset(%Recipe{}, %{
          title: "Title",
          ingredients: [%{recipe_id: 1, food: %{name: "Sugar"}, quantity: 100, description: "g"}]
        })

      assert changeset.valid?
      assert [ingredient_changeset] = changeset.changes.ingredients
      assert ingredient_changeset.valid?
    end

    test "changeset is not valid if ingredients are not valid because food is missing" do
      changeset =
        Recipe.changeset(%Recipe{}, %{
          title: "Title",
          ingredients: [%{recipe_id: 1, quantity: 100, description: "g"}]
        })

      refute changeset.valid?
    end
  end
end
