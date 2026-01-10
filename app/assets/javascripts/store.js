document.addEventListener('DOMContentLoaded', function () {
  // mobile nav toggle
  var toggle = document.getElementById('nav-toggle');
  var links = document.getElementById('nav-links');
  if (toggle && links) {
    toggle.addEventListener('click', function () {
      var expanded = this.getAttribute('aria-expanded') === 'true';
      this.setAttribute('aria-expanded', !expanded);
      links.style.display = expanded ? 'none' : 'flex';
    });
  }

  // small UI: "Added" flash for add-to-cart buttons (non-AJAX fallback)
  document.body.addEventListener('click', function (e) {
    var btn = e.target.closest && e.target.closest('.add-to-cart');
    if (btn) {
      btn.disabled = true;
      var original = btn.innerHTML;
      btn.innerHTML = 'Added';
      setTimeout(function () {
        btn.disabled = false;
        btn.innerHTML = original;
      }, 900);
    }
  }, false);
});