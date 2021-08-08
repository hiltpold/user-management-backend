defmodule UserBackend.Policies.Admin.Franchise do
  use UserBackend.Policies.Default
  require Logger

  def index(actor), do: is_admin(actor)
  def show(actor, _franchise) do
        Logger.debug inspect actor
        Logger.debug "--------------"
        Logger.debug inspect actor
        Logger.debug "--------------"
    is_admin(actor)
  end

end
