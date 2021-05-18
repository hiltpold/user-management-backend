defmodule UserBackend.Account.Notification do
  import Bamboo.Email
  #import Bamboo.Phoenix
  alias UserBackend.Mailer
  require Logger

  @reply_to "matthias.hiltpold@gmail.com"
  @from "defenders-undressed@protonmail.com"

  def deliver(%Bamboo.Email{} = email, later \\ false) do
    case later do
      true -> Mailer.deliver_now(email,response: true)
      false -> Mailer.deliver_later(email,response: true)
    end
    {:ok, %{to: email.to, body: email.html_body}}
  end

  def deliver_confirmation(user, url) do
    base_email()
    |> to(user.email)
    |> subject("Confirm your account")
    |> html_body("<strong>Welcome</strong>")
    |> deliver()
  end

  def deliver_confirmation_instructions(user, url) do
    Logger.info(user)
    base_email()
    |> to(user.email)
    |> subject("Confirm your account")
    #|> assign(:user, user)
    #|> assign(:url, url)
    #|> render("confirmation_instructions.html")
    |> html_body("<strong>Welcome</strong>")
    |> deliver()
  end

  defp base_email() do
    new_email()
    |> put_header("Reply-To", @reply_to)
    |> from(@from)
  end
end
