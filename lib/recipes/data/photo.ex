defmodule Recipes.Data.Photo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "photos" do
    field :caption, :string
    belongs_to :recipe, Recipes.Data.Recipe

    timestamps()
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:caption, :recipe_id])
  end

  def filename(photo) when is_nil(photo), do: nil

  def filename(photo) do
    "recipe_#{photo.recipe_id}_#{photo.id}.jpg"
  end

  def photos_dir() do
    Path.join(Application.app_dir(:recipes), "/priv/static/photos")
  end
end
