defmodule RecipesWeb.RecipeEditLiveTest do
  use RecipesWeb.ConnCase

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
      recipe = recipe_fixture(%{title: "Cake"})

      ingredient_fixture(%{
        recipe_id: recipe.id,
        food: %{name: "Flour"},
        quantity: 100,
        description: "g"
      })

      ingredient_fixture(%{
        recipe_id: recipe.id,
        food: %{name: "Sugar"},
        quantity: 50,
        description: "g"
      })

      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}/edit")

      assert has_element?(lv, ~s([data-test="ingredients"]))
      assert html =~ "Cake"
    end

    test "updates the recipe", %{
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
             } = Recipes.get_recipe!(recipe.id)
    end

    test "update ingredients", %{
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
      |> form("#recipe_form", ingredients: %{})
      |> render_submit()

      ## assert
      a = [
        %Recipes.Data.Ingredient{
          recipe_id: recipe.id,
          food: %{name: "Flour"},
          quantity: 200,
          description: "g"
        },
        %Recipes.Data.Ingredient{
          recipe_id: recipe.id,
          food: %{name: "Sugar"},
          quantity: 200,
          description: "g"
        }
      ]

      # == Recipes.get_recipe!(recipe.id).ingredients
    end
  end
end
