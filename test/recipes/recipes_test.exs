defmodule RecipesTest do
  use Recipes.DataCase

  alias Recipes.Data
  alias Data.Food
  alias Data.Recipe
  alias Data.Ingredient

  import Recipes.RecipesFixtures

  describe "food" do
    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    test "list_food/0 returns all food" do
      food = food_fixture()
      assert Recipes.list_food() == [food]
    end

    test "get_food!/1 returns the food with given id" do
      food = food_fixture()
      assert Recipes.get_food!(food.id) == food
    end

    test "create_food/1 with valid data creates a food" do
      assert {:ok, %Food{} = food} = Recipes.create_food(@valid_attrs)
      assert food.name == "some name"
    end

    test "create_food/1 with same name twice returns error changeset" do
      assert {:ok, %Food{} = _food} = Recipes.create_food(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Recipes.create_food(@valid_attrs)
    end

    test "create_food/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Recipes.create_food(@invalid_attrs)
    end

    test "update_food/2 with valid data updates the food" do
      food = food_fixture()
      assert {:ok, %Food{} = food} = Recipes.update_food(food, @update_attrs)
      assert food.name == "some updated name"
    end

    test "update_food/2 with invalid data returns error changeset" do
      food = food_fixture()
      assert {:error, %Ecto.Changeset{}} = Recipes.update_food(food, @invalid_attrs)
      assert food == Recipes.get_food!(food.id)
    end

    test "delete_food/1 deletes the food" do
      food = food_fixture()
      assert {:ok, %Food{}} = Recipes.delete_food(food)
      assert_raise Ecto.NoResultsError, fn -> Recipes.get_food!(food.id) end
    end

    test "change_food/1 returns a food changeset" do
      food = food_fixture()
      assert %Ecto.Changeset{} = Recipes.change_food(food)
    end
  end

  describe "recipes" do
    @valid_attrs %{description: "some description", title: "some title"}
    @update_attrs %{description: "some updated description", title: "some updated title"}
    @invalid_attrs %{description: nil, title: nil}

    test "list_recipes/0 returns all recipes" do
      recipe = recipe_fixture()
      assert Recipes.list_recipes() == [recipe]
    end

    test "get_recipe!/1 returns the recipe with given id" do
      recipe = recipe_fixture()
      assert Recipes.get_recipe!(recipe.id) == recipe
    end

    test "create_recipe/1 with valid data creates a recipe" do
      assert {:ok, %Recipe{} = recipe} = Recipes.create_recipe(@valid_attrs)
      assert recipe.description == "some description"
      assert recipe.title == "some title"
    end

    test "create_recipe/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Recipes.create_recipe(@invalid_attrs)
    end

    test "update_recipe/2 with valid data updates the recipe" do
      recipe = recipe_fixture()
      assert {:ok, %Recipe{} = recipe} = Recipes.update_recipe(recipe, @update_attrs)
      assert recipe.description == "some updated description"
      assert recipe.title == "some updated title"
    end

    test "update_recipe/2 with invalid data returns error changeset" do
      recipe = recipe_fixture()
      assert {:error, %Ecto.Changeset{}} = Recipes.update_recipe(recipe, @invalid_attrs)
      assert recipe == Recipes.get_recipe!(recipe.id)
    end

    test "delete_recipe/1 deletes the recipe" do
      recipe = recipe_fixture()
      assert {:ok, %Recipe{}} = Recipes.delete_recipe(recipe)
      assert_raise Ecto.NoResultsError, fn -> Recipes.get_recipe!(recipe.id) end
    end

    test "change_recipe/1 returns a recipe changeset" do
      recipe = recipe_fixture()
      assert %Ecto.Changeset{} = Recipes.change_recipe(recipe)
    end

    test "create recipe with ingredients" do
      assert {:ok, %Recipe{} = recipe} =
               Recipes.create_recipe(
                 Map.put(@valid_attrs, :ingredients, [
                   %{food: %{name: "Flour"}, quantity: 100.0, description: "g"},
                   %{food: %{name: "Sugar"}, quantity: 100.0, description: "g"}
                 ])
               )

      assert [
               %Ingredient{food: %Food{name: "Flour"}, quantity: 100.0, description: "g"},
               %Ingredient{food: %Food{name: "Sugar"}, quantity: 100.0, description: "g"}
             ] = recipe.ingredients
    end

    test "update recipe with ingredients" do
      assert {:ok, %Recipe{} = recipe} =
               Recipes.create_recipe(
                 Map.put(@valid_attrs, :ingredients, [
                   %{food: %{name: "Flour"}, quantity: 100.0, description: "g"},
                   %{food: %{name: "Sugar"}, quantity: 100.0, description: "g"}
                 ])
               )

      [ingredient1, ingredient2] = recipe.ingredients

      {:ok, recipe} =
        Recipes.update_recipe(recipe, %{
          ingredients: [
            %{
              id: ingredient1.id,
              food: %{id: ingredient1.food.id, name: "Flour"},
              quantity: 200.0,
              description: "g"
            }
          ]
        })

      assert [
               %Ingredient{food: %Food{name: "Flour"}, quantity: 200.0, description: "g"}
             ] = recipe.ingredients
    end

    test "create recipes with same food re uses food entity" do
      assert {:ok, %Recipe{} = recipe_1} =
               Recipes.create_recipe(
                 Map.put(@valid_attrs, :ingredients, [
                   %{food: %{name: "Sugar"}, quantity: 100.0, description: "g"}
                 ])
               )

      assert {:ok, %Recipe{} = recipe_2} =
               Recipes.create_recipe(%{
                 title: "some other name",
                 ingredients: [%{food: %{name: "Sugar"}, quantity: 2.0, description: "g"}]
               })
    end
  end
end
