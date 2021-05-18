defmodule UserBackendWeb.Router do
  use UserBackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug UserBackend.Guardian.AuthPipeline
  end

  scope "/api/v1", UserBackendWeb do
    pipe_through :api
    #resources "/users", UserController, except: [:new, :edit]
    #post "/users/sign_in", UserController, :sign_in
    post "/sign_in", UserController, :sign_in
    post "/sign_up", UserController, :create
    post "/register", UserController, :register
    post "/send_email", UserController, :send_email
    get "/verify/:token", UserController, :verify_email
  end

  scope "/api/v1", UserBackendWeb do
    pipe_through [:api, :jwt_authenticated]
    get "/my_user", UserController, :show
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: UserBackendWeb.Telemetry
    end
  end
end
