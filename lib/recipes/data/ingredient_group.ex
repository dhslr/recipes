defmodule Recipes.Data.IngredientGroup do
  @moduledoc """
    Schema for persisting recipe ingredient group data.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "ingredient_groups" do
    field(:title, :string)
    field(:position, :integer, default: 0)
    belongs_to(:recipe, Recipes.Data.Recipe, on_replace: :delete_if_exists)

    timestamps()
  end

  @doc false
  def changeset(ingredient_group, attrs) do
    ingredient_group
    |> cast(attrs, [:title, :recipe_id])
    |> validate_required([:title])
    |> foreign_key_constraint(:recipe_id)
  end

  @doc false
  def changeset(ingredient_group, attrs, position) do
    ingredient_group
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> change(position: position)
    |> foreign_key_constraint(:recipe_id)
  end
end
