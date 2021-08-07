defmodule UserBackend.Accounts.Notification do
  use Bamboo.Phoenix, view: UserBackendWeb.EmailView
  alias UserBackend.Mailer
  require Logger

  #@reply_to "matthias.hiltpold@gmail.com"
  @from "defenders-undressed@protonmail.com"

  def deliver(%Bamboo.Email{} = email, later \\ false) do
    case later do
      true -> Mailer.deliver_now(email,response: true)
      false -> Mailer.deliver_later(email,response: true)
    end
    {:ok, email}
  end

  def deliver_confirmation_instructions(user, url) do
    base_email()
    |> to(user.email)
    |> subject("Account Confirmation")
    |> assign(:user, user)
    |> assign(:url, url)
    |> put_html_layout({UserBackendWeb.LayoutView, "email.html"})
    |> render("confirmation_instructions.html")
    |> deliver()
  end

  def deliver_password_reset_confirmation(email, new_password) do
    base_email()
    |> to(email)
    |> subject("Account Confirmation")
    |> assign(:email, email)
    |> assign(:new_password, new_password)
    |> put_html_layout({UserBackendWeb.LayoutView, "email.html"})
    |> render("confirmation_password_reset.html")
    |> deliver()
  end

  defp base_email() do
    new_email()
    |> from(@from)
  end
end
