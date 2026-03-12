(function () {
  function getCsrf() {
    var meta = document.querySelector('meta[name="csrf-token"]');
    return meta && meta.content;
  }

  function updateBadge(count) {
    var el = document.getElementById('cart-count');
    if (!el) return;
    el.textContent = count;
  }

  function formatNPR(amount) {
    return new Intl.NumberFormat('en-NP', {
      style: 'currency',
      currency: 'NPR',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(amount);
  }

  function recalcTotal() {
    var total = 0.0;

    document.querySelectorAll('tbody#cart-rows tr[data-product-id]').forEach(function (row) {
      var price = parseFloat(row.dataset.price || '0');
      var qtyEl = row.querySelector('.qty-value');
      if (!qtyEl) return;

      var qty = parseInt(qtyEl.textContent || '0', 10);
      if (isNaN(qty)) qty = 0;

      var subtotal = price * qty;
      total += subtotal;

      var subtotalEl = row.querySelector('.row-subtotal');
      if (subtotalEl) {
        subtotalEl.textContent = formatNPR(subtotal);
      }
    });

    var totalEl = document.getElementById('cart-total');
    if (totalEl) {
      totalEl.textContent = formatNPR(total);
    }
  }

  async function postAdd(productId) {
    try {
      var body = new URLSearchParams({ product_id: productId }).toString();
      var res = await fetch('/cart/add_item', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': getCsrf(),
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        credentials: 'same-origin',
        body: body
      });
      if (!res.ok) return null;
      var ct = res.headers.get('content-type') || '';
      return ct.indexOf('application/json') !== -1 ? await res.json() : null;
    } catch (err) {
      console.error(err);
      alert('Could not update the cart. Please try again.');
      return null;
    }
  }

  async function patchUpdate(productId, quantity) {
    try {
      var body = new URLSearchParams({ quantity: quantity }).toString();
      var res = await fetch('/cart/update_item/' + encodeURIComponent(productId), {
        method: 'PATCH',
        headers: {
          'X-CSRF-Token': getCsrf(),
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        credentials: 'same-origin',
        body: body
      });
      if (!res.ok) return null;
      var ct = res.headers.get('content-type') || '';
      return ct.indexOf('application/json') !== -1 ? await res.json() : null;
    } catch (err) {
      console.error(err);
      alert('Could not update the cart. Please try again.');
      return null;
    }
  }

  async function deleteRemove(productId) {
    try {
      var res = await fetch('/cart/remove_item/' + encodeURIComponent(productId), {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': getCsrf(),
          'Accept': 'application/json'
        },
        credentials: 'same-origin'
      });
      if (!res.ok) return null;
      var ct = res.headers.get('content-type') || '';
      return ct.indexOf('application/json') !== -1 ? await res.json() : null;
    } catch (err) {
      console.error(err);
      alert('Could not update the cart. Please try again.');
      return null;
    }
  }

  function bindCartRows() {
    document.querySelectorAll('tbody#cart-rows tr[data-product-id]').forEach(function (row) {
      var productId = row.dataset.productId;
      var incBtn    = row.querySelector('.increase-qty');
      var decBtn    = row.querySelector('.decrease-qty');
      var qtyEl     = row.querySelector('.qty-value');
      var removeBtn = row.querySelector('.remove-item');

      if (!qtyEl) return;

      if (incBtn) {
        incBtn.addEventListener('click', async function () {
          incBtn.disabled = true;
          var data = await postAdd(productId);
          incBtn.disabled = false;

          if (data && data.cart) {
            var newQty = (data.cart[productId] || qtyEl.textContent).toString();
            qtyEl.textContent = newQty;
            if (typeof data.cart_count !== 'undefined') updateBadge(data.cart_count);
            recalcTotal();
          } else if (data === null) {
            window.location.reload();
          }
        });
      }

      if (decBtn) {
        decBtn.addEventListener('click', async function () {
          var currentQty = parseInt(qtyEl.textContent || '0', 10);
          if (isNaN(currentQty) || currentQty <= 0) currentQty = 1;

          if (currentQty <= 1) {
            if (!confirm('Remove this item from your cart?')) return;
            decBtn.disabled = true;
            var dataDel = await deleteRemove(productId);
            decBtn.disabled = false;

            if (dataDel && dataDel.cart) {
              if (!dataDel.cart[productId] || parseInt(dataDel.cart[productId], 10) <= 0) {
                row.remove();
              }
              if (typeof dataDel.cart_count !== 'undefined') updateBadge(dataDel.cart_count);
              recalcTotal();
            } else if (dataDel === null) {
              window.location.reload();
            }
            return;
          }

          var newQty = currentQty - 1;
          decBtn.disabled = true;
          var dataPatch = await patchUpdate(productId, newQty);
          decBtn.disabled = false;

          if (dataPatch && dataPatch.cart) {
            qtyEl.textContent = dataPatch.cart[productId] || newQty;
            if (typeof dataPatch.cart_count !== 'undefined') updateBadge(dataPatch.cart_count);
            recalcTotal();
            if (!dataPatch.cart[productId] || parseInt(dataPatch.cart[productId], 10) <= 0) {
              row.remove();
            }
          } else if (dataPatch === null) {
            window.location.reload();
          }
        });
      }

      if (removeBtn) {
        removeBtn.addEventListener('click', async function () {
          if (!confirm('Remove this item from your cart?')) return;
          removeBtn.disabled = true;
          var data = await deleteRemove(productId);
          removeBtn.disabled = false;

          if (data && data.cart) {
            row.remove();
            if (typeof data.cart_count !== 'undefined') updateBadge(data.cart_count);
            recalcTotal();
          } else if (data === null) {
            window.location.reload();
          }
        });
      }
    });
  }

  function initCart() {
    bindCartRows();
    recalcTotal(); // ensure totals correct on initial load
  }

  document.addEventListener('DOMContentLoaded', initCart);
  document.addEventListener('turbo:load', initCart);
})();