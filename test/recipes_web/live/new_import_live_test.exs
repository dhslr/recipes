defmodule RecipesWeb.NewImportLiveTest do
  use RecipesWeb.ConnCase

  import Phoenix.LiveViewTest
  import Recipes.AccountsFixtures

  @url "https://example.org/recipe/1234"
  @create_attrs %{url: @url}
  @invalid_attrs %{url: nil}

  setup do
    %{user: user_fixture()}
  end

  describe "Show" do
    test "redirects to login if user is not logged in ", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/imports/new")

      assert {:redirect, %{to: "/users/log_in"}} = redirect
    end

    test "url must be set before importing", %{conn: conn, user: user} do
      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/imports/new")

      assert lv
             |> form("#import-form", import_data: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"
    end

    test "show error message when importing fails", %{conn: conn, user: user} do
      Mox.expect(Recipes.Scraper.Mock, :scrape, fn @url ->
        {:error, "A helpful error message"}
      end)

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/imports/new")

      assert lv
             |> form("#import-form", import_data: @create_attrs)
             |> render_submit()
             |> Floki.parse_document!()
             |> Floki.find("p.alert") ==
               [
                 {"p", [{"class", "alert alert-danger"}],
                  [
                    "\nError when importing the recipe: \n    ",
                    {"emph", [], ["\nA helpful error message\n    "]}
                  ]}
               ]
    end

    test "successfully imports recipe", %{conn: conn, user: user} do
      Mox.expect(Recipes.Scraper.Mock, :scrape, fn @url ->
        {:ok,
         %{
           title: "Sample recipe",
           description: "Do this and that",
           kcal: 123,
           servings: 3,
           ingredients: [
             %{name: "ingredient 1", quantity: 1.0, description: "a description 1"},
             %{name: "ingredient 2", quantity: 2.5, description: "a description 2"}
           ]
         }}
      end)

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/imports/new")

      assert lv
             |> form("#import-form", import_data: @create_attrs)
             |> render_submit()

      {path, _flash} = assert_redirect(lv)
      assert path =~ ~r/\/recipes\/\d+/
    end
  end
end
