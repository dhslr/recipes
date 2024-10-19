defmodule RecipesWeb.UserLoginFeatureTest do
  use RecipesWeb.FeatureCase, async: true

  feature "a registered user can login and is redirected to recipes overview", %{
    session: session,
    user: user,
    password: password
  } do
    session
    |> visit("/recipes")
    |> fill_in(Query.text_field("user_email"), with: user.email)
    |> fill_in(Query.text_field("user_password"), with: password)
    |> click(Query.button("Log in"))
    |> assert_has(Query.text_field("Search"))
  end
end
