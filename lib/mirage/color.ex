defmodule Mirage.Color do
  @moduledoc """
  Represents an RGBA color using floating point values per channel.

  r: red
  g: green
  b: blue
  a: alpha with 0.0 being invisible and 1.0 being opaque.
  """

  @type t :: %__MODULE__{
          r: float(),
          g: float(),
          b: float(),
          a: float()
        }

  defstruct(
    r: 1.0,
    g: 1.0,
    b: 1.0,
    a: 1.0
  )

  @spec white :: t()
  def white, do: %Mirage.Color{r: 1.0, g: 1.0, b: 1.0, a: 1.0}

  @spec black :: t()
  def black, do: %Mirage.Color{r: 0.0, g: 0.0, b: 0.0, a: 1.0}

  @spec red :: t()
  def red, do: %Mirage.Color{r: 1.0, g: 0.0, b: 0.0, a: 1.0}

  @spec green :: t()
  def green, do: %Mirage.Color{r: 0.0, g: 1.0, b: 0.0, a: 1.0}

  @spec blue :: t()
  def blue, do: %Mirage.Color{r: 0.0, g: 0.0, b: 1.0, a: 1.0}

  @spec transparent :: t()
  def transparent, do: %Mirage.Color{r: 0.0, g: 0.0, b: 0.0, a: 0.0}
end
