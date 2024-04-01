# Recipes App

Recipes is a [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view) web app to manage your favorit cooking recipes. 

## Run development version
First make sure you have [elixir](https://elixir-lang.org/install.html) installed. 

  * Setup the project with `mix setup`
  * Start a development server with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Run release version with docker
This repository contains a `docker-compose.yml` that runs a release version of the recipes app and sets up a postgres database. Make sure to pass the required environment configuration variables. You can create a `.env` file for this. See the [.env.example](.env.example) file for details.

```sh
docker-compose up -d
```
For more information check the phoenix [deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Backup
There are backup and restore scripts inside the [scripts](./scripts) directory that also use the environment variables defined in the `.env` file.
