defmodule RecipesWeb.RecipeEditLiveTest do
  use RecipesWeb.ConnCase

  import Phoenix.LiveViewTest
  import Recipes.AccountsFixtures
  import Recipes.RecipesFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "The recipes detail view" do
    test "Redirects to login if user is not logged in ", %{conn: conn} do
      recipe = recipe_fixture()

      assert {:error, redirect} = live(conn, ~p"/recipes/#{recipe.id}/edit")

      assert {:redirect, %{to: "/users/log_in"}} = redirect
    end

    test "renders the recipes edit view", %{
      conn: conn,
      user: user
    } do
      recipe = recipe_fixture(%{title: "Cake"})

      flour = food_fixture(%{name: "Flour"})
      sugar = food_fixture(%{name: "Sugar"})

      ingredient_fixture(%{
        recipe_id: recipe.id,
        food_id: flour.id,
        quantity: 100,
        description: "g"
      })

      ingredient_fixture(%{
        recipe_id: recipe.id,
        food_id: sugar.id,
        quantity: 50,
        description: "g"
      })

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}/edit")

      assert html =~ "Cake"
    end

  end
end
