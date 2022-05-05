defmodule Mirage.ReadError do
  @moduledoc """
  Exception for errors encountered during image reads.
  """
  defexception message: nil, path: nil, error: nil
end
