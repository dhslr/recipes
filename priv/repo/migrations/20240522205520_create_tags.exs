defmodule Recipes.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string
      add :icon, :string

      timestamps()
    end

    create table(:recipes_tags, primary_key: false) do
      add :recipe_id, references(:recipes)
      add :tag_id, references(:tags)
    end

    create unique_index("tags", [:name])
  end
end
