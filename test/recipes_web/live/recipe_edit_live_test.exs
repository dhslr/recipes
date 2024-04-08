defmodule RecipesWeb.RecipeEditLiveTest do
  use RecipesWeb.ConnCase
  alias Recipes.Data

  import Phoenix.LiveViewTest
  import Recipes.AccountsFixtures
  import Recipes.RecipesFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "The recipes detail view" do
    test "redirects to login if user is not logged in ", %{conn: conn} do
      recipe = recipe_fixture()

      assert {:error, redirect} = live(conn, ~p"/recipes/#{recipe.id}/edit")

      assert {:redirect, %{to: "/users/log_in"}} = redirect
    end

    test "renders the recipes edit view", %{
      conn: conn,
      user: user
    } do
      recipe =
        recipe_fixture(%{
          title: "Cake",
          ingredients: [
            %{
              food: %{name: "Flour"},
              quantity: 100,
              description: "g"
            },
            %{
              food: %{name: "Sugar"},
              quantity: 50,
              description: "g"
            }
          ]
        })

      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}/edit")

      assert has_element?(lv, ~s([data-test="ingredients"]))
      assert html =~ "Cake"
    end

    test "updates the recipe and redirects back", %{
      conn: conn,
      user: user
    } do
      recipe = recipe_fixture(%{title: "Cake", description: "My description"})

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}/edit")

      lv
      |> form("#recipe_form", recipe: %{title: "New Title", description: "New description"})
      |> render_submit()

      assert %Recipes.Data.Recipe{
               title: "New Title",
               description: "New description"
             } = Data.get_recipe!(recipe.id)

      assert_redirect(lv, "/recipes/#{recipe.id}")
    end

    test "update ingredients and redirects back", %{
      conn: conn,
      user: user
    } do
      recipe =
        recipe_fixture(%{
          ingredients: [
            %{
              food: %{name: "Flour"},
              quantity: 100,
              description: "g"
            },
            %{
              food: %{name: "Sugar"},
              quantity: 50,
              description: "g"
            }
          ]
        })

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}/edit")

      lv
      |> form("#recipe_form",
        recipe: %{
          title: "Currywurst",
          description: "Lecker",
          ingredients: %{
            "0" => %{
              description: "Viel",
              food: %{name: "Ketchup"},
              quantity: 0
            },
            "1" => %{
              description: "g",
              food: %{name: "Pommes"},
              quantity: 200
            }
          }
        }
      )
      |> render_submit()

      assert %Recipes.Data.Recipe{
               title: "Currywurst",
               description: "Lecker",
               ingredients: [ketchup, pommes]
             } = Data.get_recipe!(recipe.id)

      assert %Recipes.Data.Ingredient{
               food: %{name: "Ketchup"},
               description: "Viel"
             } = ketchup

      assert %Recipes.Data.Ingredient{
               food: %{name: "Pommes"},
               quantity: 200.0,
               description: "g"
             } = pommes

      assert_redirect(lv, "/recipes/#{recipe.id}")
    end
  end
end
