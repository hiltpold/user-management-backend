defmodule UserBackendWeb.FranchiseController do
  use UserBackendWeb, :controller

  alias UserBackend.Leagues
  alias UserBackend.Leagues.Franchise
  alias UserBackendWeb.Router.Helpers, as: Routes
  alias UserBackend.Repo
  alias UserBackendWeb.Plug.Authorize
  action_fallback UserBackendWeb.FallbackController

  plug :assign_franchise when action in [:show]
  plug Authorize, [UserBackend.Policies.Admin.Franchise, :franchise]

  def index(conn, _params) do
    franchises = Leagues.list_franchises()
    render(conn, "index.json", franchises: franchises)
  end

  def create(conn, %{"franchise" => franchise_params}) do
    with {:ok, %Franchise{} = franchise} <- Leagues.create_franchise(franchise_params) do
      conn
      |> put_status(:created)
      #|> put_resp_header("location", Routes.franchise_path(conn, :show, franchise))
      |> render("show.json", franchise: franchise)
    end
  end

  def show(conn, %{"id" => id}) do
    franchise = Leagues.get_franchise!(id)
    render(conn, "show.json", franchise: franchise)
  end

  def update(conn, %{"id" => id, "franchise" => franchise_params}) do
    franchise = Leagues.get_franchise!(id)

    with {:ok, %Franchise{} = franchise} <- Leagues.update_franchise(franchise, franchise_params) do
      render(conn, "show.json", franchise: franchise)
    end
  end

  def delete(conn, %{"id" => id}) do
    franchise = Leagues.get_franchise!(id)

    with {:ok, %Franchise{}} <- Leagues.delete_franchise(franchise) do
      send_resp(conn, :no_content, "")
    end
  end

  defp assign_franchise(conn = %{params: %{"id" => id}}, _) do
    #franchise = Franchise |> Repo.get!(id) |> Franchise.preload_all()
    assign(conn, :franchise, %Franchise{})
  end
end
