defmodule Microscope.Validation do
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

  @spec validate_port(term) :: :ok | no_return

  def validate_port(port) when is_integer(port) do
    if port < 1 or port > 0xFFFF do
      raise ArgumentError, "`port' value out of range"
    else
      :ok
    end
  end

  def validate_port(x) do
    raise ArgumentError, "`port' expects an integer value, got #{inspect x}"
  end

  @spec validate_base(term) :: :ok | no_return

  def validate_base(base) when is_binary(base), do: :ok

  def validate_base(x),
    do: raise ArgumentError, "`base' expects a string, got #{inspect x}"

  @spec validate_callbacks([module]) :: :ok | no_return

  def validate_callbacks([]), do: :ok

  def validate_callbacks(cb_mods) do
    case Enum.reject cb_mods, &is_atom/1 do
      [] -> :ok
      _ -> raise ArgumentError,
        "`callbacks' expects a list of modules, got #{inspect cb_mods}"
    end
  end

  @spec validate_index(term) :: :ok | no_return

  def validate_index(index) when is_boolean(index), do: :ok

  def validate_index(x),
    do: raise ArgumentError, "`index' expects a boolean, got #{inspect x}"
end
