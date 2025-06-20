defmodule Recipes.Repo.Migrations.CreateIngredients do
  use Ecto.Migration

  def change do
    create table(:ingredients) do
      add :description, :string
      add :quantity, :float
      add :recipe_id, references(:recipes, on_delete: :delete_all), null: false
      timestamps()
    end

    create index(:ingredients, [:recipe_id])
  end
end
