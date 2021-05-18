defmodule UserBackend.Repo do
  use Ecto.Repo,
    otp_app: :user_backend,
    adapter: Ecto.Adapters.Postgres
end
