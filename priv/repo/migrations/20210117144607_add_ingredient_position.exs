defmodule Recipes.Repo.Migrations.AddIngredientPosition do
  use Ecto.Migration

  def change do
    alter table(:ingredients) do
      add :position, :integer, default: 0
    end
  end
end
