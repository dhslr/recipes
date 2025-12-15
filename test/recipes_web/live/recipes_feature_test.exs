defmodule RecipesWeb.RecipesFeatureTest do
  use RecipesWeb.FeatureCase
  import Recipes.DataFixtures

  setup do
    %{
      cake: recipe_fixture(%{title: "Cake", tags: [%{name: "Sweet"}]}),
      buritos: recipe_fixture(%{title: "Burritos", tags: [%{name: "Spicy"}]})
    }
  end

  test "in browser, a user can see recipes in the overview", %{
    conn: conn,
    user: user,
    password: password
  } do
    conn
    |> login(user.email, password)
    |> visit("/recipes")
    |> assert_has("[data-test='recipe']", text: "Cake")
    |> assert_has("[data-test='tags']", text: "Sweet")
    |> assert_has("[data-test='recipe']", text: "Burritos")
    |> assert_has("[data-test='tags']", text: "Spicy")
  end

  @doc """
    This helper goes to the login page, fills in the email and password
    and clicks the login button.
  """
  def login(conn, username, password) do
    conn
    |> visit("/users/log_in")
    |> fill_in("Email", with: username)
    |> fill_in("Password", with: password)
    |> click_button("Log in")
  end

  test "a user can search for recipes in the overview", %{
    conn: conn,
    user: user,
    password: password
  } do
    conn
    |> login(user.email, password)
    |> visit("/recipes")
    |> assert_has("input[placeholder='Search']")
    |> type("input[placeholder='Search']", "Burritos", delay: 5)
    |> assert_has("[data-test='recipe']", text: "Burritos")
    |> assert_has("[data-test='tags']", text: "Spicy")
    |> refute_has("[data-test='recipe']", text: "Cake")
    |> refute_has("[data-test='tags']", text: "Sweet")
  end

  test "a user can click on recipe in the overview", %{
    conn: conn,
    user: user,
    password: password,
    buritos: buritos
  } do
    conn
    |> login(user.email, password)
    |> visit("/recipes")
    |> click("[data-test='recipe']", "Burritos")
    |> assert_path("/recipes/#{buritos.id}")
  end
end
