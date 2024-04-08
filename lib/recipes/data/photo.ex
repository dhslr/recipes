defmodule Recipes.Data.Photo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "photos" do
    field :caption, :string
    field :data, :binary
    belongs_to :recipe, Recipes.Data.Recipe

    timestamps()
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:caption, :recipe_id])
    |> validate_required([:recipe_id])
  end

  def filename(photo) do
    "recipe_#{photo.recipe_id}_#{photo.id}.jpg"
  end

  def photos_dir() do
    Application.get_env(:recipes_backend, :photos_dir)
  end
end
