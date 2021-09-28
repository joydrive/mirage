defmodule Mirage.Image do
  @type t :: %__MODULE__{}

  defstruct byte_size: nil,
            format: nil,
            height: nil,
            width: nil,
            resource: nil

  @doc """
  Loads an image from Erlang bytes.
  """
  @spec from_bytes(binary()) ::
          {:ok, t()}
          | {:error, :badarg}
          | {:error, :unsupported_image_format}
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
end
