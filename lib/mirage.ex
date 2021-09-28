defmodule Mirage do
  alias Mirage.Image

  @type filter_type ::
          :nearest
          | :triangle
          | :catmull_rom
          | :gaussian
          | :lanczos3

  @doc """
  Resizes an image to a given dimensions with the given filter.
  The filter defaults to `:triangle` which performs and looks decent.

  Returns `:out_of_memory` if the image is too large.
  Returns `:io_error` if the Erlang binary fails to write into memory.
  """
  @spec resize(Image.t(), integer(), integer(), filter_type()) ::
          {:ok, Image.t()} | {:error, :out_of_memory | :io_error}
  def resize(image, width, height, filter \\ :triangle) do
    Mirage.Native.resize(image.resource, width, height, filter)
  end

  @doc """
  Overlays the `top` image over the `bottom` image.
  """
  @spec overlay(Image.t(), Image.t(), non_neg_integer(), non_neg_integer()) :: Image.t()
  def overlay(bottom, top, x, y) do
    Mirage.Native.overlay(bottom, top, x, y)
  end

  @spec write(Image.t(), String.t()) :: :ok | :error
  def write(image, path) do
    Mirage.Native.write(image, path)
  end
end
