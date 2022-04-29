defmodule Mirage.WriteError do
  @moduledoc """
  Exception for errors encountered during image writes.
  """
  defexception message: nil, path: nil, error: nil
end
