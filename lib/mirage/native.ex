defmodule Mirage.Native do
  use Rustler, otp_app: :mirage

  def from_bytes(_path), do: :erlang.nif_error(:nif_not_loaded)
  def resize(_resource, _width, _height, _filter), do: :erlang.nif_error(:nif_not_loaded)
  def resize_to_fill(_image, _width, _height, _filter), do: :erlang.nif_error(:nif_not_loaded)
  def overlay(_bottom, _top, _x, _y), do: :erlang.nif_error(:nif_not_loaded)
  def write(_image, _path), do: :erlang.nif_error(:nif_not_loaded)
  def empty(_width, _height), do: :erlang.nif_error(:nif_not_loaded)
end
