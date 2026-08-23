defmodule Cherry.MixProject do
  use Mix.Project

  @version "0.6.1"
  @source_url "https://github.com/holsee/cherry"

  def project do
    [
      app: :cherry,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      test_ignore_filters: [&String.starts_with?(&1, "test/fixtures/")],
      description: "A static site generator for hackers — a modern take on Octopress.",
      package: package(),
      deps: deps(),
      aliases: aliases(),
      docs: docs(),
      dialyzer: dialyzer(),
      releases: releases()
    ]
  end

  # The `mod:` entry boots the CLI dispatcher — standalone binary only
  # (CHERRY_RELEASE is set by the release workflow). Sites embedding
  # cherry as a dependency must never start an application.
  def application do
    if System.get_env("CHERRY_RELEASE") do
      [extra_applications: [:logger], mod: {Cherry.Binary, []}]
    else
      [extra_applications: [:logger]]
    end
  end

  def cli do
    [preferred_envs: [ci: :test, precommit: :test]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      {:bandit, "~> 1.12"},
      {:file_system, "~> 1.1"},
      {:lumis, "~> 0.1"},
      {:mdex, "~> 0.13"},
      {:nimble_options, "~> 1.1"},
      # HEEx templates (runtime-compiled, ADR 0002/0004): the engine lives
      # in phoenix_live_view; ~5MB of libs in the release, spike-measured.
      {:phoenix_live_view, "~> 1.1"},
      {:yaml_elixir, "~> 2.12"},
      {:burrito, "~> 1.6", only: [:dev, :prod], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:usage_rules, "~> 0.1", only: :dev, runtime: false}
    ]
  end

  # The standalone binary (ADR 0007): Burrito wraps the release into one
  # self-extracting executable per target. Native-runner matrix — each CI
  # runner builds only its own BURRITO_TARGET; no cross-compilation, so
  # the right precompiled Rust NIFs always ship.
  defp releases do
    [
      cherry: [
        applications: [cherry: :permanent],
        steps: release_steps(),
        burrito: [targets: burrito_targets()]
      ]
    ]
  end

  # Burrito's precompiled Linux ERTS is musl-libc, which can't load the
  # glibc rustler_precompiled NIFs (mdex, lumis) — and the musl NIF
  # variants still resolve the host's glibc libgcc_s and crash. The
  # release workflow sets CHERRY_CUSTOM_ERTS to the runner's own glibc
  # OTP so the Linux binary is built truly natively against glibc.
  defp burrito_targets do
    linux_erts =
      case System.get_env("CHERRY_CUSTOM_ERTS") do
        nil -> []
        path -> [custom_erts: path]
      end

    [
      linux_x86_64: [os: :linux, cpu: :x86_64] ++ linux_erts,
      linux_aarch64: [os: :linux, cpu: :aarch64] ++ linux_erts,
      macos_x86_64: [os: :darwin, cpu: :x86_64],
      macos_aarch64: [os: :darwin, cpu: :aarch64],
      windows_x86_64: [os: :windows, cpu: :x86_64]
    ]
  end

  # Gate on the env var, not Code.ensure_loaded?(Burrito): project config
  # is evaluated before deps compile on a fresh runner, so the module
  # check silently dropped the wrap step. The capture is only invoked
  # after compilation, when Burrito is loadable.
  defp release_steps do
    if System.get_env("CHERRY_RELEASE"), do: [:assemble, &Burrito.wrap/1], else: [:assemble]
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
        "test",
        "cmd --cd installer mix test"
      ]
    ]
  end

  # PLTs live in priv/plts (gitignored) so local runs and CI can cache them.
  defp dialyzer do
    [
      plt_add_apps: [:mix, :ex_unit, :eex],
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
      # The small CherryBomb mark; the large lockup lives at the top of
      # the README (absolute URL, so it renders on hexdocs and GitHub).
      logo: "priv/themes/cherrybomb/assets/cherrybomb-mark.png",
      # Bundle the large lockup into the docs so the README hero renders
      # self-contained on hexdocs; the same relative path works on GitHub.
      assets: %{"assets/docs" => "assets/docs"},
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md", "CHANGELOG.md"],
      groups_for_modules: [
        "Core API": [Cherry, Cherry.Build, Cherry.Build.Options, Cherry.Check, Cherry.Site],
        Content: [~r/^Cherry\.Content\./, ~r/^Cherry\.Collections/],
        "Portfolio & CV": [~r/^Cherry\.Portfolio/, ~r/^Cherry\.CV/],
        Themes: [~r/^Cherry\.Theme/],
        "SEO & Machine Surface": [~r/^Cherry\.SEO/, ~r/^Cherry\.Machine/, Cherry.StableJSON],
        Pipeline: [~r/^Cherry\.Pipeline/],
        "CLI & Commands": [~r/^Cherry\.CLI/, ~r/^Cherry\.Commands/, Cherry.Skill],
        "Serve & Upgrade": [~r/^Cherry\.Serve/, ~r/^Cherry\.Upgrade/, Cherry.Binary]
      ]
    ]
  end

  defp package do
    [
      licenses: ["MIT", "Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Site" => "https://cherrybomb.dev"
      },
      # priv/ is listed by subdirectory so local dialyzer PLT caches
      # (priv/plts) never ship in the package.
      files:
        ~w(lib priv/themes priv/serve priv/search mix.exs README.md LICENSE-MIT LICENSE-APACHE assets/LICENSE CHANGELOG.md)
    ]
  end
end
