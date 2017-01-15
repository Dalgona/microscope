defmodule Microscope.Validation do
  @moduledoc """
  Provides functions for validating arguments or options to Microscope.
  """

  @doc """
  Checks if the `webroot` argument is valid.

  Returns `:ok` if `webroot` is the path to an existing directory.

  Raises `ArgumentError` if `webroot` is not a directory, or `webroot` is not
  a string value.
  """
  @spec validate_webroot(term) :: :ok | no_return

  def validate_webroot(webroot) when is_binary(webroot) do
    if not File.dir? webroot do
      raise ArgumentError, "`#{webroot}' is not a directory"
    else
      :ok
    end
  end

  def validate_webroot(x) do
    raise ArgumentError, "`webroot' expects a string, got #{inspect x}"
  end

  @doc """
  Checks if the `port` option is valid.

  Returns `:ok` if `port` is a positive integer less than 65536.

  Raises `ArgumentError` if `port` is not an integer, or the value is out of
  the acceptable range.
  """
  @spec validate_port(term) :: :ok | no_return

  def validate_port(port)
    when is_integer(port) and port > 0 and port < 0x10000,
    do: :ok

  def validate_port(port) when is_integer(port),
    do: raise ArgumentError, "`port' value out of range"

  def validate_port(x),
    do: raise ArgumentError, "`port' expects an integer, got #{inspect x}"

  @doc """
  Checks if the `base` option is valid.

  Returns `:ok` if `base` is a string.

  Raises `ArgumentError` otherwise.
  """
  @spec validate_base(term) :: :ok | no_return

  def validate_base(base) when is_binary(base), do: :ok

  def validate_base(x),
    do: raise ArgumentError, "`base' expects a string, got #{inspect x}"

  @doc """
  Checks if the `callbacks` option is valid.

  Returns `:ok` if `callbacks` is a list of atoms.

  Raises `ArgumentError` if the list contains non-atom values, or `callbacks`
  is not a list.
  """
  @spec validate_callbacks(term) :: :ok | no_return

  def validate_callbacks([]), do: :ok

  def validate_callbacks(cb_mods) when is_list(cb_mods) do
    case Enum.reject cb_mods, &is_atom/1 do
      [] -> :ok
      _ -> raise ArgumentError,
        "`callbacks' expects a list of modules, got #{inspect cb_mods}"
    end
  end

  def validate_callbacks(x), do: raise ArgumentError,
    "`callbacks` expects a list of modules, got #{inspect x}"

  @doc """
  Checks if the `index` option is valid.

  Returns `:ok` if `index` is a boolean value.

  Raises `ArgumentError` otherwise.
  """
  @spec validate_index(term) :: :ok | no_return

  def validate_index(index) when is_boolean(index), do: :ok

  def validate_index(x),
    do: raise ArgumentError, "`index' expects a boolean, got #{inspect x}"
end
