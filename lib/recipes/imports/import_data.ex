defmodule Recipes.Imports.ImportData do
  @moduledoc """
  Schema for the import_data table.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "import_data" do
    field :url, :string

    belongs_to :recipe, Recipes.Data.Recipe, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(data, attrs) do
    data
    |> cast(attrs, [:url, :recipe_id])
    |> validate_required([:url])
  end
end
