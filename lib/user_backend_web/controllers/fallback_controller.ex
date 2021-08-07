defmodule UserBackendWeb.FallbackController do
  import UserBackendWeb.ErrorHelpers
  require Logger
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use UserBackendWeb, :controller

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(UserBackendWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :user_exists}) do
    conn
    |> put_status(:conflict)
    |> put_view(UserBackendWeb.ErrorView)
    |> render(:"409")
  end

  def call(conn, {:error, %Ecto.Changeset{}=changeset}) do
    if changeset.errors != nil do
      conn
        |> put_status(:bad_request)
        |> put_view(UserBackendWeb.ErrorView)
        |> render("400.json", %{message: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)})
    else
      conn
        |> put_status(:unprocessable_entity)
        |> put_view(UserBackendWeb.ErrorView)
        |> render(:"422")
    end
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Login error"})
  end
end
