defmodule Mix.Tasks.Amp.Compat do
  @moduledoc """
  Validate whether the locally installed Amp CLI is compatible with `amp_sdk` streaming mode.

      mix amp.compat
  """

  @shortdoc "Validate Amp CLI compatibility for streaming execution"

  use Mix.Task

  alias Jido.Amp.Compatibility

  @impl true
  def run(_args) do
    case Compatibility.status() do
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
end
