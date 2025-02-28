import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :recipes, Recipes.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "recipes_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 20

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :recipes, RecipesWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "UyeYu3L4cel7JejeNYhU2O0ci2Tm1XL7yXGbVYfEEtu9h9nWVMkTOz3lpefqv2Uv",
  server: true

config :recipes, http_client: Recipes.HttpClient.Mock
config :recipes, recipe_scraper: Recipes.Scraper.Mock

# In test we don't send emails.
config :recipes, Recipes.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Use ecto's sandbox feature in tests for wallaby
config :recipes, :sandbox, Ecto.Adapters.SQL.Sandbox

# Wallaby configuration
config :wallaby,
  otp_app: :recipes,
  driver: Wallaby.Selenium,
  screenshot_on_failure: true,
  js_errors: true,
  selenium: [
    server_url: "http://localhost:4444/wd/hub"
  ],
  firefox: [
    headless: true,
    window_size: [width: 1400, height: 1400]
  ]
  ]
