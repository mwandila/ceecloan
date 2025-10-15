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
    
    // Update stepper indicators
    this.updateStepperIndicators(stepNumber);
    
    // Update navigation buttons
    this.updateNavigationButtons(stepNumber);
    
    this.currentStep = stepNumber;
  }
  
  updateStepperIndicators(currentStep) {
    const stepIndicators = document.querySelectorAll('[data-step-indicator]');
    
    stepIndicators.forEach((indicator, index) => {
      const stepNumber = index + 1;
      const circle = indicator.querySelector('.step-circle');
      const label = indicator.querySelector('.step-label');
      
      if (stepNumber < currentStep) {
        // Completed step
        circle.className = 'step-circle flex h-8 w-8 items-center justify-center rounded-full bg-indigo-600 hover:bg-indigo-900';
        circle.innerHTML = `
          <svg class="h-5 w-5 text-white" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
          </svg>
        `;
        if (label) label.className = 'step-label text-xs font-medium text-indigo-600';
      } else if (stepNumber === currentStep) {
        // Current step
        circle.className = 'step-circle flex h-8 w-8 items-center justify-center rounded-full border-2 border-indigo-600 bg-white';
        circle.innerHTML = `<span class="text-indigo-600 text-sm font-medium">${stepNumber}</span>`;
        if (label) label.className = 'step-label text-xs font-medium text-indigo-600';
      } else {
        // Future step
        circle.className = 'step-circle flex h-8 w-8 items-center justify-center rounded-full border-2 border-gray-300 bg-white group-hover:border-gray-400';
        circle.innerHTML = `<span class="text-gray-500 text-sm font-medium group-hover:text-gray-900">${stepNumber}</span>`;
        if (label) label.className = 'step-label text-xs font-medium text-gray-500';
      }
      
      // Update connecting lines
      const line = indicator.querySelector('.step-line');
      if (line) {
        if (currentStep > stepNumber) {
          line.className = 'step-line h-0.5 w-full bg-indigo-600';
        } else {
          line.className = 'step-line h-0.5 w-full bg-gray-200';
        }
      }
    });
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

// Smooth scrolling for anchor links
document.addEventListener('click', function(e) {
  if (e.target.matches('a[href^="#"]')) {
    e.preventDefault();
    const targetId = e.target.getAttribute('href');
    const targetElement = document.querySelector(targetId);
    
    if (targetElement) {
      targetElement.scrollIntoView({
        behavior: 'smooth',
        block: 'start'
      });
    }
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

// Progress saving (optional - can be enhanced to save to localStorage)
function saveProgress() {
  if (window.formStepper) {
    const formData = new FormData(document.querySelector('[data-stepper-form]'));
    const data = Object.fromEntries(formData.entries());
    
    localStorage.setItem('ceec_form_progress', JSON.stringify({
      step: window.formStepper.getCurrentStep(),
      data: data,
      timestamp: new Date().toISOString()
    }));
  }
}

// Load saved progress
function loadProgress() {
  const saved = localStorage.getItem('ceec_form_progress');
  if (saved && window.formStepper) {
    try {
      const progress = JSON.parse(saved);
      
      // Restore form data
      Object.entries(progress.data).forEach(([name, value]) => {
        const field = document.querySelector(`[name="${name}"]`);
        if (field) {
          field.value = value;
        }
      });
      
      // Go to saved step
      window.formStepper.goToStep(progress.step);
      
      console.log('Progress restored from:', progress.timestamp);
    } catch (e) {
      console.warn('Could not load saved progress:', e);
    }
  }
}

// Auto-save progress on step change
document.addEventListener('click', function(e) {
  if (e.target.matches('[data-action="next-step"], [data-action="prev-step"]')) {
    setTimeout(saveProgress, 100); // Save after step transition
  }
});