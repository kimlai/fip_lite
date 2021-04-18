# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :fip_lite, FipLiteWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "c2kcBf+LAc4AaatNimc/mgoWNRZr+0/HvWgWjnXFMPVOsFwQnoEREoVZcrw5K3GG",
  render_errors: [view: FipLiteWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: FipLite.PubSub,
  live_view: [signing_salt: "CnFnqiEf"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
