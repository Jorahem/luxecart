// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "controllers"

// Mobile Menu Toggle
document.addEventListener('turbo:load', () => {
  const mobileMenuButton = document.getElementById('mobile-menu-button');
  const mobileMenu = document.getElementById('mobile-menu');
  
  if (mobileMenuButton && mobileMenu) {
    mobileMenuButton.addEventListener('click', () => {
      mobileMenu.classList.toggle('hidden');
    });
  }

  // Auto-hide alerts
  const alerts = document.querySelectorAll('.alert');
  alerts.forEach(alert => {
    setTimeout(() => {
      alert.style.opacity = '0';
      setTimeout(() => alert.remove(), 300);
    }, 5000);
  });

  // Smooth scroll
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      e.preventDefault();
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        target.scrollIntoView({
          behavior: 'smooth',
          block: 'start'
        });
      }
    });
  });

  // Add to cart animation
  const addToCartButtons = document.querySelectorAll('[data-add-to-cart]');
  addToCartButtons.forEach(button => {
    button.addEventListener('click', () => {
      button.classList.add('scale-95');
      setTimeout(() => button.classList.remove('scale-95'), 200);
    });
  });

  // Image lazy loading
  const images = document.querySelectorAll('img[data-src]');
  const imageObserver = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const img = entry.target;
        img.src = img.dataset.src;
        img.classList.add('animate-fade-in');
        observer.unobserve(img);
      }
    });
  });

  images.forEach(img => imageObserver.observe(img));
});

// Form loading states
document.addEventListener('turbo:submit-start', (event) => {
  const submitButton = event.target.querySelector('[type="submit"]');
  if (submitButton) {
    submitButton.disabled = true;
    const originalText = submitButton.innerHTML;
    submitButton.dataset.originalText = originalText;
    submitButton.innerHTML = '<span class="spinner mr-2"></span> Processing...';
  }
});

document.addEventListener('turbo:submit-end', (event) => {
  const submitButton = event.target.querySelector('[type="submit"]');
  if (submitButton) {
    submitButton.disabled = false;
    submitButton.innerHTML = submitButton.dataset.originalText || 'Submit';
  }
});
