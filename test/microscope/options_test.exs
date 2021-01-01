defmodule Microscope.OptionsTest do
  use ExUnit.Case, async: true
  import Microscope.Options

  setup do
    uniq = Base.url_encode64(:crypto.strong_rand_bytes(6))
    tmp_dir = Path.expand("microscope_test_" <> uniq, System.tmp_dir!())

    File.mkdir_p!(tmp_dir)
    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    {:ok, tmp_dir: tmp_dir}
  end

  describe "parse/1" do
    test "can return a default map" do
      expected = %{
        base: "/",
        callbacks: [],
        extra_routes: [],
        index: false,
        port: 8080,
        webroot: "/",
        gen_server_options: []
      }

      assert expected === parse(webroot: "/")
    end

    test "returns a map after all checks has passed", %{tmp_dir: tmp_dir} do
      options = [
        base: "/test_base/",
        callbacks: [A, B],
        extra_routes: [],
        index: true,
        port: 5757,
        webroot: tmp_dir,
        gen_server_options: [name: Foo]
      ]

      expected = Map.new(options)

      assert expected === parse(options)
    end

    test "raises an ArgumentError with error details in the message" do
      options = [
        base: 3,
        callbacks: {:foo, :bar},
        extra_routes: nil,
        index: 0,
        port: 999_999,
        webroot: 3,
        gen_server_options: %{name: Foo}
      ]

      message = Exception.message(assert_raise(ArgumentError, fn -> parse(options) end))

      options
      |> Keyword.keys()
      |> Enum.each(&assert String.contains?(message, to_string(&1)))
    end
  end
end
