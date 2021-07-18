defmodule UserBackendWeb.UserController do
  use UserBackendWeb, :controller
  alias UserBackend.Account
  alias UserBackend.Account.User
  alias UserBackendWeb.Router.Helpers, as: Routes
  alias UserBackend.Account.Notification
  alias UserBackend.Misc.Utils, as: Utils
  require Logger

  action_fallback UserBackendWeb.FallbackController

  def index(conn, _params) do
    users = Account.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Account.create_user(user_params),
         {:ok, token, _claims} <- UserBackend.Guardian.encode_and_sign(user) do
        conn |> render("jwt.json", jwt: token)
    end
  end

  def register(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Account.create_user(user_params) do
        token = UserBackend.Token.generate_new_account_token(user)
        verification_url = System.get_env("BASE_URI") <> Routes.user_path(UserBackendWeb.Endpoint, :verify_email, token)
        {:ok, _} = Notification.deliver_confirmation_instructions(user, verification_url)
        conn |> render("verification_url.json", url: verification_url)
    end
  end

  def verify_email(conn, %{"token" => token}) do
    with {:ok, user_id} <- UserBackend.Token.verify_new_account_token(token),
         {:ok, %User{is_verified: false} = user} <- Account.get_by!(user_id) do
      Account.update_user(user, %{is_verified: true})
      conn |> render("email_verified.json", message: "token is valid")
    else
      _ -> conn
          |> put_status(:unauthorized)
          |> render("401.json", message: "token is not valid")
    end
  end

  def verify_email(conn, _) do
    # If there is no token in our params, tell the user they've provided
    # an invalid token or expired token
    conn |> put_status(:unauthorized)
         |> render("401.json", message: "no token provided")
  end

  def reset_password(conn, %{"email" => email}) do
    new_password = %{password: Utils.random_string(8)}
    with {:ok, _} = Account.update_user_password(email, new_password),
         {:ok, _} = Notification.deliver_password_reset_confirmation(email, new_password.password) do
          conn |> put_status(200)
               |> json(%{message: "password reset successful"})
         end
  end

  def show(conn, _params) do
    user =  UserBackend.Guardian.Plug.current_resource(conn)
    conn |> render("user.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Account.get_user!(id)
    with {:ok, %User{} = user} <- Account.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Account.get_user!(id)
    with {:ok, %User{}} <- Account.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Account.email_password_auth(email, password) do
      { :ok, user } ->
        conn
          |> UserBackend.Guardian.Plug.sign_in(user)
          |> render("user.json", user: user)
      { :error, message} ->
        conn
          |> put_status(:unauthorized)
          |> render("401.json", message: message)
      end
  end

  def logout(conn, _opts) do
    conn
     |> UserBackend.Guardian.Plug.sign_out()
     |> json("success")
  end

  def csrf(conn, _opts) do
    csrf_token = get_csrf_token()
    conn
      |> put_session("_csrf_token", Process.get(:plug_unmasked_csrf_token))
      |> json(%{_csrf_token: csrf_token})
  end
end
