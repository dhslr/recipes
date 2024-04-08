defmodule Recipes.Repo.Migrations.RemoveFoodFromIngredients do
  use Ecto.Migration

  def change do
    alter table(:ingredients) do
      remove(:food_id)
    end
  end
end
