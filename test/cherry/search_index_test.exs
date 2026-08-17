defmodule Cherry.Search.IndexTest do
  use ExUnit.Case, async: true

  @moduledoc """
  The built-in search index (`search: "cherry"`). Everything here is a
  pure function of the parsed documents — no Node, no subprocess, no
  network — so the index is part of the deterministic build.
  """

  alias Cherry.Content.Document
  alias Cherry.Search.Index

  describe "tokenize/1" do
    test "splits on anything that is not a letter or number, and downcases" do
      assert Index.tokenize("Erlang/OTP, the BEAM!") == ["erlang", "otp", "beam"]
    end

    test "drops stopwords and single characters" do
      assert Index.tokenize("a walk in the park") == ["walk", "park"]
    end

    test "folds plurals so a query for one form finds the other" do
      assert Index.tokenize("algorithms") == Index.tokenize("algorithm")
      assert Index.tokenize("processes are processes") == ["processe", "processe"]
    end

    test "never smuggles a stopword through as its folded form" do
      # "this" folds to "thi", which is not in the stopword list; filtering
      # has to happen on both sides of the fold.
      refute "thi" in Index.tokenize("this is this")
      assert Index.tokenize("this is this") == []
    end

    test "keeps short words that carry meaning" do
      assert Index.tokenize("ok go") == ["ok", "go"]
    end
  end

  describe "build/2" do
    test "indexes routable documents and orders them by output path" do
      index = Index.build([document("zebra"), document("apple")], site())

      assert Enum.map(index["docs"], & &1["t"]) == ["apple", "zebra"]
      assert index["v"] == 1
    end

    test "skips raw pages and documents with no route" do
      documents = [
        document("real"),
        %Document{collection: "pages", source: "raw.html", path: "raw.html", raw?: true},
        %Document{collection: "data", source: "d.md", path: nil}
      ]

      index = Index.build(documents, site())

      assert Enum.map(index["docs"], & &1["t"]) == ["real"]
    end

    test "weights a term in the title above the same term in the body" do
      titled = document("Elixir", body: "nothing here")
      bodied = document("Something", body: "elixir elixir")

      index = Index.build([titled, bodied], site())
      %{"docs" => docs, "terms" => terms} = index

      titled_id = Enum.find_index(docs, &(&1["t"] == "Elixir"))
      assert [[^titled_id, 3]] = Enum.filter(terms["elixir"], &(hd(&1) == titled_id))
    end

    test "postings point at documents by position, sorted" do
      index = Index.build([document("a", body: "beam"), document("b", body: "beam")], site())

      assert index["terms"]["beam"] == [[0, 1], [1, 1]]
    end

    test "ignores fenced code blocks" do
      body = "prose\n\n```elixir\nSupervisor.start_link(children, opts)\n```\n"

      index = Index.build([document("t", body: body)], site())

      assert index["terms"]["prose"]
      refute index["terms"]["supervisor"]
    end

    test "indexes tags above body weight" do
      index = Index.build([document("t", body: "x", tags: ["beam"])], site())

      assert index["terms"]["beam"] == [[0, 2]]
    end

    test "carries the description as the excerpt when there is one" do
      document = document("t", body: "the body text", description: "a hand-written summary")

      assert [%{"e" => "a hand-written summary"}] = Index.build([document], site())["docs"]
    end

    test "falls back to the opening prose when there is no description" do
      assert [%{"e" => excerpt}] =
               Index.build([document("t", body: "opening line")], site())["docs"]

      assert excerpt == "opening line"
    end

    test "resolves urls through the site's base path" do
      site = %{site() | base_path: "/blog/"}

      assert [%{"u" => "/blog/apple/"}] = Index.build([document("apple")], site)["docs"]
    end

    test "carries the date when the document has one" do
      dated = %{document("t") | meta: %{title: "t", date: ~D[2015-04-28]}}

      assert [%{"d" => "2015-04-28"}] = Index.build([dated], site())["docs"]
    end
  end

  describe "render/2" do
    test "is byte-stable across runs" do
      documents = [document("a", body: "one two"), document("b", body: "two three")]

      assert Index.render(documents, site()) == Index.render(documents, site())
    end

    test "encodes valid JSON that keeps the index shape" do
      json = Index.render([document("a", body: "beam")], site()) |> JSON.decode!()

      assert json["v"] == 1
      assert [%{"t" => "a", "u" => "/a/"}] = json["docs"]
      assert json["terms"]["beam"] == [[0, 1]]
    end
  end

  defp site do
    %Cherry.Site{
      title: "Orchard",
      url: "https://orchard.example",
      base_path: "/",
      root: "/tmp/orchard",
      output: "/tmp/orchard/_site",
      search: "cherry"
    }
  end

  defp document(title, opts \\ []) do
    meta =
      %{title: title}
      |> put_present(:description, opts[:description])
      |> put_present(:tags, opts[:tags])

    %Document{
      collection: "posts",
      source: "content/posts/#{title}.md",
      path: "#{title}/index.html",
      body: Keyword.get(opts, :body, ""),
      meta: meta
    }
  end

  defp put_present(meta, _key, nil), do: meta
  defp put_present(meta, key, value), do: Map.put(meta, key, value)
end
