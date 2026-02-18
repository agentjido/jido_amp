defmodule Jido.Amp.Installer do
  @moduledoc false

  alias Jido.Amp.CLI
  alias Jido.Amp.Error

  @npm_package "@sourcegraph/amp"

  @spec ensure_installed(keyword()) :: {:ok, map()} | {:error, Jido.Amp.Error.ConfigError.t()}
  def ensure_installed(opts \\ []) when is_list(opts) do
    force? = Keyword.get(opts, :force, false)

    if force? do
      install(opts)
    else
      case CLI.resolve(opts) do
        {:ok, spec} ->
          {:ok, %{status: :already_installed, program: spec.program}}

        {:error, _reason} ->
          install(opts)
      end
    end
  end

  @spec install(keyword()) :: {:ok, map()} | {:error, Jido.Amp.Error.ConfigError.t()}
  def install(opts \\ []) when is_list(opts) do
    install_path = CLI.install_path(opts)
    install_prefix = CLI.install_prefix(opts)
    :ok = File.mkdir_p!(Path.dirname(install_path))

    with :ok <- ensure_npm_available(),
         :ok <- run_install(install_prefix),
         :ok <- ensure_executable(install_path),
         {:ok, spec} <- CLI.resolve(Keyword.put(opts, :amp_cli_path, install_path)) do
      {:ok, %{status: :installed, program: spec.program, install_path: install_path, install_prefix: install_prefix}}
    else
      {:error, _} = error -> error
    end
  end

  defp run_install(prefix) do
    case command_module().cmd("npm", ["install", "--prefix", prefix, @npm_package], stderr_to_stdout: true) do
      {_output, 0} ->
        :ok

      {output, code} ->
        {:error,
         Error.config_error("Amp CLI installation failed via npm.", %{
           key: :amp_cli_install_failed,
           details: %{
             exit_code: code,
             output: String.trim(output),
             command: "npm install --prefix #{prefix} #{@npm_package}"
           }
         })}
    end
  rescue
    error ->
      {:error,
       Error.config_error("Amp CLI installation failed via npm.", %{
         key: :amp_cli_install_failed,
         details: %{error: Exception.message(error)}
       })}
  end

  defp ensure_npm_available do
    case System.find_executable("npm") do
      nil ->
        {:error,
         Error.config_error("npm is required to install Amp CLI.", %{
           key: :npm_not_found,
           details: %{
             remediation: "Install Node.js/npm and re-run `mix amp.install`."
           }
         })}

      _ ->
        :ok
    end
  end

  defp ensure_executable(path) do
    case File.stat(path) do
      {:ok, %File.Stat{type: :regular, mode: mode}} when Bitwise.band(mode, 0o111) != 0 ->
        :ok

      {:ok, %File.Stat{type: :regular}} ->
        # npm on some systems writes non-executable permissions initially.
        case File.chmod(path, 0o755) do
          :ok -> :ok
          {:error, _} -> executable_error(path)
        end

      _ ->
        executable_error(path)
    end
  end

  defp executable_error(path) do
    {:error,
     Error.config_error("Amp CLI installation completed but binary is missing or not executable.", %{
       key: :amp_cli_install_invalid_binary,
       details: %{path: path}
     })}
  end

  defp command_module do
    Application.get_env(:jido_amp, :amp_install_command_module, System)
  end
end
