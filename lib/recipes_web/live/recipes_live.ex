defmodule RecipesWeb.RecipesLive do
  use RecipesWeb, :live_view
  alias Recipes.Data
  alias Recipes.Data.Recipe
  alias Recipes.Data.Photo

  def render(assigns) do
    ~H"""
    <.header class="text-center"></.header>

    <div class="container mx-auto">
      <div class="flex flex-wrap gap-2 justify-center">
        <div :for={recipe <- @recipes} class="text-center">
          <.link navigate={~p"/recipes/#{recipe.id}"}>
            <.main_photo photo={Recipe.first_photo(recipe)} />
            <%= recipe.title %>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  defp main_photo(assigns) do
    if assigns.photo do
      ~H"""
      <img src={"/photos/#{Photo.filename(@photo)}"} width="250px" />
      """
    else
      ~H"""
      <img src="/images/meal_placeholder.jpg" width="250px" />
      """
    end
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:recipes, Data.list_recipes())

    {:ok, socket}
  end
end
