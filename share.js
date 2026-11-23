(function () {
  "use strict";

  var button = document.querySelector(".quick-action--share");
  var status = document.querySelector(".share-status");
  if (!button || !status) return;

  var canonical = document.querySelector('link[rel="canonical"]');
  var url = canonical ? canonical.href : "";

  var canShare = typeof navigator.share === "function";
  var canCopy = !!(navigator.clipboard && typeof navigator.clipboard.writeText === "function");
  if (!canShare && !canCopy) return;

  button.hidden = false;

  function showStatus(message, variant) {
    status.textContent = message;
    status.classList.remove("share-status--success", "share-status--error");
    status.classList.add(variant === "error" ? "share-status--error" : "share-status--success");
    status.hidden = false;
  }

  function copyLink(errorMessage) {
    return navigator.clipboard.writeText(url).then(function () {
      showStatus("Enlace copiado.", "success");
    }, function () {
      showStatus(errorMessage, "error");
    });
  }

  button.addEventListener("click", function () {
    var manualCopyMessage = "No se pudo copiar el enlace. Cópialo manualmente: " + url;

    if (canShare) {
      navigator.share({ title: document.title, url: url }).catch(function (error) {
        if (error && error.name === "AbortError") return;
        if (canCopy) {
          copyLink(manualCopyMessage);
        } else {
          showStatus(manualCopyMessage, "error");
        }
      });
      return;
    }

    if (canCopy) {
      copyLink(manualCopyMessage);
    }
  });
})();
