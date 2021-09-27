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
end
