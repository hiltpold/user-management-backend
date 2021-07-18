defmodule UserBackend.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :UserBackend,
  module: UserBackend.Guardian,
  error_handler: UserBackend.AuthErrorHandler
  plug :fetch_session
  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
