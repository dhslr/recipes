defmodule Recipes.Repo.Migrations.ServicesAndKcal do
  use Ecto.Migration

  def change do
    alter table(:recipes) do
      add :kcal, :integer
      add :servings, :integer
    end
  end
end
