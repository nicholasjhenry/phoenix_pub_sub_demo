defmodule NotificationTest do
  use ExUnit.Case
  doctest Notification

  alias Phoenix.PubSub

  test "learning pub sub" do
     PubSub.subscribe Notification.PubSub, "order:123"
     PubSub.broadcast Notification.PubSub, "order:123", {:order_shipped, %{id: 123, total: 10}}
     assert {:order_shipped, %{id: 123, total: 10}} = hd(Process.info(self)[:messages])
  end
end
