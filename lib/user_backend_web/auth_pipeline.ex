defmodule UserBackend.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :UserBackend,
  module: UserBackend.Guardian,
  error_handler: UserBackend.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
