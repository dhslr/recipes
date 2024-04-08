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
  end
end
