defmodule RecipesWeb.RecipeEditUiTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature

  @user_email "user@dhslr.de"
  @user_password "VeryVeryS3cret!"

  setup do
    Recipes.Accounts.register_user(%{email: @user_email, password: @user_password})
    :ok
  end

  feature "a registered user can login and is redirected to recipes overview", %{session: session} do
    session
    |> visit("/recipes")
    |> fill_in(Query.text_field("user_email"), with: @user_email)
    |> fill_in(Query.text_field("user_password"), with: @user_password)
    |> click(Query.button("Log in"))
    |> assert_has(Query.text_field("Search"))
  end
end
