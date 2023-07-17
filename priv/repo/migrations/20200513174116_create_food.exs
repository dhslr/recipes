defmodule Recipes.Repo.Migrations.CreateFood do
  use Ecto.Migration

  def change do
    create table(:food) do
      add :name, :string

      timestamps()
    end
  end
end
