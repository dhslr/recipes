defmodule RecipesWeb.RecipeLiveTest do
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

      assert {:error, redirect} = live(conn, ~p"/recipes/#{recipe.id}")

      assert {:redirect, %{to: "/users/log_in"}} = redirect
    end

    test "renders the recipes details containing title and ingredients", %{
      conn: conn,
      user: user
    } do
      recipe = recipe_fixture(%{title: "Cake"})

      ingredient_fixture(%{
        recipe_id: recipe.id,
        name: "Flour",
        quantity: 100,
        description: "g"
      })

      ingredient_fixture(%{
        recipe_id: recipe.id,
        name: "Sugar",
        quantity: 50,
        description: "g"
      })

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}")

      assert html =~ "Cake"

      assert [
               {"li", [{"class", "flex justify-between gap-10"}],
                [
                  {"span", [{"class", "font-medium text-left"}], ["Flour"]},
                  {"span", [{"class", "text-right"}],
                   [{"span", [], ["100.0"]}, {"span", [], ["g"]}]}
                ]},
               {"li", [{"class", "flex justify-between gap-10"}],
                [
                  {"span", [{"class", "font-medium text-left"}], ["Sugar"]},
                  {"span", [{"class", "text-right"}],
                   [{"span", [], ["50.0"]}, {"span", [], ["g"]}]}
                ]}
             ] = Floki.parse_document!(html) |> Floki.find(~s([data-test="ingredients"] ul li))
    end

    test "renders the recipes details containing description as markdown", %{
      conn: conn,
      user: user
    } do
      recipe =
        recipe_fixture(%{
          title: "Cake",
          description: """
          **Yummy Cake Recipe**

          First put Flour. Then sugar.

          After that:
          1. Stir
          2. Bake
          3. Done

          """
        })

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}")

      assert [
               {
                 "div",
                 [{"class", "my-3 container mx-auto"}, {"data-test", "description"}],
                 [
                   {"p", [], [{"strong", [], ["Yummy Cake Recipe"]}]},
                   {"p", [], ["First put Flour. Then sugar."]},
                   {"p", [], ["After that:"]},
                   {"ol", [],
                    [
                      {"li", [], ["Stir"]},
                      {"li", [], ["Bake"]},
                      {"li", [], ["Done"]}
                    ]}
                 ]
               }
             ] = Floki.parse_document!(html) |> Floki.find(~s([data-test="description"]))
    end
  end
end
