defmodule RecipesWeb.UserLoginFeatureTest do
  use RecipesWeb.FeatureCase, async: true

  @login_link Query.link("Log in")
  @logout_link Query.link("Log out")
  @flash Query.css("#flash")

  feature "a user trying to access recipes overview is redirected to login and redirected back after successful login",
          %{
            session: session,
            user: user,
            password: password
          } do
    assert session
           |> visit("/recipes")
           |> current_path() == "/users/log_in"

    assert session
           |> login(user.email, password)
           |> current_path() == "/recipes"
  end

  feature "a user can log out of their session",
          %{
            session: session,
            user: user,
            password: password
          } do
    assert session
           |> visit("/recipes")
           |> login(user.email, password)
           |> assert_has(@flash)
           |> click(@flash)
           |> assert_has(@logout_link)
           |> click(@logout_link)
           |> assert_has(@login_link)
           |> current_path() == "/"
  end
end
