// Tarjeta digital — interacción mínima del cuadro QR.
// Sin dependencias, sin manejadores inline: solo addEventListener.
// Degradación sin JS: el control QR y "Guardar PNG" siguen siendo anclas
// reales al PNG estático (assets/qr.png) si este script no corre.
(function () {
  "use strict";

  var CANONICAL_URL = "https://fahed-hermoza-card.fahedhermoza.workers.dev/";

  var trigger = document.querySelector("[data-qr-trigger]");
  var dialog = document.querySelector(".qr-panel");

  if (
    !trigger ||
    !dialog ||
    typeof window.HTMLDialogElement === "undefined" ||
    typeof dialog.showModal !== "function"
  ) {
    // No dialog support (or markup missing): keep the plain anchor fallback.
    return;
  }

  var closeButton = dialog.querySelector(".qr-panel__close");
  var copyButton = dialog.querySelector(".qr-panel__copy");
  var statusEl = dialog.querySelector(".qr-panel__status");
  var lastOpener = null;
  var statusTimer = null;

  function setStatus(message) {
    if (!statusEl) {
      return;
    }
    statusEl.textContent = message;
  }

  function clearStatusTimer() {
    if (statusTimer) {
      window.clearTimeout(statusTimer);
      statusTimer = null;
    }
  }

  function openPanel(event) {
    event.preventDefault();
    lastOpener = event.currentTarget;
    setStatus("");
    dialog.showModal();
    if (closeButton) {
      closeButton.focus();
    }
  }

  function closePanel() {
    if (dialog.open) {
      dialog.close();
    }
  }

  trigger.addEventListener("click", openPanel);

  if (closeButton) {
    closeButton.addEventListener("click", closePanel);
  }

  // Backdrop click: the dialog element itself only receives the click when
  // the user clicks outside its content box.
  dialog.addEventListener("click", function (event) {
    if (event.target === dialog) {
      closePanel();
    }
  });

  // Fires on Escape (native "cancel" -> "close") and on dialog.close().
  dialog.addEventListener("close", function () {
    clearStatusTimer();
    setStatus("");
    if (lastOpener && typeof lastOpener.focus === "function") {
      lastOpener.focus();
    }
    lastOpener = null;
  });

  if (copyButton) {
    copyButton.addEventListener("click", function () {
      clearStatusTimer();
      if (
        navigator.clipboard &&
        typeof navigator.clipboard.writeText === "function"
      ) {
        navigator.clipboard.writeText(CANONICAL_URL).then(
          function () {
            setStatus("Enlace copiado");
            statusTimer = window.setTimeout(function () {
              setStatus("");
            }, 4000);
          },
          function () {
            setStatus(
              "No se pudo copiar automáticamente. Enlace: " + CANONICAL_URL
            );
          }
        );
      } else {
        setStatus(
          "No se pudo copiar automáticamente. Enlace: " + CANONICAL_URL
        );
      }
    });
  }
})();
