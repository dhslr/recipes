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

{:ok, _} = Recipes.create_food(%{name: "Salz"})
{:ok, _} = Recipes.create_food(%{name: "Pfeffer"})
{:ok, _} = Recipes.create_food(%{name: "Wasser"})
{:ok, pommes} = Recipes.create_food(%{name: "Pommes"})
{:ok, ketchup} = Recipes.create_food(%{name: "Ketchup"})
{:ok, wurst} = Recipes.create_food(%{name: "Wurst"})
{:ok, curry} = Recipes.create_food(%{name: "Curry"})

{:ok, currywurst} =
  Recipes.create_recipe(%{
    title: "Title",
    kcal: 2001,
    servings: 2,
    description: """
      1
      Die Currywurst wird 70! Zeit eine eigene Sauce zu kreieren. An der zu verwendenden Wurst scheiden sich die Geister. Mit oder ohne Pelle, was besser ist muss jeder selbst entscheiden. Da die Wurst nicht der indischen Küche entstammt, sondern in Berlin erfunden wurde, werden dort beide Sorten angeboten. Ich bevorzuge Pelle. Die Sauce sollte etwas Süsse haben, aber keine klebrige Zuckerbombe werden wie die gekauften Varianten. Den fruchtigen Geschmack sollen die Paprika und optional ein Apfel liefern. Wer den gerauchten Speck zugibt bekommt eine etwas rauchige Note. Auf dem Teller wird dann nochmal alles ordentlich mit Currypulver bestäubt.
      2
      Die Paprika, die Zwiebeln und den Knoblauch rüsten und grob würfeln. Der Apfel gibt eine zusätzliche fruchtige Note (manche Rezepte verwenden deshalb Apfelsaft statt dem Essig), ist aber vom persönlichen Geschmack abhängig und kann auch weggelassen werden. Falls also verwendet, Kerngehäuse und Stiel entfernen und grob gewürfelt mit in die Pfanne geben. Die Zutaten bräunen, es sollten Röstaromen entstehen. Den Knoblauch erst gegen Schluss zugeben, wenn die Zwiebeln schon Farbe genommen haben - zu lange angebraten wird Knoblauch bitter.
      3
      Mit dem Essig ablöschen und 5 min kochen bis der Essig fast ganz eingekocht ist. Dann die Tomaten aus der Dose dazu. Die Worcestersauce, das Salz, den Rübensirup, das Currypulver und den Sambal oelek hinein geben und alles weitere 10 - 15 min kochen. Die Masse pürieren und den Ketschup untermischen.
      4
      Abschmecken. Wer es süsser mag kann noch mehr Rübensirup zugeben. Den Sambal oelek so dosieren wie man die Schärfe gerne mag. Ein Teelöffel davon ist für die meisten Menschen genug, ohne das gleich Rauch aus den Nasenlöchern kommt. Wer es schärfer mag, nach oben ist keine Grenze. Soll es für den Kindergeburtstag sein - lieber gar nichts hinein geben. Man kann stattdessen natürlich auch ein oder zwei Peperoncino bereits mit den Paprika anbraten.
      5
      Noch heiss in Gläser abfüllen und die Deckel schliessen. Sind die Twist-off Deckel fest verschlossen, hält es sich bei dunkler Lagerung sicher 3 - 4 Monate. Die Sauce kann auch zu Grillgerichten serviert werden. Für die Currywurst am Besten nochmals anwärmen und darüber geben und mit Currypulver bestäuben. Sie schmeckt aber auch kalt.
    """
  })

{:ok, _} =
  Recipes.create_ingredient(%{description: "Viel", food_id: ketchup.id, recipe_id: currywurst.id})

{:ok, _} =
  Recipes.create_ingredient(%{
    quantity: 500,
    description: "Gramm",
    food_id: pommes.id,
    recipe_id: currywurst.id
  })

{:ok, _} =
  Recipes.create_ingredient(%{
    quantity: 1,
    description: "Stück",
    food_id: wurst.id,
    recipe_id: currywurst.id
  })

{:ok, _} = Recipes.create_ingredient(%{food_id: curry.id, recipe_id: currywurst.id})

{:ok, _} =
  Recipes.Accounts.register_user(%{
    email: "admin@dhslr.de",
    password: "supers3cret!",
    is_admin: true
  })

{:ok, _} = Recipes.Accounts.register_user(%{email: "user@dhslr.de", password: "s3cret!"})
