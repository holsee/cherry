defmodule Cherry.Serve.Reloader do
  @moduledoc """
  Live-reload fanout: SSE connections register here; the watcher broadcasts
  after every rebuild. A duplicate-key Registry is the whole pubsub.
  """

  @registry __MODULE__.Registry
  @topic :reload

  @doc "The registry child spec name."
  @spec registry() :: module()
  def registry, do: @registry

  @doc "Registers the calling process for reload notifications."
  @spec subscribe() :: :ok
  def subscribe do
    {:ok, _} = Registry.register(@registry, @topic, nil)
    :ok
  end

  @doc "Notifies every subscribed connection that the site was rebuilt."
  @spec broadcast() :: :ok
  def broadcast do
    Registry.dispatch(@registry, @topic, fn entries ->
      for {pid, _value} <- entries, do: send(pid, :cherry_reload)
    end)
  end
end
