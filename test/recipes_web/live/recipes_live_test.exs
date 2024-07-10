defmodule RecipesWeb.RecipesLiveTest do
  use RecipesWeb.ConnCase

  import Phoenix.LiveViewTest
  import Recipes.AccountsFixtures
  import Recipes.DataFixtures

  setup do
    %{user: user_fixture(), recipe: recipe_fixture(%{title: "Currywurst"})}
  end

  describe "The recipes overview" do
    test "Redirects to login if user is not logged in ", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/recipes")

      assert {:redirect, %{to: "/users/log_in"}} = redirect
    end

    test "renders the recipes overview containing a single recipe", %{
      conn: conn,
      user: user,
      recipe: currywurst
    } do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes")

      assert Floki.parse_document!(html)
             |> Floki.find(~s([data-test="recipe"] label))
             |> Floki.text() =~
               currywurst.title
    end

    test "renders the recipes overview containing two recipes", %{
      conn: conn,
      user: user,
      recipe: currywurst
    } do
      kirschtorte = recipe_fixture(%{title: "Kirschtorte", tags: [%{name: "Dessert"}]})

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes")

      titles =
        Floki.parse_document!(html)
        |> Floki.find(~s([data-test="recipe"] label))
        |> Floki.text()

      tags =
        Floki.parse_document!(html)
        |> Floki.find(~s([data-test="tags"]))
        |> Floki.text()

      assert titles =~ currywurst.title
      assert titles =~ kirschtorte.title
      assert tags =~ "Dessert"
    end

    test "renders the recipes overview with tags of recipe", %{
      conn: conn,
      user: user
    } do
      %{tags: [vegetarian, dessert]} =
        recipe_fixture(%{title: "Kirschtorte", tags: [%{name: "Vegetarian"}, %{name: "Dessert"}]})

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes")

      tags =
        Floki.parse_document!(html)
        |> Floki.find(~s([data-test="tags"]))
        |> Floki.text()

      assert tags =~ vegetarian.name
      assert tags =~ dessert.name
    end

    test "renders the recipes tag cloud without duplicated tags", %{
      conn: conn,
      user: user
    } do
      %{tags: [vegetarian, dessert]} =
        recipe_fixture(%{title: "Kirschtorte", tags: [%{name: "Vegetarian"}, %{name: "Dessert"}]})

      recipe_fixture(%{title: "Sahneschnitte", tags: [%{name: "Dessert"}]})

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes")

      tag_cloud =
        Floki.parse_document!(html)
        |> Floki.find(~s([data-test="tag-cloud"] a))
        |> Floki.text()

      assert tag_cloud == vegetarian.name <> dessert.name
    end

    test "click on tag in the recipes tag cloud sets the search query", %{
      conn: conn,
      user: user
    } do
      recipe_fixture(%{title: "Kirschtorte", tags: [%{name: "Vegetarian"}, %{name: "Dessert"}]})
      recipe_fixture(%{title: "Chili", tags: [%{name: "Ragout"}, %{name: "Spicy"}]})

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes")

      html =
        lv
        |> element(~s([data-test="tag-cloud"] a), "Vegetarian")
        |> render_click()

      assert Floki.parse_document!(html)
             |> Floki.find(~s([data-test="search-bar"] input))
             |> Floki.attribute("value") == ["Vegetarian"]
    end

    test "filters the recipes by typing into the input field", %{
      conn: conn,
      user: user,
      recipe: currywurst
    } do
      kirschtorte = recipe_fixture(%{title: "Kirschtorte", tags: [%{name: "Dessert"}]})

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes")

      html =
        lv
        |> element("form")
        |> render_change(%{query: "Kirsch"})

      titles =
        Floki.parse_document!(html)
        |> Floki.find(~s([data-test="recipe"] label))
        |> Floki.text()

      assert titles =~ kirschtorte.title
      refute titles =~ currywurst.title

      html =
        lv
        |> element("form")
        |> render_change(%{query: "Dessert"})

      titles =
        Floki.parse_document!(html)
        |> Floki.find(~s([data-test="recipe"] label))
        |> Floki.text()

      assert titles =~ kirschtorte.title
      refute titles =~ currywurst.title
    end

    test "filtering recipes by query also works with sub strings", %{
      conn: conn,
      user: user,
      recipe: currywurst
    } do
      kirschtorte = recipe_fixture(%{title: "Kirschtorte"})

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes")

      html =
        lv
        |> element("form")
        |> render_change(%{query: "torte"})

      assert html =~ kirschtorte.title
      refute html =~ currywurst.title
    end

    test "click on clear icon clears the search query value", %{
      conn: conn,
      user: user
    } do
      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes")

      html =
        lv
        |> element("form")
        |> render_change(%{query: "old query"})

      assert Floki.parse_document!(html)
             |> Floki.find(~s([data-test="search-bar"] input))
             |> Floki.attribute("value") == ["old query"]

      html =
        lv
        |> element(~s([data-test="clear-search-button"]))
        |> render_click()

      assert Floki.parse_document!(html)
             |> Floki.find(~s([data-test="search-bar"] input))
             |> Floki.attribute("value") == [""]
    end

    test "click on new recipe button opens recipe edit view", %{conn: conn, user: user} do
      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes")

      lv
      |> element("a", "New")
      |> render_click()

      assert_redirect(lv, "/recipes/new")
    end

    test "click on the recipe in the overview redirects to recipes detail", %{
      conn: conn,
      user: user,
      recipe: recipe
    } do
      logged_in_con = log_in_user(conn, user)

      {:ok, lv, _html} =
        logged_in_con
        |> live(~p"/recipes")

      assert {:ok, _lv, _html} =
               lv
               |> element("a", recipe.title)
               |> render_click()
               |> follow_redirect(logged_in_con, "/recipes/#{recipe.id}")
    end

    test "click on import recipe button opens import recipe view", %{conn: conn, user: user} do
      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes")

      lv
      |> element("a", "Import")
      |> render_click()

      assert_redirect(lv, "/imports/new")
    end
  end
end
