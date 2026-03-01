// app/javascript/theme-toggle.js
// Robust theme toggle with delegation and fallback bindings (works with Turbo and dynamic DOM)
console.log('theme-toggle.js loaded');

(function () {
  var TOGGLE_SELECTORS = [
    '#theme-toggle',
    '#theme-toggle-mobile',
    '.theme-toggle-btn',
    '[aria-label="Toggle color theme"]',
    'button[title*="Toggle color"]'
  ].join(',');

  function updateIcons(isDark) {
    var ids = [
      ['theme-toggle-dark-icon', 'theme-toggle-light-icon'],
      ['theme-toggle-dark-icon-mobile', 'theme-toggle-light-icon-mobile']
    ];
    ids.forEach(function(pair) {
      var darkId = pair[0], lightId = pair[1];
      var darkIcon = document.getElementById(darkId);
      var lightIcon = document.getElementById(lightId);
      if (darkIcon) { darkIcon.classList.toggle('hidden', !isDark); }
      if (lightIcon) { lightIcon.classList.toggle('hidden', isDark); }
    });
  }

  function applyTheme(isDark) {
    try {
      var metaThemeColor = document.querySelector('meta[name="theme-color"]');
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
    } catch (err) {
      console.warn('theme-toggle: applyTheme failed', err);
    }
  }

  function findAndBindExplicit() {
    // Try to find specific toggles and attach direct handlers (if not already bound)
    var nodes = document.querySelectorAll(TOGGLE_SELECTORS);
    nodes.forEach(function(node) {
      if (node.dataset.luxecartBound === 'true') return;
      node.addEventListener('click', function (e) {
        // Allow normal event bubbling; we only toggle theme
        var nowDark = document.documentElement.classList.toggle('dark');
        applyTheme(nowDark);
      });
      node.dataset.luxecartBound = 'true';
    });
    if (nodes.length) {
      console.log('theme-toggle: bound', nodes.length, 'elements');
    }
    return nodes.length > 0;
  }

  function init() {
    if (window.__luxecart_theme_init_done) {
      updateIcons(document.documentElement.classList.contains('dark'));
      return;
    }
    window.__luxecart_theme_init_done = true;
    console.log('theme-toggle: init');

    // Ensure initial theme is set from storage or prefers-color-scheme
    try {
      var saved = null;
      try { saved = localStorage.getItem('theme'); } catch (e) {}
      var prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
      if (saved === 'dark') applyTheme(true);
      else if (saved === 'light') applyTheme(false);
      else applyTheme(prefersDark);
    } catch (e) { /* ignore storage errors */ }

    // Direct binding (best-effort)
    findAndBindExplicit();

    // Delegated handler as fallback so dynamic inserts are handled
    document.addEventListener('click', function (e) {
      var toggle = e.target.closest(TOGGLE_SELECTORS);
      if (!toggle) return;
      // If element already handled by explicit binding, that handler will run too;
      // toggling twice is possible if both handlers run — to avoid double toggle, short-circuit here
      if (toggle.dataset.luxecartBound === 'true') return;
      var nowDark = document.documentElement.classList.toggle('dark');
      applyTheme(nowDark);
    });

    // Observe DOM insertions to re-run explicit binding if the nav is re-rendered
    try {
      var observer = new MutationObserver(function (mutations) {
        // If navbar/toggle elements are added later, bind them
        if (document.querySelector(TOGGLE_SELECTORS)) {
          findAndBindExplicit();
        }
      });
      observer.observe(document.documentElement, { childList: true, subtree: true });
    } catch (e) {
      // ignore if MutationObserver is not available
    }

    // react to OS-level changes only if user hasn't explicitly set a preference
    try {
      var mq = window.matchMedia('(prefers-color-scheme: dark)');
      if (mq && mq.addEventListener) {
        mq.addEventListener('change', function (e) {
          try {
            if (!localStorage.getItem('theme')) applyTheme(e.matches);
          } catch (err) { /* ignore */ }
        });
      }
    } catch (err) { /* ignore */ }
  }

  // Run init on DOMContentLoaded and Turbo navigation
  document.addEventListener('DOMContentLoaded', init);
  document.addEventListener('turbo:load', init);
  // If DOM already ready, run now
  if (document.readyState === 'interactive' || document.readyState === 'complete') {
    init();
  }
})();