defmodule Recipes.Scraper.Chefkoch.Integration.Test do
  use ExUnit.Case
  alias Recipes.Scraper.Chefkoch

  @url "https://www.chefkoch.de/rezepte/295211108896980/Spargel-mit-Parmesan-Kruste.html"

  test "converts html file data into recipe" do
    Mox.expect(Recipes.HttpClient.Mock, :get, fn @url ->
      {:ok,
       %{status_code: 200, body: File.read!("/tmp/recipe.html")}}
    end)

    assert {:ok, %{} = scraped_recipe} = Chefkoch.scrape(@url)

    assert scraped_recipe.title == "Spargel mit Parmesan-Kruste"
    assert scraped_recipe.servings == 4
    assert scraped_recipe.kcal == 1288

    assert scraped_recipe.description ==
             "Weißen Spargel schälen, die Enden ca. 1 - 2 cm breit abschneiden. Grünen Spargel nur im unteren Drittel schälen. Knoblauch abziehen."

    assert scraped_recipe.image_url == "https://img.chefkoch-cdn.de/rezepte/295211108896980/bilder/1505562/crop-960x540/spargel-mit-parmesan-kruste.jpg"

    assert scraped_recipe.ingredients == [
             %{
               name: "Spargel, weißer (auch grüner oder gemischt möglich)",
               quantity: 2.0,
               description: "kg",
               position: 1
             },
             %{
               name: "Knoblauchzehe(n)",
               quantity: 2.0,
               position: 2
             },
             %{
               name: "Salz und Pfeffer",
               position: 3
             },
             %{
               name: "Tomate(n)",
               quantity: 3.0,
               position: 4
             },
             %{description: "g", name: "Parmesan, geriebener", position: 5, quantity: 75.0},
             %{description: "EL", name: "Kräuter, gemischte (Thymian, Basilikum, Petersilie)", position: 6, quantity: 4.0},
             %{description: "EL", name: "Semmelbrösel", position: 7, quantity: 3.0},
             %{description: "g", name: "Butterflöckchen", position: 8, quantity: 50.0},
             %{name: "Butter für die Form", position: 9}
           ]
  end
end
