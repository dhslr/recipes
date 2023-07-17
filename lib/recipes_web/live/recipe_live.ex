defmodule RecipesWeb.RecipeLive do
  use RecipesWeb, :live_view

  def render(assigns) do
    assigns = assign(assigns, :recipe_form, Recipes.change_recipe(assigns.recipe))

    ~H"""
    <.header class="text-center">
      <%= gettext("View and edit your recipe") %>
    </.header>

    <.simple_form
      for={@recipe_form}
      id="recipe_form"
      phx-change="validate_recipe"
      phx-submit="update_recipe"
    >
      <.input field={@recipe_form[:title]} label={gettext("Title")} required />
      <.input field={@recipe_form[:description]} label={gettext("Description")} required />
      <:actions>
        <.button phx-disable-with="Saving..."><%= gettext("Save") %></.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(params, _session, socket) do
    recipe = Recipes.get_recipe!(params["id"])

    socket =
      socket
      |> assign(:recipe, recipe)
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end
end
