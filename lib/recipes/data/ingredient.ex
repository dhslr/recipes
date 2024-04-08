defmodule Recipes.Data.Ingredient do
  use Ecto.Schema
  import Ecto.Changeset
  alias Recipes.Data.Food
  alias Recipes.Repo

  schema "ingredients" do
    field(:description, :string)
    field(:quantity, :float)
    field(:position, :integer, default: 0)
    belongs_to(:recipe, Recipes.Data.Recipe, on_replace: :delete_if_exists)
    belongs_to(:food, Food, on_replace: :nilify)

    timestamps()
  end

  @doc false
  def changeset(ingredient, attrs) do
    ingredient
    |> cast(attrs, [:description, :quantity, :recipe_id, :food_id, :position])
    |> foreign_key_constraint(:recipe_id)
    |> put_assoc(:food, parse_food(attrs), required: true)
  end

  defp parse_food(attrs) do
    food_attrs = attrs["food"] || attrs[:food] || %{}
    food_changeset = Food.changeset(%Food{}, food_attrs)

    if food_changeset.valid? do
      get_or_insert_food(food_attrs["name"] || food_attrs[:name])
    else
      food_changeset
    end
  end

  # This uses ecto upserts like described here https://hexdocs.pm/ecto/constraints-and-upserts.html#upserts
  defp get_or_insert_food(name) do
    Repo.insert!(%Food{name: name}, on_conflict: [set: [name: name]], conflict_target: :name)
  end
end
