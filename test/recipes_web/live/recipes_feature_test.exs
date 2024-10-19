defmodule RecipesWeb.RecipesFeatureTest do
  use RecipesWeb.FeatureCase, async: true
  import Recipes.DataFixtures

  setup do
    %{
      cake: recipe_fixture(%{title: "Cake", tags: [%{name: "Sweet"}]}),
      buritos: recipe_fixture(%{title: "Buritos", tags: [%{name: "Spicy"}]})
    }
  end

  feature "a user can recipes in the overview", %{
    session: session,
    user: user,
    password: password
  } do
    session
    |> visit("/recipes")
    |> fill_in(Query.text_field("user_email"), with: user.email)
    |> fill_in(Query.text_field("user_password"), with: password)
    |> click(Query.button("Log in"))
    |> assert_has(Query.css("[data-test='recipe']", text: "Cake"))
    |> assert_has(Query.css("[data-test='tags']", text: "Sweet"))
    |> assert_has(Query.css("[data-test='recipe']", text: "Buritos"))
    |> assert_has(Query.css("[data-test='tags']", text: "Spicy"))
  end
end
