// app/assets/javascripts/store.js
document.addEventListener('DOMContentLoaded', function () {
  function getCsrf() {
    var m = document.querySelector('meta[name="csrf-token"]');
    return m ? m.getAttribute('content') : '';
  }

  // small toast helper (replace with your app's toast if you have one)
  function showToast(message, isError) {
    var root = document.getElementById('toast-root') || (function() {
      var el = document.createElement('div');
      el.id = 'toast-root';
      el.style.position = 'fixed';
      el.style.top = '12px';
      el.style.right = '12px';
      el.style.zIndex = 9999;
      document.body.appendChild(el);
      return el;
    })();

    var el = document.createElement('div');
    el.className = isError ? 'toast toast-error' : 'toast toast-success';
    el.style.background = isError ? '#fee2e2' : '#fff';
    el.style.color = isError ? '#991b1b' : '#111';
    el.style.borderRadius = '6px';
    el.style.padding = '10px 14px';
    el.style.boxShadow = '0 4px 10px rgba(0,0,0,0.08)';
    el.style.marginTop = '8px';
    el.textContent = message;
    root.appendChild(el);
    setTimeout(function () { el.remove(); }, 3500);
  }

  // Submit forms created by Rails' button_to (form.add-to-cart)
  document.querySelectorAll('form.add-to-cart').forEach(function (form) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();

      var url = form.action || '/cart/add_item';
      var formData = new FormData(form);

      fetch(url, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': getCsrf(),
          'Accept': 'application/json'
        },
        body: formData,
        credentials: 'same-origin'
      }).then(function (res) {
        if (res.ok) {
          return res.json().catch(function(){ return {}; });
        }
        // non-OK responses: try to parse JSON error, otherwise throw
        return res.json().then(function (j) {
          throw j;
        }).catch(function () {
          throw new Error('Failed to add to cart');
        });
      }).then(function (json) {
        // success
        showToast(json.message || 'Added to cart');
        // Optionally update cart count on page here (if you return cart data)
        // Example: update a counter element with id 'cart-count'
        if (json.cart && document.getElementById('cart-count')) {
          document.getElementById('cart-count').textContent = (json.cart.cart_items || []).reduce(function(sum, it){ return sum + (it.quantity||0); }, 0);
        } else if (json.cart && json.cart.length) {
          // fallback if structure differs
        }
      }).catch(function (err) {
        // err may be an object with error key or message(s)
        var msg = (err && (err.error || err.message)) || 'Failed to add to cart';
        showToast(msg, true);
        console.error('Add to cart error:', err);
      });
    });
  });

  // Handle elements that are not forms but have data-product-id (for custom buttons)
  document.querySelectorAll('.add-to-cart[data-product-id]').forEach(function (el) {
    // if the element is inside a form, we already hooked the form submit above - skip
    if (el.closest('form')) return;

    el.addEventListener('click', function (e) {
      e.preventDefault();
      var productId = el.dataset.productId;
      var qty = el.dataset.quantity || 1;
      if (!productId) {
        showToast('Product not found', true);
        return;
      }

      fetch('/cart/add_item', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': getCsrf(),
          'Accept': 'application/json'
        },
        credentials: 'same-origin',
        body: JSON.stringify({ product_id: productId, quantity: qty })
      }).then(function (res) {
        if (res.ok) {
          return res.json().catch(function(){ return {}; });
        }
        return res.json().then(function (j) { throw j; }).catch(function () { throw new Error('Failed to add to cart'); });
      }).then(function (json) {
        showToast(json.message || 'Added to cart');
      }).catch(function (err) {
        var msg = (err && (err.error || err.message)) || 'Failed to add to cart';
        showToast(msg, true);
        console.error('Add to cart error:', err);
      });
    });
  });

  // Small UI effect for non-AJAX fallback (keeps previous behavior)
  document.body.addEventListener('click', function (e) {
    var btn = e.target.closest && e.target.closest('.add-to-cart');
    if (btn && btn.tagName !== 'FORM') {
      // visual feedback when button pressed
      btn.disabled = true;
      setTimeout(function () { try { btn.disabled = false; } catch (e) {} }, 900);
    }
  }, false);
});