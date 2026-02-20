defmodule Mix.Tasks.AmpTasksTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias Jido.Amp.Test.{StubCLI, StubCommand, StubInstaller}
  alias Mix.Tasks.Amp.{Compat, Install}

  setup do
    old_cli_module = Application.get_env(:jido_amp, :amp_cli_module)
    old_command_module = Application.get_env(:jido_amp, :amp_command_module)
    old_install_module = Application.get_env(:jido_amp, :amp_install_module)
    old_cli_resolve = Application.get_env(:jido_amp, :stub_cli_resolve)
    old_command_run = Application.get_env(:jido_amp, :stub_command_run)
    old_ensure_installed = Application.get_env(:jido_amp, :stub_ensure_installed)

    Application.put_env(:jido_amp, :amp_cli_module, StubCLI)
    Application.put_env(:jido_amp, :amp_command_module, StubCommand)
    Application.put_env(:jido_amp, :amp_install_module, StubInstaller)

    Application.put_env(:jido_amp, :stub_cli_resolve, fn -> {:ok, %{program: "/tmp/amp"}} end)

    Application.put_env(:jido_amp, :stub_command_run, fn _args, _opts ->
      {:ok, "ok"}
    end)

    Application.put_env(:jido_amp, :stub_ensure_installed, fn _opts ->
      {:ok, %{status: :already_installed, program: "/tmp/amp"}}
    end)

    on_exit(fn ->
      restore_env(:jido_amp, :amp_cli_module, old_cli_module)
      restore_env(:jido_amp, :amp_command_module, old_command_module)
      restore_env(:jido_amp, :amp_install_module, old_install_module)
      restore_env(:jido_amp, :stub_cli_resolve, old_cli_resolve)
      restore_env(:jido_amp, :stub_command_run, old_command_run)
      restore_env(:jido_amp, :stub_ensure_installed, old_ensure_installed)
    end)

    :ok
  end

  describe "mix amp.compat" do
    test "prints success status when compatible" do
      Application.put_env(:jido_amp, :stub_command_run, fn
        ["--help"], _opts -> {:ok, "amp --execute --stream-json"}
        ["--version"], _opts -> {:ok, "2.0.0"}
        _args, _opts -> {:ok, "ok"}
      end)

      Mix.Task.reenable("amp.compat")

      output =
        capture_io(fn ->
          Compat.run([])
        end)

      assert output =~ "Amp compatibility check passed"
      assert output =~ "2.0.0"
    end

    test "passes --path override to compatibility checks" do
      Application.put_env(:jido_amp, :stub_cli_resolve, fn ->
        assert System.get_env("AMP_CLI_PATH") == "/custom/amp"
        {:ok, %{program: "/custom/amp"}}
      end)

      Application.put_env(:jido_amp, :stub_command_run, fn
        ["--help"], _opts -> {:ok, "amp --execute --stream-json"}
        ["--version"], _opts -> {:ok, "2.0.0"}
        _args, _opts -> {:ok, "ok"}
      end)

      Mix.Task.reenable("amp.compat")
      output = capture_io(fn -> Compat.run(["--path", "/custom/amp"]) end)

      assert output =~ "Amp compatibility check passed"
      assert output =~ "/custom/amp"
    end

    test "raises on compatibility failure" do
      Application.put_env(:jido_amp, :stub_cli_resolve, fn -> {:error, :enoent} end)

      Mix.Task.reenable("amp.compat")

      assert_raise Mix.Error, ~r/Amp compatibility check failed/, fn ->
        capture_io(fn ->
          Compat.run([])
        end)
      end
    end
  end

  describe "mix amp.install" do
    test "prints CLI found message when amp exists" do
      Mix.Task.reenable("amp.install")

      output =
        capture_io(fn ->
          Install.run([])
        end)

      assert output =~ "Amp CLI found"
      assert output =~ "/tmp/amp"
    end

    test "installs amp when missing" do
      Application.put_env(:jido_amp, :stub_ensure_installed, fn _opts ->
        {:ok, %{status: :installed, program: "/tmp/amp", install_prefix: "/tmp"}}
      end)

      Mix.Task.reenable("amp.install")

      output =
        capture_io(fn ->
          Install.run([])
        end)

      assert output =~ "Amp CLI installed"
      assert output =~ "/tmp/amp"
    end

    test "passes --path override to installer module" do
      Application.put_env(:jido_amp, :stub_ensure_installed, fn opts ->
        send(self(), {:ensure_installed_opts, opts})
        {:ok, %{status: :already_installed, program: "/tmp/amp"}}
      end)

      Mix.Task.reenable("amp.install")
      _ = capture_io(fn -> Install.run(["--path", "/custom/amp"]) end)
      assert_receive {:ensure_installed_opts, opts}
      assert opts[:amp_cli_path] == "/custom/amp"
    end

    test "raises when installer fails" do
      Application.put_env(:jido_amp, :stub_ensure_installed, fn _opts ->
        {:error, Jido.Amp.Error.config_error("install failed", %{key: :amp_cli_install_failed})}
      end)

      Mix.Task.reenable("amp.install")

      assert_raise Mix.Error, ~r/Amp install failed/, fn ->
        capture_io(fn ->
          Install.run([])
        end)
      end
    end
  end

  defp restore_env(app, key, nil), do: Application.delete_env(app, key)
  defp restore_env(app, key, value), do: Application.put_env(app, key, value)
end
