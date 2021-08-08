defmodule UserBackend.Policies.Default do
  defmacro __using__(_opts) do
    quote do
      def index(_actor), do: false
      def show(_actor, _resource), do: false

      defp is_admin(nil), do: false
      defp is_admin(actor), do: Map.get(actor, :admin, false)

      defoverridable index: 1, show: 2
    end
  end
end
