defmodule Recipes.ImportsTest do
  use Recipes.DataCase

  alias Recipes.Imports

  describe "imports" do
    alias Recipes.Imports.ImportData

    import Recipes.ImportsFixtures
    import Recipes.RecipesFixtures

    @invalid_attrs %{url: nil, recipe_id: nil}

    test "list_imports/0 returns all imports" do
      import_data = import_fixture()
      assert Imports.list_imports() == [import_data]
    end

    test "get_import!/1 returns the import with given id" do
      import_data = import_fixture()
      assert Imports.get_import!(import_data.id) == import_data
    end

    test "create_import/1 with valid data creates a import" do
      recipe = recipe_fixture()
      valid_attrs = %{url: "some url", recipe_id: recipe.id}

      assert {:ok, %ImportData{} = import_data} = Imports.create_import(valid_attrs)
      assert import_data.url == "some url"
      assert import_data.recipe_id == recipe.id
    end

    test "create_import/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Imports.create_import(@invalid_attrs)
    end

    test "update_import/2 adds recipe_id to the import" do
      recipe = recipe_fixture()
      import_data = import_fixture()
      update_attrs = %{recipe_id: recipe.id}

      assert {:ok, %ImportData{} = import_data} = Imports.update_import(import_data, update_attrs)
      assert import_data.url == "some url"
      assert import_data.recipe_id == recipe.id
    end

    test "update_import/2 with invalid data returns error changeset" do
      import_data = import_fixture()
      assert {:error, %Ecto.Changeset{}} = Imports.update_import(import_data, @invalid_attrs)
      assert import_data == Imports.get_import!(import_data.id)
    end

    test "delete_import/1 deletes the import" do
      import_data = import_fixture()
      assert {:ok, %ImportData{}} = Imports.delete_import(import_data)
      assert_raise Ecto.NoResultsError, fn -> Imports.get_import!(import_data.id) end
    end

    test "change_import/1 returns a import changeset" do
      import_data = import_fixture()
      assert %Ecto.Changeset{} = Imports.change_import(import_data)
    end
  end
end
