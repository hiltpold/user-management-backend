defmodule UserBackendWeb.UserView do
  use UserBackendWeb, :view
  alias UserBackendWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, email: user.email, is_active: user.is_active}
  end

  def render("sign_in.json", %{user: user}) do
    %{
      data: %{
        user: %{
          id: user.id,
          email: user.email
         }
       }
     }
   end

   def render("jwt.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end

  def render("verification_url.json", %{url: url}) do
    %{url: url}
  end
end