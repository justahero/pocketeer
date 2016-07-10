defmodule Pocketeer.Mixfile do
  use Mix.Project

  @version "0.1.2"
  @project_url "https://www.github.com/justahero/pocketeer"

  def project do
    [ app: :pocketeer,
      name: "Pocketeer",
      version: @version,
      elixir: "~> 1.2",
      description: description,
      deps: deps,
      package: package,
      source_url: @project_url,
      homepage_url: @project_url,
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod
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
      {:httpotion, "~> 3.0"},
      {:poison, "~> 2.1"},

      {:bypass, "~> 0.5", only: :test},
      {:excoveralls, "~> 0.5", only: :test},

      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: [:dev, :test, :docs]}
    ]
  end

  defp package do
    [ files: [ "lib", "mix.exs", "README.md", "LICENSE" ],
      maintainers: [ "Sebastian Ziebell" ],
      licenses: ["MIT"],
      links: %{"Github" => @project_url}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
