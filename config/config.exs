# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :gpanel_one_page, GpanelOnePageWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "y7X97HLrq2MjM0dUiRBxxyX+G3PfmI5XqroxtteIDRf63yA7p4GClSHKwgt3MURz",
  render_errors: [view: GpanelOnePageWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GpanelOnePage.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "+Gl0U97q"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
