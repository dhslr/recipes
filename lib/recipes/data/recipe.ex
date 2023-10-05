defmodule Recipes.Data.Recipe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recipes" do
    field :description, :string
    field :title, :string
    field :kcal, :integer
    field :servings, :integer

    has_many :ingredients, Recipes.Data.Ingredient,
      on_delete: :delete_all,
      on_replace: :delete_if_exists

    has_many :photos, Recipes.Data.Photo
    timestamps()
  end

  @doc false
  def changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:title, :description, :kcal, :servings])
    |> cast_assoc(:ingredients,
      with: &Recipes.Data.Ingredient.changeset/2,
      drop_param: :ingredients_drop
    )
    |> validate_required([:title])
  end
end
