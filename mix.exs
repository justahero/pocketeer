defmodule Pocketeer.Mixfile do
  use Mix.Project

  def project do
    [ app: :pocketeer,
      version: "0.0.1",
      elixir: "~> 1.2",
      deps: deps,
      package: package
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpotion]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpotion, "~> 2.2.0"},
      {:poison, "~> 2.1.0"},
      {:mock, "~> 0.1.3", only: :test},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: [:dev, :test, :docs]}
    ]
  end

  defp package do
    [ files: [ "lib", "mix.exs", "README.md" ],
      maintainers: [ "Sebastian Ziebell" ]
    ]
  end
end
