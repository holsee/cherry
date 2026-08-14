defmodule Cherry.MixProject do
  use Mix.Project

  @version "0.1.0-dev"
  @source_url "https://github.com/holsee/cherry"

  def project do
    [
      app: :cherry,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: "A static site generator for hackers — a modern take on Octopress.",
      package: package(),
      deps: deps(),
      aliases: aliases(),
      docs: docs()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  def cli do
    [preferred_envs: [precommit: :test]]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:usage_rules, "~> 0.1", only: :dev, runtime: false}
    ]
  end

  # The single quality gate. CI runs exactly this and nothing else (AGENTS.md).
  defp aliases do
    [
      precommit: [
        "compile --warnings-as-errors",
        "format --check-formatted",
        "credo --strict",
        "cmd npm run check",
        "test"
      ]
    ]
  end

  defp docs do
    [
      main: "readme",
      name: "Cherry",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end

  defp package do
    [
      licenses: ["MIT", "Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Site" => "https://cherrybomb.dev"
      },
      files: ~w(lib mix.exs README.md LICENSE-MIT LICENSE-APACHE CHANGELOG.md)
    ]
  end
end
