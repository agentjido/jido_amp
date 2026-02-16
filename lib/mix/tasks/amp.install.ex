defmodule Mix.Tasks.Amp.Install do
  @moduledoc """
  Check for the Amp CLI and provide installation instructions.

      mix amp.install

  Verifies that the `amp` CLI binary is available. If not found,
  prints installation instructions.
  """

  @shortdoc "Check Amp CLI installation and provide setup instructions"

  use Mix.Task

  @impl true
  def run(_args) do
    case cli_module().resolve() do
      {:ok, spec} ->
        Mix.shell().info(["Amp CLI found: ", :green, spec.program, :reset])

      {:error, _} ->
        Mix.shell().info([
          :yellow,
          "Amp CLI not found.",
          :reset,
          "\n\n",
          "Install the Amp CLI using one of these methods:\n\n",
          "  npm install -g @sourcegraph/amp\n\n",
          "Or visit: https://ampcode.com for installation instructions.\n\n",
          "After installation, run this task again to verify:\n\n",
          "  mix amp.install\n"
        ])
    end
  end

  defp cli_module do
    Application.get_env(:jido_amp, :amp_cli_module, AmpSdk.CLI)
  end
end
