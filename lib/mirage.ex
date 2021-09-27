defmodule Mirage do
  alias Mirage.Image

  @doc """
  Resizes an image to a given dimensions.
  """
  @spec resize(Image.t(), integer(), integer()) :: Image.t()
  def resize(image, width, height) do
    Mirage.Native.resize(image.resource, width, height)
  end

  @doc """
  Overlays Image A over Image B
  """
  @spec overlay_image(Image.t(), Image.t(), keyword()) :: Image.t()
  def overlay_image(_image_a, _image_b, _options) do
    :todo
  end
end
