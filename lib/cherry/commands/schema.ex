defmodule Cherry.Commands.Schema do
  @doc_text """
  Prints a collection's frontmatter schema.

  ## Usage

      mix cherry.schema COLLECTION [--json]

  Lists every field with its type, whether it is required, its default,
  and its documentation. Agents: run this before writing content files —
  the schema is the contract your frontmatter must satisfy.
  """

  @moduledoc @doc_text

  @behaviour Cherry.CLI.Command

  alias Cherry.CLI.{Context, Error}
  alias Cherry.Collections
  alias Cherry.Collections.Schema

  @impl Cherry.CLI.Command
  @spec doc() :: String.t()
  def doc, do: @doc_text

  @impl Cherry.CLI.Command
  @spec switches() :: keyword()
  def switches, do: []

  @impl Cherry.CLI.Command
  @spec run(Context.t()) :: {:ok, map()} | {:error, Error.t()}
  def run(%Context{args: [name]}) do
    case Collections.fetch(name) do
      {:ok, collection} ->
        {:ok, %{collection: name, fields: Schema.introspect(collection.schema())}}

      :error ->
        {:error,
         %Error{
           code: :unknown_collection,
           message:
             "unknown collection #{inspect(name)} — available: " <>
               Enum.join(Collections.names(), ", "),
           exit: 2
         }}
    end
  end

  def run(%Context{}) do
    {:error,
     %Error{
       code: :usage,
       message:
         "usage: cherry schema COLLECTION — available: " <>
           Enum.join(Collections.names(), ", "),
       exit: 2
     }}
  end

  @impl Cherry.CLI.Command
  @spec human(map()) :: iodata()
  def human(%{collection: name, fields: fields}) do
    header = "#{name} frontmatter:"

    lines =
      Enum.map(fields, fn field ->
        required = if field.required, do: " (required)", else: ""
        default = if field.default != nil, do: " [default: #{inspect(field.default)}]", else: ""
        doc = if field.doc, do: " — #{field.doc}", else: ""
        "  #{field.name}: #{field.type}#{required}#{default}#{doc}"
      end)

    Enum.join([header | lines], "\n")
  end
end
