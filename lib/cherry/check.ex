defmodule Cherry.Check do
  @moduledoc """
  The verifier (DESIGN.md §6): runs every rule against a finished build
  token and returns structured diagnostics.

  Rules so far: broken internal links, missing meta descriptions,
  images without alt text, duplicate titles, and Atom feed sanity.
  Checks read the in-memory build — nothing is written to disk.
  """

  alias Cherry.Build
  alias Cherry.Check.Diagnostic
  alias Cherry.Content.{Document, Page}
  alias Cherry.Theme
  alias Cherry.Theme.Drift

  @doc "Runs every rule; diagnostics come back errors-first."
  @spec run(Build.t()) :: [Diagnostic.t()]
  def run(%Build{} = build) do
    Diagnostic.sort(
      broken_links(build) ++
        missing_descriptions(build) ++
        unfilled_scaffolds(build) ++
        missing_alt(build) ++
        duplicate_titles(build) ++
        feed_sanity(build) ++
        overlay_drift(build)
    )
  end

  # --- broken internal links -------------------------------------------

  @href ~r/(?:href|src)="([^"]+)"/

  defp broken_links(build) do
    targets = link_targets(build)
    base = build.site.base_path

    for %Page{} = page <- html_pages(build),
        url <- internal_urls(page.content, base),
        not MapSet.member?(targets, resolve_link(url, base)) do
      %Diagnostic{
        file: page.source,
        rule: "broken-link",
        message: "links to #{url}, which this build does not emit",
        severity: :error
      }
    end
  end

  defp html_pages(build) do
    Enum.filter(build.pages, &String.ends_with?(&1.path, ".html"))
  end

  defp link_targets(build) do
    paths = Enum.map(build.pages, & &1.path) ++ Enum.map(build.assets, & &1.path)
    MapSet.new(paths ++ post_stage_targets(build.site))
  end

  # The Post stage writes these after Emit, so the in-memory build
  # cannot know them — but the layout legitimately links them.
  defp post_stage_targets(%{search: "pagefind"}) do
    ["pagefind/pagefind-ui.css", "pagefind/pagefind-ui.js"]
  end

  defp post_stage_targets(_site), do: []

  defp internal_urls(html, base) do
    @href
    |> Regex.scan(html, capture: :all_but_first)
    |> List.flatten()
    |> Enum.filter(&internal?(&1, base))
  end

  # Protocol-relative URLs (`//host/…`) are external even though they
  # start with the base path.
  defp internal?(url, base) do
    String.starts_with?(url, base) and not String.starts_with?(url, "//")
  end

  defp resolve_link(url, base) do
    rel =
      url
      |> String.trim_leading(base)
      |> String.split(~r/[?#]/, parts: 2)
      |> hd()

    cond do
      rel == "" -> "index.html"
      String.ends_with?(rel, "/") -> rel <> "index.html"
      true -> rel
    end
  end

  # --- missing descriptions --------------------------------------------

  defp missing_descriptions(build) do
    for %Document{raw?: false} = doc <- build.documents,
        doc.collection in ["posts", "pages"],
        Map.get(doc.meta, :description) in [nil, ""] do
      %Diagnostic{
        file: doc.source,
        rule: "missing-description",
        message: "no description: — search snippets and social cards fall back to nothing",
        severity: :warning
      }
    end
  end

  # --- scaffolds nobody filled in --------------------------------------

  # `gen.post` and friends leave a body to write and empty strings to
  # replace. Publishing without doing either is almost never intended,
  # and nothing else in the suite notices: an empty post renders as a
  # title over nothing at all.
  defp unfilled_scaffolds(build) do
    empty_bodies(build) ++ empty_fields(build)
  end

  defp empty_bodies(build) do
    # Posts and pages only: a portfolio entry that is all frontmatter is
    # a legitimate record, not an unfinished draft.
    for %Document{raw?: false} = doc <- build.documents,
        doc.collection in ["posts", "pages"],
        String.trim(doc.body) == "" do
      %Diagnostic{
        file: doc.source,
        rule: "empty-body",
        message: "no body — the page renders as a heading over nothing",
        severity: :warning
      }
    end
  end

  defp empty_fields(build) do
    for %Document{raw?: false} = doc <- build.documents,
        {field, ""} <- Enum.sort(doc.meta),
        field != :description do
      %Diagnostic{
        file: doc.source,
        rule: "unfilled-field",
        message: "#{field}: is still the empty string the scaffold wrote",
        severity: :warning
      }
    end
  end

  # --- images without alt text -----------------------------------------

  @img ~r/<img\b[^>]*>/

  defp missing_alt(build) do
    for %Document{raw?: false, html: html} = doc <- build.documents,
        is_binary(html),
        img <- List.flatten(Regex.scan(@img, html)),
        not String.contains?(img, "alt=") do
      %Diagnostic{
        file: doc.source,
        rule: "missing-alt",
        message: "image without alt text: #{String.slice(img, 0, 60)}…",
        severity: :warning
      }
    end
  end

  # --- duplicate titles -------------------------------------------------

  defp duplicate_titles(build) do
    build.documents
    |> Enum.filter(&(not &1.raw? and is_binary(&1.meta[:title])))
    |> Enum.group_by(& &1.meta.title)
    |> Enum.filter(fn {_title, docs} -> length(docs) > 1 end)
    |> Enum.flat_map(fn {title, docs} ->
      others = Enum.map(docs, & &1.source)

      Enum.map(docs, fn doc ->
        %Diagnostic{
          file: doc.source,
          rule: "duplicate-title",
          message:
            "title #{inspect(title)} is shared by " <>
              Enum.join(others -- [doc.source], ", "),
          severity: :warning
        }
      end)
    end)
  end

  # --- feed sanity --------------------------------------------------------

  defp feed_sanity(build) do
    atom_sanity(build) ++ json_feed_sanity(build)
  end

  defp atom_sanity(build) do
    case Enum.find(build.pages, &(&1.path == "feed.xml")) do
      nil ->
        [
          %Diagnostic{
            file: "feed.xml",
            rule: "feed-missing",
            message: "the build emits no Atom feed",
            severity: :error
          }
        ]

      feed ->
        for {required, rule} <- [
              {"<feed", "feed-invalid"},
              {"<id>", "feed-invalid"},
              {"<updated>", "feed-invalid"}
            ],
            not String.contains?(feed.content, required) do
          %Diagnostic{
            file: "feed.xml",
            rule: rule,
            message: "feed.xml lacks #{required}…> — not valid Atom",
            severity: :error
          }
        end
    end
  end

  # --- overlay drift (managed theme upgrades) -----------------------------

  defp overlay_drift(build) do
    case Theme.load_active(build.site) do
      {:ok, theme} ->
        for entry <- Drift.entries(build.site, theme), entry.status != :current do
          %Diagnostic{
            file: entry.overlay |> Path.relative_to(build.site.root) |> String.replace("\\", "/"),
            rule: drift_rule(entry.status),
            message: drift_message(entry),
            severity: :warning
          }
        end

      # An unloadable theme fails the build long before checking.
      {:error, _reason} ->
        []
    end
  end

  defp drift_rule(:untracked), do: "untracked-overlay"
  defp drift_rule(_status), do: "stale-overlay"

  defp drift_message(%Drift.Entry{status: :auto_updatable, template: template}) do
    "#{template} drifted upstream but is untouched here — cherry theme.diff --apply re-ejects it"
  end

  defp drift_message(%Drift.Entry{status: :conflict, template: template}) do
    "#{template} changed both upstream and here — resolve via cherry theme.diff"
  end

  defp drift_message(%Drift.Entry{status: :untracked, template: template}) do
    "#{template} has no provenance header — re-eject to enable managed upgrades"
  end

  defp json_feed_sanity(build) do
    case Enum.find(build.pages, &(&1.path == "feed.json")) do
      nil ->
        [
          %Diagnostic{
            file: "feed.json",
            rule: "feed-missing",
            message: "the build emits no JSON Feed",
            severity: :error
          }
        ]

      feed ->
        case JSON.decode(feed.content) do
          {:ok, %{"version" => _version, "items" => items}} when is_list(items) ->
            []

          _invalid ->
            [
              %Diagnostic{
                file: "feed.json",
                rule: "feed-invalid",
                message: "feed.json is not a decodable JSON Feed with version and items",
                severity: :error
              }
            ]
        end
    end
  end
end
