ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Recipes.Repo, :manual)
Application.put_env(:phoenix_test, :base_url, RecipesWeb.Endpoint.url())
