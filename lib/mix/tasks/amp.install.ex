defmodule Mix.Tasks.Amp.Install do
  @moduledoc """
  Ensure the Amp CLI is installed at a deterministic location.

      mix amp.install

  By default this installs (or reuses) Amp under `~/.amp/bin/amp`.
  Use `--path` to override target executable path.
  """

  @shortdoc "Install Amp CLI idempotently"

  use Mix.Task

  @switches [path: :string, force: :boolean]

  @impl true
  def run(args) do
    {opts, _positional, invalid} = OptionParser.parse(args, strict: @switches)
    validate_options!(invalid)

    install_opts =
      []
      |> maybe_put(:amp_cli_path, opts[:path])
      |> maybe_put(:force, opts[:force] || false)

    case installer_module().ensure_installed(install_opts) do
      {:ok, %{status: :already_installed, program: program}} ->
        Mix.shell().info(["Amp CLI found: ", :green, program, :reset])

      {:ok, %{status: :installed, program: program, install_prefix: install_prefix}} ->
        Mix.shell().info([
          :green,
          "Amp CLI installed.",
          :reset,
          "\n",
          "Program: ",
          program,
          "\n",
          "Prefix: ",
          install_prefix
        ])

      {:error, error} ->
        Mix.raise("""
        Amp install failed.

        #{Exception.message(error)}
        """)
    end
  end

  defp validate_options!([]), do: :ok

  defp validate_options!(invalid) do
    invalid_text =
      Enum.map_join(invalid, ", ", fn
        {name, nil} -> format_invalid_name(name)
        {name, value} -> "#{format_invalid_name(name)}=#{value}"
      end)

    Mix.raise("invalid options: #{invalid_text}")
  end

  defp format_invalid_name(name) when is_binary(name) do
    if String.starts_with?(name, "-"), do: name, else: "--#{name}"
  end

  defp format_invalid_name(name) when is_atom(name), do: "--#{name}"

  defp maybe_put(opts, _key, nil), do: opts
  defp maybe_put(opts, key, value), do: Keyword.put(opts, key, value)

  defp installer_module do
    Application.get_env(:jido_amp, :amp_install_module, Jido.Amp.Installer)
  end
end
