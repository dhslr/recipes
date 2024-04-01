# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Recipes.Repo.insert!(%Recipes.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Recipes.Data

{:ok, currywurst} =
  Data.create_recipe(%{
    title: "Title",
    kcal: 2001,
    servings: 2,
    description: """
    Zeit, eine eigene Sauce zu kreieren. Bei der Wahl der Wurst scheiden sich die Geister: mit oder ohne Pelle? Jeder muss selbst entscheiden, was besser schmeckt. Die Sauce sollte eine angenehme Süße haben, ohne dabei zur klebrigen Zuckerbombe zu werden. Die fruchtige Note liefern Paprika und optional ein Apfel. Wer einen Hauch von Rauchigkeit mag, kann gerauchten Speck hinzufügen. Und natürlich darf das Currypulver nicht fehlen – auf dem Teller wird alles ordentlich damit bestäubt. Guten Appetit! 🌶️🍅🌭
    """,
    ingredients: [
      %{description: "Viel", name: "Ketchup"},
      %{
        quantity: 500,
        description: "Gramm",
        name: "Pommes"
      },
      %{name: "Curry"},
      %{name: "Wurst"}
    ]
  })

{:ok, _} =
  Recipes.Accounts.register_user(%{
    email: "admin@dhslr.de",
    password: "supers3cret!",
    is_admin: true
  })

{:ok, _} = Recipes.Accounts.register_user(%{email: "user@dhslr.de", password: "s3cret!"})
