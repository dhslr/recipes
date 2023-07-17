defmodule Recipes.Repo.Migrations.CreatePhotos do
  use Ecto.Migration

  def change do

    create table(:photos) do
      add :caption, :string
      add :data, :binary
      add :recipe_id, references(:recipes, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:photos, [:recipe_id])
  end
end
