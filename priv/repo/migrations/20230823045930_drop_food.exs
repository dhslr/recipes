defmodule Recipes.Repo.Migrations.DropFood do
  use Ecto.Migration

  def change do
    drop table(:food)
  end
end
