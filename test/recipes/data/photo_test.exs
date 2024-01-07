defmodule Recipes.Data.PhotoTest do
  alias Recipes.Data.Photo
  use Recipes.DataCase

  describe "photos" do
    test "photo with valid caption and recipe" do
      changeset = Photo.changeset(%Photo{}, %{caption: "a caption", recipe_id: 1})
      assert changeset.valid?
    end

    test "photo with position" do
      changeset = Photo.changeset(%Photo{}, %{caption: "a caption", recipe_id: 1}, 1)
      assert changeset.valid?
    end

    test "filename, get filename of photo" do
      filename = Photo.filename(%Photo{id: 42, caption: "first", recipe_id: 23})

      assert filename == "recipe_23_42.jpg"
    end

    test "filename, returns nil for nil" do
      filename = Photo.filename(nil)

      assert filename == nil
    end
  end
end
