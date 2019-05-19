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
        webroot: "/"
      }

      assert expected === parse(webroot: "/")
    end

    test "returns a map after all checks has passed", %{tmp_dir: tmp_dir} do
      expected = %{
        base: "/test_base/",
        callbacks: [A, B],
        extra_routes: [],
        index: true,
        port: 5757,
        webroot: tmp_dir
      }

      assert expected ===
               parse(
                 base: "/test_base/",
                 callbacks: [A, B],
                 extra_routes: [],
                 index: true,
                 port: 5757,
                 webroot: tmp_dir
               )
    end

    test "raises an ArgumentError with error details in the message" do
      error =
        assert_raise(ArgumentError, fn ->
          parse(
            base: 3,
            callbacks: {:foo, :bar},
            extra_routes: nil,
            index: 0,
            port: 999_999,
            webroot: 3
          )
        end)

      message = Exception.message(error)

      Enum.each(~w(base callbacks extra_routes index port webroot), fn k ->
        String.contains?(message, k)
      end)
    end
  end
end
