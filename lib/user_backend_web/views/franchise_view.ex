defmodule UserBackendWeb.FranchiseView do
  use UserBackendWeb, :view
  alias UserBackendWeb.FranchiseView

  def render("index.json", %{franchises: franchises}) do
    %{data: render_many(franchises, FranchiseView, "franchise.json")}
  end

  def render("show.json", %{franchise: franchise}) do
    %{data: render_one(franchise, FranchiseView, "franchise.json")}
  end

  def render("franchise.json", %{franchise: franchise}) do
    %{id: franchise.id}
  end
end
