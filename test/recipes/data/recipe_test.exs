defmodule Recipes.Data.RecipeTest do
  alias Recipes.Data.Photo
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

    test "changset with servings and kcal" do
      changeset = Recipe.changeset(%Recipe{}, %{title: "title", servings: 4, kcal: 1234})
      assert changeset.valid?
    end

    test "changeset with ingredients" do
      changeset =
        Recipe.changeset(%Recipe{}, %{
          title: "Title",
          ingredients: [%{recipe_id: 1, name: "Sugar", quantity: 100, description: "g"}]
        })

      assert changeset.valid?
      assert [ingredient_changeset] = changeset.changes.ingredients
      assert ingredient_changeset.valid?
    end

    test "changeset with photos" do
      changeset =
        Recipe.changeset(%Recipe{}, %{
          title: "Title",
          photos: [%{caption: "test"}]
        })

      assert changeset.valid?
      assert [photos_changeset] = changeset.changes.photos
      assert photos_changeset.valid?
    end

    test "get first photo from recipe" do
      photo =
        Recipe.first_photo(%Recipe{
          id: 1,
          title: "Title",
          photos: [
            %Photo{caption: "first", recipe_id: 1},
            %Photo{caption: "second", recipe_id: 1}
          ]
        })

      assert %Photo{caption: "first", recipe_id: 1} == photo
    end

    test "first_photo, return nil when there are no photos" do
      photo1 =
        Recipe.first_photo(%Recipe{
          id: 1,
          title: "Title",
          photos: []
        })

      photo2 =
        Recipe.first_photo(%Recipe{
          id: 1,
          title: "Title"
        })

      assert nil == photo1
      assert nil == photo2
    end

    # TODO need to make name required
    test "changeset is not valid if ingredients are not valid because name is missing" do
      changeset =
        Recipe.changeset(%Recipe{}, %{
          title: "Title",
          ingredients: [%{recipe_id: 1, quantity: 100, description: "g"}]
        })

      refute changeset.valid?
    end
  end
end
