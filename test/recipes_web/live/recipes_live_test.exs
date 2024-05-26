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

    test "renders the recipes overview containing a recipe", %{conn: conn, user: user} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes")

      assert html =~ "Currywurst"
    end

    test "renders the recipes overview containing two recipes", %{conn: conn, user: user} do
      recipe_fixture(%{title: "Kirschtorte"})

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes")

      assert html =~ "Currywurst"
      assert html =~ "Kirschtorte"
    end

    test "filters the recipes by typing into the input field", %{conn: conn, user: user} do
      recipe_fixture(%{title: "Kirschtorte"})

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes")

      html =
        lv
        |> element("form")
        |> render_change(%{query: "Kirsch"})

      assert html =~ "Kirschtorte"
      refute html =~ "Currywurst"
    end

    test "filtering recipes by query also works with sub strings", %{conn: conn, user: user} do
      recipe_fixture(%{title: "Kirschtorte"})

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes")

      html =
        lv
        |> element("form")
        |> render_change(%{query: "torte"})

      assert html =~ "Kirschtorte"
      refute html =~ "Currywurst"
    end

    test "click on new recipe button opens recipe edit view", %{conn: conn, user: user} do
      recipe_fixture(%{title: "Kirschtorte"})

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
               |> element("a", "Currywurst")
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
