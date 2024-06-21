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

    has_many :tags, Recipes.Data.Tag,
      on_delete: :delete_all,
      on_replace: :delete_if_exists

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
    |> put_assoc(
      :tags,
      attrs["tags"] || attrs[:tags] || []
    )
  end

  def first_photo(%Recipes.Data.Recipe{photos: [h | _t] = photos}) do
    Enum.min(photos, &(&1.position <= &2.position), h)
  end

  def first_photo(_recipe), do: nil

  def empty do
    %Recipes.Data.Recipe{ingredients: [], tags: [], photos: []}
  end
end
