defmodule UserBackend.Misc.Utils do

  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64
  end

  def convert!("true"), do: true
  def convert!("false"), do: false

end
