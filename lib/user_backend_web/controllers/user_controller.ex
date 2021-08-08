defmodule UserBackendWeb.UserController do
  use UserBackendWeb, :controller
  alias UserBackend.Accounts
  alias UserBackend.Accounts.User
  alias UserBackendWeb.Router.Helpers, as: Routes
  alias UserBackend.Accounts.Notification
  alias UserBackend.Misc.Utils, as: Utils
  import UserBackendWeb.ErrorHelpers
  require Logger

  action_fallback UserBackendWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params),
         {:ok, token, _claims} <- UserBackend.Guardian.encode_and_sign(user) do
        conn |> render("jwt.json", jwt: token)
    end
  end

  def register(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
        token = UserBackend.Token.generate_new_account_token(user)
        verification_url = System.get_env("BASE_URI") <> Routes.user_path(UserBackendWeb.Endpoint, :verify_email, token)
        {:ok, _} = Notification.deliver_confirmation_instructions(user, verification_url)
        conn |> render("verification_url.json", url: verification_url)
   # else
   #   {:error, %Ecto.Changeset{}=changeset} -> Logger.debug inspect changeset.errors
   #   {:error, :user_exists}
    end
  end

  def verify_email(conn, %{"token" => token}) do
    with {:ok, user_id} <- UserBackend.Token.verify_new_account_token(token),
         {:ok, %User{is_verified: false} = user} <- Accounts.get_by!(user_id) do
          case Accounts.update_user(user, %{is_verified: true}) do
            {:ok, _ } ->
              conn
                |> render("message.json", message: "token is valid")
            {:error, _} ->
              conn
                |> put_status(:internal_server_error)
                |> put_view(UserBackendWeb.ErrorView)
                |> render(:"500")
          end
    else
      _ -> conn
          |> put_status(:unauthorized)
          |> render("401.json", message: "token is not valid or has already been used for activation")
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
    with {:ok, _} = Accounts.update_user_password(email, new_password),
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
    user = Accounts.get_user!(id)
    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.email_password_auth(email, password) do
      { :ok, user } ->
        Logger.debug inspect user
        case user.is_verified do
          true ->
            conn
              |> UserBackend.Guardian.Plug.sign_in(user)
              |> render("user.json", user: user)
          _ ->
            conn
              |> put_status(:forbidden)
              |> render("403.json", message: "account not verified")
        end
      { :error, message} ->
        conn
          |> put_status(:unauthorized)
          |> render("401.json", message: message)
      end
  end

  def logout(conn, _opts) do
    conn
      |> UserBackend.Guardian.Plug.sign_out()
      |> put_status(:ok)
      |> render("message.json", message: "successfully logged out")
  end

  def csrf(conn, _opts) do
    csrf_token = get_csrf_token()
    conn
      |> put_session("_csrf_token", Process.get(:plug_unmasked_csrf_token))
      |> json(%{_csrf_token: csrf_token})
  end
end
