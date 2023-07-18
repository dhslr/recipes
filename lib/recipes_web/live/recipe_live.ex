defmodule RecipesWeb.RecipeLive do
  use RecipesWeb, :live_view

  def render(assigns) do
    assigns = assign(assigns, :form_data, to_form(Recipes.change_recipe(assigns.recipe)))

    ~H"""
    <.header class="text-center">
      <h1><%= @recipe.title %></h1>
    </.header>

    <h3><%= gettext("Ingredients") %></h3>
    <.ingredients_list ingredients={@recipe.ingredients} />
    <.photos photos={@recipe.photos} />
    <div class="p-1 shadow mt-2"><%= @recipe.description %></div>
    <.back navigate={~p"/recipes"}><%= gettext("Back") %></.back>
    """
  end

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:recipe, Recipes.get_recipe!(params["id"]))

    {:ok, socket}
  end

  defp photos(assigns) do
    ~H"""
    <ul>
      <li :for={photo <- @photos}>
        <img src={~p"/photos/#{photo.filename}"} />
      </li>
    </ul>
    """
  end

  defp ingredients_list(assigns) do
    ~H"""
    <ul>
      <li :for={ingredient <- @ingredients}>
        <span class="font-medium"><%= ingredient.food.name %></span>
        <span><%= ingredient.quantity %></span>
        <span><%= ingredient.description %></span>
      </li>
    </ul>
    """
  end
end
