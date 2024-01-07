defmodule Recipes.Repo.Migrations.AddPositionToPhotos do
  use Ecto.Migration

  def change do
    alter table(:photos) do
      add :position, :integer, default: 0
    end
  end
end
