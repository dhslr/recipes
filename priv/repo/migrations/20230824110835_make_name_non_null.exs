defmodule Recipes.Repo.Migrations.MakeNameNonNull do
  use Ecto.Migration

  def change do
    alter table(:ingredients) do
      modify :name, :string, null: false
    end

  end
end
