defmodule Recipes.Data.Ingredient do
  use Ecto.Schema
  import Ecto.Changeset
  alias Recipes.Data.Food

  schema "ingredients" do
    field(:name, :string)
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
    |> cast(attrs, [:description, :quantity, :recipe_id, :food_id, :position, :name])
    |> foreign_key_constraint(:food_id)
    |> foreign_key_constraint(:recipe_id)
    #|> put_assoc(:food, parse_food(attrs), required: true)
  end
end
