defmodule Recipes.Data.Tag do
  alias Recipes.Data.Recipe
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :icon, :string
    field :name, :string

    many_to_many :recipes, Recipe, join_through: "recipes_tags"

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :icon])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
