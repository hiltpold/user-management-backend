
defmodule UserBackendWeb.Plug.Authorize do
  import Plug.Conn
  import Phoenix.Controller
  require Logger
  def init(opts), do: opts

  def call(conn, policy_module) when not is_list(policy_module),
    do: call(conn, [policy_module, nil])

  def call(conn, [policy_module, resource_name]) do

    Logger.debug inspect policy_module
    Logger.debug inspect resource_name
    Logger.debug inspect resource_name

    user =  UserBackend.Guardian.Plug.current_resource(conn)
    #user = conn.assigns.current_user
    resource = conn.assigns[resource_name]

    Logger.debug inspect user
    Logger.debug inspect resource

    if apply_policy(policy_module, action_name(conn), user, resource) do
      conn
    else
      conn
      #|> put_flash(:result, "failure")
      #|> redirect(to: UserBackendWeb.Plug.Conn.referer_or_root_path(conn))
      |> put_status(:internal_server_error)
      |> put_view(UserBackendWeb.ErrorView)
      |> render(:"401")
      #|> halt()
    end
  end

  defp apply_policy(module, action, user, nil), do: apply(module, action, [user])
  defp apply_policy(module, action, user, resource), do: apply(module, action, [user, resource])
end
