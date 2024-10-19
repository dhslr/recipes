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
    {:ok, session} = Wallaby.start_session(metadata: metadata)

    {:ok, session: session}
  end

  setup do
    password = :crypto.strong_rand_bytes(12) |> Base.url_encode64()
    user = Recipes.AccountsFixtures.user_fixture(%{password: password})
    {:ok, user: user, password: password}
  end
end
