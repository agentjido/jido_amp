defmodule Jido.Amp.Skills do
  @moduledoc """
  Amp skill management wrappers.
  """

  @doc "Add a skill source."
  @spec add(String.t()) :: {:ok, String.t()} | {:error, term()}
  def add(source) do
    sdk_module().skills_add(source)
  end

  @doc "List installed skills."
  @spec list() :: {:ok, String.t()} | {:error, term()}
  def list do
    sdk_module().skills_list()
  end

  @doc "Remove a skill."
  @spec remove(String.t()) :: {:ok, String.t()} | {:error, term()}
  def remove(name) do
    sdk_module().skills_remove(name)
  end

  @doc "Show skill info."
  @spec info(String.t()) :: {:ok, String.t()} | {:error, term()}
  def info(name) do
    sdk_module().skills_info(name)
  end

  defp sdk_module do
    Application.get_env(:jido_amp, :amp_sdk_module, AmpSdk)
  end
end
