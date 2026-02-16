defmodule Jido.Amp.OptionsTest do
  use ExUnit.Case, async: true

  alias Jido.Amp.Options

  describe "new/1" do
    test "parses keyword options" do
      assert {:ok, %Options{} = options} =
               Options.new(mode: "safe", cwd: "/tmp/project", no_color: true)

      assert options.mode == "safe"
      assert options.cwd == "/tmp/project"
      assert options.no_color == true
    end

    test "returns error for invalid values" do
      assert {:error, _reason} = Options.new(mode: 123)
    end

    test "new!/1 raises for invalid values" do
      assert_raise ArgumentError, fn ->
        Options.new!(mode: 123)
      end
    end
  end

  describe "to_amp_options/1" do
    test "converts parsed options to AmpSdk.Types.Options struct" do
      assert {:ok, %AmpSdk.Types.Options{} = options} =
               Options.to_amp_options(%{mode: "safe", labels: ["ci"], thinking: true})

      assert options.mode == "safe"
      assert options.labels == ["ci"]
      assert options.thinking == true
      assert options.stream_timeout_ms > 0
      assert options.no_jetbrains == false
    end

    test "to_amp_options!/1 raises for invalid values" do
      assert_raise ArgumentError, fn ->
        Options.to_amp_options!(%{stream_timeout_ms: "bad"})
      end
    end
  end
end
