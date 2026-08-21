defmodule Cherry.Commands.GenActionTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  @workflow ".github/workflows/pages.yml"
  @cloudflare_workflow ".github/workflows/cloudflare.yml"

  @tag :tmp_dir
  test "writes a Pages workflow with CNAME for a custom domain", %{tmp_dir: tmp} do
    site(tmp, ~s|[title: "T", url: "https://cherrybomb.dev"]|)

    {code, output} = run(["gen.action", "--source", tmp])

    assert code == 0
    assert output =~ @workflow
    assert output =~ "CNAME: cherrybomb.dev"

    workflow = File.read!(Path.join(tmp, @workflow))
    assert workflow =~ "branches: [main]"
    version = to_string(Application.spec(:cherry, :vsn))
    assert workflow =~ "uses: holsee/cherry/action@v#{version}"
    refute workflow =~ "action@develop"
    assert workflow =~ "touch _site/.nojekyll"
    assert workflow =~ ~s|echo "cherrybomb.dev" > _site/CNAME|
    assert workflow =~ "actions/upload-pages-artifact"
    assert workflow =~ "actions/deploy-pages"
  end

  @tag :tmp_dir
  test "user-pages and project-pages sites carry no CNAME", %{tmp_dir: tmp} do
    site(tmp, ~s|[title: "T", url: "https://holsee.github.io"]|)
    {0, _output} = run(["gen.action", "--source", tmp])
    refute File.read!(Path.join(tmp, @workflow)) =~ "CNAME"

    subpath = Path.join(tmp, "subpath")
    site(subpath, ~s|[title: "T", url: "https://cherrybomb.dev", base_path: "repo"]|)
    {0, _output} = run(["gen.action", "--source", subpath])
    refute File.read!(Path.join(subpath, @workflow)) =~ "CNAME"
  end

  @tag :tmp_dir
  test "--branch changes the trigger; --json reports the path", %{tmp_dir: tmp} do
    site(tmp, ~s|[title: "T", url: "https://t.example"]|)

    {0, output} = run(["gen.action", "--source", tmp, "--branch", "develop", "--json"])

    assert %{"ok" => true, "data" => data} = JSON.decode!(output)
    assert data["host"] == "github"
    assert data["path"] == @workflow
    assert data["branch"] == "develop"
    assert File.read!(Path.join(tmp, @workflow)) =~ "branches: [develop]"
  end

  @tag :tmp_dir
  test "refuses to overwrite without --force", %{tmp_dir: tmp} do
    site(tmp, ~s|[title: "T", url: "https://t.example"]|)

    {0, _output} = run(["gen.action", "--source", tmp])
    File.write!(Path.join(tmp, @workflow), "hands off")

    {code, stderr} = run_stderr(["gen.action", "--source", tmp])
    assert code == 1
    assert stderr =~ "already exists"
    assert File.read!(Path.join(tmp, @workflow)) == "hands off"

    {0, _output} = run(["gen.action", "--source", tmp, "--force"])
    assert File.read!(Path.join(tmp, @workflow)) =~ "Deploy to GitHub Pages"
  end

  @tag :tmp_dir
  test "a directory without cherry.exs is refused", %{tmp_dir: tmp} do
    {code, stderr} = run_stderr(["gen.action", "--source", tmp])
    assert code == 1
    assert stderr =~ "no cherry.exs found"
  end

  @tag :tmp_dir
  test "--host cloudflare writes a wrangler config and a deploy workflow", %{tmp_dir: tmp} do
    site(tmp, ~s|[title: "Cherry Bomb!", url: "https://cherrybomb.dev"]|)

    {code, output} = run(["gen.action", "--source", tmp, "--host", "cloudflare"])

    assert code == 0
    assert output =~ @cloudflare_workflow
    assert output =~ "wrangler.jsonc"
    assert output =~ "worker: cherry-bomb"

    config = File.read!(Path.join(tmp, "wrangler.jsonc"))
    assert config =~ ~s|"name": "cherry-bomb"|
    assert config =~ ~s|"directory": "./_site"|
    assert config =~ ~s|"not_found_handling": "404-page"|
    assert config =~ ~r/"compatibility_date": "\d{4}-\d{2}-\d{2}"/
    refute config =~ ~s|"main"|

    workflow = File.read!(Path.join(tmp, @cloudflare_workflow))
    assert workflow =~ "branches: [main]"
    version = to_string(Application.spec(:cherry, :vsn))
    assert workflow =~ "uses: holsee/cherry/action@v#{version}"
    refute workflow =~ "action@develop"
    assert workflow =~ "uses: cloudflare/wrangler-action@v4"
    assert workflow =~ "secrets.CLOUDFLARE_API_TOKEN"
    assert workflow =~ "secrets.CLOUDFLARE_ACCOUNT_ID"
    refute workflow =~ "CNAME"
    refute workflow =~ ".nojekyll"
    refute workflow =~ "deploy-pages"
  end

  @tag :tmp_dir
  test "--name overrides the worker name; --json reports both files", %{tmp_dir: tmp} do
    site(tmp, ~s|[title: "T", url: "https://t.example"]|)

    argv = ["gen.action", "--source", tmp, "--host", "cloudflare", "--name", "my-site", "--json"]
    {0, output} = run(argv)

    assert %{"ok" => true, "data" => data} = JSON.decode!(output)
    assert data["host"] == "cloudflare"
    assert data["path"] == @cloudflare_workflow
    assert data["config"] == "wrangler.jsonc"
    assert data["name"] == "my-site"
    assert data["branch"] == "main"
    assert File.read!(Path.join(tmp, "wrangler.jsonc")) =~ ~s|"name": "my-site"|
  end

  @tag :tmp_dir
  test "an existing wrangler.jsonc is refused without --force", %{tmp_dir: tmp} do
    site(tmp, ~s|[title: "T", url: "https://t.example"]|)
    File.write!(Path.join(tmp, "wrangler.jsonc"), "hands off")

    {code, stderr} = run_stderr(["gen.action", "--source", tmp, "--host", "cloudflare"])
    assert code == 1
    assert stderr =~ "wrangler.jsonc already exists"
    assert File.read!(Path.join(tmp, "wrangler.jsonc")) == "hands off"
    refute File.exists?(Path.join(tmp, @cloudflare_workflow))

    {0, _output} = run(["gen.action", "--source", tmp, "--host", "cloudflare", "--force"])
    assert File.read!(Path.join(tmp, "wrangler.jsonc")) =~ "not_found_handling"
  end

  @tag :tmp_dir
  test "an unknown --host is a usage error", %{tmp_dir: tmp} do
    site(tmp, ~s|[title: "T", url: "https://t.example"]|)

    {code, stderr} = run_stderr(["gen.action", "--source", tmp, "--host", "netlify"])
    assert code == 2
    assert stderr =~ "expected github or cloudflare"
    refute File.exists?(Path.join(tmp, "wrangler.jsonc"))
  end

  defp site(dir, config) do
    File.mkdir_p!(dir)
    File.write!(Path.join(dir, "cherry.exs"), config)
  end

  defp run(argv) do
    with_io(fn -> Cherry.CLI.run(argv) end)
  end

  defp run_stderr(argv) do
    holder = self()
    stderr = capture_io(:stderr, fn -> send(holder, {:code, Cherry.CLI.run(argv)}) end)
    assert_receive {:code, code}
    {code, stderr}
  end
end
