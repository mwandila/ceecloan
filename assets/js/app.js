// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Multi-step form stepper functionality
class FormStepper {
  constructor(formId, options = {}) {
    this.form = document.getElementById(formId);
    this.currentStep = 1;
    this.totalSteps = options.totalSteps || 6;
    this.steps = [];
    this.stepContainers = [];
    
    // Initialize stepper
    this.init();
  }
  
  init() {
    // Find all step containers
    this.stepContainers = Array.from(document.querySelectorAll('[data-step]'));
    this.totalSteps = this.stepContainers.length;
    
    // Hide all steps except the first one
    this.showStep(1);
    
    // Bind navigation events
    this.bindEvents();
  }
  
  bindEvents() {
    // Next step buttons
    document.addEventListener('click', (e) => {
      if (e.target.matches('[data-action="next-step"]') || e.target.closest('[data-action="next-step"]')) {
        e.preventDefault();
        this.nextStep();
      }
    });
    
    // Previous step buttons
    document.addEventListener('click', (e) => {
      if (e.target.matches('[data-action="prev-step"]') || e.target.closest('[data-action="prev-step"]')) {
        e.preventDefault();
        this.previousStep();
      }
    });
    
    // Step indicator clicks
    document.addEventListener('click', (e) => {
      if (e.target.matches('[data-step-number]')) {
        e.preventDefault();
        const stepNumber = parseInt(e.target.dataset.stepNumber);
        if (stepNumber <= this.currentStep) {
          this.goToStep(stepNumber);
        }
      }
    });
    
    // Form submission handling
    document.addEventListener('click', (e) => {
      if (e.target.matches('[data-action="submit-form"]') || e.target.closest('[data-action="submit-form"]')) {
        e.preventDefault();
        this.submitForm();
      }
    });
  }
  
  showStep(stepNumber) {
    // Hide all steps
    this.stepContainers.forEach((container, index) => {
      if (index + 1 === stepNumber) {
        container.style.display = 'block';
        container.classList.add('active');
      } else {
        container.style.display = 'none';
        container.classList.remove('active');
      }
    });
    
    // Update navigation buttons
    this.updateNavigationButtons(stepNumber);
    
    this.currentStep = stepNumber;
  }
  
  updateNavigationButtons(currentStep) {
    const prevButton = document.querySelector('[data-action="prev-step"]');
    const nextButton = document.querySelector('[data-action="next-step"]');
    const submitButton = document.querySelector('button[type="submit"]');
    const stepCounter = document.querySelector('[data-step-counter]');
    
    // Update previous button
    if (prevButton) {
      if (currentStep > 1) {
        prevButton.style.display = 'inline-flex';
        prevButton.disabled = false;
      } else {
        prevButton.style.display = 'none';
      }
    }
    
    // Update next/submit button
    if (currentStep < this.totalSteps) {
      if (nextButton) {
        nextButton.style.display = 'inline-flex';
        nextButton.disabled = false;
      }
      if (submitButton) {
        submitButton.style.display = 'none';
      }
    } else {
      if (nextButton) {
        nextButton.style.display = 'none';
      }
      if (submitButton) {
        submitButton.style.display = 'inline-flex';
      }
    }
    
    // Update step counter
    if (stepCounter) {
      stepCounter.textContent = `Step ${currentStep} of ${this.totalSteps}`;
    }
  }
  
  validateCurrentStep() {
    const currentContainer = this.stepContainers[this.currentStep - 1];
    if (!currentContainer) return true;
    
    const requiredFields = currentContainer.querySelectorAll('[required]');
    let isValid = true;
    
    requiredFields.forEach(field => {
      if (!field.checkValidity()) {
        isValid = false;
        field.classList.add('border-red-300');
        field.focus();
        
        // Show error message
        this.showFieldError(field, 'This field is required');
      } else {
        field.classList.remove('border-red-300');
        this.hideFieldError(field);
      }
    });
    
    return isValid;
  }
  
  showFieldError(field, message) {
    // Remove existing error
    this.hideFieldError(field);
    
    const errorDiv = document.createElement('div');
    errorDiv.className = 'field-error text-red-600 text-sm mt-1';
    errorDiv.textContent = message;
    
    field.parentNode.appendChild(errorDiv);
  }
  
  hideFieldError(field) {
    const existingError = field.parentNode.querySelector('.field-error');
    if (existingError) {
      existingError.remove();
    }
  }
  
  nextStep() {
    if (this.currentStep < this.totalSteps && this.validateCurrentStep()) {
      this.showStep(this.currentStep + 1);
      this.scrollToTop();
    }
  }
  
  previousStep() {
    if (this.currentStep > 1) {
      this.showStep(this.currentStep - 1);
      this.scrollToTop();
    }
  }
  
  goToStep(stepNumber) {
    if (stepNumber >= 1 && stepNumber <= this.totalSteps) {
      this.showStep(stepNumber);
      this.scrollToTop();
    }
  }
  
  scrollToTop() {
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    });
  }
  
  submitForm() {
    // Validate the current step (final step)
    if (this.validateCurrentStep()) {
      // Show loading state on submit button
      const submitButton = document.querySelector('[data-action="submit-form"]');
      if (submitButton) {
        const originalText = submitButton.innerHTML;
        submitButton.disabled = true;
        submitButton.innerHTML = `
          <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          Submitting...
        `;
        
        // Submit the form after a short delay to show loading state
        setTimeout(() => {
          this.form.submit();
        }, 500);
      } else {
        // Fallback if button not found
        this.form.submit();
      }
    } else {
      // Show error message if validation fails
      alert('Please fill in all required fields before submitting.');
    }
  }
  
  // Public methods
  getCurrentStep() {
    return this.currentStep;
  }
  
  getTotalSteps() {
    return this.totalSteps;
  }
}

// Auto-initialize stepper when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
  const stepperForm = document.querySelector('[data-stepper-form]');
  if (stepperForm) {
    window.formStepper = new FormStepper(stepperForm.id);
  }
});

// Form validation feedback
document.addEventListener('input', function(e) {
  if (e.target.matches('input, select, textarea')) {
    const field = e.target;
    
    if (field.checkValidity()) {
      field.classList.remove('border-red-300');
      field.classList.add('border-green-300');
      
      // Hide error message
      const errorElement = field.parentNode.querySelector('.field-error');
      if (errorElement) {
        errorElement.remove();
      }
    } else {
      field.classList.remove('border-green-300');
      field.classList.add('border-red-300');
    }
  }
});

