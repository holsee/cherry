defmodule Cherry.ThemeTokensTest do
  use ExUnit.Case, async: true

  alias Cherry.Theme

  @color_literal ~r/#[0-9a-fA-F]{3,8}\b|rgba?\(|hsla?\(|oklch\(/

  test "templates carry no hard-coded colors — tokens only (house rule)" do
    for template <- Path.wildcard(Path.join(Theme.default_root(), "templates/*.eex")) do
      content = File.read!(template)

      refute Regex.match?(@color_literal, content),
             "#{Path.basename(template)} contains a color literal; use a token in site.css"
    end
  end

  test "site.css defines colors only as custom-property tokens" do
    css = File.read!(Path.join(Theme.default_root(), "assets/site.css"))

    offenders =
      css
      |> String.split("\n")
      |> Enum.with_index(1)
      |> Enum.filter(fn {line, _n} ->
        Regex.match?(@color_literal, line) and not String.match?(line, ~r/^\s*--[\w-]+:/)
      end)

    assert offenders == [],
           "color literals outside token definitions:\n" <>
             Enum.map_join(offenders, "\n", fn {line, n} -> "  #{n}: #{String.trim(line)}" end)
  end

  test "every manifest token is defined in site.css for both renditions" do
    {:ok, theme} = Theme.load(Theme.default_root())
    css = File.read!(Path.join(Theme.default_root(), "assets/site.css"))

    for {token, _spec} <- theme.tokens do
      name = Atom.to_string(token)
      definitions = css |> String.split("\n") |> Enum.count(&(&1 =~ ~r/^\s*#{name}:/))

      # Color tokens appear three times (light, dark-via-media, dark-via-toggle);
      # rendition-independent tokens (fonts, measure) once.
      expected = if name =~ ~r/^--(color|syn)-/, do: 3, else: 1

      assert definitions == expected,
             "#{name} defined #{definitions}x in site.css, expected #{expected}"
    end
  end
end
