defmodule NotificationTest do
  use ExUnit.Case
  doctest Notification

  # worker(Subscriber, ["events:orders"])
  defmodule Subscriber do
    use GenServer

    # Client API

    def start_link(channel) do
      GenServer.start_link(__MODULE__, channel)
    end

    # Server Callbacks

    def init(channel) do
      IO.inspect "Subscribing to #{channel}"
      pid = self
      ref = Phoenix.PubSub.subscribe(Notification.PubSub, channel)
      {:ok, {pid, channel, ref}}
    end

    def handle_info({:order_shipped, _payload} = message, state) do
      IO.inspect "#######################"
      IO.inspect "Test - Received Message:"
      IO.inspect message
      IO.inspect "#######################"
      {:noreply, state}
    end

    def handle_info(message, state) do
      IO.inspect "#######################"
      IO.inspect "Catch All - Received Message:"
      IO.inspect message
      IO.inspect "#######################"
      {:noreply, state}
    end
  end

  test "learning pub sub" do
    Subscriber.start_link("events:orders")
    Phoenix.PubSub.subscribe(Notification.PubSub, "events:orders")

    Phoenix.PubSub.broadcast(Notification.PubSub, "events:orders", {:order_shipped, %{id: 123, total: 10}})
    :timer.sleep 500

    messages = Process.info(self)[:messages]
    assert length(messages) == 1
    assert {:order_shipped, %{id: 123, total: 10}} = hd(messages)
  end
end
