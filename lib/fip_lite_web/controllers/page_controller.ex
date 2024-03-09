defmodule FipLiteWeb.PageController do
  use FipLiteWeb, :controller
  alias FipLite.NowPlaying

  def index(conn, _params) do
    render(conn, "index.html", now_playing: NowPlaying.get())
  end
end
