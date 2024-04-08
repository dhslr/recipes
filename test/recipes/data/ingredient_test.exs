defmodule Recipes.Data.IngredientTest do
  use Recipes.DataCase

  alias Recipes.Data.Ingredient

  describe "ingredients" do
    @valid_attrs %{
      description: "some description",
      quantity: 12.5,
      food: %{name: "Food"},
      recipe_id: 1,
      position: 1
    }
    @invalid_attrs_no_food %{description: "some description", recipe_id: 1}
    @invalid_attrs_no_recipe_id %{description: "some description", food_id: 1}
    @invalid_attrs_quantity_no_number %{
      description: "some description",
      quantity: "a",
      food_id: 1,
      recipe_id: 1
    }

    test "changeset with valid attributes" do
      changeset = Ingredient.changeset(%Ingredient{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset_1 = Ingredient.changeset(%Ingredient{}, @invalid_attrs_no_food)
      changeset_2 = Ingredient.changeset(%Ingredient{}, @invalid_attrs_no_recipe_id)
      changeset_3 = Ingredient.changeset(%Ingredient{}, @invalid_attrs_quantity_no_number)
      refute changeset_1.valid?
      refute changeset_2.valid?
      refute changeset_3.valid?
    end

    test "changeset with food" do
      changeset =
        Ingredient.changeset(%Ingredient{}, Map.put(@valid_attrs, :food, %{name: "New food"}))

      assert changeset.valid?
      assert changeset.changes.food.valid?
    end

    test "changeset with invalid food" do
      changeset =
        Ingredient.changeset(
          %Ingredient{},
          Map.put(@valid_attrs, :food, %{non_existing: "New food"})
        )

      refute changeset.valid?
    end

    test "changeset with new food" do
      changeset =
        Ingredient.changeset(
          %Ingredient{},
          %{
            description: "some description",
            quantity: 12.5,
            recipe_id: 1,
            position: 1,
            food: %{name: "New food"}
          }
        )

      assert changeset.valid?
    end
  end
end
