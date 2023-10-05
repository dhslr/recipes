defmodule Recipes.Data.IngredientTest do
  use Recipes.DataCase

  alias Recipes.Data.Ingredient

  describe "ingredients" do
    @valid_attrs %{
      description: "some description",
      quantity: 12.5,
      name: "Food",
      recipe_id: 1,
      position: 1
    }
    @invalid_attrs_no_name %{description: "some description", recipe_id: 1}
    @invalid_attrs_quantity_no_number %{
      description: "some description",
      quantity: "a",
      name: "Food",
      recipe_id: 1
    }

    test "changeset with valid attributes" do
      changeset = Ingredient.changeset(%Ingredient{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset_1 = Ingredient.changeset(%Ingredient{}, @invalid_attrs_no_name)
      changeset_2 = Ingredient.changeset(%Ingredient{}, @invalid_attrs_quantity_no_number)
      refute changeset_1.valid?
      refute changeset_2.valid?
    end
  end
end
