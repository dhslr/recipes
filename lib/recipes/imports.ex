defmodule Recipes.Imports do
  @moduledoc """
  The Imports context.
  """

  import Ecto.Query, warn: false
  alias Recipes.Repo

  alias Recipes.Imports.ImportData

  @doc """
  Returns the list of imports.

  ## Examples

      iex> list_imports()
      [%ImportData{}, ...]

  """
  def list_imports do
    Repo.all(ImportData)
  end

  @doc """
  Gets a single import.

  Raises `Ecto.NoResultsError` if the ImportData does not exist.

  ## Examples

      iex> get_import!(123)
      %ImportData{}

      iex> get_import!(456)
      ** (Ecto.NoResultsError)

  """
  def get_import!(id), do: Repo.get!(ImportData, id)

  @doc """
  Creates a import.

  ## Examples

      iex> create_import(%{field: value})
      {:ok, %ImportData{}}

      iex> create_import(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_import(attrs \\ %{}) do
    %ImportData{}
    |> ImportData.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a import.

  ## Examples

      iex> update_import(import_data, %{field: new_value})
      {:ok, %ImportData{}}

      iex> update_import(import_data, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_import(%ImportData{} = import_data, attrs) do
    import_data
    |> ImportData.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a import.

  ## Examples

      iex> delete_import(import_data)
      {:ok, %ImportData{}}

      iex> delete_import(import_data)
      {:error, %Ecto.Changeset{}}

  """
  def delete_import(%ImportData{} = import_data) do
    Repo.delete(import_data)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking import changes.

  ## Examples

      iex> change_import(import_data)
      %Ecto.Changeset{data: %ImportData{}}

  """
  def change_import(%ImportData{} = import_data, attrs \\ %{}) do
    ImportData.changeset(import_data, attrs)
  end
end
