defmodule Recipes.Data do
  @moduledoc """
  The Data context.
  """

  import Ecto.Query, warn: false
  alias Recipes.Data.Ingredient
  alias Recipes.Data.Photo
  alias Recipes.Repo

  require Logger

  alias Recipes.Data.Recipe

  @doc """
  Returns the list of recipes sorted alphabetically.

  ## Examples

      iex> list_recipes()
      [%Recipe{}, ...]

  """
  def list_recipes do
    Repo.all(Recipe)
    |> Repo.preload([:ingredients, :photos, :tags])
    |> Enum.sort(&(&1.title <= &2.title))
  end

  def list_recipes_by_tag_or_title(tag_or_title) do
    escaped_tag_or_title = "%#{String.replace(tag_or_title, "%", "\\%")}%"

    title_query =
      from r in Recipe,
        join: t in assoc(r, :tags),
        where: ilike(t.name, ^escaped_tag_or_title)

    tag_query_union =
      from r in Recipe,
        where: ilike(r.title, ^escaped_tag_or_title),
        union: ^title_query

    Repo.all(
      from(r in subquery(tag_query_union),
        order_by: r.title,
        preload: [:ingredients, :photos, :tags]
      )
    )
  end

  def get_ingredient_names do
    Repo.all(Ingredient)
    |> Enum.map(fn i -> i.name end)
    |> Enum.uniq()
  end

  @doc """
  Gets a single recipe.

  Raises `Ecto.NoResultsError` if the Recipe does not exist.

  ## Examples

      iex> get_recipe!(123)
      %Recipe{}

      iex> get_recipe!(456)
      ** (Ecto.NoResultsError)

  """
  def get_recipe!(id), do: Repo.get!(Recipe, id) |> Repo.preload([:ingredients, :photos, :tags])

  @doc """
  Creates a recipe.

  ## Examples

      iex> create_recipe(%{title: "recipe title", description: "recipe description", kcal: 1234, servings: 4})
      {:ok, %Recipe{title: "recipe title", kcal: 1234}}

      iex> create_recipe(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_recipe(attrs \\ %{}) do
    %Recipe{}
    |> Recipe.changeset(attrs)
    |> Repo.insert()
    |> preload_h([:ingredients, :photos, :tags])
  end

  @doc """
  Updates a recipe.

  ## Examples

      iex> update_recipe(recipe, %{field: new_value})
      {:ok, %Recipe{}}

      iex> update_recipe(recipe, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_recipe(%Recipe{} = recipe, attrs) do
    recipe
    |> Recipe.changeset(attrs)
    |> Repo.update()
    |> preload_h([:ingredients, :photos, :tags])
  end

  @doc """
  Deletes a recipe.

  ## Examples

      iex> delete_recipe(recipe)
      {:ok, %Recipe{}}

      iex> delete_recipe(recipe)
      {:error, %Ecto.Changeset{}}

  """
  def delete_recipe(%Recipe{} = recipe) do
    Repo.delete(recipe)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking recipe changes.

  ## Examples

      iex> change_recipe(recipe)
      %Ecto.Changeset{data: %Recipe{}}

  """
  def change_recipe(%Recipe{} = recipe, attrs \\ %{}) do
    Recipe.changeset(recipe, attrs)
  end

  alias Recipes.Data.Ingredient

  @doc """
  Creates a ingredient.

  ## Examples

      iex> create_ingredient(%{recipe_id: 1, name: "Food"})
      {:ok, %Ingredient{}}

      iex> create_ingredient(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ingredient(attrs) do
    %Ingredient{}
    |> Ingredient.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Adds an ingredient to the recipe.

  ## Examples

      iex> add_ingredient(recipe, "Bananas")
      %Ecto.Changeset{data: %Recipe{}}

  """
  def add_ingredient(recipe, ingredient_name) do
    recipe
    |> Ecto.Changeset.change(%{})
    |> Ecto.Changeset.put_assoc(:ingredients, recipe.ingredients ++ [%{name: ingredient_name}])
  end

  defp preload_h({:ok, entity}, what), do: {:ok, Repo.preload(entity, what)}
  defp preload_h(error, _), do: error

  @doc """
  Updates a ingredient.

  ## Examples

      iex> delete_ingredient(ingredient)
      {:ok, %Ingredient{}}

      iex> delete_ingredient(ingredient)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ingredient(%Ingredient{} = ingredient) do
    Repo.delete(ingredient)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ingredient changes.

  ## Examples

      iex> change_ingredient(ingredient)
      %Ecto.Changeset{data: %Ingredient{}}

  """
  def change_ingredient(%Ingredient{} = ingredient, attrs \\ %{}) do
    Ingredient.changeset(ingredient, attrs)
  end

  def create_photo(%{photo_file_path: path, recipe_id: recipe_id}) do
    {:ok, %Photo{} = photo} = create_photo_entry(%{recipe_id: recipe_id})

    case File.copy(path, filepath(photo)) do
      {:ok, _file} ->
        {:ok, photo}

      {:error, error} = err ->
        Logger.error(
          "Failed to create photo entry for uploaded photo at #{path} and recipe #{recipe_id}: #{error}"
        )

        delete_photo(photo)
        err
    end
  end

  defp create_photo_entry(attrs) do
    %Photo{}
    # TODO support caption
    |> Photo.changeset(attrs)
    |> Repo.insert()
  end

  def get_photo!(id), do: Repo.get!(Photo, id)

  def delete_photo(%Photo{} = photo) do
    File.rm(filepath(photo))
    Repo.delete(photo)
  end

  defp filepath(%Photo{} = photo) do
    Path.join(Photo.photos_dir(), Photo.filename(photo))
  end

  alias Recipes.Data.Tag

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end
end
