# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :user_backend,
  ecto_repos: [UserBackend.Repo],
  generators: [binary_id: true]

#Add support for microseconds at the database level
# avoid having to configure it on every migration file
config :user_backend, UserBackend.Repo, migration_timestamps: [type: :utc_datetime_usec]

# Configures the endpoint
config :user_backend, UserBackendWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("ENDPOINT_SECRET"),
  render_errors: [view: UserBackendWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: UserBackend.PubSub,
  live_view: [signing_salt: "GX1pXPj5"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# Guardian
config :user_backend, UserBackend.Guardian,
       issuer: "user_backend",
       secret_key: System.get_env("GUARDIAN_SECRET_KEY")
