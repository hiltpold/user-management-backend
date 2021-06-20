defmodule UserBackendWeb.Router do
  use UserBackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :jwt_authenticated do
    plug UserBackend.Guardian.AuthPipeline
  end

  scope "/api/", UserBackendWeb do
    pipe_through :api
    scope "/v1/users/" do
      post "/login", UserController, :login
      post "/register", UserController, :register
      get "/verify/:token", UserController, :verify_email
      get "/verify", UserController, :verify_email
      post "/password/forgot", UserController, :forgot_password
      #post "/:id/password/renewal", UserController, :password_renewal
      #post "/:id/password/forgot", UserController, :password_renewal
      #post "/:id/email/forgot", UserController, :password_renewal
    end
  end

  #scope "/api/", UserBackendWeb.Api do
  #  scope "/v1/" do
  #    pipe_through [:api, :jwt_authenticated]
  #    get "/my_user", UserController, :show
  #  end
  #end


  #scope "/", UserBackendWeb do
  #  pipe_through :browser # Use the default browser stack
  #  get "/verify/:token", UserController, :verify_email_test
  #end

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
