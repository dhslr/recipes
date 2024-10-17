defmodule CoreComponentsTest do
  alias RecipesWeb.CoreComponents
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  describe "datalist" do
    test "renders given options" do
      html =
        render_component(&CoreComponents.datalist/1, id: "testid", options: ["Sugar", "Wheat"])

      parsed_html = Floki.parse_document!(html)

      assert parsed_html ==
               [
                 {"datalist", [{"id", "testid"}],
                  [{"option", [{"value", "Sugar"}], []}, {"option", [{"value", "Wheat"}], []}]}
               ]
    end
  end
end
