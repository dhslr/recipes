defmodule RecipesWeb.NewImportLive do
  alias Recipes.Imports.ImportData
  alias Recipes.Imports
  use RecipesWeb, :live_view
  alias Recipes.Scraper

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:error, nil)
     |> assign_form(Imports.change_import(%ImportData{}))}
  end

  @impl true
  def handle_event("validate", %{"import_data" => import_params}, socket) do
    changeset =
      socket.assigns.form.data
      |> Imports.change_import(import_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"import_data" => import_params}, socket) do
    with {:ok, import_data} <- Imports.create_import(import_params),
         {:ok, scraped_recipe} <- Scraper.scrape(import_data.url),
         {:ok, recipe} <- Recipes.Data.create_recipe(scraped_recipe),
         {:ok, _updated_import} <-
           Recipes.Imports.update_import(import_data, %{recipe_id: recipe.id}) do
      {:noreply, push_navigate(socket, to: ~p"/recipes/#{recipe.id}")}

    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}

      {:error, err} ->
        {:noreply, assign(socket, :error, IO.inspect(err))}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
