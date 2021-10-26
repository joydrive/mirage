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
  Loads an image from a `binary`.

  Returns the discovered format of the image on success.
  """
  @spec from_bytes(binary()) ::
          {:ok, format(), t()}
          | {:error, :invalid_image | :unsupported_image_format}
  def from_bytes(bytes) do
    Mirage.Native.from_bytes(bytes)
  end

  @doc """
  Reads an image from the filesystem at `path`.
  """
  @spec read(String.t()) ::
          {:ok, format(), t()}
          | {:error, File.posix() | :invalid_image | :unsupported_image_format}
  def read(path) do
    with {:ok, bytes} <- File.read(path) do
      from_bytes(bytes)
    end
  end

  @doc """
  Similar to `read/1` but raises `Mirage.ReadError` if an error occurs.
  """
  @spec read!(String.t()) :: {format(), t()} | no_return()
  def read!(path) do
    case read(path) do
      {:ok, format, image} ->
        {format, image}

      {:error, error} ->
        raise Mirage.ReadError,
          message: "Error while reading image from path '#{path}': '#{inspect(error)}'",
          path: path,
          error: error
    end
  end

  @doc """
  Creates a new empty image with the given width and height.

  ## Example

    iex> {:ok, _image} = Mirage.Image.empty(100, 100)

  """
  @spec empty(non_neg_integer(), non_neg_integer()) :: {:ok, t()}
  def empty(width, height) do
    Mirage.Native.empty(width, height)
  end

  @doc """
  Writes the image to the provided path. The format of the image is determined
  by the file extension in the path.
  """
  @spec write(t(), String.t()) :: :ok | {:error, String.t()}
  def write(image, path) do
    Mirage.Native.write(image, path)
  end

  @doc """
  Similar to `write/2` but raises `Mirage.WriteError` if an error occurs.
  """
  @spec write!(t(), String.t()) :: :ok | no_return()
  def write!(image, path) do
    case Mirage.Native.write(image, path) do
      :ok ->
        :ok

      {:error, error} ->
        raise Mirage.WriteError,
          message: "Error while writing image to path '#{path}': '#{inspect(error)}'",
          path: path,
          error: error
    end
  end
end
