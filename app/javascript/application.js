import "controllers"
import "@hotwired/turbo-rails"

import "chartkick"
import "Chart.bundle"

// Import local theme toggle (relative import)
import "./theme-toggle"



// app/javascript/application.js

document.addEventListener("turbo:load", setupLuxecartChat);
document.addEventListener("DOMContentLoaded", setupLuxecartChat);

function setupLuxecartChat() {
  const openBtn   = document.getElementById("luxecart-start-live-chat");
  const widget    = document.getElementById("luxecart-chat-widget");
  const closeBtn  = document.getElementById("luxecart-chat-close");
  const form      = document.getElementById("luxecart-chat-form");
  const input     = document.getElementById("luxecart-chat-input");
  const messages  = document.getElementById("luxecart-chat-messages");

  if (!widget) return; // layout not loaded yet or different page

  if (openBtn) {
    openBtn.addEventListener("click", () => {
      widget.style.display = "flex";
      input && input.focus();
    });
  }

  if (closeBtn) {
    closeBtn.addEventListener("click", () => {
      widget.style.display = "none";
    });
  }

  if (form && input && messages) {
    form.addEventListener("submit", async (e) => {
      e.preventDefault();
      const text = input.value.trim();
      if (!text) return;

      addChatBubble(messages, text, "user");
      input.value = "";

      // Fake AI response for now – replace this with a real API call later
      addChatBubble(messages, "Thinking…", "bot", { temp: true });

      // Simulate a small delay
      setTimeout(() => {
        removeLastTempBotBubble(messages);
        addChatBubble(
          messages,
          "I’m a demo LuxeCart assistant. In production you can connect me to an AI API (like OpenAI) and answer questions about products, orders, or sizing."
        );
      }, 700);
    });
  }
}

function addChatBubble(container, text, role = "bot", options = {}) {
  const wrapper = document.createElement("div");
  wrapper.style.marginBottom = "8px";
  wrapper.dataset.role = role;
  if (options.temp) wrapper.dataset.temp = "true";

  const bubble = document.createElement("div");
  bubble.textContent = text;
  bubble.style.display = "inline-block";
  bubble.style.padding = "8px 10px";
  bubble.style.borderRadius = "14px";
  bubble.style.maxWidth = "85%";
  bubble.style.wordBreak = "break-word";

  if (role === "user") {
    wrapper.style.textAlign = "right";
    bubble.style.background = "#4f46e5";
    bubble.style.color = "#ffffff";
  } else {
    bubble.style.background = "#e5e7eb";
    bubble.style.color = "#111827";
  }

  wrapper.appendChild(bubble);
  container.appendChild(wrapper);
  container.scrollTop = container.scrollHeight;
}

function removeLastTempBotBubble(container) {
  const nodes = Array.from(container.querySelectorAll("[data-temp='true'][data-role='bot']"));
  const last = nodes[nodes.length - 1];
  if (last) last.remove();
}