defmodule Recipes.Data.Recipe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recipes" do
    field :description, :string
    field :title, :string
    field :kcal, :integer
    field :servings, :integer

    has_many :ingredients, Recipes.Data.Ingredient
    has_many :photos, Recipes.Data.Photo
    timestamps()
  end

  @doc false
  def changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:title, :description, :kcal, :servings])
    |> validate_required([:title])
  end
end
