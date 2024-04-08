defmodule Recipes.Repo.Migrations.FoodUniqueConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:food, [:name])
  end
end
