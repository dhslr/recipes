defmodule Recipes.Scraper.Chefkoch.Test do
  use ExUnit.Case
  alias Recipes.Scraper.Chefkoch

  @url "http://chefkoch.de/rezepte/1234"

  test "converts html file data into recipe" do
    Mox.expect(Recipes.HttpClient.Mock, :get, fn @url ->
      {:ok,
       %{status_code: 200, body: File.read!("test/support/fixtures/scraper/chefkoch/recipe.html")}}
    end)

    assert {:ok, %{} = scraped_recipe} = Chefkoch.scrape(@url)

    assert scraped_recipe.title == "Die echte Sauce Bolognese"
    assert scraped_recipe.servings == 6
    assert scraped_recipe.kcal == 6000

    assert scraped_recipe.description ==
             "Das Wichtigste an einer  Bolognese ist das sogenannte..."

    assert scraped_recipe.image_url == "https://img.chefkoch-cdn.de/bolognese.jpg"

    assert scraped_recipe.ingredients == [
             %{
               name: "Rinderhackfleisch",
               quantity: 1.0,
               description: "kg",
               position: 1
             },
             %{
               name: "Knoblauchzehe(n)",
               quantity: 3.0,
               description: "in Scheiben geschnitten",
               position: 2
             },
             %{
               name: "Möhre(n)",
               quantity: 3.0,
               position: 3
             },
             %{
               name: "Gemüsebrühe",
               quantity: 1250,
               description: "ml",
               position: 4
             },
             %{
               name: "Wasser",
               position: 5
             },
             %{
               name: "Tomatenmark",
               description: "n. B.",
               position: 6
             },
             %{
               name: "Käse",
               description: "n. B. gerieben",
               position: 7
             },
             %{
               name: "Milch",
               description: "Liter",
               quantity: 0.5,
               position: 8
             },
             %{
               name: "Staudensellerie",
               quantity: 3.0,
               description: "Stange/n",
               position: 9
             },
             %{
               name: "Tomate(n)",
               quantity: 1.5,
               description: "Dose/n geschälte, à 400 g",
               position: 10
             },
             %{
               name: "Peperoncini",
               quantity: 3.0,
               description: "zerstampfte",
               position: 11
             },
             %{
               name: "Meersalz und Pfeffer",
               position: 12
             },
             %{
               name: "Olivenöl",
               description: "wenig",
               position: 13
             }
           ]
  end

  test "unexpected http status, error is returned" do
    Mox.expect(Recipes.HttpClient.Mock, :get, fn _ ->
      {:ok, %{status_code: 400}}
    end)

    assert {:error, _} = Chefkoch.scrape(@url)
  end

  test "unexpected response, error is returned" do
    Mox.expect(Recipes.HttpClient.Mock, :get, fn _ ->
      {:ok, %{status_code: 200, body: "unexpected"}}
    end)

    assert {:error, _} = Chefkoch.scrape("")
  end
end
