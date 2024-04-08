defmodule Recipes.Repo.Migrations.AddNameForIngredient do
  use Ecto.Migration

  def change do
    alter table(:ingredients) do
      add :name, :string
    end
  end
end
