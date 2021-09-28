defmodule Mirage.MixProject do
  use Mix.Project

  def project do
    [
      app: :mirage,
      compilers: Mix.compilers(),
      deps: deps(),
      elixir: "~> 1.7",
      rustler_crates: [mirage: []],
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.22"},
      {:exblockhash,
       git: "https://github.com/joydrive/exblockhash.git", ref: "43a9d35", only: [:test]}
    ]
  end
end
