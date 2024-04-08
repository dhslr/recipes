defmodule Recipes.Repo.Migrations.AddNameForIngredient do
  use Ecto.Migration

  alias Recipes.Data

  def change do
    alter table(:ingredients) do
      add :name, :string
    end
    alter table(:food) do
      modify :name, :string, null: true
    end
  end

end
