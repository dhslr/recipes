defmodule RecipesWeb.TagLiveTest do
  use RecipesWeb.ConnCase

  import Phoenix.LiveViewTest
  import Recipes.DataFixtures
  import Recipes.AccountsFixtures

  @create_attrs %{icon: "some icon", name: "some name"}
  @update_attrs %{icon: "some updated icon", name: "some updated name"}
  @invalid_attrs %{icon: nil, name: nil}

  setup do
    %{user: user_fixture(), tag: tag_fixture()}
  end

  describe "Index" do
    test "redirects to login if user is not logged in ", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/tags")

      assert {:redirect, %{to: "/users/log_in"}} = redirect
    end

    test "lists all tags", %{conn: conn, tag: tag, user: user} do
      {:ok, _index_live, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/tags")

      assert html =~ "Listing Tags"
      assert html =~ tag.icon
    end

    test "saves new tag", %{conn: conn, user: user} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/tags")

      assert index_live |> element("a", "New Tag") |> render_click() =~
               "New Tag"

      assert_patch(index_live, ~p"/tags/new")

      assert index_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#tag-form", tag: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tags")

      html = render(index_live)
      assert html =~ "Tag created successfully"
      assert html =~ "some icon"
    end

    test "updates tag in listing", %{conn: conn, tag: tag, user: user} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/tags")

      assert index_live |> element("#tags-#{tag.id} a", "Edit") |> render_click() =~
               "Edit Tag"

      assert_patch(index_live, ~p"/tags/#{tag}/edit")

      assert index_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#tag-form", tag: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tags")

      html = render(index_live)
      assert html =~ "Tag updated successfully"
      assert html =~ "some updated icon"
    end

    test "deletes tag in listing", %{conn: conn, tag: tag, user: user} do
      {:ok, index_live, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/tags")

      assert index_live |> element("#tags-#{tag.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tags-#{tag.id}")
    end
  end

  describe "Show" do
    test "displays tag", %{conn: conn, tag: tag, user: user} do
      {:ok, _show_live, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/tags/#{tag}")

      assert html =~ "Show Tag"
      assert html =~ tag.icon
    end

    test "updates tag within modal", %{conn: conn, tag: tag, user: user} do
      {:ok, show_live, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/tags/#{tag}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Tag"

      assert_patch(show_live, ~p"/tags/#{tag}/show/edit")

      assert show_live
             |> form("#tag-form", tag: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#tag-form", tag: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/tags/#{tag}")

      html = render(show_live)
      assert html =~ "Tag updated successfully"
      assert html =~ "some updated icon"
    end
  end
end
