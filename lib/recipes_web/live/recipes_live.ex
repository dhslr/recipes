defmodule RecipesWeb.RecipesLive do
  use RecipesWeb, :live_view
  alias Recipes.Data
  alias Recipes.Data.Recipe
  alias Recipes.Data.Photo

  def render(assigns) do
    assigns =
      assigns
      |> assign(:form_data, to_form(%{"query" => assigns.query}))
      |> assign(
        :filtered_recipes,
        Enum.filter(assigns.recipes, fn recipe ->
          String.contains?(String.capitalize(recipe.title), String.capitalize(assigns.query))
        end)
      )

    ~H"""
    <.header class="text-center"></.header>

    <div class="container mx-auto">
      <.search_bar form_data={@form_data} />
      <div class="flex flex-wrap gap-2 justify-center">
        <div :for={recipe <- @filtered_recipes} class="text-center">
          <.link navigate={~p"/recipes/#{recipe.id}"}>
            <.main_photo photo={Recipe.first_photo(recipe)} />
            <%= recipe.title %>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  defp search_bar(assigns) do
    ~H"""
    <div>
    </div>
    <.simple_form for={@form_data} phx-change="change-query" class="mb-12">
      <.input type="text" field={@form_data[:query]} placeholder={gettext("Search")} />
    </.simple_form>
    """
  end

  defp main_photo(assigns) do
    if assigns.photo do
      ~H"""
      <img src={"/photos/#{Photo.filename(@photo)}"} width="250px" />
      """
    else
      ~H"""
      <img src="/images/meal_placeholder.jpg" width="250px" />
      """
    end
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:recipes, Data.list_recipes())
      |> assign(:query, "")

    {:ok, socket}
  end

  def handle_event("change-query", %{"query" => query}, socket) do
    {:noreply, socket |> assign(:query, query)}
  end
end
