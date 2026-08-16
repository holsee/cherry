defmodule Cherry.Search.Index do
  @moduledoc """
  Builds the search index emitted for `search: "cherry"` — the built-in
  engine that needs no Node, no npm, and no network (DESIGN.md §7).

  The index is an inverted list: every indexed token maps to the
  documents containing it and a weight. Ranking happens in the browser,
  so the emitted file carries weights and document metadata, not scores.

      %{
        "v" => 1,
        "docs" => [%{"u" => "introsort/", "t" => "Introsort", "e" => "…", "d" => "2014-03-02"}],
        "terms" => %{"introsort" => [[0, 9]]}
      }

  `terms` values are `[document_index, weight]` pairs, pointing into
  `docs` by position. Weight is term frequency with the title counted
  three times and tags twice, so a word in a title outranks the same
  word buried in a paragraph.

  Fenced code blocks are stripped before tokenizing. Prose is what
  readers search for, and a technical archive's code samples otherwise
  dominate the index with symbols and language keywords.
  """

  alias Cherry.Content.Document
  alias Cherry.Site
  alias Cherry.StableJSON

  @format_version 1
  @title_weight 3
  @tag_weight 2
  @excerpt_length 160
  @min_token_length 2

  # Small, closed stopword list: the words that appear in nearly every
  # document carry no signal but a large share of the postings.
  @stopwords MapSet.new(~w(
    a an and are as at be been but by can do does for from had has have he her
    his how i if in into is it its more most no not of on or our out so some
    such than that the their them then there these they this to too up very was
    we were what when where which who will with would you your
  ))

  @typedoc "The index as plain data, before JSON encoding."
  @type t :: %{String.t() => term()}

  @doc """
  Builds the index for every routable, non-raw document.

  Documents are ordered by output path so the same content always
  produces the same document indices, which keeps the build byte-stable.
  """
  @spec build([Document.t()], Site.t()) :: t()
  def build(documents, %Site{} = site) do
    docs = documents |> Enum.filter(&indexable?/1) |> Enum.sort_by(& &1.path)

    %{
      "v" => @format_version,
      "docs" => Enum.map(docs, &document_entry(&1, site)),
      "terms" => terms(docs)
    }
  end

  @doc "Builds the index and encodes it as deterministic JSON."
  @spec render([Document.t()], Site.t()) :: String.t()
  def render(documents, %Site{} = site) do
    documents |> build(site) |> StableJSON.encode!()
  end

  @doc """
  Splits text into index tokens.

  Public because the browser island must tokenize queries exactly the
  same way; the two implementations are checked against each other in
  `test/cherry/search_index_test.exs`.
  """
  @spec tokenize(String.t()) :: [String.t()]
  def tokenize(text) do
    text
    |> String.downcase()
    |> String.split(~r/[^\p{L}\p{N}]+/u, trim: true)
    |> Enum.filter(&keep?/1)
    |> Enum.map(&fold/1)
    |> Enum.filter(&keep?/1)
  end

  # Naive plural folding, applied to queries too: "algorithms" and
  # "algorithm" must reach the same posting list. Deliberately not a
  # stemmer — a real one needs a dictionary the browser would have to
  # download. Stopwords are filtered before folding and again after,
  # because folding otherwise smuggles "this" through the list as "thi".
  defp fold(token) do
    if String.length(token) > 3 and String.ends_with?(token, "s") and
         not String.ends_with?(token, "ss") do
      String.slice(token, 0..-2//1)
    else
      token
    end
  end

  defp keep?(token) do
    String.length(token) >= @min_token_length and not MapSet.member?(@stopwords, token)
  end

  defp indexable?(%Document{raw?: false, path: path}) when is_binary(path) do
    String.ends_with?(path, "index.html")
  end

  defp indexable?(_document), do: false

  defp document_entry(%Document{meta: meta} = document, site) do
    entry = %{
      "u" => Site.href(site, Document.rel_url(document.path)),
      "t" => title(document),
      "e" => excerpt(document)
    }

    case meta[:date] do
      %Date{} = date -> Map.put(entry, "d", Date.to_iso8601(date))
      _ -> entry
    end
  end

  defp title(%Document{meta: meta, path: path}) do
    meta[:title] || path |> Path.dirname() |> Path.basename()
  end

  defp excerpt(%Document{meta: meta} = document) do
    case meta[:description] do
      description when is_binary(description) and description != "" ->
        description

      _ ->
        document |> prose() |> String.slice(0, @excerpt_length) |> String.trim()
    end
  end

  defp terms(documents) do
    documents
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {document, index}, acc ->
      document
      |> weights()
      |> Enum.reduce(acc, fn {token, weight}, terms ->
        Map.update(terms, token, [[index, weight]], &[[index, weight] | &1])
      end)
    end)
    |> Map.new(fn {token, postings} -> {token, Enum.sort(postings)} end)
  end

  # One pass per field, so a term's weight reflects where it appeared.
  defp weights(%Document{meta: meta} = document) do
    tags = meta |> Map.get(:tags, []) |> Enum.join(" ")

    counted(prose(document), 1)
    |> merge_counts(counted(title(document), @title_weight))
    |> merge_counts(counted(tags, @tag_weight))
  end

  defp counted(text, weight) do
    text
    |> tokenize()
    |> Enum.frequencies()
    |> Map.new(fn {token, count} -> {token, count * weight} end)
  end

  defp merge_counts(left, right) do
    Map.merge(left, right, fn _token, a, b -> a + b end)
  end

  # Markdown source minus the parts that are not prose: fenced code,
  # HTML tags, and link targets (the link text survives).
  defp prose(%Document{body: body}) do
    body
    |> String.replace(~r/^```.*?^```/ms, " ")
    |> String.replace(~r/<[^>]*>/, " ")
    |> String.replace(~r/\]\([^)]*\)/, "] ")
  end
end
