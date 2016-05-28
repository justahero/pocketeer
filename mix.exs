defmodule Pocketeer.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [ app: :pocketeer,
      name: "Pocketeer",
      version: @version,
      elixir: "~> 1.2",
      deps: deps,
      package: package,
      description: description,
      elixirc_paths: elixirc_paths(Mix.env),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpotion]]
  end

  def description do
    "An Elixir client for the Pocket API"
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

      {:bypass, "~> 0.5.1", only: :test},
      {:excoveralls, "~> 0.5.4", only: :test},

      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: [:dev, :test, :docs]}
    ]
  end

  defp package do
    [ files: [ "lib", "mix.exs", "README.md" ],
      maintainers: [ "Sebastian Ziebell" ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
