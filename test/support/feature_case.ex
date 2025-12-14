defmodule RecipesWeb.FeatureCase do
  @moduledoc """
  This module defines the test case to be used by
  feature (e2e) tests than are run in a browser.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import RecipesWeb.FeatureCase

      use PhoenixTest.Playwright.Case, async: true, headless: false, slow_mo: :timer.seconds(1)
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Recipes.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  setup do
    password = :crypto.strong_rand_bytes(12) |> Base.url_encode64()
    user = Recipes.AccountsFixtures.user_fixture(%{password: password})
    {:ok, user: user, password: password}
  end
end
