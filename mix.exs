defmodule Microscope.Mixfile do
  use Mix.Project

  def project do
    [app: :microscope,
     version: "1.0.0",
     elixir: "> 1.3.2",
     description: "A simple static web server written in Elixir",
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :cowboy, :mime]]
  end

  defp package do
    [name: :microscope,
     maintainers: ["Dalgona"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/Dalgona/microscope"}]
  end

  defp deps do
    [{:cowboy, "~> 1.0"},
     {:mime, "~> 1.0"},
     {:credo, "~> 0.5.3", only: [:dev]},
     {:dialyxir, "~> 0.4.3", only: [:dev], runtime: false},
     {:ex_doc, "~> 0.14", only: [:dev]}]
  end
end
