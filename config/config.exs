# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :conv,
  ecto_repos: [Conv.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :conv, ConvWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "sbeojDhZgVWDB66HHT7wUS66/fBsCLl7p0Hag8Ng/rYLLrLzW3Yg8knIhq5RHtHl",
  render_errors: [view: ConvWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Conv.PubSub,
  live_view: [signing_salt: "rsags7xp"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
