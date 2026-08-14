defmodule Cherry.Commands.GenActionTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  @workflow ".github/workflows/pages.yml"

  @tag :tmp_dir
  test "writes a Pages workflow with CNAME for a custom domain", %{tmp_dir: tmp} do
    site(tmp, ~s|[title: "T", url: "https://cherrybomb.dev"]|)

    {code, output} = run(["gen.action", "--source", tmp])

    assert code == 0
    assert output =~ @workflow
    assert output =~ "CNAME: cherrybomb.dev"

    workflow = File.read!(Path.join(tmp, @workflow))
    assert workflow =~ "branches: [main]"
    assert workflow =~ "uses: holsee/cherry/action@develop"
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
