defmodule Cherry.MixProject do
  use Mix.Project

  @version "0.0.1"
  @source_url "https://github.com/holsee/cherry"

  def project do
    [
      app: :cherry,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      description:
        "A static site generator for hackers — a modern take on Octopress. " <>
          "Pre-release name claim; see the GitHub repo for the design and roadmap.",
      package: package(),
      deps: []
    ]
  end

  def application do
    [extra_applications: [:logger]]
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
