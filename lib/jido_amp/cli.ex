defmodule Jido.Amp.CLI do
  @moduledoc false

  @type resolve_opt :: {:amp_cli_path, String.t()} | {:cli_path, String.t()}

  @spec configured_path(keyword()) :: String.t() | nil
  def configured_path(opts \\ []) when is_list(opts) do
    opts[:amp_cli_path] ||
      opts[:cli_path] ||
      Application.get_env(:jido_amp, :amp_cli_path)
  end

  @spec resolve(keyword()) :: {:ok, term()} | {:error, term()}
  def resolve(opts \\ []) when is_list(opts) do
    with_amp_cli_path(configured_path(opts), fn ->
      cli_module().resolve()
    end)
  end

  @spec with_amp_cli_path(String.t() | nil, (-> result)) :: result when result: var
  def with_amp_cli_path(nil, fun) when is_function(fun, 0), do: fun.()

  def with_amp_cli_path(path, fun) when is_binary(path) and path != "" and is_function(fun, 0) do
    previous = System.get_env("AMP_CLI_PATH")
    System.put_env("AMP_CLI_PATH", path)

    try do
      fun.()
    after
      restore_amp_cli_path(previous)
    end
  end

  @spec install_path(keyword()) :: String.t()
  def install_path(opts \\ []) when is_list(opts) do
    opts[:install_path] ||
      opts[:amp_cli_path] ||
      opts[:cli_path] ||
      Application.get_env(:jido_amp, :amp_install_path) ||
      Path.join([System.user_home!(), ".amp", "bin", "amp"])
  end

  @spec install_prefix(keyword()) :: String.t()
  def install_prefix(opts \\ []) when is_list(opts) do
    opts[:install_prefix] ||
      Application.get_env(:jido_amp, :amp_install_prefix) ||
      install_path(opts) |> Path.dirname() |> Path.dirname()
  end

  defp restore_amp_cli_path(nil), do: System.delete_env("AMP_CLI_PATH")
  defp restore_amp_cli_path(path), do: System.put_env("AMP_CLI_PATH", path)

  defp cli_module do
    Application.get_env(:jido_amp, :amp_cli_module, AmpSdk.CLI)
  end
end
