defmodule Jido.Amp.Review do
  @moduledoc """
  Amp review command wrapper.
  """

  @doc "Run `amp review`."
  @spec run(keyword()) :: {:ok, String.t()} | {:error, term()}
  def run(opts \\ []) do
    sdk_module().review(opts)
  end

  defp sdk_module do
    Application.get_env(:jido_amp, :amp_sdk_module, AmpSdk)
  end
end
