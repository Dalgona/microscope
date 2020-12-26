defmodule Microscope.Mixfile do
  use Mix.Project

  def project do
    [
      app: :microscope,
      version: "1.3.0",
      elixir: "~> 1.11",
      description: "A simple static web server written in Elixir",
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  def application do
    [extra_applications: [:eex]]
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
      {:cowboy, "~> 2.8"},
      {:mime, "~> 1.5"},
      {:credo, "~> 1.5", only: [:dev]},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "0.23.0", only: [:dev]}
    ]
  end
end
