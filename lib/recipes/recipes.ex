defmodule Recipes do
  @moduledoc """
  The Data context.
  """

  import Ecto.Query, warn: false
  alias Recipes.Repo
  alias Recipes.Data.Food
  alias Recipes.Data.Photo

  require Logger

  @doc """
  Returns the list of food.

  ## Examples

      iex> list_food()
      [%Food{}, ...]

  """
  def list_food do
    Repo.all(Food)
  end

  @doc """
  Gets a single food.

  Raises `Ecto.NoResultsError` if the Food does not exist.

  ## Examples

      iex> get_food!(123)
      %Food{}

      iex> get_food!(456)
      ** (Ecto.NoResultsError)

  """
  def get_food!(id), do: Repo.get!(Food, id)

  @doc """
  Creates a food.

  ## Examples

      iex> create_food(%{field: value})
      {:ok, %Food{}}

      iex> create_food(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_food(attrs \\ %{}) do
    %Food{}
    |> Food.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a food.

  ## Examples

      iex> update_food(food, %{field: new_value})
      {:ok, %Food{}}

      iex> update_food(food, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_food(%Food{} = food, attrs) do
    food
    |> Food.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a food.

  ## Examples

      iex> delete_food(food)
      {:ok, %Food{}}

      iex> delete_food(food)
      {:error, %Ecto.Changeset{}}

  """
  def delete_food(%Food{} = food) do
    Repo.delete(food)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking food changes.

  ## Examples

      iex> change_food(food)
      %Ecto.Changeset{data: %Food{}}

  """
  def change_food(%Food{} = food, attrs \\ %{}) do
    Food.changeset(food, attrs)
  end

  alias Recipes.Data.Recipe

  @doc """
  Returns the list of recipes.

  ## Examples

      iex> list_recipes()
      [%Recipe{}, ...]

  """
  def list_recipes do
    Repo.all(Recipe) |> Repo.preload(ingredients: [:food], photos: [])
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
  def get_recipe!(id), do: Repo.get!(Recipe, id) |> Repo.preload(ingredients: [:food], photos: [])

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
    |> preload_h([:ingredients, :photos])
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
    |> preload_h([:ingredients, :photos])
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

      iex> create_ingredient(%{recipe_id: 1, food_id: 1})
      {:ok, %Ingredient{}}

      iex> create_ingredient_and_food(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ingredient(attrs) do
    %Ingredient{}
    |> Ingredient.changeset(attrs)
    |> Repo.insert()
    |> preload_h([:food])
  end

  def get_or_create_food(name) do
    case Repo.get_by(Food, name: name) do
      nil -> create_food(%{name: name})
      food -> {:ok, food}
    end
  end

  defp preload_h({:ok, entity}, what), do: {:ok, Repo.preload(entity, what)}
  defp preload_h(error, _), do: error

  @doc """
  Updates a ingredient.

  ## Examples

      iex> update_ingredient(ingredient, %{field: new_value})
      {:ok, %Ingredient{}}

      iex> update_ingredient(ingredient, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ingredient(%Ingredient{} = ingredient, attrs) do
    ingredient
    |> Ingredient.changeset(attrs)
    |> Repo.update()
    |> preload_h([:food])
  end

  @doc """
  Deletes a ingredient.

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

  def create_photo(%{"upload" => %Plug.Upload{} = upload} = attrs) do
    with {:ok, %Photo{} = photo} <- create_photo_entry(attrs),
         {:ok, _} <- File.copy(upload.path, "#{filepath(photo)}") do
      {:ok, photo}
    end
  end

  defp create_photo_entry(attrs) do
    %Photo{}
    |> Photo.changeset(attrs)
    |> Repo.insert()
  end

  def get_photo!(id), do: Repo.get!(Photo, id)

  def delete_photo(%Photo{} = photo) do
    File.rm(filepath(photo))
    Repo.delete(photo)
  end

  defp filepath(%Photo{} = photo) do
    path = Path.join(Photo.photos_dir(), Photo.filename(photo))
    Logger.debug("Deleting photo #{path}")
    path
  end
end
