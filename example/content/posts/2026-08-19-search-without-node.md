---
title: Search without Node
description: Cherry's built-in search engine is an inverted index in pure Elixir and a 2KB client. Term weighting, plural folding, and a tokenizer that lives in two languages.
tags:
  - elixir
  - design
---
Set `search: "cherry"` in your config and your site gets full-text search: a search box, ranked results, keyboard shortcut, the lot. No Node, no npm, no wasm blob, no third-party service. The whole engine is one Elixir module that builds an index at compile time and one small TypeScript island that ranks in the browser. This post walks through both, because the computer science involved is old, small, and genuinely pleasing.

## An inverted index, the classic shape

The index Cherry emits is the data structure every search engine from grep to Google grew out of: for every token, the list of documents containing it, with a weight.

```json
{
  "v": 1,
  "docs": [
    {
      "u": "/introsort/",
      "t": "Introsort",
      "e": "The hybrid sort in your standard library.",
      "d": "2014-03-02"
    }
  ],
  "terms": {
    "introsort": [[0, 9]]
  }
}
```

`terms` values are `[document_index, weight]` pairs pointing into `docs` by position. Querying is a lookup, not a scan: the word you typed either has a postings list or it does not.

Building it is a fold over the documents, and it reads like the textbook pseudocode, because Elixir's standard library is most of the algorithm:

```elixir
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
```

## Weights: where a word appears matters

A word in a title should outrank the same word buried in paragraph six. Rather than store fields separately, the builder counts each field with a multiplier and merges the maps. `Enum.frequencies/1` does the counting; `Map.merge/3` with a resolver does the combining:

```elixir
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
```

Title counts three times, tags twice, prose once. That is the entire relevance model on the build side, and it is enough, because the other half of the ranking happens at query time.

One quiet decision hides in `prose/1`: fenced code blocks are stripped before tokenising. A technical archive's code samples would otherwise dominate the index with language keywords and symbol soup. Prose is what readers search for, so prose is what gets indexed.

## The tokenizer lives in two languages

Here is the awkward truth of build-time search: the index is built in Elixir, but the query is typed in a browser. If the two sides tokenise differently, "Algorithms" at build time and "algorithm" at query time never meet.

So the tokenizer is deliberately tiny, defined once in prose, and implemented twice:

```elixir
def tokenize(text) do
  text
  |> String.downcase()
  |> String.split(~r/[^\p{L}\p{N}]+/u, trim: true)
  |> Enum.filter(&keep?/1)
  |> Enum.map(&fold/1)
  |> Enum.filter(&keep?/1)
end
```

Downcase, split on anything that is not a letter or number (Unicode-aware, so accented words survive), drop short tokens and stopwords, fold plurals. The TypeScript side is the same pipeline in fifteen lines, and a test in Cherry's suite feeds the same corpus through both implementations and fails if they ever disagree. The contract is not documentation; it is executable.

## Plural folding, and the bug the pipeline shape prevents

Real stemmers need dictionaries, and dictionaries are exactly the kind of payload a browser island should not download. Cherry folds plurals the naive way instead: longer than three characters, ends in `s`, does not end in `ss`, drop the `s`. "Algorithms" and "algorithm" reach the same postings list; "class" keeps its dignity.

Look back at the tokenizer, though: stopwords are filtered *before* folding and *again after*. That second filter is load-bearing. Fold "this" and you get "thi", which is not on the stopword list, and suddenly a word carrying zero signal is smuggled into every posting list on the site. The comment in the source calls it what it is: folding otherwise smuggles "this" through as "thi". Cheap lesson, worth stating: every normalisation step can un-normalise a guarantee established earlier, so re-check the invariant after.

And the client never filters stopwords at all. It does not need a copy of the list: a stopword is simply absent from the index, so it contributes nothing. The cheapest code is the code the invariant makes unnecessary.

## Ranking: tf-idf, sixteen lines, in the browser

The build side stored term frequencies. The query side supplies the other classic ingredient, inverse document frequency: a term that appears everywhere tells you little, a rare term tells you a lot. Since the postings list length *is* the document frequency, idf falls out of data already in hand:

```ts
for (const token of tokens) {
  const postings = index.terms[token];
  if (!postings) continue;

  const idf = Math.log(1 + total / postings.length);
  for (const [id, weight] of postings) {
    const current = scores.get(id) ?? { score: 0, matched: 0 };
    current.score += weight * idf;
    current.matched += 1;
    scores.set(id, current);
  }
}
```

Results sort by how many distinct query terms matched, then by score, so a document containing all your words beats a document that says one of them fifty times. That tie-break is the difference between search that feels right and search that feels like grep.

## The boring virtues

The parts that make it a Cherry feature rather than a demo:

- **Deterministic.** Documents are sorted by output path before numbering, and the JSON encoder emits keys in stable order, so the index is byte-identical across builds like everything else in `_site/`.
- **Lazy.** The island fetches the index on first focus of the search box. A visitor who never searches never downloads it.
- **An enhancement, not a dependency.** If the fetch fails, search silently does nothing and the site remains a website. Failure of a nicety should not look like failure of the page.
- **Honest about its ceiling.** For a huge archive you may want Pagefind's sharded indexes, and `search: "pagefind"` is right there. For a blog and its pages, the built-in engine is a rounding error in the build and one small file in the tree.

Fifty-year-old information retrieval, one small Elixir module, sixteen lines of scoring. Some problems are just the right size. The [docs cover the config](/docs/configuration/), and `cherry new` gives you a site to search in thirty seconds.
