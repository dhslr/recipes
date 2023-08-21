defmodule RecipesWeb.RecipeViewLive do
  use RecipesWeb, :live_view
  alias Recipes.Data

  def render(assigns) do
    assigns = assign(assigns, :form_data, to_form(Data.change_recipe(assigns.recipe)))

    ~H"""
    <.header class="text-center my-3">
      <h1><%= @recipe.title %></h1>
    </.header>

    <.ingredients_list ingredients={@recipe.ingredients} class="my-3" />
    <.photos photos={@recipe.photos} class="my-3" />
    <.description description={@recipe.description} class="my-3" />

    <div class="flex justify-between items-start align-baseline">
      <.back navigate={~p"/recipes"}><%= gettext("Back") %></.back>
      <.label_button
        icon="hero-pencil"
        label={gettext("Edit")}
        class="mt-16"
        href={~p"/recipes/#{@recipe.id}/edit"}
      />
    </div>
    """
  end

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:recipe, Data.get_recipe!(params["id"]))

    {:ok, socket}
  end

  attr :class, :string, default: ""
  attr :description, :string, required: true

  def description(assigns) do
    {:ok, html_doc, []} = Earmark.as_html(assigns.description, compact_output: true, eex: true)
    assigns = assign(assigns, :description, html_doc)

    ~H"""
    <.sub_header text={gettext("Preparation")} class="my-3" />
    <div class={[@class]} data-test="description"><%= raw(@description) %></div>
    """
  end

  attr :class, :string, default: ""
  attr :photos, :list, required: true

  defp photos(assigns) do
    ~H"""
    <ul class={[@class]} data-test="photos">
      <li :for={_photo <- @photos}>
        <%!-- <img src={~p"/photos/#{photo.filename()}"} /> --%>
      </li>
    </ul>
    """
  end

  attr :class, :string, default: ""
  attr :ingredients, :list, required: true

  defp ingredients_list(assigns) do
    ~H"""
    <.sub_header text={gettext("Ingredients")} />

    <div class={["text-center", @class]} data-test="ingredients">
      <ul class="inline-block">
        <li :for={ingredient <- @ingredients} class="flex justify-between gap-10">
          <span class="font-medium text-left"><%= ingredient.name %></span>
          <span class="text-right">
            <span><%= ingredient.quantity %></span>
            <span><%= ingredient.description %></span>
          </span>
        </li>
      </ul>
    </div>
    """
  end

  attr :class, :string, default: ""
  attr :text, :string, required: true

  defp sub_header(assigns) do
    ~H"""
    <div class={["flex justify-evenly gap-6 items-center", @class]}>
      <div class="border border-solid h-[1px] flex-1"></div>
      <h3 class="text-center"><%= @text %></h3>
      <div class="border border-solid h-[1px] flex-1"></div>
    </div>
    """
  end
end
