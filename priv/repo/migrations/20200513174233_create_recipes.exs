defmodule Recipes.Repo.Migrations.CreateRecipes do
  use Ecto.Migration

  def change do
    create table(:recipes) do
      add :title, :string
      add :description, :text

      timestamps()
    end
  end
end
