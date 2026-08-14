defmodule Cherry.Pipeline.Stages.Validate do
  @moduledoc """
  Validates every document against its collection schema, assigns routes,
  and applies draft/future selection.

  All schema errors are reported together (one broken file must not hide
  the next), each naming the source file and the field. Selection lives
  here because it depends on validated metadata; `today` comes from the
  build options, never from a clock read (ADR 0005).
  """

  @behaviour Cherry.Pipeline.Stage

  alias Cherry.Build
  alias Cherry.Collections
  alias Cherry.Collections.Schema
  alias Cherry.Content.Document

  @impl Cherry.Pipeline.Stage
  @spec run(Build.t()) :: {:ok, Build.t()} | {:error, String.t()}
  def run(%Build{} = build) do
    results = Enum.map(build.documents, &validate_document/1)

    case Enum.group_by(results, &elem(&1, 0), &elem(&1, 1)) do
      %{error: errors} ->
        {:error, Enum.join(errors, "\n")}

      %{ok: documents} ->
        selected =
          documents
          |> Enum.reject(&rejected?(&1, build.options))
          |> Enum.sort_by(&{&1.collection, &1.path})

        {:ok, %Build{build | documents: selected}}

      %{} ->
        {:ok, build}
    end
  end

  defp validate_document(%Document{raw?: true} = doc), do: {:ok, doc}

  defp validate_document(%Document{} = doc) do
    {:ok, collection} = Collections.fetch(doc.collection)

    case Schema.validate(doc.meta, collection.schema(), doc.source) do
      {:ok, meta} ->
        validated = %Document{doc | meta: meta}
        {:ok, %Document{validated | path: collection.route(validated)}}

      {:error, message} ->
        {:error, message}
    end
  end

  defp rejected?(%Document{meta: meta}, options) do
    draft_rejected = Map.get(meta, :draft, false) and not options.drafts?

    future_rejected =
      case Map.get(meta, :date) do
        %Date{} = date -> Date.after?(date, options.today) and not options.future?
        nil -> false
      end

    draft_rejected or future_rejected
  end
end
