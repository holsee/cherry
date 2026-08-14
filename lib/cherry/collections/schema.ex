defmodule Cherry.Collections.Schema do
  @moduledoc """
  Validates frontmatter against a collection schema and introspects schemas
  for humans and agents.

  Frontmatter arrives with string keys straight from YAML; keys are matched
  against the schema's known atoms (never `String.to_atom/1` on user input)
  and validation errors always name the source file and the field.
  """

  @doc "Validates a string-keyed meta map; returns an atom-keyed map."
  @spec validate(map(), keyword(), String.t()) :: {:ok, map()} | {:error, String.t()}
  def validate(meta, schema, source) do
    known = Map.new(Keyword.keys(schema), &{Atom.to_string(&1), &1})

    with {:ok, pairs} <- atomize(meta, known, source),
         {:ok, validated} <- run(pairs, schema, source) do
      {:ok, Map.new(validated)}
    end
  end

  @doc """
  A schema as introspectable data for `--json`: name, type, required,
  default, and doc per field.
  """
  @spec introspect(keyword()) :: [map()]
  def introspect(schema) do
    Enum.map(schema, fn {name, spec} ->
      %{
        name: Atom.to_string(name),
        type: spec |> Keyword.get(:type, :any) |> type_to_string(),
        required: Keyword.get(spec, :required, false),
        default: Keyword.get(spec, :default),
        doc: Keyword.get(spec, :doc)
      }
    end)
  end

  defp atomize(meta, known, source) do
    Enum.reduce_while(meta, {:ok, []}, fn {key, value}, {:ok, acc} ->
      case Map.fetch(known, key) do
        {:ok, atom} -> {:cont, {:ok, [{atom, value} | acc]}}
        :error -> {:halt, {:error, "#{source}: unknown field #{inspect(key)}"}}
      end
    end)
  end

  defp run(pairs, schema, source) do
    case NimbleOptions.validate(pairs, schema) do
      {:ok, validated} ->
        {:ok, validated}

      {:error, %NimbleOptions.ValidationError{} = error} ->
        {:error, "#{source}: #{Exception.message(error)}"}
    end
  end

  defp type_to_string({:list, inner}), do: "list of #{type_to_string(inner)}"
  defp type_to_string({:custom, Cherry.Collections.Posts, :validate_date, []}), do: "date"
  defp type_to_string(type) when is_atom(type), do: Atom.to_string(type)
  defp type_to_string(other), do: inspect(other)
end
