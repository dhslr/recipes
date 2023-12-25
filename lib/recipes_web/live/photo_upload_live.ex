defmodule RecipesWeb.PhotoUploadLive do
  use RecipesWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:photo, accept: ~w(.jpg .jpeg .heic), max_entries: 3)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :photo, fn %{path: path}, _entry ->
        dest = Path.join([System.tmp_dir!(), Path.basename(path)])
        File.cp!(path, dest)
        {:ok, dest}
      end)
    {:noreply, update(socket, :uploaded_files, &(&1 ++ uploaded_files))}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
