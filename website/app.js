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

});