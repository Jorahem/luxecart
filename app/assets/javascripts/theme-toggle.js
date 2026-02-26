// Small theme manager: sets html.dark and persists preference to localStorage.
// - Click toggle to switch
// - If no stored preference, uses prefers-color-scheme
// - Updates meta theme-color if present
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

  function setTheme(isDark) {
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

  // detect saved preference or OS preference
  var saved = null;
  try { saved = localStorage.getItem('theme'); } catch(e) { /* ignore */ }
  var prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;

  if (saved === 'dark') {
    setTheme(true);
  } else if (saved === 'light') {
    setTheme(false);
  } else {
    setTheme(prefersDark);
  }

  // Toggle on button click
  if (toggle) {
    toggle.addEventListener('click', function () {
      setTheme(document.documentElement.classList.toggle('dark'));
    });
  }

  // If user hasn't chosen theme explicitly, respond to OS changes
  try {
    var mq = window.matchMedia('(prefers-color-scheme: dark)');
    if (mq && mq.addEventListener) {
      mq.addEventListener('change', function (e) {
        try {
          if (!localStorage.getItem('theme')) {
            setTheme(e.matches);
          }
        } catch (err) { /* ignore */ }
      });
    }
  } catch (err) { /* older browsers fallback */ }
});