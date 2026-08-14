defmodule CherryNew.MixProject do
  use Mix.Project

  @version "0.1.0-rc.1"
  @source_url "https://github.com/holsee/cherry"

  def project do
    [
      app: :cherry_new,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: false,
      deps: [],
      description: "Cherry project generator — mix cherry.new PATH",
      package: [
        licenses: ["MIT", "Apache-2.0"],
        links: %{"GitHub" => @source_url}
      ]
    ]
  end

  def application do
    [extra_applications: [:eex]]
  end
end
