defmodule FipLiteWeb.NowPlayingChannel do
  use Phoenix.Channel
  alias FipLite.NowPlaying

  def join("fip:now_playing", _message, socket) do
    {:ok, NowPlaying.get(), socket}
  end
end
