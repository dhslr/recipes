defmodule Recipes.Data.Ingredient do
  use Ecto.Schema
  import Ecto.Changeset
  alias Recipes.Data.Food
  alias Recipes.Repo

  schema "ingredients" do
    field :description, :string
    field :quantity, :float
    field :position, :integer, default: 0
    belongs_to :recipe, Recipes.Data.Recipe
    belongs_to :food, Food

    timestamps()
  end

  @doc false
  def changeset(ingredient, attrs) do
    ingredient
    |> cast(attrs, [:description, :quantity, :recipe_id, :food_id, :position])
    |> foreign_key_constraint(:recipe_id)
    |> cast_assoc(:food, required: true, with: &Food.create_or_get_changeset/2)
  end
end
