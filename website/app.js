document.querySelectorAll(".copy-btn").forEach((button) => {
  button.addEventListener("click", async () => {
    const code = button.parentElement.querySelector("code");

    if (!code) return;

    try {
      await navigator.clipboard.writeText(code.innerText.trim());
      button.classList.add("copied");

      setTimeout(() => {
        button.classList.remove("copied");
      }, 1800);
    } catch (err) {
      console.error("Clipboard error:", err);
    }
  });
});

if (window.AOS) {
  document.body.classList.add("aos-ready");

  AOS.init({
    duration: 650,
    easing: "ease-out-cubic",
    offset: 80,
    once: true,
  });
}

async function loadSnapshot() {
  try {
    const url = document.querySelector('meta[name="snapshot-url"]').content;
    const data = await fetchSnapshot(url);

    document.getElementById("height").textContent =
      data.height.toLocaleString();

    document.getElementById("created").textContent =
      new Intl.DateTimeFormat("en", {
        dateStyle: "medium",
        timeStyle: "short",
        timeZone: "UTC",
      }).format(new Date(data.created)) + " UTC";

    document.getElementById("size").textContent =
      formatBytes(data.size_bytes);

    document.getElementById("sha256").textContent =
      data.sha256;

    document.getElementById("version").textContent =
      data.version;

    const btn = document.querySelector(".button.primary");
    if (btn && data.download_url) {
      btn.href = data.download_url;
    }

  } catch (err) {
    console.error("Snapshot load failed:", err);
  }
}

async function fetchSnapshot(url) {
  try {
    const res = await fetch(url, { cache: "no-store" });
    if (!res.ok) throw new Error(`Snapshot request failed: ${res.status}`);
    return await res.json();
  } catch (err) {
    console.warn("Remote snapshot metadata unavailable, using local fallback.", err);

    const fallback = await fetch("snapshot.json", { cache: "no-store" });
    if (!fallback.ok) throw new Error(`Fallback snapshot request failed: ${fallback.status}`);
    return await fallback.json();
  }
}

function formatBytes(bytes) {
  const gb = bytes / (1024 ** 3);
  if (gb > 1) return gb.toFixed(2) + " GB";

  const mb = bytes / (1024 ** 2);
  return mb.toFixed(2) + " MB";
}

loadSnapshot();
