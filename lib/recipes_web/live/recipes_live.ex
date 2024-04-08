defmodule RecipesWeb.RecipesLive do
  use RecipesWeb, :live_view
  alias Recipes.Data
  alias Recipes.Data.Recipe
  alias Recipes.Data.Photo

  def render(assigns) do
    photo = ~H"""
    <.header class="text-center"></.header>

    <div class="container mx-auto">
      <div class="flex flex-wrap gap-2 justify-center">
        <div :for={recipe <- @recipes} class="text-center">
          <.link navigate={~p"/recipes/#{recipe.id}"}>
            <img src={"/photos/#{Photo.filename(Recipe.first_photo(recipe))}"} width="250px" />
            <%= recipe.title %>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:recipes, Data.list_recipes())

    {:ok, socket}
  end
end
