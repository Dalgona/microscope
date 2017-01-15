defmodule Microscope.ValidationTest do
  use ExUnit.Case, async: true
  import Microscope.Validation

  describe "validate_index/1" do
    test "when true" do
      assert validate_index(true) == :ok
    end

    test "when false" do
      assert validate_index(false) == :ok
    end

    test "any other values" do
      assert catch_error(validate_index 666)
    end
  end

  describe "validate_callbacks/1" do
    test "an empty list" do
      assert validate_callbacks([]) == :ok
    end

    test "a list of atoms" do
      assert validate_callbacks([Module1, Module2]) == :ok
    end

    test "not a list of atoms" do
      assert catch_error(validate_callbacks [Module1, 666, Module2])
    end

    test "not even a list" do
      assert catch_error(validate_callbacks 666)
    end
  end

  describe "validate_base/1" do
    test "a string" do
      assert validate_base("/home/") == :ok
    end

    test "any other values" do
      assert catch_error(validate_base 666)
    end
  end

  describe "validate_port/1" do
    test "in range" do
      assert validate_port(1) == :ok
      assert validate_port(65_535) == :ok
      assert validate_port(32_768) == :ok
    end

    test "out of range" do
      assert catch_error(validate_port 0)
      assert catch_error(validate_port 65_536)
      assert catch_error(validate_port -100)
      assert catch_error(validate_port 1048576)
    end

    test "not even an integer" do
      assert catch_error(validate_port "666")
    end
  end

  describe "validate_webroot/2" do
    test "an existing directory" do
      assert validate_webroot("/tmp") == :ok
    end

    test "not a directory" do
      assert catch_error(validate_webroot <<6, 6, 6>>)
    end

    test "not even a string" do
      assert catch_error(validate_webroot 666)
    end
  end
end
