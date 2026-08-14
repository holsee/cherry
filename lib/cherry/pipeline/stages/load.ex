defmodule Cherry.Pipeline.Stages.Load do
  @moduledoc """
  Reads content and static files from the site root into the token.

  Each collection's directory is scanned; files are split into frontmatter
  and body. Bare `.html` files without frontmatter become raw documents
  (emitted verbatim); markdown without frontmatter is an error. File lists
  are sorted and paths normalised to forward slashes so the token is
  identical on every OS.
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build
  alias Cherry.Collections
  alias Cherry.Content.{Asset, Document, Frontmatter}

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()} | {:error, String.t()}
  def run(%Build{site: site} = build) do
    results =
      Enum.flat_map(Collections.all(), fn {name, collection} ->
        site.root
        |> files_under(collection.dir())
        |> Enum.map(fn {abs, rel} -> load_file(name, collection, abs, rel) end)
      end)

    case split_errors(results) do
      {documents, []} ->
        assets =
          site.root
          |> files_under("static")
          |> Enum.map(fn {abs, rel} -> %Asset{source: abs, path: rel} end)

        {:ok, %Build{build | documents: documents, assets: assets}}

      {_documents, errors} ->
        {:error, Enum.join(errors, "\n")}
    end
  end

  defp load_file(name, collection, abs, rel) do
    source = to_url_path(Path.join(collection.dir(), rel))
    content = File.read!(abs)

    case Frontmatter.parse(content) do
      {:ok, nil, body} ->
        if Path.extname(rel) == ".html" do
          {:ok, %Document{collection: name, source: source, body: body, path: rel, raw?: true}}
        else
          {:error, "#{source}: missing frontmatter (--- fenced YAML) "}
        end

      {:ok, meta, body} ->
        case collection.parse_source(rel, meta) do
          {:ok, merged} ->
            {:ok, %Document{collection: name, source: source, meta: merged, body: body}}

          {:error, reason} ->
            {:error, "#{source}: #{reason}"}
        end

      {:error, reason} ->
        {:error, "#{source}: #{reason}"}
    end
  end

  defp split_errors(results) do
    {oks, errors} = Enum.split_with(results, &match?({:ok, _}, &1))
    {Enum.map(oks, fn {:ok, doc} -> doc end), Enum.map(errors, fn {:error, msg} -> msg end)}
  end

  defp files_under(root, subdir) do
    base = Path.join(root, subdir)

    base
    |> Path.join("**")
    |> Path.wildcard()
    |> Enum.filter(&File.regular?/1)
    |> Enum.map(&{&1, to_url_path(Path.relative_to(&1, base))})
    |> Enum.sort_by(fn {_abs, rel} -> rel end)
  end

  defp to_url_path(path), do: String.replace(path, "\\", "/")
end
