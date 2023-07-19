defmodule RecipesWeb.RecipesLive do
  use RecipesWeb, :live_view

  def render(assigns) do
    ~H"""
    <.header class="text-center"></.header>

    <div class="flex">
      <div :for={recipe <- @recipes} class="w-20 h-20 bg-sky-100 text-center">
        <.link navigate={~p"/recipes/#{recipe.id}"} class="">
          <%= recipe.title %>
        </.link>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:recipes, Recipes.list_recipes())

    {:ok, socket}
  end
end
