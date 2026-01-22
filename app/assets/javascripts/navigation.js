// Make Turbo's progress bar appear quickly
if (window.Turbo && typeof Turbo.setProgressBarDelay === "function") {
  Turbo.setProgressBarDelay(100); // default ~500ms; lower feels snappier
}

// Simple fade overlay during navigation
(function () {
  function show() {
    document.body.classList.add("is-loading");
  }
  function hide() {
    document.body.classList.remove("is-loading");
  }

  // Show as soon as we start a visit/fetch; hide on load or error
  document.addEventListener("turbo:before-fetch-request", show);
  document.addEventListener("turbo:visit", show);

  document.addEventListener("turbo:load", hide);
  document.addEventListener("turbo:fetch-request-error", hide);
})();