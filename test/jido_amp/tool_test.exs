defmodule Jido.Amp.ToolTest do
  use ExUnit.Case, async: true
  doctest Jido.Amp.Tool

  import Jido.Amp.Test.Fixtures

  describe "new/1" do
    test "creates tool from valid attributes" do
      {:ok, tool} = Jido.Amp.Tool.new(valid_tool_spec())
      assert tool.name == "test_tool"
      assert tool.description == "A test tool"
      assert is_map(tool.input_schema)
    end

    test "coerces string keys to atoms" do
      {:ok, tool} = Jido.Amp.Tool.new(simple_tool_spec())
      assert tool.name == "simple"
    end

    test "returns error for missing required fields" do
      {:error, _reason} = Jido.Amp.Tool.new(%{"name" => "test"})
    end

    test "returns error for invalid input" do
      {:error, _reason} = Jido.Amp.Tool.new(nil)
    end

    test "sets default values" do
      {:ok, tool} = Jido.Amp.Tool.new(valid_tool_spec())
      assert tool.tags == []
    end
  end

  describe "new!/1" do
    test "creates tool and returns it" do
      tool = Jido.Amp.Tool.new!(valid_tool_spec())
      assert tool.name == "test_tool"
    end

    test "raises on invalid attributes" do
      assert_raise ArgumentError, ~r/Invalid tool/, fn ->
        Jido.Amp.Tool.new!(%{"name" => "test"})
      end
    end
  end

  describe "schema/0" do
    test "returns the Zoi schema" do
      schema = Jido.Amp.Tool.schema()
      assert is_map(schema)
    end
  end

  describe "validate/2" do
    test "returns ok for valid input map" do
      {:ok, tool} = Jido.Amp.Tool.new(valid_tool_spec())
      assert :ok == Jido.Amp.Tool.validate(tool, %{})
    end

    test "returns ok for input with parameters" do
      {:ok, tool} = Jido.Amp.Tool.new(valid_tool_spec())
      assert :ok == Jido.Amp.Tool.validate(tool, %{"param" => "value"})
    end

    test "returns error for non-map input" do
      {:ok, tool} = Jido.Amp.Tool.new(valid_tool_spec())
      {:error, message} = Jido.Amp.Tool.validate(tool, "not a map")
      assert message == "input must be a map"
    end

    test "returns error for nil input" do
      {:ok, tool} = Jido.Amp.Tool.new(valid_tool_spec())
      {:error, message} = Jido.Amp.Tool.validate(tool, nil)
      assert message == "input must be a map"
    end

    test "returns error for list input" do
      {:ok, tool} = Jido.Amp.Tool.new(valid_tool_spec())
      {:error, message} = Jido.Amp.Tool.validate(tool, [])
      assert message == "input must be a map"
    end
  end

  describe "merge_defaults/2" do
    test "merges timeout setting" do
      {:ok, tool} = Jido.Amp.Tool.new(valid_tool_spec())
      merged = Jido.Amp.Tool.merge_defaults(tool, %{timeout: 5000})
      assert merged.timeout == 5000
    end

    test "merges multiple settings" do
      {:ok, tool} = Jido.Amp.Tool.new(valid_tool_spec())

      merged =
        Jido.Amp.Tool.merge_defaults(tool, %{
          timeout: 5000,
          tags: ["important"]
        })

      assert merged.timeout == 5000
      assert merged.tags == ["important"]
    end

    test "preserves original tool immutability" do
      {:ok, original} = Jido.Amp.Tool.new(valid_tool_spec())
      _merged = Jido.Amp.Tool.merge_defaults(original, %{timeout: 5000})
      assert is_nil(original.timeout)
    end

    test "does not override immutable fields" do
      {:ok, tool} = Jido.Amp.Tool.new(valid_tool_spec())

      merged =
        Jido.Amp.Tool.merge_defaults(tool, %{
          name: "different_name",
          timeout: 5000
        })

      assert merged.name == "test_tool"
      assert merged.timeout == 5000
    end

    test "handles empty defaults map" do
      {:ok, tool} = Jido.Amp.Tool.new(valid_tool_spec())
      merged = Jido.Amp.Tool.merge_defaults(tool, %{})
      assert merged == tool
    end
  end
end
