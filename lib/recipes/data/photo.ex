defmodule Recipes.Data.Photo do
  @moduledoc """
  Schema used for persisting uploaded photos.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "photos" do
    field :caption, :string
    field :position, :integer, default: 0
    belongs_to :recipe, Recipes.Data.Recipe, on_replace: :delete_if_exists

    timestamps()
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:caption, :recipe_id])
  end

  def changeset(photo, attrs, position) do
    photo
    |> cast(attrs, [:caption, :recipe_id])
    |> change(position: position)
    |> foreign_key_constraint(:recipe_id)
  end

  def filename(photo) when is_nil(photo), do: nil

  def filename(photo) do
    "recipe_#{photo.recipe_id}_#{photo.id}.jpg"
  end

  def photos_dir() do
    Path.join(Application.app_dir(:recipes), "/priv/static/photos")
  end
end
