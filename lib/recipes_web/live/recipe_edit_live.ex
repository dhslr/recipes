defmodule RecipesWeb.RecipeEditLive do
  use RecipesWeb, :live_view
  require Logger
  alias Recipes.Data

  def render(assigns) do
    form_data =
      assigns.recipe
      |> Ecto.Changeset.change()
      |> to_form()

    assigns = assign(assigns, :form_data, form_data)

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
          <div class="flex justify-between">
            <.inputs_for :let={food} field={ingredient[:food]}>
              <.input type="text" field={food[:name]} />
            </.inputs_for>
            <.input type="text" field={ingredient[:quantity]} />
            <.input type="text" field={ingredient[:description]} />
          </div>
        </.inputs_for>
      </div>

      <:actions>
        <.button phx-disable-with="Saving..."><%= gettext("Save") %></.button>
      </:actions>
    </.simple_form>
    <.back navigate={~p"/recipes/#{@recipe.id}"}><%= gettext("Back") %></.back>
    """
  end

  def mount(params, _session, socket) do
    recipe = Data.get_recipe!(params["id"])

    {:ok, socket |> assign(:recipe, recipe)}
  end

  def handle_event("validate_recipe", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("update_recipe", params, socket) do
    {:ok, recipe} = Data.update_recipe(socket.assigns.recipe, params["recipe"])

    Logger.debug("Recipe updated: #{inspect(recipe)}")
    {:noreply, push_navigate(socket, to: ~p"/recipes/#{recipe.id}")}
  end
end
