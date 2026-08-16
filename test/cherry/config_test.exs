defmodule Cherry.ConfigTest do
  use ExUnit.Case, async: true

  @moduledoc """
  `cherry config` — the verb that makes the CLI loop closed. Without it,
  an agent can scaffold a theme but cannot activate it, because every
  route to `cherry.exs` runs through a text editor.
  """

  @moduletag :tmp_dir

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Commands.Config

  describe "reading" do
    test "prints every readable key", %{tmp_dir: tmp} do
      source = site(tmp)

      assert {:ok, %{config: config}} = run([], source)
      assert config["title"] == "Orchard"
      assert config["url"] == "https://orchard.example"
      assert config["base_path"] == "/"
      assert config["search"] == nil
    end

    test "prints one key", %{tmp_dir: tmp} do
      assert {:ok, %{key: "title", value: "Orchard"}} = run(["title"], site(tmp))
    end

    test "refuses a key that is not config", %{tmp_dir: tmp} do
      assert {:error, %Error{code: :unknown_key, exit: 2}} = run(["nonsense"], site(tmp))
    end
  end

  describe "writing" do
    test "replaces an existing value and reports what it was", %{tmp_dir: tmp} do
      source = site(tmp)

      assert {:ok, %{key: "title", value: "Grove", previous: "Orchard"}} =
               run(["title", "Grove"], source)

      assert {:ok, site} = Cherry.Site.load(source)
      assert site.title == "Grove"
    end

    test "adds a key the file does not have yet", %{tmp_dir: tmp} do
      source = site(tmp)

      assert {:ok, %{previous: nil}} = run(["search", "cherry"], source)
      assert {:ok, %{search: "cherry"}} = Cherry.Site.load(source)
    end

    test "leaves the rest of the file exactly as it was", %{tmp_dir: tmp} do
      source = site(tmp)
      path = Path.join(source, "cherry.exs")

      File.write!(
        path,
        "# a comment worth keeping\n[\n  title: \"Orchard\",\n  # about the url\n  url: \"https://orchard.example\"\n]\n"
      )

      assert {:ok, _data} = run(["title", "Grove"], source)

      content = File.read!(path)
      assert content =~ "# a comment worth keeping"
      assert content =~ "# about the url"
      assert content =~ ~s(title: "Grove")
    end

    test "rolls back a value the schema rejects", %{tmp_dir: tmp} do
      source = site(tmp)
      path = Path.join(source, "cherry.exs")
      before = File.read!(path)

      assert {:error, %Error{code: :invalid_value, exit: 2}} = run(["search", "algolia"], source)
      assert File.read!(path) == before
      assert {:ok, _site} = Cherry.Site.load(source)
    end

    test "refuses structured settings rather than reformatting them", %{tmp_dir: tmp} do
      assert {:error, %Error{code: :unknown_key}} = run(["nav", "Guides"], site(tmp))
    end
  end

  defp run(args, source) do
    Config.run(%Context{verb: "config", args: args, opts: [source: source]})
  end

  defp site(tmp) do
    source = Path.join(tmp, "site")
    File.mkdir_p!(Path.join(source, "content/posts"))

    File.write!(
      Path.join(source, "cherry.exs"),
      ~s([title: "Orchard", url: "https://orchard.example"])
    )

    source
  end
end
