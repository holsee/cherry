defmodule CherryNew.MixProject do
  use Mix.Project

  @version "0.1.0-rc.3"
  @source_url "https://github.com/holsee/cherry"

  def project do
    [
      app: :cherry_new,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: false,
      deps: [{:ex_doc, "~> 0.34", only: :dev, runtime: false}],
      docs: [
        main: "readme",
        name: "cherry_new",
        logo: "../priv/themes/cherrybomb/assets/cherrybomb-mark.png",
        source_url: @source_url,
        source_ref: "v#{@version}",
        extras: ["README.md"]
      ],
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
