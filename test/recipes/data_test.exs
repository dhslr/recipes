defmodule DataTest do
  use Recipes.DataCase

  alias Recipes.Data
  alias Data.Recipe
  alias Data.Ingredient

  import Recipes.RecipesFixtures

  describe "recipes" do
    @valid_attrs %{description: "some description", title: "some title"}
    @update_attrs %{description: "some updated description", title: "some updated title"}
    @invalid_attrs %{description: nil, title: nil}

    test "list_recipes/0 returns all recipes" do
      recipe = recipe_fixture()
      assert Data.list_recipes() == [recipe]
    end

    test "get_recipe!/1 returns the recipe with given id" do
      recipe = recipe_fixture()
      assert Data.get_recipe!(recipe.id) == recipe
    end

    test "create_recipe/1 with valid data creates a recipe" do
      assert {:ok, %Recipe{} = recipe} = Data.create_recipe(@valid_attrs)
      assert recipe.description == "some description"
      assert recipe.title == "some title"
    end

    test "create_recipe/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Data.create_recipe(@invalid_attrs)
    end

    test "update_recipe/2 with valid data updates the recipe" do
      recipe = recipe_fixture()
      assert {:ok, %Recipe{} = recipe} = Data.update_recipe(recipe, @update_attrs)
      assert recipe.description == "some updated description"
      assert recipe.title == "some updated title"
    end

    test "update_recipe/2 with invalid data returns error changeset" do
      recipe = recipe_fixture()
      assert {:error, %Ecto.Changeset{}} = Data.update_recipe(recipe, @invalid_attrs)
      assert recipe == Data.get_recipe!(recipe.id)
    end

    test "delete_recipe/1 deletes the recipe" do
      recipe = recipe_fixture()
      assert {:ok, %Recipe{}} = Data.delete_recipe(recipe)
      assert_raise Ecto.NoResultsError, fn -> Data.get_recipe!(recipe.id) end
    end

    test "change_recipe/1 returns a recipe changeset" do
      recipe = recipe_fixture()
      assert %Ecto.Changeset{} = Data.change_recipe(recipe)
    end

    test "create recipe with ingredients" do
      assert {:ok, %Recipe{} = recipe} =
               Data.create_recipe(
                 Map.put(@valid_attrs, :ingredients, [
                   %{name: "Flour", quantity: 100.0, description: "g"},
                   %{name: "Sugar", quantity: 100.0, description: "g"}
                 ])
               )

      assert [
               %Ingredient{name: "Flour", quantity: 100.0, description: "g"},
               %Ingredient{name: "Sugar", quantity: 100.0, description: "g"}
             ] = recipe.ingredients
    end

    test "update recipe with ingredients" do
      assert {:ok, %Recipe{} = recipe} =
               Data.create_recipe(
                 Map.put(@valid_attrs, :ingredients, [
                   %{name: "Flour", quantity: 100.0, description: "g"},
                   %{name: "Sugar", quantity: 100.0, description: "g"}
                 ])
               )

      [ingredient1, _] = recipe.ingredients

      {:ok, recipe} =
        Data.update_recipe(recipe, %{
          ingredients: [
            %{
              id: ingredient1.id,
              name: "Flour",
              quantity: 200.0,
              description: "g"
            }
          ]
        })

      assert [
               %Ingredient{name: "Flour", quantity: 200.0, description: "g"}
             ] = recipe.ingredients
    end

    test "add ingredient changeset to recipe" do
      recipe = recipe_fixture()
      changeset = Data.add_ingredient(recipe, "Bananas")

      assert changeset.valid?
      assert %{ingredients: [%Ecto.Changeset{changes: %{name: "Bananas"}}]} = changeset.changes
    end
  end
end
