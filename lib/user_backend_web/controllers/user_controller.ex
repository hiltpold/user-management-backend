defmodule UserBackendWeb.UserController do
  use UserBackendWeb, :controller
  alias UserBackend.Account
  alias UserBackend.Account.User
  alias UserBackendWeb.Router.Helpers, as: Routes
  alias UserBackend.Account.Notification
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
    #with {:ok, %User{} = user} <- Account.create_user(user_params) do
    with {:ok, %User{} = user} <- Account.create_user(user_params) do
        token = UserBackend.Token.generate_new_account_token(user)
        Logger.info("Verifing the following token: #{inspect(token)}")
        verification_url = Routes.user_path(UserBackendWeb.Endpoint, :verify_email, token)
        Logger.info("Token URL: #{inspect(verification_url)}")
        {:ok, email_info} = Notification.deliver_confirmation_instructions(user, verification_url)
        #UserBackend.Notifications.send_account_verification_email(user, verification_url)
        conn |> render("verification_url.json", url: verification_url)
    end
  end

  def verify_email(conn, %{"token" => token}) do
    Logger.info("VERIFY TOKEN: #{inspect(token)}")
    {:ok, tmp} = UserBackend.Token.verify_new_account_token(token)
    Logger.info("VERIFY USER ID: #{inspect(tmp)}")
    #{:ok, u }=Account.get_user!(tmp)
    #Logger.info("VERIFY USER: #{inspect(u)}")
    with {:ok, user_id} <- UserBackend.Token.verify_new_account_token(token),
         {:ok, %User{is_verified: false} = user} <- Account.get_user!(user_id) do
      Logger.info("VERIFY USER ---->: #{inspect(user)}")
      UserBackend.Account.mark_as_verified(user)
      conn |> render("user.json", user: user)
    else
      _ -> render("401.json", message: "The token is invalid.")
    end
  end

  def verify_email(conn, _) do
    # If there is no token in our params, tell the user they've provided
    # an invalid token or expired token
    conn
    |> put_flash(:error, "The verification link is invalid.")
    |> redirect(to: "/")
  end

  #def create(conn, %{"user" => user_params}) do
  #  with {:ok, %User{} = user} <- Account.create_user(user_params),
  #       {:ok, token, _claims} <- Guardian.mix (user) do
  #      conn |> render("jwt.json", jwt: token)
  #      #|> put_status(:created)
  #      #|> put_resp_header("location", Routes.user_path(conn, :show, user))
  #      #|> render("jwt.json", jwt: token)
  #  end
  #end

  def show(conn, _params) do
    user = UserBackend.Guardian.Plug.current_resource(conn)
    conn |> render("user.json", user: user)
  end

  #def show(conn, %{"id" => id}) do
  #  user = Account.get_user!(id)
  #  render(conn, "show.json", user: user)
  #end

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

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Account.token_sign_in(email, password) do
      {:ok, token, _claims} ->
        conn |> render("jwt.json", jwt: token)
      _ ->
        {:error, :unauthorized}
    end
  end

  #def sign_in(conn, %{"email" => email, "password" => password}) do
  #  case UserBackend.Account.authenticate_user(email, password) do
  #    {:ok, user} ->
  #      conn
  #      |> put_status(:ok)
  #      |> put_view(UserBackendWeb.UserView)
  #      |> render("sign_in.json", user: user)

  #    {:error, message} ->
  #      conn
  #      |> put_status(:unauthorized)
  #      |> put_view(UserBackendWeb.ErrorView)
  #      |> render("401.json", message: message)
  #  end
  #end
end
