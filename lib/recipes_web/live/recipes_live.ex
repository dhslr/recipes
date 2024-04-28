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
          String.contains?(String.upcase(recipe.title), String.upcase(assigns.query))
        end)
      )

    ~H"""
    <.header class="text-center"></.header>

    <div class="container mx-auto">
      <.search_bar form_data={@form_data} />
      <div class="flex flex-wrap gap-5 justify-evenly">
        <div :for={recipe <- @filtered_recipes}>
          <.link navigate={~p"/recipes/#{recipe.id}"} class="text-center break-words block w-[320px]">
            <.main_photo photo={Recipe.first_photo(recipe)} />
            <div class="rounded-md text-center bg-slate-100 mt-1 p-1"><%= recipe.title %></div>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  defp search_bar(assigns) do
    ~H"""
    <div class="flex gap-2 mb-12 items-baseline content-center">
      <.simple_form for={@form_data} phx-change="change-query" class="flex-1">
        <.input type="text" field={@form_data[:query]} placeholder={gettext("Search")} />
      </.simple_form>
      <.label_button href={~p(/recipes/new)} icon="hero-plus" type="button" label="New recipe" />
      <.floating_button href={~p(/imports/new)} type="button" label="Import recipe" />
    </div>
    """
  end

  defp main_photo(assigns) do
    ~H"""
    <div class="overflow-hidden w-[320px] h-[240px] mx-auto rounded-xl">
      <img
        :if={assigns.photo}
        src={"/photos/#{Photo.filename(@photo)}"}
        class="object-cover w-full h-full"
      />
      <img :if={!assigns.photo} src="/images/meal_placeholder.jpg" class="object-cover w-full h-full" />
    </div>
    """
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
