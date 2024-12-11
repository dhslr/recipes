defmodule RecipesWeb.RecipesLive do
  use RecipesWeb, :live_view

  alias Recipes.Data

  alias Recipes.Data.Photo
  alias Recipes.Data.Recipe

  defp filtered_recipes(%{query: query, recipes: recipes}) do
    if String.length(query) > 0 do
      Data.list_recipes_by_tag_or_title(query)
    else
      recipes
    end
  end

  def render(assigns) do
    assigns =
      assigns
      |> assign(:form_data, to_form(%{"query" => assigns.query}))
      |> assign(
        :filtered_recipes,
        filtered_recipes(assigns)
      )

    ~H"""
    <.main_content>
      <.search_bar form_data={@form_data} />
      <.tag_cloud tags={@tags} />
      <div class="flex flex-wrap gap-5 justify-evenly">
        <div
          :for={recipe <- @filtered_recipes}
          id={"recipe_#{recipe.id}"}
          class="bg-slate-100 p-2 rounded-xl"
          data-test="recipe"
        >
          <.link navigate={~p"/recipes/#{recipe.id}"} class="text-center break-words block w-[320px]">
            <.main_photo photo={Recipe.first_photo(recipe)} />
            <label class="text-center mt-1 p-1" for={"recipe_#{recipe.id}"}>
              {recipe.title}
            </label>
            <div class="text-sm text-slate-600" data-test="tags">
              {Enum.map(recipe.tags, & &1.name) |> Enum.join(", ")}
            </div>
          </.link>
        </div>
      </div>
      <:action position="right">
        <.label_button
          href={~p(/recipes/new)}
          icon="hero-plus"
          type="button"
          label="New"
          color="emerald"
          class="min-w-32"
        />
      </:action>
      <:action position="right">
        <.label_button
          href={~p(/imports/new)}
          icon="hero-cloud-arrow-down"
          type="button"
          color="emerald"
          label="Import"
          class="min-w-32"
        />
      </:action>
    </.main_content>
    """
  end

  defp tag_cloud(assigns) do
    ~H"""
    <div class="flex gap-3 justify-center max-w-40 mb-10 flex-wrap" data-test="tag-cloud">
      <a :for={tag <- @tags} phx-click="click-tag" phx-value-tag-name={tag.name} href="#">
        <.tag name={tag.name} />
      </a>
    </div>
    """
  end

  defp search_bar(assigns) do
    ~H"""
    <div data-test="search-bar" class="flex gap-2 mb-2 items-baseline content-center">
      <.simple_form for={@form_data} phx-change="change-query" class="flex-1">
        <.input type="text" field={@form_data[:query]} placeholder={gettext("Search")} />
      </.simple_form>
      <button type="button" phx-click="clear-search" data-test="clear-search-button">
        <.icon name="hero-x-mark" />
      </button>
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
      # {:ok, stream(socket, :tags, Data.list_tags())} TODO maybe stream recipes here?
      |> assign(:recipes, Data.list_recipes())
      |> assign(:query, "")
      |> assign(:tags, Data.list_tags() |> Enum.uniq_by(& &1.name))

    {:ok, socket}
  end

  def handle_event("click-tag", %{"tag-name" => name}, socket) do
    {:noreply, socket |> assign(:query, name)}
  end

  def handle_event("change-query", %{"query" => query}, socket) do
    {:noreply, socket |> assign(:query, query)}
  end

  def handle_event("clear-search", _, socket) do
    {:noreply, socket |> assign(:query, "")}
  end
end
