defmodule RecipesWeb.RecipeLiveTest do
  use RecipesWeb.ConnCase

  import Phoenix.LiveViewTest
  import Recipes.AccountsFixtures
  import Recipes.RecipesFixtures

  setup do
    %{
      user: user_fixture(),
      recipe: recipe_fixture(%{title: "Cake", description: "Yummy cake recipe"})
    }
  end

  describe "The recipes detail view" do
    test "Redirects to login if user is not logged in ", %{conn: conn, recipe: recipe} do
      assert {:error, redirect} = live(conn, ~p"/recipes/#{recipe.id}")

      assert {:redirect, %{to: "/users/log_in"}} = redirect
    end

    test "renders the recipes details containing description and ingredients", %{
      conn: conn,
      user: user,
      recipe: recipe
    } do
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
        |> live(~p"/recipes/#{recipe.id}")

      assert html =~ "Cake"
      assert html =~ "Yummy cake recipe"
      assert html =~ "Flour"
      assert html =~ "Sugar"
    end
  end
end
