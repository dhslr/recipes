defmodule CoreComponentsTest do
  alias RecipesWeb.CoreComponents
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  describe "datalist" do
    test "renders given options" do
      html =
        render_component(&CoreComponents.datalist/1, id: "testid", options: ["Sugar", "Wheat"])

      parsed_html = LazyHTML.from_fragment(html) |> LazyHTML.to_tree()

      assert parsed_html ==
               [
                 {"datalist", [{"id", "testid"}],
                  [
                    "\n  ",
                    {"option", [{"value", "Sugar"}], []},
                    {"option", [{"value", "Wheat"}], []},
                    "\n"
                  ]}
               ]
    end
  end
end
