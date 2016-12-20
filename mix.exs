defmodule Microscope.Mixfile do
  use Mix.Project

  def project do
    [app: :microscope,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :cowboy, :mime]]
  end

  defp deps do
    [{:cowboy, "~> 1.0"},
     {:mime, "~> 1.0"},
     {:credo, "~> 0.5.3", only: [:dev]},
     {:dialyxir, "~> 0.4", only: [:dev], runtime: false}]
  end
end
