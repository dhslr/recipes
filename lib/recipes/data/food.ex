defmodule Recipes.Data.Food do
  use Ecto.Schema
  import Ecto.Changeset
  alias Recipes.Repo

  schema "food" do
    field :name, :string
    has_many :ingredients, Recipes.Data.Ingredient, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(food, attrs) do
    food
    |> innercg(attrs)
    |> unique_constraint([:name])
  end

  def create_or_get_changeset(food, attrs) do
    cs = innercg(food, attrs)

    if cs.valid? do
      get_or_create_food(attrs.name, cs)
    else
      cs
    end
  end

  defp innercg(food, attrs) do
    food
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  defp get_or_create_food(name, cs) do
    food = Repo.get_by(Recipes.Data.Food, name: name)
    dbg(food)
    if food do
      innercg(food, %{})
    else
      unique_constraint(cs, [:name])
    end
  end
end
