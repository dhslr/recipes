defmodule Recipes.Repo.Migrations.CreateImports do
  use Ecto.Migration

  def change do
    create table(:import_data) do
      add :url, :string
      add :recipe_id, references(:recipes, on_delete: :delete_all)

      timestamps()
    end

    create index(:import_data, [:recipe_id])
  end
end
