defmodule Mirage.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :mirage,
      compilers: Mix.compilers(),
      deps: deps(),
      elixir: "~> 1.7",
      rustler_crates: [mirage: []],
      start_permanent: Mix.env() == :prod,
      version: @version,
      dialyzer: dialyzer(),
      name: "Mirage",
      docs: [
        main: "Mirage",
        extras: ["README.md"]
      ]
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.6.0-rc.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:exblockhash,
       git: "https://github.com/joydrive/exblockhash.git", ref: "0290186", only: [:test]},
      {:rustler, "~> 0.25"}
    ]
  end
end
