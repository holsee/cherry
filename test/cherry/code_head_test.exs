defmodule Cherry.CodeHeadTest do
  use ExUnit.Case, async: true

  alias Cherry.Build
  alias Cherry.Content.CodeHead
  alias Cherry.Content.Document
  alias Cherry.Pipeline.Stages.Transform
  alias Cherry.Site

  describe "parse/1" do
    test "language alone" do
      assert CodeHead.parse("elixir") == {"elixir", nil}
    end

    test "language with a title" do
      assert CodeHead.parse(~s(elixir title="lib/foo.ex")) == {"elixir", "lib/foo.ex"}
    end

    test "title alone — the first token is not mistaken for a language" do
      assert CodeHead.parse(~s(title="notes.txt")) == {nil, "notes.txt"}
    end

    test "bare fence yields neither" do
      assert CodeHead.parse("") == {nil, nil}
      assert CodeHead.parse(nil) == {nil, nil}
    end

    test "an empty title counts as absent" do
      assert CodeHead.parse(~s(sh title="")) == {"sh", nil}
    end
  end

  describe "wrap/3" do
    test "renders icon, language, and title" do
      html = CodeHead.wrap("<pre>x</pre>", "elixir", "lib/foo.ex")

      assert html =~ ~s(<figure class="code-block">)
      assert html =~ ~s(<figcaption class="code-head">)
      assert html =~ ~s(code-icon--elixir)
      assert html =~ ~s(<span class="code-lang">elixir</span>)
      assert html =~ ~s(<span class="code-title">lib/foo.ex</span>)
      assert String.ends_with?(html, "<pre>x</pre></figure>")
    end

    test "language aliases map to their editor glyphs" do
      assert CodeHead.wrap("<pre/>", "sh", nil) =~ "code-icon--shell"
      assert CodeHead.wrap("<pre/>", "heex", nil) =~ "code-icon--phoenix"
      assert CodeHead.wrap("<pre/>", "yml", nil) =~ "code-icon--yaml"
      assert CodeHead.wrap("<pre/>", "prompt", nil) =~ "code-icon--prompt"
    end

    test "an unknown language falls back to the file glyph" do
      assert CodeHead.wrap("<pre/>", "brainfuck", nil) =~ "code-icon--file"
    end

    test "titles are HTML-escaped" do
      html = CodeHead.wrap("<pre/>", "text", ~s(<script>"x"&y.txt))

      assert html =~ "&lt;script&gt;&quot;x&quot;&amp;y.txt"
      refute html =~ "<script>"
    end
  end

  describe "through the transform stage" do
    test "a fenced block with a language gains the header; a bare fence does not" do
      body = """
      ```elixir title="lib/foo.ex"
      IO.puts(:hi)
      ```

      ```
      no info string
      ```
      """

      doc = %Document{
        source: "x.md",
        collection: :pages,
        body: body,
        path: "x/index.html",
        raw?: false,
        meta: %{}
      }

      build = %Build{
        options: [],
        site: %Site{
          title: "t",
          url: "https://x",
          base_path: "",
          root: ".",
          output: "_site"
        },
        documents: [doc]
      }

      {:ok, out} = Transform.run(build)
      html = hd(out.documents).html

      assert html =~ ~s(<figcaption class="code-head">)
      assert html =~ ~s(<span class="code-title">lib/foo.ex</span>)
      # The block still highlights exactly as before, inside the figure.
      assert html =~ ~s(<code class="language-elixir")
      # The bare fence stays a bare pre: exactly one header on the page.
      assert length(String.split(html, "code-head")) == 2
    end
  end
end
