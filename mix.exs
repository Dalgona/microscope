defmodule Microscope.Mixfile do
  use Mix.Project

  def project do
    [
      app: :microscope,
      version: "1.1.0",
      elixir: "~> 1.6",
      description: "A simple static web server written in Elixir",
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [applications: [:logger, :cowboy, :mime]]
  end

  defp package do
    [
      name: :microscope,
      maintainers: ["Dalgona"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Dalgona/microscope"}
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.6.1"},
      {:mime, "~> 1.3"},
      {:credo, "~> 1.0", only: [:dev]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "0.18.4", only: [:dev]}
    ]
  end
end
