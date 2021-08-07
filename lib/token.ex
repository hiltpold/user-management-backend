defmodule UserBackend.Token do
  @moduledoc """
  Handles creating and validating tokens.
  """
  alias UserBackend.Accounts.User

  @account_verification_salt "KCrWkXq4DNtasXSVUunMnW/E6nJm0Cje/S+niOUeSho/nHraXXi7HbKX79ktlO4x"

  def generate_new_account_token(%User{id: user_id}) do
    Phoenix.Token.sign(UserBackendWeb.Endpoint, @account_verification_salt, user_id)
  end

  def generate_new_token(%User{id: user_id, role: user_role}) do
    Phoenix.Token.sign(UserBackendWeb.Endpoint, @account_verification_salt, %{id: user_id, role: user_role})
  end

  def verify_new_account_token(token) do
    max_age = 86_400 # tokens that are older than a day should be invalid
    Phoenix.Token.verify(UserBackendWeb.Endpoint, @account_verification_salt, token, max_age: max_age)
  end
end
