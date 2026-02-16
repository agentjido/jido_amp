defmodule Jido.Amp.Tools do
  @moduledoc """
  Amp tool management wrappers.
  """

  @doc "List active tools."
  @spec list() :: {:ok, String.t()} | {:error, term()}
  def list do
    sdk_module().tools_list()
  end

  @doc "Show a tool definition."
  @spec show(String.t()) :: {:ok, String.t()} | {:error, term()}
  def show(tool_name) do
    sdk_module().tools_show(tool_name)
  end

  @doc "Execute a tool."
  @spec use(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def use(tool_name, opts \\ []) do
    sdk_module().tools_use(tool_name, opts)
  end

  @doc "Create a custom tool."
  @spec make(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def make(tool_name, opts \\ []) do
    sdk_module().tools_make(tool_name, opts)
  end

  defp sdk_module do
    Application.get_env(:jido_amp, :amp_sdk_module, AmpSdk)
  end
end
