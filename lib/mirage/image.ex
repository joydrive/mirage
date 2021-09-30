defmodule Mirage.Image do
  @moduledoc """
  Module for reading, writing, and creating images.
  """

  @typedoc """
  Represents a loaded image in working memory.
  """
  @type t :: %__MODULE__{
          byte_size: non_neg_integer(),
          height: non_neg_integer(),
          width: non_neg_integer()
        }

  @typedoc """
  The format of an image. This is also the list of supported formats that can be
  read and written with this library.
  """
  @type format ::
          :png
          | :jpeg
          | :gif
          | :webp
          | :pnm
          | :tiff
          | :tga
          | :dds
          | :bmp
          | :ico
          | :hdr
          | :farbfeld
          | :avif

  defstruct(
    byte_size: nil,
    height: nil,
    width: nil,
    resource: nil
  )

  @doc """
  Attempts to load an image from a `binary`.
  """
  @spec from_bytes(binary()) ::
          {:ok, format(), t()}
          | {:error, :invalid_image | :unsupported_image_format}
  def from_bytes(bytes) do
    Mirage.Native.from_bytes(bytes)
  end

  @doc """
  Creates a new empty image with the given width and height.
  """
  @spec empty(non_neg_integer(), non_neg_integer()) :: {:ok, t()}
  def empty(width, height) do
    Mirage.Native.empty(width, height)
  end

  @doc """
  Writes the image to the provided path. The format of the image is determined
  by the file extension in the path.
  """
  @spec write(Image.t(), String.t()) :: :ok | {:error, String.t()}
  def write(image, path) do
    Mirage.Native.write(image, path)
  end
end
