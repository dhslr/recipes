defmodule RecipesWeb.RecipeEditLive do
  use RecipesWeb, :live_view
  require Logger
  alias Recipes.Data
  alias Recipes.Data.Photo
  alias Recipes.Data.Recipe

  @impl true
  def mount(params, _session, socket) do
    socket = apply_action(socket, socket.assigns.live_action, params)

    link =
      if(socket.assigns.live_action == :new,
        do: ~p"/recipes",
        else: ~p"/recipes/#{socket.assigns.recipe.id}"
      )

    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> assign(:dirty, false)
     |> assign(:back_link, link)
     |> assign(:ingredient_names, Data.get_ingredient_names())
     |> assign(:ingredient_descriptions, Data.get_ingredient_descriptions())
     |> allow_upload(:photo, accept: ~w(.jpg .jpeg .heic .png .gif), max_entries: 3)
     |> assign(:form_data, to_form(Data.change_recipe(socket.assigns.recipe)))}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    recipe = Data.get_recipe!(id)

    socket
    |> assign(:page_title, "Edit Recipe")
    |> assign(:recipe, recipe)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Recipe")
    |> assign(:recipe, Recipe.empty())
  end

  @impl true
  def handle_event("validate_recipe", params, socket) do
    Logger.debug("Validate recipe : #{inspect(params)}")

    form_data =
      socket.assigns.recipe
      |> Recipes.Data.change_recipe(params["recipe"])
      |> struct!(action: :validate)
      |> to_form()

    {:noreply, socket |> assign(:form_data, form_data) |> assign(:dirty, true)}
  end

  @impl true
  def handle_event("save_recipe", %{"recipe" => recipe_params} = attrs, socket) do
    Logger.debug("Save recipe : #{inspect(attrs)}")

    _photos =
      consume_uploaded_entries(socket, :photo, fn %{path: path}, _entry ->
        Data.create_photo(%{
          photo_file_path: path,
          recipe_id: socket.assigns.recipe.id
        })
      end)

    case save_recipe(socket, socket.assigns.live_action, recipe_params) do
      {:ok, recipe} -> {:noreply, push_navigate(socket, to: ~p"/recipes/#{recipe.id}")}
      {:error, changeset} -> {:noreply, assign(socket, :form_data, changeset |> to_form)}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  @impl true
  def handle_event("reposition", _params, socket) do
    # handled by ecto via sort_param
    {:noreply, socket}
  end

  defp photo_upload(assigns) do
    ~H"""
    <%!-- use phx-drop-target with the upload ref to enable file drag and drop --%>
    <section phx-drop-target={@uploads.photo.ref}>
      <ul class="flex gap-2">
        <li :for={entry <- @uploads.photo.entries} class="upload-entry">
          <figure class="py-1 w-[400px]">
            <div class="relative">
              <.live_img_preview entry={entry} width={400} class="relative" />
              <progress
                value={entry.progress}
                max="100"
                class="absolute top-[93%] w-full p-[5px] opacity-60"
              >
                {entry.progress}%
              </progress>
            </div>
            <div class="flex justify-between">
              <figcaption>{entry.client_name}</figcaption>
              <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref}>
                <.trash_icon />
              </button>
            </div>
          </figure>
          <div class="flex my-6">
            <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
            <%= for err <- upload_errors(@uploads.photo, entry) do %>
              <p class="alert alert-danger">{error_to_string(err)}</p>
            <% end %>
          </div>
        </li>
        <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
        <%= for err <- upload_errors(@uploads.photo) do %>
          <p class="alert alert-danger">{error_to_string(err)}</p>
        <% end %>
      </ul>
      <%!-- TODO use mechanism like in ingredients for adding --%>
      <label class="cursor-pointer float-right">
        <.icon name="hero-plus-circle" /> {gettext("add")}
        <.live_file_input upload={@uploads.photo} class="hidden" />
      </label>
    </section>
    """
  end

  defp trash_icon(assigns) do
    ~H"""
    <.icon
      name="hero-trash"
      class="bg-red-500 h-6 w-6 transition-transform transform hover:scale-105"
    />
    """
  end

  defp save_recipe(_socket, :new, recipe_params) do
    Data.create_recipe(recipe_params)
  end

  defp save_recipe(socket, :edit, recipe_params) do
    Data.update_recipe(socket.assigns.recipe, recipe_params)
  end

  defp error_to_string(:too_large), do: gettext("File too large")
  defp error_to_string(:too_many_files), do: gettext("You have selected too many files")
  defp error_to_string(:not_accepted), do: gettext("You have selected an unacceptable file type")
end
