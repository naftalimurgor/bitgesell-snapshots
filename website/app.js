document.querySelectorAll(".copy-btn").forEach(button => {

  button.addEventListener("click", async () => {

    const code = button.parentElement.querySelector("code");

    try {

      await navigator.clipboard.writeText(code.innerText);

      button.classList.add("copied");

      setTimeout(() => {

        button.classList.remove("copied");

      }, 1800);

    } catch (err) {

      console.error("Clipboard error:", err);

    }

  });

})

async function loadSnapshot() {
  try {
    const url = document.querySelector('meta[name="snapshot-url"]').content;

    const res = await fetch(url, { cache: "no-store" });
    const data = await res.json();


    document.getElementById("height").textContent =
      data.height.toLocaleString();

    document.getElementById("created").textContent =
      new Date(data.created).toUTCString();

    document.getElementById("size").textContent =
      formatBytes(data.size_bytes);

    document.getElementById("sha256").textContent =
      data.sha256;

    document.getElementById("version").textContent =
      data.version;

    // optional: wire download button if it exists
    const btn = document.querySelector(".btn-primary");
    if (btn && data.download_url) {
      btn.href = data.download_url;
    }

  } catch (err) {
    console.error("Snapshot load failed:", err);
  }
}

function formatBytes(bytes) {
  const gb = bytes / (1024 ** 3);
  if (gb > 1) return gb.toFixed(2) + " GB";

  const mb = bytes / (1024 ** 2);
  return mb.toFixed(2) + " MB";
}

loadSnapshot()