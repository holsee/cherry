defmodule Cherry.Machine do
  @moduledoc """
  The machine-readable half of the published site (DESIGN.md §6):
  markdown mirrors — every content route carries `index.md` alongside
  `index.html` — and `/llms.txt`, the llmstxt.org index agents start
  from.

  Everything derives from the same build token as the HTML, so the two
  surfaces can never disagree. Unlisted pages keep their mirrors (the
  URL works when shared) but never appear in `llms.txt`.
  """

  alias Cherry.Build
  alias Cherry.Content.{Document, Page}
  alias Cherry.CV
  alias Cherry.CV.Skill
  alias Cherry.Machine.Mirror
  alias Cherry.Portfolio
  alias Cherry.Portfolio.Timeline
  alias Cherry.Site
  alias Cherry.Theme.Helpers

  @doc "All machine-surface pages for a build: the mirrors plus `llms.txt`."
  @spec pages(Build.t()) :: [Page.t()]
  def pages(%Build{site: site} = build) do
    portfolio = Portfolio.from_build(build)
    cv = if Portfolio.present?(portfolio), do: CV.project(portfolio, build.options.today)
    posts = posts_newest_first(build.documents)

    mirrors =
      document_mirrors(build.documents) ++
        [post_index(site, posts)] ++
        tag_mirrors(site, posts) ++
        portfolio_mirrors(site, portfolio, posts) ++
        cv_mirror(cv)

    Enum.map(mirrors, &Mirror.to_page/1) ++ [llms_txt(build, portfolio, cv, posts)]
  end

  # --- document mirrors ----------------------------------------------------

  # Raw documents have no markdown source; data-only documents (nil
  # path) have no route. Everything else mirrors its own body.
  defp document_mirrors(documents) do
    for %Document{raw?: false, path: path} = doc <- documents,
        is_binary(path) and String.ends_with?(path, "index.html") do
      %Mirror{path: mirror_path(path), markdown: document_markdown(doc)}
    end
  end

  defp mirror_path(path), do: String.replace_suffix(path, "index.html", "index.md")

  defp document_markdown(%Document{meta: meta, body: body}) do
    date =
      case meta[:date] do
        %Date{} = date -> "*#{Date.to_iso8601(date)}*\n\n"
        _missing -> ""
      end

    "# #{meta.title}\n\n" <> date <> String.trim(body) <> "\n"
  end

  # --- synthetic mirrors ---------------------------------------------------

  defp post_index(site, posts) do
    %Mirror{path: "blog/index.md", markdown: "# Blog\n" <> post_list(site, posts)}
  end

  defp tag_mirrors(site, posts) do
    posts
    |> Enum.flat_map(fn post -> Enum.map(post.meta.tags, &{Helpers.tag_slug(&1), &1}) end)
    |> Enum.uniq_by(fn {slug, _tag} -> slug end)
    |> Enum.sort()
    |> Enum.map(fn {slug, tag} ->
      tagged = Enum.filter(posts, fn post -> tag in post.meta.tags end)

      %Mirror{
        path: Path.join(["blog", "tags", slug, "index.md"]),
        markdown: "# Tagged: #{tag}\n" <> post_list(site, tagged)
      }
    end)
  end

  defp post_list(_site, []), do: ""

  defp post_list(site, posts) do
    items =
      for post <- posts do
        "- [#{post.meta.title}](#{mirror_href(site, post.path)}) — " <>
          Date.to_iso8601(post.meta.date) <> "\n"
      end

    "\n" <> Enum.join(items)
  end

  defp mirror_href(site, path), do: Site.href(site, Document.rel_url(path) <> "index.md")

  # --- portfolio mirrors ---------------------------------------------------

  defp portfolio_mirrors(site, portfolio, posts) do
    if Portfolio.present?(portfolio) do
      [timeline_mirror(portfolio) | story_mirrors(site, portfolio, posts)]
    else
      []
    end
  end

  defp timeline_mirror(portfolio) do
    years =
      for {year, items} <- Timeline.groups(portfolio) do
        "\n## #{year}\n\n" <> Enum.map_join(items, &timeline_item/1)
      end

    %Mirror{
      path: "portfolio/index.md",
      markdown:
        "# Portfolio\n\n" <>
          profile_line(portfolio.profile) <>
          Enum.join(years) <> oss_section(portfolio.oss)
    }
  end

  defp profile_line(nil), do: ""

  defp profile_line(profile) do
    headline = if profile.headline, do: " — #{profile.headline}", else: ""
    "#{profile.name}#{headline}\n"
  end

  defp timeline_item(%Timeline.Item{kind: :position, entry: entry}) do
    "- **#{entry.title}** · #{entry.org} — #{Helpers.format_range(entry.started, entry.ended)}\n"
  end

  defp timeline_item(%Timeline.Item{kind: :project, entry: entry}) do
    "- **#{entry.title}** (project, #{entry.status}) — " <>
      Helpers.format_range(entry.started, entry.ended) <> "\n"
  end

  defp timeline_item(%Timeline.Item{kind: :talk, entry: entry}) do
    "- **#{entry.title}** · #{entry.event} — #{Helpers.format_month(entry.date)}\n"
  end

  defp timeline_item(%Timeline.Item{kind: :education, entry: entry}) do
    "- **#{entry.title}** · #{entry.institution} — " <>
      Helpers.format_range(entry.started, entry.ended) <> "\n"
  end

  defp oss_section([]), do: ""

  defp oss_section(oss) do
    "\n## Open source\n\n" <>
      Enum.map_join(oss, fn entry -> "- [#{entry.title}](#{entry.repo}) — #{entry.role}\n" end)
  end

  defp story_mirrors(site, portfolio, posts) do
    for tag <- Portfolio.tags(portfolio) do
      slug = Helpers.tag_slug(tag)
      filtered = Portfolio.filter_by_tag(portfolio, tag)
      tagged_posts = Enum.filter(posts, fn post -> tag in post.meta.tags end)

      sections =
        [
          story_section("Positions", filtered.positions, &story_position/1),
          story_section("Projects", filtered.projects, &story_project/1),
          story_section("Talks", filtered.talks, &story_talk/1),
          story_section("Open source", filtered.oss, &story_oss/1),
          story_section("Education", filtered.education, &story_education/1),
          story_section(
            "Posts",
            tagged_posts,
            &"- [#{&1.meta.title}](#{mirror_href(site, &1.path)})\n"
          )
        ]

      %Mirror{
        path: Path.join(["story", slug, "index.md"]),
        markdown: "# The #{tag} story\n" <> Enum.join(sections)
      }
    end
  end

  defp story_section(_title, [], _render), do: ""

  defp story_section(title, entries, render) do
    "\n## #{title}\n\n" <> Enum.map_join(entries, render)
  end

  defp story_position(entry) do
    "- **#{entry.title}** · #{entry.org} — #{Helpers.format_range(entry.started, entry.ended)}\n"
  end

  defp story_project(entry) do
    "- **#{entry.title}** (#{entry.status}) — " <>
      Helpers.format_range(entry.started, entry.ended) <> "\n"
  end

  defp story_talk(entry) do
    "- **#{entry.title}** · #{entry.event} — #{Helpers.format_month(entry.date)}\n"
  end

  defp story_oss(entry), do: "- [#{entry.title}](#{entry.repo}) — #{entry.role}\n"

  defp story_education(entry) do
    "- **#{entry.title}** · #{entry.institution} — " <>
      Helpers.format_range(entry.started, entry.ended) <> "\n"
  end

  # --- CV mirror -------------------------------------------------------------

  defp cv_mirror(nil), do: []

  defp cv_mirror(%CV{profile: profile} = cv) do
    case profile.cv.visibility do
      :off ->
        []

      visibility ->
        [
          %Mirror{
            path: "cv/index.md",
            markdown: cv_markdown(cv),
            unlisted?: visibility == :unlisted
          }
        ]
    end
  end

  defp cv_markdown(%CV{profile: profile} = cv) do
    headline = if profile.headline, do: "#{profile.headline}\n\n", else: ""

    "# #{profile.name}\n\n" <>
      headline <>
      "*Updated #{Calendar.strftime(cv.updated, "%B %Y")}*\n" <>
      cv_skills(cv.skills) <>
      cv_entries("Experience", cv.positions, &cv_position/1) <>
      cv_entries("Projects", cv.projects, &cv_project/1) <>
      cv_entries("Talks", cv.talks, &story_talk/1) <>
      cv_entries("Open source", cv.oss, &story_oss/1) <>
      cv_entries("Education", cv.education, &story_education/1)
  end

  defp cv_skills([]), do: ""

  defp cv_skills(skills) do
    "\n## Skills\n\n" <>
      Enum.map_join(skills, fn skill -> "- #{skill.tag} — #{Skill.format_years(skill)}\n" end)
  end

  defp cv_entries(_title, [], _render), do: ""

  defp cv_entries(title, entries, render) do
    "\n## #{title}\n\n" <> Enum.map_join(entries, render)
  end

  defp cv_position(entry) do
    story_position(entry) <> highlights(entry)
  end

  defp cv_project(entry) do
    story_project(entry) <> highlights(entry)
  end

  defp highlights(entry) do
    Enum.map_join(Helpers.cv_highlights(entry), fn highlight -> "  - #{highlight}\n" end)
  end

  # --- llms.txt --------------------------------------------------------------

  defp llms_txt(%Build{site: site} = build, portfolio, cv, posts) do
    description = if site.description, do: "\n> #{site.description}\n", else: ""

    content =
      "# #{site.title}\n" <>
        description <>
        blog_section(site, posts) <>
        pages_section(site, build.documents) <>
        portfolio_section(site, portfolio) <>
        cv_section(site, cv)

    %Page{source: ":llms", path: "llms.txt", content: content}
  end

  defp blog_section(site, posts) do
    "\n## Blog\n\n- [Blog](#{Site.abs_url(site, "blog/index.md")})\n" <>
      Enum.map_join(posts, fn post ->
        "- [#{post.meta.title}](#{abs_mirror(site, post.path)}) — " <>
          Date.to_iso8601(post.meta.date) <> "\n"
      end)
  end

  defp pages_section(site, documents) do
    pages =
      for %Document{raw?: false, collection: "pages", path: path} = doc <- documents,
          is_binary(path) and String.ends_with?(path, "index.html") do
        "- [#{doc.meta.title}](#{abs_mirror(site, path)})\n"
      end

    if pages == [], do: "", else: "\n## Pages\n\n" <> Enum.join(pages)
  end

  defp portfolio_section(site, portfolio) do
    if Portfolio.present?(portfolio) do
      stories =
        Enum.map_join(Portfolio.tags(portfolio), fn tag ->
          slug = Helpers.tag_slug(tag)
          "- [The #{tag} story](#{Site.abs_url(site, "story/#{slug}/index.md")})\n"
        end)

      "\n## Portfolio\n\n- [Portfolio](#{Site.abs_url(site, "portfolio/index.md")})\n" <> stories
    else
      ""
    end
  end

  # Only a public CV is announced; unlisted stays shareable but silent.
  defp cv_section(site, %CV{profile: %{cv: %{visibility: :public}}}) do
    "\n## CV\n\n- [CV](#{Site.abs_url(site, "cv/index.md")})\n" <>
      "- [JSON Resume](#{Site.abs_url(site, "cv.json")})\n"
  end

  defp cv_section(_site, _cv), do: ""

  defp abs_mirror(site, path), do: Site.abs_url(site, Document.rel_url(path) <> "index.md")

  defp posts_newest_first(documents) do
    documents
    |> Enum.filter(&(&1.collection == "posts" and not &1.raw?))
    |> Enum.sort_by(&{Date.to_erl(&1.meta.date), &1.meta.slug}, :desc)
  end
end
