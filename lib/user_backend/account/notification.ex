defmodule UserBackend.Account.Notification do
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
    {:ok, %{to: email.to, body: email.html_body}}
  end

  def deliver_confirmation_instructions(user, url) do
    Logger.info(user)
    base_email()
    |> to(user.email)
    |> subject("Account Confirmation")
    |> assign(:user, user)
    |> assign(:url, url)
    |> put_html_layout({UserBackendWeb.LayoutView, "email.html"})
    |> render("confirmation_instructions.html")
    |> deliver()
  end

  defp base_email() do
    new_email()
    #|> put_header("Reply-To", @reply_to)
    |> from(@from)
  end
end
