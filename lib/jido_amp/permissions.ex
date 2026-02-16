defmodule Jido.Amp.Permissions do
  @moduledoc """
  Amp permission rule management wrappers.
  """

  @doc "List parsed permission rules."
  @spec list(keyword()) :: {:ok, [AmpSdk.Types.PermissionRule.t()]} | {:error, term()}
  def list(opts \\ []) do
    sdk_module().permissions_list(opts)
  end

  @doc "List raw permission CLI output."
  @spec list_raw(keyword()) :: {:ok, String.t()} | {:error, term()}
  def list_raw(opts \\ []) do
    sdk_module().permissions_list_raw(opts)
  end

  @doc "Test permissions for a given tool."
  @spec test(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def test(tool_name, opts \\ []) do
    sdk_module().permissions_test(tool_name, opts)
  end

  @doc "Add a permission rule."
  @spec add(String.t(), String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def add(tool, action, opts \\ []) do
    sdk_module().permissions_add(tool, action, opts)
  end

  defp sdk_module do
    Application.get_env(:jido_amp, :amp_sdk_module, AmpSdk)
  end
end
