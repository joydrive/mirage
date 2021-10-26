# Mirage

> Image manipulation library for Elixir.

This library provides a [Rust] implemented [NIF] which currently supports
resizing and compositing images.

## Installation

Because this library is partially implemented in [Rust], you will need to have
the Rust toolchain installed on your system.

### Install Rust

```bash
curl https://sh.rustup.rs -sSf | sh
```

### Add package to your mix.exs

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mirage` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mirage, "~> 0.1.0"}
  ]
end
```

## Resizing Example

```elixir
{_, image} = Mirage.Image.read!("input.jpg")

image
|> Mirage.resize_to_fill(100, 100)
|> Mirage.Image.write!("output.png")
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/mirage](https://hexdocs.pm/mirage).

[rust]: https://www.rust-lang.org/
[nif]: http://erlang.org/doc/man/erl_nif.html
