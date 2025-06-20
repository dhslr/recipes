defmodule RecipesWeb.RecipeEditLiveTest do
  use RecipesWeb.ConnCase
  alias Recipes.Data

  import Phoenix.LiveViewTest
  import Recipes.AccountsFixtures
  import Recipes.DataFixtures

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
              name: "Flour",
              quantity: 100,
              description: "g"
            },
            %{
              name: "Sugar",
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

    test "renders the recipe edit view for new recipe", %{
      conn: conn,
      user: user
    } do
      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/new")

      assert has_element?(lv, "button", "Save")
      assert has_element?(lv, "label", "Ingredients")

      assert [
               {"div",
                [
                  {"id", "ingredients"},
                  {"data-test", "ingredients"},
                  {"class", "ml-3"},
                  {"phx-hook", "Sortable"}
                ],
                [
                  {"label", [{"class", "float-right cursor-pointer my-2"}],
                   [
                     {"input",
                      [
                        {"type", "checkbox"},
                        {"name", "recipe[ingredients_order][]"},
                        {"class", "hidden"}
                      ], []},
                     {"span", [{"class", "hero-plus-circle"}], []},
                     " add\n    "
                   ]}
                ]}
             ] = Floki.parse_document!(html) |> Floki.find(~s([data-test="ingredients"]))
    end

    test "renders the recipe edit view for new recipe, can edit and save", %{
      conn: conn,
      user: user
    } do
      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/new")

      assert has_element?(lv, "button", "Save")
      assert has_element?(lv, "label", "Ingredients")

      lv
      |> form("#recipe_form",
        recipe: %{title: "A Title", description: "A description", servings: 4, kcal: 1234}
      )
      |> render_submit()

      {path, _flash} = assert_redirect(lv)
      assert path =~ ~r(/recipes/\d+)
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
      |> form("#recipe_form",
        recipe: %{title: "New Title", description: "New description", servings: 4, kcal: 1234}
      )
      |> render_submit()

      assert_redirect(lv, "/recipes/#{recipe.id}")

      assert %Recipes.Data.Recipe{
               title: "New Title",
               description: "New description",
               servings: 4,
               kcal: 1234
             } = Data.get_recipe!(recipe.id)
    end

    test "update ingredients and redirects back", %{
      conn: conn,
      user: user
    } do
      recipe =
        recipe_fixture(%{
          ingredients: [
            %{
              name: "Flour",
              quantity: 100,
              description: "g"
            },
            %{
              name: "Sugar",
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
              name: "Ketchup",
              quantity: 0
            },
            "1" => %{
              description: "g",
              name: "Pommes",
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
               name: "Ketchup",
               description: "Viel"
             } = ketchup

      assert %Recipes.Data.Ingredient{
               name: "Pommes",
               quantity: 200.0,
               description: "g"
             } = pommes

      assert_redirect(lv, "/recipes/#{recipe.id}")
    end

    test "removes ingredient and save recipe", %{
      conn: conn,
      user: user
    } do
      recipe =
        recipe_fixture(%{
          ingredients: [
            %{
              name: "Flour",
              quantity: 100,
              description: "g"
            },
            %{
              name: "Sugar",
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
      |> form("#recipe_form", recipe: %{"ingredients_drop" => ["0"]})
      |> render_submit()

      assert %Recipes.Data.Recipe{
               ingredients: [sugar]
             } = Data.get_recipe!(recipe.id)

      assert %Recipes.Data.Ingredient{
               name: "Sugar",
               quantity: 50.0,
               description: "g"
             } = sugar

      assert_redirect(lv, "/recipes/#{recipe.id}")
    end

    test "removes all ingredients and save recipe", %{
      conn: conn,
      user: user
    } do
      recipe =
        recipe_fixture(%{
          ingredients: [
            %{
              name: "Flour",
              quantity: 200,
              description: "g"
            },
            %{
              name: "Sugar",
              quantity: 100,
              description: "g"
            }
          ]
        })

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}/edit")

      lv
      |> form("#recipe_form", recipe: %{"ingredients_drop" => ["0", "1"]})
      |> render_submit()

      assert %Recipes.Data.Recipe{
               ingredients: []
             } = Data.get_recipe!(recipe.id)

      assert_redirect(lv, "/recipes/#{recipe.id}")
    end

    test "can change tags in recipe", %{
      conn: conn,
      user: user
    } do
      recipe = recipe_fixture(%{tags: [%{name: "Vegan"}, %{name: "Vegetarian"}]})

      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}/edit")

      assert(
        [
          "Vegan",
          "Vegetarian"
        ] =
          Floki.parse_document!(html)
          |> Floki.find(~s([data-test="tags"] input[type="text"]))
          |> Floki.attribute("value")
      )

      lv
      |> form("#recipe_form",
        recipe: %{
          tags: %{
            "0" => %{
              name: "Meat"
            },
            "1" => %{
              name: "Pork"
            }
          }
        }
      )
      |> render_submit()

      assert_redirect(lv, "/recipes/#{recipe.id}")

      assert %Recipes.Data.Recipe{
               tags: [tag1, tag2]
             } = Data.get_recipe!(recipe.id)

      assert %Recipes.Data.Tag{name: "Meat"} = tag1
      assert %Recipes.Data.Tag{name: "Pork"} = tag2
    end

    test "removes all tags and save recipe", %{
      conn: conn,
      user: user
    } do
      recipe =
        recipe_fixture(%{
          tags: [
            %{
              name: "Yummy"
            },
            %{
              name: "Unhealthy"
            }
          ]
        })

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}/edit")

      lv
      |> form("#recipe_form", recipe: %{"tags_drop" => ["0", "1"]})
      |> render_submit()

      assert %Recipes.Data.Recipe{
               tags: []
             } = Data.get_recipe!(recipe.id)

      assert_redirect(lv, "/recipes/#{recipe.id}")
    end
  end
end
