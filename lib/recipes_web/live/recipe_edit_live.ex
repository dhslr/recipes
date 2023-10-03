defmodule RecipesWeb.RecipeEditLive do
  use RecipesWeb, :live_view
  require Logger
  alias Recipes.Data

  def render(assigns) do
    assigns = assign(assigns, form_data: to_form(assigns.changeset))

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
            <.input type="text" field={ingredient[:name]} />
            <.input type="text" field={ingredient[:quantity]} />
            <.input type="text" field={ingredient[:description]} />
            <label  class="self-center">
              <input
                type="checkbox"
                name="recipe[ingredients_drop][]"
                value={ingredient.index}
                class="hidden"
              />
              <.icon name="hero-trash" class="bg-red-500 h-6 w-6" />
            </label>
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
    Logger.debug("Mount recipe edit : #{inspect(params)}")
    recipe = Data.get_recipe!(params["id"])
    changeset = Data.change_recipe(recipe)

    {:ok, socket |> assign(changeset: changeset, recipe: recipe)}
  end

  def handle_event("validate_recipe", params, socket) do
    Logger.debug("Validate recipe : #{inspect(params)}")

        changeset = Recipes.Data.change_recipe(socket.assigns.recipe, params["recipe"])
    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_event("update_recipe", params, socket) do
    Logger.debug("Update recipe : #{inspect(params)}")

    {:ok, recipe} = Data.update_recipe(socket.assigns.recipe, params["recipe"])
    {:noreply, push_navigate(socket, to: ~p"/recipes/#{recipe.id}")}
  end
end
