// Improved theme-toggle for Turbo + importmap (frontend)
// Initializes once, works on DOMContentLoaded and turbo:load, and guards against double handlers.
console.log('theme-toggle.js loaded');

function initThemeToggle() {
  // idempotent: avoid running twice
  if (window.__luxecartThemeInitialized) return;
  window.__luxecartThemeInitialized = true;

  var toggle = document.getElementById('theme-toggle');
  var darkIcon = document.getElementById('theme-toggle-dark-icon');
  var lightIcon = document.getElementById('theme-toggle-light-icon');
  var metaThemeColor = document.querySelector('meta[name="theme-color"]');

  function updateIcons(isDark) {
    if (!darkIcon || !lightIcon) return;
    if (isDark) {
      darkIcon.classList.remove('hidden');
      lightIcon.classList.add('hidden');
    } else {
      darkIcon.classList.add('hidden');
      lightIcon.classList.remove('hidden');
    }
  }

  function applyTheme(isDark) {
    if (isDark) {
      document.documentElement.classList.add('dark');
      try { localStorage.setItem('theme', 'dark'); } catch(e) {}
      if (metaThemeColor) metaThemeColor.setAttribute('content', '#0f172a');
    } else {
      document.documentElement.classList.remove('dark');
      try { localStorage.setItem('theme', 'light'); } catch(e) {}
      if (metaThemeColor) metaThemeColor.setAttribute('content', '#ffffff');
    }
    updateIcons(isDark);
  }

  // initial state
  var saved = null;
  try { saved = localStorage.getItem('theme'); } catch(e) {}
  var prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;

  if (saved === 'dark') applyTheme(true);
  else if (saved === 'light') applyTheme(false);
  else applyTheme(prefersDark);

  if (!toggle) { console.log('theme-toggle button not found'); return; }

  // Attach a single click handler (remove old if present)
  if (toggle._themeClickHandler) {
    toggle.removeEventListener('click', toggle._themeClickHandler);
  }
  toggle._themeClickHandler = function () {
    var nowDark = document.documentElement.classList.toggle('dark');
    applyTheme(nowDark);
  };
  toggle.addEventListener('click', toggle._themeClickHandler);

  // Respond to OS changes when user hasn't explicitly set a preference
  try {
    var mq = window.matchMedia('(prefers-color-scheme: dark)');
    if (mq && mq.addEventListener) {
      mq.addEventListener('change', function (e) {
        try {
          if (!localStorage.getItem('theme')) applyTheme(e.matches);
        } catch (err) { /* ignore */ }
      });
    }
  } catch (err) { /* ignore older browsers */ }
}

// Run on initial load and on Turbo visits (frontend)
document.addEventListener('DOMContentLoaded', initThemeToggle);
document.addEventListener('turbo:load', initThemeToggle);