defmodule FipLite.NowPlaying do
  use GenServer

  @refresh_url "https://www.radiofrance.fr/fip/api/live"

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
        IO.puts("error 1")
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

  defp schedule_work(milliseconds) do
    IO.puts("Scheduling update in #{milliseconds / 1000} seconds")
    Process.send_after(self(), :fetch_info, milliseconds)
  end

  defp do_fetch_info() do
    IO.puts("#{DateTime.now!("Etc/UTC")} - Fetching now playing information")

    with r <- Finch.build(:get, @refresh_url),
         {:ok, %Finch.Response{status: 200, body: body}} <- Finch.request(r, FipLiteFinch),
         %{"delayToRefresh" => refresh_delay, "now" => track} = data <- Jason.decode!(body) do
      IO.inspect(data)

      schedule_work(refresh_delay)

      {:ok,
       %{
         title: track["firstLine"]["title"],
         artist: track["secondLine"]["title"],
         cover_url: track["visuals"]["card"]["webpSrc"]
       }}
    else
      error ->
        IO.inspect(error)
        schedule_work(5000)
        :error
    end
  end
end
