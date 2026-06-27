// Initialize Clipboard.js

const clipboard = new ClipboardJS('#copy-button')

clipboard.on('success', function (e) {

  const button = e.trigger;

  const originalText = button.textContent;

  button.textContent = 'copied!';

  button.classList.add('copied')

  setTimeout(() => {

    button.textContent = originalText;

    button.classList.remove('copied')

  }, 2000)

  e.clearSelection()

})

clipboard.on('error', function () {

  alert('Copy failed. Please copy the command manually.')

})