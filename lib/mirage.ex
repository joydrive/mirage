defmodule Mirage do
  @moduledoc """
  This top level module is for transforming images.

  For reading and writing images, see the `Mirage.Image` module.
  """

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
  @spec resize(Image.t(), integer(), integer(), filter_type()) :: Image.t()
  def resize(image, width, height, filter \\ :triangle) do
    Mirage.Native.resize(image.resource, width, height, filter)
  end

  @doc """
  Resize this image using the specified filter algorithm defaults to
  `:triangle`. The image’s aspect ratio is preserved. The image is scaled to the
  maximum possible size that fits within the larger (relative to aspect ratio)
  of the bounds specified by nwidth and nheight, then cropped to fit within the
  other bound.
  """
  @spec resize_to_fill(Image.t(), integer(), integer(), filter_type()) :: Image.t()
  def resize_to_fill(image, new_width, new_height, filter \\ :triangle) do
    Mirage.Native.resize_to_fill(image.resource, new_width, new_height, filter)
  end

  @doc """
  Overlays the `top` image over the `bottom` image.
  """
  @spec overlay(Image.t(), Image.t(), non_neg_integer(), non_neg_integer()) :: Image.t()
  def overlay(bottom, top, x \\ 0, y \\ 0) do
    Mirage.Native.overlay(bottom, top, x, y)
  end
end
