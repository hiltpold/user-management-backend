defmodule UserBackendWeb.Router do
  use UserBackendWeb, :router
  require Logger

  pipeline :init_frontend do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :frontend do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authenticate do
    plug UserBackend.Guardian.AuthPipeline
  end

  scope "/users/", UserBackendWeb do
    pipe_through [:init_frontend]
    scope "/v1/" do
      get "/csrf", UserController, :csrf # csrf not really neceassry in a json api
      post "/register", UserController, :register
    end
  end

  scope "/users/", UserBackendWeb do
    pipe_through [:frontend]
    scope "/v1/" do
      post "/login", UserController, :login
      get "/verify/:token", UserController, :verify_email
      get "/verify", UserController, :verify_email
      post "/logout", UserController, :logout
      post "/password/reset", UserController, :reset_password
      #post "/:id/password/renewal", UserController, :password_renewal
      #post "/:id/password/forgot", UserController, :password_renewal
      #post "/:id/email/forgot", UserController, :password_renewal
      #get "/my_user", UserController, :show
    end
  end

  scope "/api/", UserBackendWeb do
    scope "/test/" do
      pipe_through [:frontend, :authenticate]
      get "/my_user", UserController, :show
    end
  end

  scope "/users/", UserBackendWeb do
      pipe_through [:frontend, :authenticate]
      scope "/v1/" do
      post "/test", UserController, :show
     end
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
