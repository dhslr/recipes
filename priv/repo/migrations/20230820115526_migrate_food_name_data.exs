defmodule Recipes.Repo.Migrations.MigrateFoodNameData do
  use Ecto.Migration

  alias Recipes.Repo
  alias Recipes.Data

  def change do
    migrate_data()
  end

  def migrate_data() do
    for food <- Data.list_food() do
      food = Repo.preload(food, [:ingredients])

      for ingredient <- food.ingredients do
        unless ingredient.name do
          {:ok, _} = Data.update_ingredient(ingredient, %{name: food.name})
        end
      end
    end
  end
end
