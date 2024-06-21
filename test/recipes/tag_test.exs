defmodule TagTest do
  use Recipes.DataCase

  alias Recipes.Data.Tag

  @valid_attrs %{name: "some name", icon: "some icon"}
  @invalid_attrs %{icon: "only icon"}

  test "changeset with valid attributes" do
    changeset = Tag.changeset(%Tag{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Tag.changeset(%Tag{}, @invalid_attrs)
    refute changeset.valid?
  end
end
