# Generates one "Using <theme>" page per official theme under
# example/content/pages/themes/<name>.md, from the theme's own
# manifest - tokens, fonts, and the shipped-vs-inherited template
# split come from theme.exs and the templates/ directory, so the
# pages cannot drift from the API they document.
#
#   mix run scripts/gen_theme_docs.exs

defmodule GenThemeDocs do
  @out "example/content/pages/themes"

  def run do
    File.mkdir_p!(@out)

    for name <- Cherry.Theme.builtin_names() do
      dir = Path.join([:code.priv_dir(:cherry), "themes", name])
      manifest = dir |> Path.join("theme.exs") |> Code.eval_file() |> elem(0)
      File.write!(Path.join(@out, "#{name}.md"), page(name, dir, manifest))
      IO.puts("themes/#{name}.md")
    end
  end

  defp page(name, dir, manifest) do
    description = Keyword.fetch!(manifest, :description)
    contract = Keyword.fetch!(manifest, :cherry_contract)
    tokens = Keyword.fetch!(manifest, :tokens)
    templates = Keyword.fetch!(manifest, :templates)

    templates_dir = Path.join(dir, "templates")

    shipped =
      templates_dir
      |> then(&if(File.dir?(&1), do: File.ls!(&1), else: []))
      |> Enum.map(fn file ->
        file
        |> String.replace_suffix(".html.eex", "")
        |> String.replace_suffix(".html.heex", "")
        |> String.to_atom()
      end)
      |> MapSet.new()

    {owned, inherited} = Enum.split_with(templates, fn {key, _} -> key in shipped end)

    {color_tokens, other_tokens} =
      Enum.split_with(tokens, fn {key, _} -> String.starts_with?(to_string(key), "--color") end)

    {syn_tokens, rest_tokens} =
      Enum.split_with(other_tokens, fn {key, _} -> String.starts_with?(to_string(key), "--syn") end)

    accent = get_in(tokens, [:"--color-accent"]) || []

    """
    ---
    title: "Using #{name}"
    description: "Install, override, and extend the #{name} theme the Cherry way: its token API, its templates, and where each rung of the styling ladder applies."
    ---
    ## Using #{name}

    #{description}

    See it live in the [exhibition](https://cherrybomb.dev/t/#{name}/), or back in [the gallery](/themes/). Like every official theme, #{name} implements theme contract #{contract}: every colour flows through the tokens below, the stylesheet lives in the `theme` cascade layer so your unlayered overrides always win, and any template it does not ship falls back to the default theme's copy.

    ### Install

    One config line, or one command:

    ```elixir
    # cherry.exs
    theme: "#{name}"
    ```

    ```text
    $ cherry config theme #{name}
    ```

    Then `cherry build` (or `cherry serve` while you look around). Nothing else moves: your content, your overlays for other themes, and your token overrides for other themes stay where they are.

    ### The styling ladder, applied to #{name}

    Restyling costs exactly as much ownership as you choose to take. In order:

    **Rung 1 - override a token.** The manifest below is #{name}'s public styling API. Overrides land in every page head, survive theme upgrades, and are validated against the manifest (a typo is an error, not a dead line):

    ```text
    $ cherry config tokens.--color-accent "light-dark(#{example_light(accent)}, #{example_dark(accent)})"
    $ cherry theme.tokens        # shows the merged view
    ```

    **Rung 2 - custom.css.** Drop `assets/custom.css` into your site and it links after the theme stylesheet and the tokens block on every page. #{name}'s own CSS lives in the `theme` cascade layer, so a plain selector in your unlayered file beats the theme without specificity games or `!important`.

    **Rung 3 - overlay a template.** Write `themes/#{name}/templates/<template>.html.eex` (or `.html.heex`) in your site and it shadows just that template.

    **Rung 4 - eject.** `cherry theme.eject <template>` copies the original into that overlay directory with a provenance header, so `cherry theme.diff` can tell you forever after whether upstream moved under your copy.

    **Rung 5 - a theme of your own.** `cherry gen.theme mytheme --from #{name}` scaffolds the whole thing - manifest, templates, stylesheet#{islands_note(dir)} - into `themes/mytheme/`, yours deliberately.

    The [theming reference](/docs/theming/) covers every rung in depth; the [theme guide](/guides/creating-a-theme/) walks rung 5.

    ### Token API

    Colour tokens are `light-dark()` pairs: one override sets both renditions, and the theme toggle flips a single `color-scheme` property.

    #### Surface and text

    #{token_table(color_tokens)}

    #### Syntax highlighting

    #{token_table(syn_tokens)}

    #### Type and measure

    #{token_table_single(rest_tokens)}

    ### Templates

    #{ships_line(name, owned, templates)} Overlay or eject any name in either list.

    #### Shipped by #{name}

    #{template_table(owned)}

    #### Inherited from default

    #{template_table(inherited)}

    ### Working with an agent

    Cherry ships [a skill](https://github.com/holsee/cherry/tree/develop/skills/cherry) that teaches a coding agent the operating loop above - the ladder, the CLI verbs, and the recovery playbook - so you can say *"make the accent electric blue, the Cherry way"* and it will reach for `cherry config tokens.--color-accent` instead of forking the stylesheet. Install it into your site's `.claude/skills/` (sites scaffolded with `cherry new` already carry `AGENTS.md` describing the same loop), then ask in terms of outcomes:

    - *"Warm up #{name}'s palette for both renditions"* - the agent lists the manifest with `cherry theme.tokens`, overrides rung-1 tokens, and verifies with `cherry check`.
    - *"Tighten the reading column"* - one token: `--measure`.
    - *"Restyle the post list"* - rung 2 in `assets/custom.css` if CSS reaches it, `cherry theme.eject post_list` if structure has to change.

    The one rule to hold an agent to: never edit the theme's own files under `themes/#{name}/` unless they were ejected there on purpose - `cherry theme.diff` will name anything that drifts.
    """
  end

  defp ships_line(name, owned, templates) do
    total = length(templates)

    case length(owned) do
      0 ->
        "#{name} ships no templates of its own: all #{total} in the contract resolve to the default theme's copy, so its whole voice is CSS and every template stays current without you owning it."

      ^total ->
        "#{name} ships every one of the #{total} templates in the contract; nothing falls back."

      n ->
        "#{name} ships #{n} of the #{total} templates in the contract; the rest resolve to the default theme's copy, so they stay current without you owning them."
    end
  end

  @shared_js ~w(copy-code.js theme-toggle.js video-embed.js search.js)

  defp islands_note(dir) do
    assets = Path.join(dir, "assets")

    own_island? =
      File.dir?(assets) and
        assets
        |> File.ls!()
        |> Enum.any?(&(String.ends_with?(&1, ".js") and &1 not in @shared_js))

    if own_island?, do: ", islands", else: ""
  end

  defp example_light(spec), do: Keyword.get(spec, :default, "#0000ee")
  defp example_dark(spec), do: Keyword.get(spec, :dark, Keyword.get(spec, :default, "#7c9eff"))

  defp token_table(tokens) do
    rows =
      Enum.map(tokens, fn {key, spec} ->
        light = spec |> Keyword.get(:default, "") |> code()
        dark = spec |> Keyword.get(:dark) |> code()
        "| `#{key}` | #{light} | #{dark} | #{Keyword.get(spec, :doc, "")} |"
      end)

    Enum.join(["| Token | Light | Dark | Role |", "| --- | --- | --- | --- |" | rows], "\n")
  end

  defp token_table_single(tokens) do
    rows =
      Enum.map(tokens, fn {key, spec} ->
        "| `#{key}` | #{spec |> Keyword.get(:default, "") |> code()} | #{Keyword.get(spec, :doc, "")} |"
      end)

    Enum.join(["| Token | Default | Role |", "| --- | --- | --- |" | rows], "\n")
  end

  defp code(nil), do: "-"
  defp code(value), do: "`#{value}`"

  defp template_table([]), do: "_None - every template is the theme's own._"

  defp template_table(templates) do
    rows =
      Enum.map(templates, fn {key, spec} ->
        assigns = spec |> Keyword.get(:assigns, []) |> Enum.map_join(", ", &"`@#{&1}`")
        "| `#{key}` | #{assigns} | #{Keyword.get(spec, :doc, "")} |"
      end)

    Enum.join(["| Template | Assigns | Purpose |", "| --- | --- | --- |" | rows], "\n")
  end
end

GenThemeDocs.run()
