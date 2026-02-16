defmodule Jido.Amp.Tasks do
  @moduledoc """
  Amp task management wrappers.
  """

  @doc "List available tasks."
  @spec list() :: {:ok, String.t()} | {:error, term()}
  def list do
    sdk_module().tasks_list()
  end

  @doc "Import tasks from a JSON file."
  @spec import(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def import(json_file, opts \\ []) do
    sdk_module().tasks_import(json_file, opts)
  end

  defp sdk_module do
    Application.get_env(:jido_amp, :amp_sdk_module, AmpSdk)
  end
end
