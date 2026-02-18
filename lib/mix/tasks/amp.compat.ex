defmodule Mix.Tasks.Amp.Compat do
  @moduledoc """
  Validate whether the locally installed Amp CLI is compatible with `amp_sdk` streaming mode.

      mix amp.compat
  """

  @shortdoc "Validate Amp CLI compatibility for streaming execution"

  use Mix.Task

  alias Jido.Amp.Compatibility

  @switches [path: :string]

  @impl true
  def run(args) do
    {opts, _positional, invalid} = OptionParser.parse(args, strict: @switches)
    validate_options!(invalid)

    compat_opts = if is_binary(opts[:path]) and opts[:path] != "", do: [amp_cli_path: opts[:path]], else: []

    case Compatibility.status(compat_opts) do
      {:ok, metadata} ->
        Mix.shell().info([
          :green,
          "Amp compatibility check passed.",
          :reset,
          "\n",
          "CLI: ",
          metadata.program,
          "\n",
          "Version: ",
          metadata.version,
          "\n",
          "Required flags: ",
          Enum.join(metadata.required_flags, ", ")
        ])

      {:error, error} ->
        Mix.raise("""
        Amp compatibility check failed.

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
end
