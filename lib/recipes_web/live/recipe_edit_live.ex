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
      <h4><%= gettext("Ingredients") %></h4>
      <div data-test="ingredients" class="ml-3">
        <.inputs_for :let={ingredient} field={@form_data[:ingredients]}>
          <div class="columns-3">
            <span><%= ingredient.data.food.name %></span>
            <.input type="text" field={ingredient[:quantity]} />
            <.input type="text" field={ingredient[:description]} />
          </div>
        </.inputs_for>
      </div>

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

  def handle_event("validate_recipe", _, socket) do
    {:noreply, socket}
  end

  def handle_event("update_recipe", params, socket) do
    {:ok, recipe} = Recipes.update_recipe(socket.assigns.recipe, params["recipe"])

    {:noreply, assign(socket, recipe: recipe)}
  end

end
