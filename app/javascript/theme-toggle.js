// app/javascript/theme-toggle.js
console.log('theme-toggle.js loaded');

document.addEventListener('DOMContentLoaded', function () {
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

  toggle.addEventListener('click', function () {
    var nowDark = document.documentElement.classList.toggle('dark');
    applyTheme(nowDark);
  });

  try {
    var mq = window.matchMedia('(prefers-color-scheme: dark)');
    if (mq && mq.addEventListener) {
      mq.addEventListener('change', function (e) {
        if (!localStorage.getItem('theme')) applyTheme(e.matches);
      });
    }
  } catch (err) { /* ignore */ }
});