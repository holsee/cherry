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
      docs: docs(),
      dialyzer: dialyzer()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  def cli do
    [preferred_envs: [ci: :test, precommit: :test]]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:usage_rules, "~> 0.1", only: :dev, runtime: false}
    ]
  end

  # The single quality gate. CI runs exactly this and nothing else (AGENTS.md).
  # `mix ci` is the same gate under the name you reach for before pushing.
  defp aliases do
    [
      ci: ["precommit"],
      precommit: [
        "compile --warnings-as-errors",
        "format --check-formatted",
        "credo --strict",
        "dialyzer",
        &check_assets/1,
        "test"
      ]
    ]
  end

  # PLTs live in priv/plts (gitignored) so local runs and CI can cache them.
  defp dialyzer do
    [
      plt_add_apps: [:mix],
      plt_local_path: "priv/plts",
      plt_core_path: "priv/plts"
    ]
  end

  # Runs through the OS shell: on Windows, npm is npm.cmd, which OTP refuses
  # to spawn directly (so `mix cmd npm` fails there).
  defp check_assets(_args) do
    {output, status} = System.shell("npm run check", stderr_to_stdout: true)
    IO.write(output)
    if status != 0, do: Mix.raise("npm run check failed (exit #{status})")
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
