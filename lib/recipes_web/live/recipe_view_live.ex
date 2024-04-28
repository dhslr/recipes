defmodule RecipesWeb.RecipeViewLive do
  use RecipesWeb, :live_view
  alias Recipes.Data.Photo
  alias Recipes.Data

  def render(assigns) do
    assigns =
      assign(assigns,
        form_data: to_form(Data.change_recipe(assigns.recipe))
      )

    ~H"""
    <.main_content>
      <.header class="text-center my-3">
        <h1><%= @recipe.title %></h1>
      </.header>
      <.back navigate={~p"/recipes"}><%= gettext("Back") %></.back>
      <.photos photos={@recipe.photos} class="my-3" />
      <.sub_header text={gettext("Ingredients")} />
      <.ingredients_list
        adjust_factor={@adjusted_servings / max(1, @recipe.servings)}
        ingredients={@recipe.ingredients}
        class="my-3"
      />
      <div class="flex items-center justify-center mt-3">
        <.servings servings={@adjusted_servings} />
      </div>

      <.description description={@recipe.description} class="my-3 container mx-auto" />
      <.kcal :if={@recipe.kcal} kcal={@recipe.kcal} />

      <div class="flex justify-between items-start align-baseline">
        <.label_button
          icon="hero-pencil"
          label={gettext("Edit")}
          class="mt-16"
          href={~p"/recipes/#{@recipe.id}/edit"}
        />
      </div>
    </.main_content>
    """
  end

  def mount(params, _session, socket) do
    recipe = Data.get_recipe!(params["id"])

    {:ok,
     assign(socket,
       recipe: recipe,
       adjusted_servings: recipe.servings
     )}
  end

  attr(:class, :string, default: "")
  attr(:description, :string, required: true)

  def description(assigns) do
    {:ok, html_doc, []} = Earmark.as_html(assigns.description, compact_output: true, eex: true)
    assigns = assign(assigns, :description, html_doc)

    ~H"""
    <.sub_header text={gettext("Preparation")} class="my-3" />
    <div class={[@class]} data-test="description"><%= raw(@description) %></div>
    """
  end

  attr(:class, :string, default: "")
  attr(:photos, :list, required: true)

  defp photos(assigns) do
    ~H"""
    <ul class="my-2 flex justify-evenly gap-y-2 flex-wrap" data-test="photos">
      <li :for={photo <- @photos} class="min-w-[200px] max-h-[400px] max-w-[400px]">
        <img src={"/photos/#{Photo.filename(photo)}"} class="object-cover w-full h-full" />
      </li>
    </ul>
    """
  end

  attr(:class, :string, default: "")
  attr(:ingredients, :list, required: true)
  attr(:adjust_factor, :float, required: true)

  defp ingredients_list(assigns) do
    ~H"""
    <div class={["text-center", @class]} data-test="ingredients">
      <ul class="inline-block">
        <li :for={ingredient <- @ingredients} class="flex justify-between gap-10">
          <span class="font-medium text-left"><%= ingredient.name %></span>
          <span class="text-right">
            <span><%= adjust_quantity(ingredient.quantity, @adjust_factor) %></span>
            <span><%= ingredient.description %></span>
          </span>
        </li>
      </ul>
    </div>
    """
  end

  defp adjust_quantity(quantity, _factor) when is_nil(quantity), do: nil

  defp adjust_quantity(quantity, factor),
    do: :erlang.float_to_binary(quantity * factor, decimals: 1)

  attr(:class, :string, default: "")
  attr(:text, :string, required: true)

  defp sub_header(assigns) do
    ~H"""
    <div class={["flex justify-evenly gap-6 items-center", @class]}>
      <div class="border border-solid h-[1px] flex-1"></div>
      <h3 class="text-center"><%= @text %></h3>
      <div class="border border-solid h-[1px] flex-1"></div>
    </div>
    """
  end

  attr(:servings, :float, required: true)

  defp servings(assigns) do
    ~H"""
    <div class=" p-3 text-lg rounded-full">
      <div class="flex flex-wrap content-center text-center" data-test="servings">
        <button
          name="decrease-servings"
          type="button"
          phx-click="change-servings"
          phx-value-servings={max(1, assigns.servings - 1)}
        >
          <.icon name="hero-minus-circle w-8 h-8" />
        </button>
        <span class="w-8 text-center"><%= @servings %></span>
        <button
          name="increase-servings"
          type="button"
          phx-click="change-servings"
          phx-value-servings={assigns.servings + 1}
        >
          <.icon name="hero-plus-circle  w-8 h-8" />
        </button>
      </div>
      <div class="text-center"><%= gettext("Servings") %></div>
    </div>
    """
  end

  attr(:kcal, :float, required: true)

  defp kcal(assigns) do
    ~H"""
    <div class="text-gray-500" data-test="kcal">
      <span :if={@kcal}><%= @kcal %> kcal pro Portion</span>
    </div>
    """
  end

  def handle_event("change-servings", %{"servings" => servings}, socket) do
    {new_servings, _} = Integer.parse(servings)

    {:noreply,
     socket
     |> push_patch(to: ~p"/recipes/#{socket.assigns.recipe.id}?servings=#{new_servings}")}
  end

  def handle_params(params, _uri, socket) do
    with servings_str when not is_nil(servings_str) <- params["servings"],
         {servings, _} <- Integer.parse(servings_str) do
      {:noreply,
       socket
       |> assign(adjusted_servings: servings)}
    else
      _ -> {:noreply, socket}
    end
  end
end
