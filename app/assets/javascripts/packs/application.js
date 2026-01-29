document.addEventListener("turbo:visit", () => {
  document.getElementById('spinner').style.display = 'block';
});
document.addEventListener("turbo:load", () => {
  document.getElementById('spinner').style.display = 'none';
});



// Toast example function
function showToast(message) {
  const toast = document.getElementById('toast');
  toast.textContent = message;
  toast.classList.add('show');
  setTimeout(() => {
    toast.classList.remove('show');
  }, 2100);
}

// Example: Call showToast() after a cart update
// showToast('Product added to cart!');


// app/javascript/application.js

document.addEventListener("DOMContentLoaded", function() {
  // Check if the server rendered a welcome message
  const toastDiv = document.getElementById('welcome-toast');
  const toastMsg = document.getElementById('welcome-message');
  // You can set this server-side with a flash, gon, or data attribute
  const welcomeText = window.welcomeUserMessage || toastMsg?.textContent?.trim();

  if (toastDiv && welcomeText) {
    toastMsg.textContent = welcomeText;
    toastDiv.style.opacity = '1';
    toastDiv.style.pointerEvents = 'auto';
    toastDiv.style.transform = 'translateY(0)';

    setTimeout(function() {
      toastDiv.style.opacity = '0';
      toastDiv.style.pointerEvents = 'none';
      toastDiv.style.transform = 'translateY(-16px)';
    }, 5000); // 5 seconds
  }
});