defmodule RecipesWeb.FeatureCase do
  @moduledoc """
  This module defines the test case to be used by
  feature (e2e) tests than are run in a browser.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import RecipesWeb.FeatureCase
      import Wallaby.Feature
      use Wallaby.DSL
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Recipes.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Recipes.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Recipes.Repo, self())
    {:ok, session} = Wallaby.start_session(
      metadata: metadata,
      browser: Wallaby.Chrome,
      window_size: [width: 1400, height: 1400]
    )

    {:ok, session: session}
  end

  setup do
    password = :crypto.strong_rand_bytes(12) |> Base.url_encode64()
    user = Recipes.AccountsFixtures.user_fixture(%{password: password})
    {:ok, user: user, password: password}
  end

  @doc """
    This helper goes to the login page, fills in the email and password
    and clicks the login button.
  """
  @spec login(Wallaby.Session.t(), String.t(), String.t()) :: Wallaby.Session.t()
  def login(session, user_email, password) do
    session
    |> Wallaby.Browser.visit("/users/log_in")
    |> Wallaby.Browser.fill_in(Wallaby.Query.text_field("user_email"), with: user_email)
    |> Wallaby.Browser.fill_in(Wallaby.Query.text_field("user_password"), with: password)
    |> Wallaby.Browser.click(Wallaby.Query.button("Log in"))
  end
end
