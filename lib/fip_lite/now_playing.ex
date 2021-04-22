defmodule FipLite.NowPlaying do
  use GenServer

  @refresh_url "https://www.fip.fr/latest/api/graphql?operationName=Now&variables=%7B%22bannerPreset%22%3A%22266x266%22%2C%22stationId%22%3A7%7D&extensions=%7B%22persistedQuery%22%3A%7B%22version%22%3A1%2C%22sha256Hash%22%3A%2295ed3dd1212114e94d459439bd60390b4d6f9e37b38baf8fd9653328ceb3b86b%22%7D%7D"

  # Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  # Server (callbacks)

  @impl true
  def init(_) do
    {:ok, nil, {:continue, :fetch_info}}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(:fetch_info, current_track) do
    case do_fetch_info() do
      {:ok, track} when track != current_track ->
        IO.inspect(current_track, label: "current track")
        IO.inspect(track, label: "new track")
        FipLiteWeb.Endpoint.broadcast("fip:now_playing", "new_track", track)
        {:noreply, track}

      {:ok, track} ->
        {:noreply, track}

      :error ->
        {:noreply, current_track}
    end
  end

  @impl true
  def handle_continue(:fetch_info, current_track) do
    case do_fetch_info() do
      {:ok, track} when track != current_track ->
        IO.inspect(current_track, label: "current track")
        IO.inspect(track, label: "new track")
        FipLiteWeb.Endpoint.broadcast("fip:now_playing", "new_track", track)
        {:noreply, track}

      {:ok, track} ->
        {:noreply, track}

      :error ->
        {:noreply, current_track}
    end
  end

  defp schedule_work(seconds) do
    # sometimes we get a negative number for the next update, weird
    seconds =
      if seconds < 0 do
        2
      else
        # most of the time fip seems to change the currently displayed
        # track 26s early compared to the actual stream, weird too
        seconds + 26
      end

    IO.puts("Scheduling update in #{seconds} seconds")
    Process.send_after(self(), :fetch_info, 1000 * seconds)
  end

  defp do_fetch_info() do
    IO.puts("#{DateTime.now!("Etc/UTC")} - Fetching now playing information")

    with r <- Finch.build(:get, @refresh_url),
         {:ok, %Finch.Response{status: 200, body: body}} <- Finch.request(r, FipLiteFinch),
         %{"data" => %{"now" => %{"playing_item" => track} = now} = data} <- Jason.decode!(body) do
      IO.inspect(data)

      schedule_work(
        DateTime.diff(
          DateTime.from_unix!(now["next_refresh"]),
          DateTime.from_unix!(now["server_time"])
        )
      )

      {:ok,
       %{
         title: track["subtitle"],
         artist: track["title"],
         cover_url: track["cover"]
       }}
    else
      _ ->
        schedule_work(5)
        :error
    end
  end
end
