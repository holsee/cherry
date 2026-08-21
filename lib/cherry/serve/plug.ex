defmodule Cherry.Serve.Plug do
  @moduledoc """
  Serves the built output directory in dev, with two additions production
  never sees: a live-reload client injected into every HTML page and the
  `/__cherry/reload` SSE endpoint that drives it.
  """

  @behaviour Plug

  import Plug.Conn

  alias Cherry.Serve.Reloader

  # Compiled from assets/js/livereload.ts (committed, like every island).
  @external_resource "priv/serve/livereload.js"
  @livereload_script "<script>" <> File.read!("priv/serve/livereload.js") <> "</script>"

  @impl Plug
  @spec init(map()) :: map()
  def init(opts), do: opts

  @impl Plug
  @spec call(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def call(%Plug.Conn{path_info: ["__cherry", "reload"]} = conn, config) do
    if config[:verbose?], do: IO.puts("GET /__cherry/reload → SSE subscriber connected")
    sse(conn)
  end

  def call(conn, %{output: output} = config) do
    started = System.monotonic_time(:microsecond)
    base = Map.get(config, :base, [])

    # A base_path site serves under its prefix, exactly as production
    # will: the bare root redirects there, and an unprefixed path that
    # would 404 on the real host 404s here too.
    case strip_base(conn.path_info, base) do
      {:ok, segments} ->
        case resolve(output, segments) do
          {:ok, path} -> conn |> serve_file(path, 200) |> log_request(config, started)
          :error -> conn |> not_found(output) |> log_request(config, started)
        end

      :redirect ->
        conn
        |> put_resp_header("location", "/" <> Enum.join(base, "/") <> "/")
        |> send_resp(302, "")
        |> log_request(config, started)

      :error ->
        conn |> not_found(output) |> log_request(config, started)
    end
  end

  # --verbose request log: one line per response, timed from dispatch.
  defp log_request(conn, %{verbose?: true}, started) do
    elapsed_us = System.monotonic_time(:microsecond) - started
    IO.puts("#{conn.method} #{conn.request_path} → #{conn.status} #{format_elapsed(elapsed_us)}")
    conn
  end

  defp log_request(conn, _config, _started), do: conn

  defp format_elapsed(us) when us < 1_000, do: "#{us}µs"
  defp format_elapsed(us), do: "#{Float.round(us / 1_000, 1)}ms"

  defp sse(conn) do
    Reloader.subscribe()

    conn
    |> put_resp_header("content-type", "text/event-stream")
    |> put_resp_header("cache-control", "no-cache")
    |> send_chunked(200)
    |> sse_loop()
  end

  defp sse_loop(conn) do
    receive do
      :cherry_reload ->
        case chunk(conn, "data: reload\n\n") do
          {:ok, conn} -> sse_loop(conn)
          {:error, _reason} -> conn
        end
    end
  end

  defp strip_base(path_info, []), do: {:ok, path_info}
  defp strip_base([], _base), do: :redirect

  defp strip_base(path_info, base) do
    if List.starts_with?(path_info, base) do
      {:ok, Enum.drop(path_info, length(base))}
    else
      :error
    end
  end

  defp resolve(output, segments) do
    if Enum.any?(segments, &unsafe_segment?/1) do
      :error
    else
      base = Path.join([output | segments])
      index = Path.join(base, "index.html")

      cond do
        File.regular?(base) -> {:ok, base}
        File.regular?(index) -> {:ok, index}
        true -> :error
      end
    end
  end

  defp unsafe_segment?(segment) do
    segment == ".." or String.contains?(segment, "\\") or String.contains?(segment, ":")
  end

  defp serve_file(conn, path, status) do
    if Path.extname(path) == ".html" do
      html =
        path
        |> File.read!()
        |> String.replace("</body>", @livereload_script <> "</body>")

      conn
      |> put_resp_header("content-type", "text/html; charset=utf-8")
      |> send_resp(status, html)
    else
      conn
      |> put_resp_header("content-type", MIME.from_path(path))
      |> send_resp(status, File.read!(path))
    end
  end

  defp not_found(conn, output) do
    page = Path.join(output, "404.html")

    if File.regular?(page) do
      serve_file(conn, page, 404)
    else
      send_resp(conn, 404, "not found")
    end
  end
end
