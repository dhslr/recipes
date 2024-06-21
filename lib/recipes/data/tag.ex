defmodule Recipes.Data.Tag do
  @moduledoc """
    Schema for persisting tag data.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :icon, :string
    field :name, :string

    belongs_to(:recipe, Recipes.Data.Recipe, on_replace: :delete_if_exists)

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :icon, :recipe_id])
    |> validate_required([:name])
    |> foreign_key_constraint(:recipe_id)
  end
end
