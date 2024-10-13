defmodule RecipesWeb.RecipeEditUiTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature
  import Recipes.AccountsFixtures

  @password "VeryVeryS3cret!"

  setup do
    %{user: user_fixture(%{password: @password})}
  end

  feature "a registered user can login and is redirected to recipes overview", %{
    session: session,
    user: user
  } do
    session
    |> visit("/recipes")
    |> fill_in(Query.text_field("user_email"), with: user.email)
    |> fill_in(Query.text_field("user_password"), with: @password)
    |> click(Query.button("Log in"))
    |> assert_has(Query.text_field("Search"))
  end
end
