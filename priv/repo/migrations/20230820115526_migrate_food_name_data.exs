defmodule Recipes.Repo.Migrations.MigrateFoodNameData do
  use Ecto.Migration

  alias Recipes.Data

  def change do
    migrate_data()
  end

  def migrate_data() do
    for recipe <- Data.list_recipes(),
        ingredient <- recipe.ingredients do
      food = ingredient.food
      {:ok, _} = Data.update_ingredient(ingredient, %{name: food.name})
    end
  end
end
