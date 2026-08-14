# Regenerates the fixture golden trees after an intentional output change:
#
#     mix run scripts/regen_goldens.exs
#
# Review the diff — the goldens are the output contract.
today = ~D[2026-08-14]

for fixture <- ["minimal", "blog", "folio"] do
  source = Path.join("test/fixtures/sites", fixture)
  output = Path.join(source, "expected")

  File.rm_rf!(output)

  case Cherry.build(source: source, output: output, today: today) do
    {:ok, build} ->
      IO.puts("#{fixture}: #{length(build.pages)} pages, #{length(build.assets)} assets")

    {:error, reason} ->
      IO.puts(:stderr, "#{fixture}: #{reason}")
      System.halt(1)
  end
end
