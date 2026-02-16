defmodule Jido.Amp.CompatibilityTest do
  use ExUnit.Case, async: true

  alias Jido.Amp.Compatibility
  alias Jido.Amp.Error.ConfigError
  alias Jido.Amp.Test.{StubCLI, StubCommand}

  setup do
    old_cli_module = Application.get_env(:jido_amp, :amp_cli_module)
    old_command_module = Application.get_env(:jido_amp, :amp_command_module)
    old_cli_resolve = Application.get_env(:jido_amp, :stub_cli_resolve)
    old_command_run = Application.get_env(:jido_amp, :stub_command_run)

    Application.put_env(:jido_amp, :amp_cli_module, StubCLI)
    Application.put_env(:jido_amp, :amp_command_module, StubCommand)

    on_exit(fn ->
      restore_env(:jido_amp, :amp_cli_module, old_cli_module)
      restore_env(:jido_amp, :amp_command_module, old_command_module)
      restore_env(:jido_amp, :stub_cli_resolve, old_cli_resolve)
      restore_env(:jido_amp, :stub_command_run, old_command_run)
    end)

    :ok
  end

  test "returns error when CLI is missing" do
    Application.put_env(:jido_amp, :stub_cli_resolve, fn -> {:error, :enoent} end)

    assert {:error, %ConfigError{key: :amp_cli}} = Compatibility.status()
    assert Compatibility.compatible?() == false
    assert {:error, %ConfigError{key: :amp_cli}} = Compatibility.check()
  end

  test "returns error when stream-json support is not present" do
    Application.put_env(:jido_amp, :stub_cli_resolve, fn -> {:ok, %{program: "/tmp/amp"}} end)

    Application.put_env(:jido_amp, :stub_command_run, fn
      ["--help"], _opts -> {:ok, "Usage: amp --execute"}
      _args, _opts -> {:ok, "ok"}
    end)

    assert {:error, %ConfigError{key: :amp_cli_streaming_compatibility}} = Compatibility.status()
    assert Compatibility.compatible?() == false
  end

  test "returns ok when required flags are present" do
    Application.put_env(:jido_amp, :stub_cli_resolve, fn -> {:ok, %{program: "/tmp/amp"}} end)

    Application.put_env(:jido_amp, :stub_command_run, fn
      ["--help"], _opts -> {:ok, "amp --execute --stream-json"}
      ["--version"], _opts -> {:ok, "9.9.9"}
      _args, _opts -> {:ok, "ok"}
    end)

    assert {:ok, status} = Compatibility.status()
    assert status.program == "/tmp/amp"
    assert status.version == "9.9.9"
    assert Compatibility.compatible?() == true
    assert Compatibility.check() == :ok
    assert Compatibility.assert_compatible!() == :ok
  end

  test "assert_compatible!/0 raises ConfigError on incompatibility" do
    Application.put_env(:jido_amp, :stub_cli_resolve, fn -> {:error, :enoent} end)

    assert_raise ConfigError, fn ->
      Compatibility.assert_compatible!()
    end
  end

  defp restore_env(app, key, nil), do: Application.delete_env(app, key)
  defp restore_env(app, key, value), do: Application.put_env(app, key, value)
end
