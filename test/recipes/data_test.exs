defmodule DataTest do
  alias Recipes.Data.Photo
  use Recipes.DataCase

  alias Recipes.Data

  alias Data.Ingredient
  alias Data.Recipe
  alias Data.Tag

  import Recipes.DataFixtures

  describe "recipes" do
    @valid_attrs %{description: "some description", title: "some title"}
    @update_attrs %{description: "some updated description", title: "some updated title"}
    @invalid_attrs %{description: nil, title: nil}

    test "list_recipes/0 returns all recipes" do
      recipe = recipe_fixture()
      assert Data.list_recipes() == [recipe]
    end

    test "list_recipes_by_tag_or_title returns recipe for matching title" do
      recipe1 =
        recipe_fixture(%{title: "Kirschtorte", tags: [%{name: "Lunch"}, %{name: "Sweet"}]})

      _recipe2 = recipe_fixture(%{title: "Kirschmarmelade", tags: [%{name: "Breakfast"}]})

      assert Data.list_recipes_by_tag_or_title("Kirschtorte") == [recipe1]
    end

    test "list_recipes_by_tag_or_title returns recipe for matching tag" do
      recipe1 =
        recipe_fixture(%{title: "Kirschtorte", tags: [%{name: "Lunch"}, %{name: "Sweet"}]})

      _recipe2 = recipe_fixture(%{title: "Kirschmarmelade", tags: [%{name: "Breakfast"}]})

      assert Data.list_recipes_by_tag_or_title("Lunch") == [recipe1]
    end

    test "list_recipes_by_tag_or_title returns recipe for partial matching tag" do
      recipe1 =
        recipe_fixture(%{title: "Kirschtorte", tags: [%{name: "Lunch"}, %{name: "Fruits"}]})

      recipe2 =
        recipe_fixture(%{
          title: "Kirschmarmelade",
          tags: [%{name: "Breakfast"}, %{name: "Fruits"}]
        })

      assert Data.list_recipes_by_tag_or_title("Fru") == [recipe2, recipe1]
    end

    test "list_recipes_by_tag_or_title returns recipe for partial matching title" do
      recipe1 = recipe_fixture(%{title: "Kirschtorte", tags: [%{name: "Lunch"}]})
      recipe2 = recipe_fixture(%{title: "Kirschmarmelade", tags: [%{name: "Breakfast"}]})

      assert Data.list_recipes_by_tag_or_title("Kirsch") == [recipe2, recipe1]
    end

    test "list_recipes_by_tag_or_title returns recipe for matching tag and title" do
      recipe1 = recipe_fixture(%{title: "Kirschtorte", tags: [%{name: "Kirschtorte"}]})

      assert Data.list_recipes_by_tag_or_title("Kirschtorte") == [recipe1]
      assert Data.list_recipes_by_tag_or_title("Kirsch") == [recipe1]
    end

    test "list_recipes_by_tag_or_title returns empty list for no match" do
      _recipe = recipe_fixture(%{title: "Kirschtorte", tags: [%{name: "Lunch"}]})

      assert Data.list_recipes_by_tag_or_title("Himbeerkuchen") == []
    end

    test "list_recipes_by_tag_or_title returns recipe for matching title, should not be case sensitive" do
      recipe1 =
        recipe_fixture(%{title: "Kirschtorte", tags: [%{name: "Lunch"}, %{name: "Sweet"}]})

      recipe2 = recipe_fixture(%{title: "Kirschmarmelade", tags: [%{name: "Breakfast"}]})

      assert Data.list_recipes_by_tag_or_title("kirsch") == [recipe2, recipe1]
      assert Data.list_recipes_by_tag_or_title("break") == [recipe2]
    end

    test "get_recipe!/1 returns the recipe with given id" do
      recipe = recipe_fixture()
      assert Data.get_recipe!(recipe.id) == recipe
    end

    test "create_recipe/1 with valid data creates a recipe with default servings" do
      assert {:ok, %Recipe{} = recipe} = Data.create_recipe(@valid_attrs)
      assert recipe.description == "some description"
      assert recipe.title == "some title"
      assert recipe.servings == 1
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

    test "create recipe with tags" do
      assert {:ok, %Recipe{} = recipe} =
               Data.create_recipe(
                 Map.put(@valid_attrs, :tags, [%{name: "Lunch"}, %{name: "Vegan"}])
               )

      assert [
               %Tag{name: "Lunch"},
               %Tag{name: "Vegan"}
             ] = recipe.tags
    end

    test "update recipe with tags" do
      recipe = recipe_fixture()
      {:ok, recipe} = Data.update_recipe(recipe, %{tags: [%{name: "Pasta"}, %{name: "Italian"}]})

      assert [
               %Tag{name: "Pasta"},
               %Tag{name: "Italian"}
             ] = recipe.tags
    end

    test "update recipe with existing tags" do
      recipe = recipe_fixture()
      tag = tag_fixture(%{recipe_id: recipe.id})

      {:ok, recipe} =
        Data.update_recipe(recipe, %{tags: [%{name: tag.name, id: tag.id}, %{name: "NewTag"}]})

      assert [
               existing_tag,
               new_tag
             ] = recipe.tags

      # why new id? transaction?
      # assert existing_tag.id == tag.id
      assert existing_tag.name == tag.name
      assert new_tag.name == "NewTag"
    end

    test "add ingredient changeset to recipe" do
      recipe = recipe_fixture()
      changeset = Data.add_ingredient(recipe, "Bananas")

      assert changeset.valid?
      assert %{ingredients: [%Ecto.Changeset{changes: %{name: "Bananas"}}]} = changeset.changes
    end

    test "create photo from uploaded file" do
      recipe = recipe_fixture()
      path = Path.join(Application.app_dir(:recipes), "/priv/static/images/meal_placeholder.jpg")

      assert {:ok, photo} =
               Data.create_photo(%{
                 photo_file_path: path,
                 recipe_id: recipe.id,
                 position: 0
               })

      assert File.exists?(Path.join(Photo.photos_dir(), Photo.filename(photo)))
      assert Data.get_photo!(photo.id) != nil
    end

    test "create photo from uploaded file but file does not exist" do
      recipe = recipe_fixture()
      path = Path.join(Application.app_dir(:recipes), "/does_not_exist/nono.jpg")

      photos = Repo.all(Photo)

      assert {:error, :enoent} =
               Data.create_photo(%{
                 photo_file_path: path,
                 recipe_id: recipe.id,
                 position: 0
               })

      # no photo entry is saved for failed creation
      assert photos == Repo.all(Photo)
    end
  end

  describe "tags" do
    @invalid_attrs %{name: nil}

    test "list_tags/0 returns all tags" do
      recipe = recipe_fixture()
      tag = tag_fixture(%{recipe_id: recipe.id})
      assert Data.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      recipe = recipe_fixture()
      tag = tag_fixture(%{recipe_id: recipe.id})
      assert Data.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      recipe = recipe_fixture()
      valid_attrs = %{icon: "some icon", name: "some name", recipe_id: recipe.id}

      assert {:ok, %Tag{} = tag} = Data.create_tag(valid_attrs)
      assert tag.icon == "some icon"
      assert tag.name == "some name"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Data.create_tag(@invalid_attrs)
    end
  end

  describe "ingredients" do
    test "ingredient_names\0 returns all ingredient names" do
      recipe = recipe_fixture()
      sugar = ingredient_fixture(%{name: "Sugar", recipe_id: recipe.id})
      wheat = ingredient_fixture(%{name: "Wheat", recipe_id: recipe.id})
      assert Data.get_ingredient_names() == [sugar.name, wheat.name]
    end

    test "ingredient_names\0 returns empty list if there is no data" do
      assert Data.get_ingredient_names() == []
    end
  end
end
