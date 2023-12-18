defmodule Recipes.Data.Food do
  use Ecto.Schema
  import Ecto.Changeset

  schema "food" do
    field :name, :string
    has_many :ingredients, Recipes.Data.Ingredient, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(food, attrs) do
    food
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint([:name])
  end
end
