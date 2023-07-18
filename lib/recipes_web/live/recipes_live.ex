defmodule RecipesWeb.RecipesLive do
  use RecipesWeb, :live_view


  def render(assigns) do
    ~H"""
    <.header class="text-center"></.header>

    <ul>
      <li :for={recipe <- @recipes}>
        <.link navigate={~p"/recipes/#{recipe.id}"}>
          <%= recipe.title %>
        </.link>
      </li>
    </ul>

    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:recipes, Recipes.list_recipes())

    {:ok, socket}
  end
end
