defmodule Recipes.Data.Recipe do
  @moduledoc """
  Schema for persisting recipe data.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "recipes" do
    field :title, :string
    field :description, :string, default: ""
    field :kcal, :integer
    field :servings, :integer, default: 1

    has_many :ingredients, Recipes.Data.Ingredient,
      preload_order: [asc: :position],
      on_delete: :delete_all,
      on_replace: :delete_if_exists

    has_many :photos, Recipes.Data.Photo,
      preload_order: [asc: :position],
      on_delete: :delete_all,
      on_replace: :delete_if_exists

    many_to_many :tags, Recipes.Data.Tag, join_through: "recipes_tags", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:title, :description, :kcal, :servings])
    |> validate_required([:title])
    |> cast_assoc(:ingredients,
      with: &Recipes.Data.Ingredient.changeset/3,
      drop_param: :ingredients_drop,
      sort_param: :ingredients_order
    )
    |> cast_assoc(:photos,
      with: &Recipes.Data.Photo.changeset/3,
      drop_param: :photos_drop,
      sort_param: :photos_order
    )
    |> cast_assoc(:tags,
      with: &Recipes.Data.Tag.changeset/2,
      drop_param: :tags_drop,
      sort_param: :tags_order
    )
  end

  def first_photo(%Recipes.Data.Recipe{photos: [h | _t] = photos}) do
    Enum.min(photos, &(&1.position <= &2.position), h)
  end

  def first_photo(_recipe), do: nil
end
