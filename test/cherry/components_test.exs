defmodule Cherry.ComponentsTest do
  use ExUnit.Case, async: true

  @moduledoc """
  Content components: the remark-directive set (`::figure`, `::video`,
  `:::note` …) that expands to token-styled HTML before markdown, works
  in any theme, and degrades to a precise `component` diagnostic — never
  a broken build — when misused.
  """

  alias Cherry.Content.Components

  @mdex [extension: [alerts: true], render: [unsafe: true]]

  describe "figure" do
    test "renders image, alt, and caption, escaped" do
      html =
        Components.render(
          ~s(::figure{src="images/a.svg" alt="A <diagram>" caption="Nuts & bolts"})
        )

      assert html =~ ~s(<figure>)
      assert html =~ ~s(<img src="images/a.svg" alt="A &lt;diagram&gt;">)
      assert html =~ ~s(<figcaption>Nuts &amp; bolts</figcaption>)
    end

    test "caption is optional" do
      html = Components.render(~s(::figure{src="a.png" alt="A"}))
      assert html =~ "<figure>"
      refute html =~ "figcaption"
    end

    test "missing alt refuses to render and diagnoses" do
      line = ~s(::figure{src="a.png"})
      assert Components.render(line) == line

      assert [%{rule: "component", line: 1, severity: :error, message: message}] =
               Components.diagnose(line, "post.md")

      assert message =~ "alt text is not optional"
    end
  end

  describe "video" do
    test "youtube renders a facade link, not an iframe" do
      html = Components.render(~s(::video{youtube="dQw4w9WgXcQ" title="The demo"}))

      assert html =~ ~s(href="https://www.youtube.com/watch?v=dQw4w9WgXcQ")
      assert html =~ ~s(data-video-embed="dQw4w9WgXcQ")
      assert html =~ ~s(<span class="video-embed-title">The demo</span>)
      refute html =~ "iframe", "no third-party request may exist at rest"
    end

    test "a local file renders a native player" do
      html = Components.render(~s(::video{src="videos/demo.mp4" title="Demo"}))
      assert html =~ ~s(<video class="video-local" controls preload="metadata")
      assert html =~ ~s(src="videos/demo.mp4")
    end

    test "root-absolute src and poster pick up base_path" do
      html =
        Components.render(
          ~s(::video{src="/videos/demo.mp4" poster="/images/still.png" title="Demo"}),
          "/repo/"
        )

      assert html =~ ~s(src="/repo/videos/demo.mp4")
      assert html =~ ~s(poster="/repo/images/still.png")

      figure = Components.render(~s(::figure{src="/images/a.svg" alt="A"}), "/repo/")
      assert figure =~ ~s(src="/repo/images/a.svg")
    end

    test "youtube without a title diagnoses" do
      assert [%{message: message}] =
               Components.diagnose(~s(::video{youtube="x"}), "post.md")

      assert message =~ "needs a title"
    end
  end

  describe "callout containers" do
    test "the five alert types render onto the alert classes with markdown inside" do
      body = """
      :::tip{title="Heads up"}
      Any **markdown** works in here.
      :::
      """

      html = body |> Components.render() |> MDEx.to_html!(@mdex)

      assert html =~ ~s(<div class="markdown-alert markdown-alert-tip">)
      assert html =~ ~s(<p class="markdown-alert-title">Heads up</p>)
      assert html =~ "<strong>markdown</strong>"
      assert html =~ "</div>"
    end

    test "the title defaults to the capitalized type" do
      html = Components.render(":::warning\nbody\n:::")
      assert html =~ ~s(<p class="markdown-alert-title">Warning</p>)
    end

    test "a stray ::: with nothing open passes through" do
      assert Components.render("some text\n:::") == "some text\n:::"
    end

    test "an unclosed container diagnoses" do
      assert [%{message: message}] = Components.diagnose(":::note\nbody", "post.md")
      assert message =~ "never closed"
    end
  end

  describe "code fences shield the syntax" do
    test "directives inside fenced blocks are shown, not expanded" do
      body = """
      ```
      ::figure{src="a.png" alt="A"}
      :::tip
      ```
      """

      assert Components.render(body) == body
      assert Components.diagnose(body <> "\n::bogus{}", "post.md") |> length() == 1
    end
  end

  describe "unknown directives" do
    test "stay verbatim and diagnose with the real options" do
      line = ~s(::gallery{dir="shots"})
      assert Components.render(line) == line

      assert [%{message: message}] = Components.diagnose(line, "post.md")
      assert message =~ "unknown component ::gallery"
      assert message =~ "figure, video"
    end

    test "an unknown container names the five real ones" do
      assert [%{message: message}] = Components.diagnose(":::spoiler\nx\n:::", "post.md")
      assert message =~ "note, tip, important, warning, caution"
    end

    test "an attribute the component does not take is named" do
      assert [%{message: message}] =
               Components.diagnose(~s(::figure{src="a" alt="b" width="20"}), "post.md")

      assert message =~ "does not take width"
    end
  end

  describe "check integration" do
    @moduletag :tmp_dir

    test "a bad directive in a post is a component diagnostic", %{tmp_dir: tmp} do
      source = Path.join(tmp, "src")
      File.mkdir_p!(Path.join(source, "content/posts"))

      File.write!(
        Path.join(source, "cherry.exs"),
        ~s([title: "Orchard", url: "https://orchard.example"])
      )

      File.write!(Path.join(source, "content/posts/2026-01-01-clip.md"), """
      ---
      title: "Clip"
      date: 2026-01-01
      tags: [demo]
      description: "A clip."
      ---

      ::video{youtube="abc123"}
      """)

      {:ok, _build, diagnostics} = Cherry.check(source: source, today: ~D[2026-01-02])

      assert Enum.any?(diagnostics, fn diagnostic ->
               diagnostic.rule == "component" and diagnostic.message =~ "needs a title"
             end)
    end
  end
end
