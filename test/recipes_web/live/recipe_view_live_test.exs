defmodule RecipesWeb.RecipeLiveTest do
  use RecipesWeb.ConnCase

  import Phoenix.LiveViewTest
  import Recipes.AccountsFixtures
  import Recipes.DataFixtures

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
                 [
                   {"class", "markdown-body markdown my-3 container mx-auto"},
                   {"data-test", "description"}
                 ],
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

    test "renders the recipes details containing kcal", %{
      conn: conn,
      user: user
    } do
      recipe = recipe_fixture(%{kcal: 1337})

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}")

      assert [
               {
                 "div",
                 [{"class", "text-gray-500"}, {"data-test", "kcal"}],
                 [{"span", [], ["1337 kcal per serving"]}]
               }
             ] = Floki.parse_document!(html) |> Floki.find(~s([data-test="kcal"]))
    end

    test "renders the recipes details without kcal", %{
      conn: conn,
      user: user
    } do
      recipe = recipe_fixture(%{kcal: nil})

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}")

      assert [] == Floki.parse_document!(html) |> Floki.find(~s([data-test="kcal"]))
    end

    test "renders the recipes details containing servings", %{
      conn: conn,
      user: user
    } do
      recipe = recipe_fixture(%{servings: 4})

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}")

      assert [
               {
                 "div",
                 _,
                 [
                   {
                     "button",
                     [
                       {"name", "decrease-servings"},
                       {"type", "button"},
                       {"phx-click", "change-servings"},
                       {"phx-value-servings", "3"}
                     ],
                     [{"span", [{"class", "hero-minus-circle w-8 h-8"}], []}]
                   },
                   {"span", [{"class", "w-8 text-center"}], ["4"]},
                   {
                     "button",
                     [
                       {"name", "increase-servings"},
                       {"type", "button"},
                       {"phx-click", "change-servings"},
                       {"phx-value-servings", "5"}
                     ],
                     [{"span", [{"class", "hero-plus-circle  w-8 h-8"}], []}]
                   }
                 ]
               }
             ] = Floki.parse_document!(html) |> Floki.find(~s([data-test="servings"]))
    end

    test "can increase recipe servings", %{
      conn: conn,
      user: user
    } do
      recipe = recipe_fixture(%{servings: 2})

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}")

      html =
        lv
        |> element(~s(button[name="increase-servings"]))
        |> render_click()

      assert [
               {
                 "div",
                 _,
                 [
                   {
                     "button",
                     [
                       {"name", "decrease-servings"},
                       {"type", "button"},
                       {"phx-click", "change-servings"},
                       {"phx-value-servings", "2"}
                     ],
                     [{"span", [{"class", "hero-minus-circle w-8 h-8"}], []}]
                   },
                   {"span", [{"class", "w-8 text-center"}], ["3"]},
                   {
                     "button",
                     [
                       {"name", "increase-servings"},
                       {"type", "button"},
                       {"phx-click", "change-servings"},
                       {"phx-value-servings", "4"}
                     ],
                     [{"span", [{"class", "hero-plus-circle  w-8 h-8"}], []}]
                   }
                 ]
               }
             ] = Floki.parse_document!(html) |> Floki.find(~s([data-test="servings"]))
    end

    test "can decrease recipe servings", %{
      conn: conn,
      user: user
    } do
      recipe = recipe_fixture(%{servings: 2})

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}")

      html =
        lv
        |> element(~s(button[name="decrease-servings"]))
        |> render_click()

      assert [
               {
                 "div",
                 _,
                 [
                   {
                     "button",
                     [
                       {"name", "decrease-servings"},
                       {"type", "button"},
                       {"phx-click", "change-servings"},
                       {"phx-value-servings", "1"}
                     ],
                     [{"span", [{"class", "hero-minus-circle w-8 h-8"}], []}]
                   },
                   {"span", [{"class", "w-8 text-center"}], ["1"]},
                   {
                     "button",
                     [
                       {"name", "increase-servings"},
                       {"type", "button"},
                       {"phx-click", "change-servings"},
                       {"phx-value-servings", "2"}
                     ],
                     [{"span", [{"class", "hero-plus-circle  w-8 h-8"}], []}]
                   }
                 ]
               }
             ] = Floki.parse_document!(html) |> Floki.find(~s([data-test="servings"]))
    end

    test "renders the recipes details containing servings with adjusted servings in URL", %{
      conn: conn,
      user: user
    } do
      recipe = recipe_fixture(%{servings: 4})

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}?servings=17")

      assert [
               {
                 "div",
                 _,
                 [
                   {
                     "button",
                     [
                       {"name", "decrease-servings"},
                       {"type", "button"},
                       {"phx-click", "change-servings"},
                       {"phx-value-servings", "16"}
                     ],
                     [{"span", [{"class", "hero-minus-circle w-8 h-8"}], []}]
                   },
                   {"span", [{"class", "w-8 text-center"}], ["17"]},
                   {
                     "button",
                     [
                       {"name", "increase-servings"},
                       {"type", "button"},
                       {"phx-click", "change-servings"},
                       {"phx-value-servings", "18"}
                     ],
                     [{"span", [{"class", "hero-plus-circle  w-8 h-8"}], []}]
                   }
                 ]
               }
             ] = Floki.parse_document!(html) |> Floki.find(~s([data-test="servings"]))
    end

    test "shows photos of recipe", %{
      conn: conn,
      user: user
    } do
      recipe = recipe_fixture(%{photos: [%{caption: "step 1"}, %{caption: "yummy"}]})
      [photo1, photo2] = recipe.photos

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}")

      assert [
               {"ul",
                [
                  {"class", "my-2 flex justify-evenly gap-y-2 flex-wrap"},
                  {"data-test", "photos"}
                ],
                [
                  {"li", [{"class", "min-w-[200px] max-h-[400px] max-w-[400px]"}],
                   [
                     {"img",
                      [
                        {"src", "/photos/recipe_#{recipe.id}_#{photo1.id}.jpg"},
                        {"class", "object-cover w-full h-full"}
                      ], []}
                   ]},
                  {"li", [{"class", "min-w-[200px] max-h-[400px] max-w-[400px]"}],
                   [
                     {"img",
                      [
                        {"src", "/photos/recipe_#{recipe.id}_#{photo2.id}.jpg"},
                        {"class", "object-cover w-full h-full"}
                      ], []}
                   ]}
                ]}
             ] == Floki.parse_document!(html) |> Floki.find(~s([data-test="photos"]))
    end

    test "shows tags of recipe", %{
      conn: conn,
      user: user
    } do
      recipe = recipe_fixture(%{tags: [%{name: "Healthy"}, %{name: "Quick"}]})
      [tag1, tag2] = recipe.tags

      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/recipes/#{recipe.id}")

      assert [
               {"div", [{"class", "text-center mt-4"}, {"data-test", "tags"}],
                [
                  {"ul", [{"class", "flex gap-1"}],
                   [
                     {"li", [{"class", ""}],
                      [
                        {"span", [{"class", "font-small bg-zinc-100 rounded-xl border p-1"}],
                         [tag1.name]}
                      ]},
                     {"li", [{"class", ""}],
                      [
                        {"span", [{"class", "font-small bg-zinc-100 rounded-xl border p-1"}],
                         [tag2.name]}
                      ]}
                   ]}
                ]}
             ] == Floki.parse_document!(html) |> Floki.find(~s([data-test="tags"]))
    end
  end
end
