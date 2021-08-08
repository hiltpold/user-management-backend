defmodule UserBackendWeb.UserView do
  use UserBackendWeb, :view
  alias UserBackendWeb.UserView

  def render("message.json", %{message: message}) do
    %{message: message}
  end

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, email: user.email, is_verified: user.is_verified}
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

  def render("401.json", %{message: message}) do
    %{
      errors: %{
        detail: message
      }
    }
  end

  def render("403.json", %{message: message}) do
    %{
      errors: %{
        detail: message
      }
    }
  end

  def render("500.json", %{message: message}) do
    %{
      errors: %{
        detail: message
      }
    }
  end
end
