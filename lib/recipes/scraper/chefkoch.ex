defmodule Recipes.Scraper.Chefkoch do
  @moduledoc """
  Scaper to scrape recipes from chefkoch
  """

  alias Recipes.HttpClient
  alias Recipes.Scraper

  @behaviour Scraper

  require Logger

  @impl true
  def scrape(url) do
    with {:ok, %{body: body, status_code: 200}} <- HttpClient.get(url),
         {:ok, recipe_data} <- extract_recipe_data(body),
         {:ok, recipe_json_data} <- Jason.decode(recipe_data),
         {:ok, scraped_recipe} <- to_scraped_recipe(recipe_json_data) do
      {:ok, scraped_recipe}
    else
      {:error, _} = err -> err
      e -> {:error, "Error obtaining chefkoch recipe from '#{url}' #{inspect(e)}"}
    end
  end

  defp extract_recipe_data(document) do
    document
    |> Floki.parse_document!()
    |> Floki.find("head > script[type='application/ld+json']")
    |> get_recipe_json_data()
  end

  defp get_recipe_json_data([_ | [{_, _, [recipe_data]}]]), do: {:ok, recipe_data}
  defp get_recipe_json_data(_), do: {:error, "Data is not in expected format!"}

  defp to_scraped_recipe(%{} = chefkoch_recipe) do
    Logger.debug("Scraped recipe #{inspect(chefkoch_recipe)}")

    ingredients =
      chefkoch_recipe["recipeIngredient"]
      |> Enum.with_index(1)
      |> Enum.map(&transform_ingredient/1)

    Logger.debug("Scraped ingredients #{inspect(ingredients)}")
    servings = parse_serving(chefkoch_recipe["recipeYield"])
    Logger.debug("Scraped servings: #{inspect(servings)}")
    kcal = parse_calories(chefkoch_recipe["nutrition"], servings)
    Logger.debug("Scraped kcal: #{inspect(kcal)}")

    {:ok,
     %{
       title: chefkoch_recipe["name"],
       ingredients: ingredients,
       image_url: chefkoch_recipe["image"],
       servings: servings,
       kcal: kcal,
       description: chefkoch_recipe["recipeInstructions"]
     }}
  end

  defp to_scraped_recipe(_), do: {:error, "Data is not in expected format!"}

  defp parse_serving(servings) when is_binary(servings) do
    case Regex.run(~r"^\d+", servings) do
      [num_str] -> Integer.parse(num_str)
      _ -> nil
    end
    |> case do
      {num, _} -> num
      _ -> nil
    end
  end

  defp parse_serving(_), do: nil

  defp parse_calories(%{"calories" => calories}, servings) when is_number(servings) do
    kcal_regex = ~r"(\d+) kcal"

    if Regex.match?(kcal_regex, calories) do
      [[_ | [kcal_str]]] = Regex.scan(kcal_regex, calories)
      {kcal, _} = Integer.parse(kcal_str)
      kcal * servings
    else
      nil
    end
  end

  defp parse_calories(_, _), do: nil

  defp transform_ingredient({ingredient_string, position}) do
    {quantity, rest} = extract_quantity(ingredient_string)
    {trailing_description, rest} = extract_trailing_description(rest)
    {name, rest} = extract_name(rest)

    filter_empty_or_nil(%{
      name: name,
      quantity: quantity,
      position: position,
      description: String.trim("#{rest} #{trailing_description}")
    })
  end

  defp extract_name(ingredient_string) do
    n_b = "n. B. "

    cond do
      String.starts_with?(ingredient_string, n_b) ->
        name = String.replace(ingredient_string, n_b, "")
        {name, String.trim(n_b)}

      String.starts_with?(ingredient_string, " ") ->
        name = String.trim(ingredient_string)
        {name, nil}

      true ->
        [quantity_description | name_parts] = String.split(ingredient_string, " ")
        name = Enum.join(name_parts, " ")
        {name, quantity_description}
    end
  end

  defp extract_trailing_description(ingredient) do
    trailing_description_regex = ~r" , (.*)"
    rest = Regex.replace(trailing_description_regex, ingredient, "")

    case Regex.run(trailing_description_regex, ingredient) do
      [_, trailing_description] -> {trailing_description, rest}
      nil -> {nil, rest}
    end
  end

  defp extract_quantity(ingredient_string) do
    ingredient_string = sanatize_quantity(ingredient_string)
    quantity_regex = ~r"^\d+\.?\d* "

    quantity_str =
      case Regex.run(quantity_regex, ingredient_string) do
        [quantity_str] -> quantity_str
        _ -> nil
      end

    {convert_quantity(quantity_str), Regex.replace(quantity_regex, ingredient_string, "")}
  end

  defp sanatize_quantity(ingredient_string) do
    sanatized =
      Regex.replace(~r"(\d+)\.(\d+)", ingredient_string, "\\1\\2")
      |> String.replace(~r" ?⅛", ".25")
      |> String.replace(~r" ?½", ".5")
      |> String.replace(~r" ?¾", ".75")
      |> String.replace(~r" ?⅛", ".125")

    if Regex.match?(~r"\.\d", sanatized) do
      # Add preceding 0 if string looks like ".5"
      "0" <> sanatized
    else
      sanatized
    end
  end

  defp convert_quantity(nil), do: nil

  defp convert_quantity(quantity) do
    quantity
    |> Float.parse()
    |> case do
      {digit, _} -> digit
      _ -> ""
    end
  end

  defp filter_empty_or_nil(map) do
    map
    |> Enum.reject(fn {_, v} -> (is_binary(v) and String.length(v) == 0) or is_nil(v) end)
    |> Map.new()
  end
end
