defmodule RecipesWeb.UserLoginFeatureTest do
  use RecipesWeb.FeatureCase

  test "a user trying to access recipes overview is redirected to login and redirected back after successful login",
       %{
         conn: conn,
         user: user,
         password: password
       } do
    assert conn
           |> visit("/recipes")
           |> assert_path("/users/log_in")

    assert conn
           |> login(user.email, password)
           |> assert_path("/recipes")
  end

  test "a user can log out of their session",
       %{
         conn: conn,
         user: user,
         password: password
       } do
    assert conn
           |> visit("/recipes")
           |> login(user.email, password)
           |> assert_has("#flash")
           |> click("#flash")
           |> click_link("Log out")
           |> assert_has("a", text: "Log in")
           |> assert_path("/")
  end

  defp login(conn, username, password) do
    conn
    |> visit("/users/log_in")
    |> fill_in("Email", with: username)
    |> fill_in("Password", with: password)
    |> click_button("Log in")
  end
end
