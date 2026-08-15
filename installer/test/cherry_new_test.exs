defmodule CherryNewTest do
  use ExUnit.Case, async: true

  @moduletag :tmp_dir

  test "scaffolds a complete agent-ready site", %{tmp_dir: tmp} do
    site = Path.join(tmp, "my_orchard")

    output =
      ExUnit.CaptureIO.capture_io(fn ->
        Mix.Tasks.Cherry.New.run([site, "--cherry-path", "/checkout/cherry"])
      end)

    assert output =~ "creating AGENTS.md"
    assert output =~ "mix deps.get"

    mix_exs = File.read!(Path.join(site, "mix.exs"))
    assert mix_exs =~ "app: :my_orchard"
    assert mix_exs =~ "defmodule MyOrchard.MixProject"
    assert mix_exs =~ ~s({:cherry, path: "/checkout/cherry"})

    # Without this config the mdex_native NIF ships without Lumis and any
    # code block crashes the consumer's build.
    assert File.read!(Path.join(site, "config/config.exs")) =~
             "config :mdex_native, syntax_highlighter: :lumis"

    cherry_exs = File.read!(Path.join(site, "cherry.exs"))
    assert cherry_exs =~ ~s(title: "My Orchard")
    {config, _bindings} = Code.eval_string(cherry_exs)
    assert Keyword.fetch!(config, :url) == "https://example.com"

    agents = File.read!(Path.join(site, "AGENTS.md"))
    assert agents =~ "mix cherry.schema posts --json"
    assert agents =~ "mix cherry.check --strict --json"
    assert agents =~ "Never edit `_site/`"

    skill = File.read!(Path.join(site, ".claude/skills/publish/SKILL.md"))
    assert skill =~ "name: publish"
    assert skill =~ "mix cherry.publish"

    today = Date.to_iso8601(Date.utc_today())
    post = File.read!(Path.join(site, "content/posts/#{today}-hello-cherry.md"))
    assert post =~ "title: Hello, Cherry"
    assert post =~ "description:"

    assert File.exists?(Path.join(site, "content/pages/index.md"))
    assert File.exists?(Path.join(site, "content/pages/about.md"))
    assert File.exists?(Path.join(site, ".gitignore"))
    assert File.exists?(Path.join(site, "static/images/.gitkeep"))
  end

  test "defaults the cherry dep to the matching hex release", %{tmp_dir: tmp} do
    site = Path.join(tmp, "plain")
    ExUnit.CaptureIO.capture_io(fn -> Mix.Tasks.Cherry.New.run([site]) end)

    version = Mix.Project.config()[:version]
    mix_exs = File.read!(Path.join(site, "mix.exs"))
    assert mix_exs =~ ~s[{:cherry, "~> #{version}"}]
    refute mix_exs =~ "github:"
  end

  test "refuses a non-empty target", %{tmp_dir: tmp} do
    site = Path.join(tmp, "taken")
    File.mkdir_p!(site)
    File.write!(Path.join(site, "keep.txt"), "x")

    assert_raise Mix.Error, ~r/not empty/, fn ->
      Mix.Tasks.Cherry.New.run([site])
    end
  end

  test "rejects names that cannot become an app atom", %{tmp_dir: tmp} do
    assert_raise Mix.Error, ~r/app name/, fn ->
      Mix.Tasks.Cherry.New.run([Path.join(tmp, "123")])
    end
  end

  test "requires a path argument" do
    assert_raise Mix.Error, ~r/usage/, fn ->
      Mix.Tasks.Cherry.New.run([])
    end
  end
end
