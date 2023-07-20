defmodule RecipesWeb.RecipeEditLive do
  use RecipesWeb, :live_view

  def render(assigns) do
    assigns = assign(assigns, :form_data, to_form(Recipes.change_recipe(assigns.recipe)))

    ~H"""
    <.header class="text-center">
      <h1><%= @recipe.title %></h1>
    </.header>

    <.simple_form
      for={@form_data}
      id="recipe_form"
      phx-change="validate_recipe"
      phx-submit="update_recipe"
    >
      <.input field={@form_data[:title]} label={gettext("Title")} required />
      <.input type="textarea" field={@form_data[:description]} label={gettext("Description")} />
      <:actions>
        <.button phx-disable-with="Saving..."><%= gettext("Save") %></.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:recipe, Recipes.get_recipe!(params["id"]))

    {:ok, socket}
  end
end
