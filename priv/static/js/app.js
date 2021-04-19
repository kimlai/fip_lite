import { Socket } from "/js/phoenix.js";

const video = document.getElementById("video");
if (Hls.isSupported()) {
  const hls = new Hls();
  hls.loadSource("https://stream.radiofrance.fr/fip/fip.m3u8?id=radiofrance");
  hls.attachMedia(video);
}
// hls.js is not supported on platforms that do not have Media Source Extensions (MSE) enabled.
// When the browser has built-in HLS support (check using `canPlayType`), we can provide an HLS manifest (i.e. .m3u8 URL) directly to the video element throught the `src` property.
// This is using the built-in support of the plain video element, without using hls.js.
// Note: it would be more normal to wait on the 'canplay' event below however on Safari (where you are most likely to find built-in HLS support) the video.src URL must be on the user-driven
// white-list before a 'canplay' event will be emitted; the last video event that can be reliably listened-for when the URL is not on the white-list is 'loadedmetadata'.
else if (video.canPlayType("application/vnd.apple.mpegurl")) {
  video.src = "https://stream.radiofrance.fr/fip/fip.m3u8?id=radiofrance";
}

const play = document.getElementById("play");
const pause = document.getElementById("pause");

play.addEventListener("click", () => {
  video.play();
  pause.innerHTML = "...";
});

pause.addEventListener("click", () => {
  video.pause();
  play.innerHTML = "...";
});

video.addEventListener("play", () => {
  play.classList.add("hidden");
  pause.classList.remove("hidden");
  pause.innerHTML = "Stop";
});
video.addEventListener("pause", () => {
  pause.classList.add("hidden");
  play.classList.remove("hidden");
  play.innerHTML = "Play";
});

const updateTrackInfo = track => {
  console.log("Got new track", track);
  document.querySelector(".title").innerHTML = track.title;
  document.querySelector(".artist").innerHTML = track.artist;
  document.querySelector("img").setAttribute("src", track.cover_url);
};

const socket = new Socket("/socket", {});
socket.connect();
const channel = socket.channel("fip:now_playing", {});
channel.on("new_track", updateTrackInfo);
channel
  .join()
  .receive("ok", updateTrackInfo)
  .receive("error", ({ reason }) => console.log("failed join", reason))
  .receive("timeout", () => console.log("Networking issue. Still waiting..."));
