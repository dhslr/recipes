defmodule Recipes.Repo.Migrations.CreateIngredientGroups do
  use Ecto.Migration

  def change do
    create table(:ingredient_groups) do
      add :title, :string
      add :position, :integer, default: 0
      add :recipe_id, references(:recipes, on_delete: :delete_all), null: false
      timestamps()
    end

    create index(:ingredient_groups, [:recipe_id])
  end
end
