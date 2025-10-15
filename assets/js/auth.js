// Authentication page JavaScript
// This file is for auth pages that already have LiveView connections
// DO NOT initialize LiveSocket here as LiveView handles that automatically

// Basic form validation and UX enhancements for auth pages
document.addEventListener('DOMContentLoaded', function() {
  // Add any auth-specific JavaScript here that doesn't conflict with LiveView
  console.log('Auth page loaded');
  
  // Example: Add loading states to buttons
  const forms = document.querySelectorAll('form');
  forms.forEach(form => {
    form.addEventListener('submit', function(e) {
      const submitButton = form.querySelector('button[type="submit"]');
      if (submitButton && !submitButton.disabled) {
        // Let the form submit normally, don't prevent default
        setTimeout(() => {
          submitButton.disabled = true;
        }, 0);
      }
    });
  });
});