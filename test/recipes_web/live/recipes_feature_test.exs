defmodule RecipesWeb.RecipesFeatureTest do
  use RecipesWeb.FeatureCase, async: true
  import Recipes.DataFixtures

  setup do
    %{
      cake: recipe_fixture(%{title: "Cake", tags: [%{name: "Sweet"}]}),
      buritos: recipe_fixture(%{title: "Buritos", tags: [%{name: "Spicy"}]})
    }
  end

  feature "a user can see recipes in the overview", %{
    session: session,
    user: user,
    password: password
  } do
    session
    |> login(user.email, password)
    |> visit("/recipes")
    |> assert_has(Query.css("[data-test='recipe']", text: "Cake"))
    |> assert_has(Query.css("[data-test='tags']", text: "Sweet"))
    |> assert_has(Query.css("[data-test='recipe']", text: "Buritos"))
    |> assert_has(Query.css("[data-test='tags']", text: "Spicy"))
  end

  feature "a user can search for recipes in the overview", %{
    session: session,
    user: user,
    password: password
  } do
    session
    |> login(user.email, password)
    |> visit("/recipes")
    |> assert_has(Query.fillable_field("Search"))
    |> fill_in(Query.fillable_field("Search"), with: "Buritos")
    |> assert_has(Query.css("[data-test='recipe']", text: "Buritos"))
    |> assert_has(Query.css("[data-test='tags']", text: "Spicy"))
    |> refute_has(Query.css("[data-test='recipe']", text: "Cake"))
    |> refute_has(Query.css("[data-test='tags']", text: "Sweet"))
  end

  feature "a user can click on recipe in the overview", %{
    session: session,
    user: user,
    password: password,
    buritos: buritos
  } do
    assert session
           |> login(user.email, password)
           |> visit("/recipes")
           |> click(Query.css("[data-test='recipe']", text: "Buritos"))
           |> assert_has(Query.css("[data-test='ingredients']"))
           |> current_path() =~ "/recipes/#{buritos.id}"
  end
end
