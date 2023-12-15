defmodule RecipesWeb.RecipeEditLive do
  alias Recipes.Data.Recipe
  use RecipesWeb, :live_view
  require Logger
  alias Recipes.Data

  @impl true
  def render(assigns) do
    link =
      if(assigns.live_action == :new,
        do: ~p"/recipes",
        else: ~p"/recipes/#{assigns.recipe.id}"
      )

    assigns = assign(assigns, back_link: link)

    ~H"""
    <.header class="text-center">
      <h1><%= @recipe.title %></h1>
    </.header>

    <.simple_form
      for={@form_data}
      id="recipe_form"
      phx-change="validate_recipe"
      phx-submit="save_recipe"
      class="container mx-auto max-w-4xl"
    >
      <.back navigate={@back_link}><%= gettext("Back") %></.back>
      <.input field={@form_data[:title]} label={gettext("Title")} required />
      <.input type="textarea" field={@form_data[:description]} label={gettext("Description")} />
      <h4><%= gettext("Ingredients") %></h4>
      <div data-test="ingredients" class="ml-3">
        <.inputs_for :let={ingredient} field={@form_data[:ingredients]}>
          <div class="flex justify-between">
            <.input type="text" field={ingredient[:name]} placeholder={gettext("What")} />
            <.input
              type="text"
              field={ingredient[:quantity]}
              placeholder={gettext("Quantity (opt.)")}
            />
            <.input
              type="text"
              field={ingredient[:description]}
              placeholder={gettext("Description/Unit (opt.)")}
            />
            <label class="self-center">
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
        <.button type="button" phx-click="add_ingredient" phx-disable-with="Adding...">
          <.icon name="hero-plus" class="bg-green-300" />
        </.button>
        <.button phx-disable-with="Saving..."><%= gettext("Save") %></.button>
      </:actions>
    </.simple_form>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    socket = apply_action(socket, socket.assigns.live_action, params)
    {:ok, assign(socket, :form_data, to_form(Data.change_recipe(socket.assigns.recipe)))}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    recipe = Data.get_recipe!(id)

    socket
    |> assign(:page_title, "Edit Recipe")
    |> assign(:recipe, recipe)
  end

  defp apply_action(socket, :new, _params) do
    recipe = %Recipe{}

    socket
    |> assign(:page_title, "New Recipe")
    |> assign(:recipe, recipe)
  end

  @impl true
  def handle_event("validate_recipe", params, socket) do
    Logger.debug("Validate recipe : #{inspect(params)}")

    changeset = Recipes.Data.change_recipe(socket.assigns.recipe, params["recipe"])
    {:noreply, socket |> assign(:form_data, to_form(changeset))}
  end

  @impl true
  def handle_event("add_ingredient", _params, socket) do
    Logger.debug("Add ingredient")

    socket =
      update(socket, :form_data, fn %{source: changeset} ->
        existing = Ecto.Changeset.get_assoc(changeset, :ingredients)
        changeset = Ecto.Changeset.put_assoc(changeset, :ingredients, existing ++ [%{name: ""}])
        to_form(changeset)
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("save_recipe", %{"recipe" => recipe_params}, socket) do
    Logger.debug("Save recipe : #{inspect(recipe_params)}")

    {:ok, recipe} = save_recipe(socket, socket.assigns.live_action, recipe_params)
    {:noreply, push_navigate(socket, to: ~p"/recipes/#{recipe.id}")}
  end

  defp save_recipe(_socket, :new, recipe_params) do
    Data.create_recipe(recipe_params)
  end

  defp save_recipe(socket, :edit, recipe_params) do
    Data.update_recipe(socket.assigns.recipe, recipe_params)
  end
end
