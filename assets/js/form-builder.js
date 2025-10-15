// Form Builder JavaScript
class FormBuilder {
  constructor() {
    this.formSchema = window.formBuilderConfig?.formSchema || { sections: [] };
    this.updateUrl = window.formBuilderConfig?.updateUrl;
    this.currentFieldId = null;
    this.fieldCounter = 0;
    
    this.init();
  }

  init() {
    this.setupDragAndDrop();
    this.setupEventListeners();
    this.renderFormCanvas();
  }

  setupDragAndDrop() {
    // Make field palette items draggable
    const paletteItems = document.querySelectorAll('[data-field-type]');
    paletteItems.forEach(item => {
      item.addEventListener('dragstart', this.handleDragStart.bind(this));
    });

    // Setup drop zone
    const dropZone = document.getElementById('drop-zone');
    const formCanvas = document.getElementById('form-canvas');
    
    [dropZone, formCanvas].forEach(zone => {
      zone.addEventListener('dragover', this.handleDragOver.bind(this));
      zone.addEventListener('drop', this.handleDrop.bind(this));
    });
  }

  setupEventListeners() {
    // Save form button
    const saveBtn = document.getElementById('save-form-btn');
    if (saveBtn) {
      saveBtn.addEventListener('click', this.saveForm.bind(this));
    }

    // Add section button
    const addSectionBtn = document.getElementById('add-section-btn');
    if (addSectionBtn) {
      addSectionBtn.addEventListener('click', this.addSection.bind(this));
    }
  }

  handleDragStart(e) {
    const fieldType = e.target.getAttribute('data-field-type');
    e.dataTransfer.setData('text/plain', fieldType);
    e.dataTransfer.effectAllowed = 'copy';
  }

  handleDragOver(e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'copy';
    
    // Add visual feedback
    const dropZone = document.getElementById('drop-zone');
    if (e.target === dropZone || dropZone.contains(e.target)) {
      dropZone.classList.add('border-indigo-500', 'bg-indigo-50', 'dark:bg-indigo-900/20');
    }
  }

  handleDrop(e) {
    e.preventDefault();
    const fieldType = e.dataTransfer.getData('text/plain');
    
    // Remove visual feedback
    const dropZone = document.getElementById('drop-zone');
    dropZone.classList.remove('border-indigo-500', 'bg-indigo-50', 'dark:bg-indigo-900/20');
    
    this.addField(fieldType);
  }

  addField(fieldType) {
    this.fieldCounter++;
    const fieldId = `field_${this.fieldCounter}`;
    
    const field = {
      id: fieldId,
      name: `${fieldType}_${this.fieldCounter}`,
      label: this.getDefaultLabel(fieldType),
      type: fieldType,
      required: false,
      ...this.getDefaultFieldConfig(fieldType)
    };

    // Add to schema
    if (!this.formSchema.sections || this.formSchema.sections.length === 0) {
      this.formSchema.sections = [{
        id: 'section_1',
        name: 'General Information',
        fields: []
      }];
    }

    this.formSchema.sections[0].fields.push(field);
    this.renderFormCanvas();
    this.selectField(fieldId);
  }

  addSection() {
    const sectionName = prompt('Enter section name:');
    if (!sectionName) return;

    const sectionId = `section_${Date.now()}`;
    const section = {
      id: sectionId,
      name: sectionName,
      fields: []
    };

    if (!this.formSchema.sections) {
      this.formSchema.sections = [];
    }

    this.formSchema.sections.push(section);
    this.renderFormCanvas();
  }

  getDefaultLabel(fieldType) {
    const labels = {
      text: 'Text Input',
      number: 'Number Input',
      date: 'Date',
      select: 'Select Option',
      multiselect: 'Multiple Choice',
      textarea: 'Text Area',
      radio: 'Radio Selection',
      checkbox: 'Checkbox',
      file: 'File Upload',
      photo: 'Photo',
      gps: 'GPS Location',
      signature: 'Signature'
    };
    return labels[fieldType] || fieldType;
  }

  getDefaultFieldConfig(fieldType) {
    const configs = {
      select: { options: ['Option 1', 'Option 2', 'Option 3'] },
      multiselect: { options: ['Option 1', 'Option 2', 'Option 3'] },
      radio: { options: ['Option 1', 'Option 2', 'Option 3'] },
      number: { min: null, max: null },
      text: { placeholder: 'Enter text here' },
      textarea: { placeholder: 'Enter text here', rows: 3 }
    };
    return configs[fieldType] || {};
  }

  renderFormCanvas() {
    const formCanvas = document.getElementById('form-canvas');
    const dropZone = document.getElementById('drop-zone');
    
    if (!this.formSchema.sections || this.formSchema.sections.length === 0) {
      dropZone.style.display = 'block';
      // Clear any existing fields
      const existingFields = formCanvas.querySelectorAll('.form-field');
      existingFields.forEach(field => field.remove());
      return;
    }

    dropZone.style.display = 'none';
    
    // Clear canvas
    const existingFields = formCanvas.querySelectorAll('.form-field, .form-section');
    existingFields.forEach(field => field.remove());

    // Render sections and fields
    this.formSchema.sections.forEach(section => {
      const sectionElement = this.createSectionElement(section);
      formCanvas.appendChild(sectionElement);
      
      section.fields.forEach(field => {
        const fieldElement = this.createFieldElement(field);
        sectionElement.appendChild(fieldElement);
      });
    });
  }

  createSectionElement(section) {
    const sectionDiv = document.createElement('div');
    sectionDiv.className = 'form-section bg-gray-50 dark:bg-gray-800 rounded-lg p-4 mb-4';
    sectionDiv.setAttribute('data-section-id', section.id);
    
    sectionDiv.innerHTML = `
      <div class="flex justify-between items-center mb-3">
        <h4 class="text-lg font-medium text-gray-900 dark:text-gray-100">${section.name}</h4>
        <div class="flex space-x-2">
          <button class="text-sm text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200" onclick="formBuilder.editSection('${section.id}')">
            Edit
          </button>
          <button class="text-sm text-red-500 hover:text-red-700 dark:text-red-400 dark:hover:text-red-200" onclick="formBuilder.deleteSection('${section.id}')">
            Delete
          </button>
        </div>
      </div>
    `;
    
    return sectionDiv;
  }

  createFieldElement(field) {
    const fieldDiv = document.createElement('div');
    fieldDiv.className = 'form-field bg-white dark:bg-background-dark border border-gray-200 dark:border-gray-700 rounded-lg p-4 mb-3 cursor-pointer hover:border-indigo-500 transition-colors';
    fieldDiv.setAttribute('data-field-id', field.id);
    fieldDiv.onclick = () => this.selectField(field.id);
    
    const requiredBadge = field.required ? 
      '<span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200">Required</span>' : 
      '';
    
    fieldDiv.innerHTML = `
      <div class="flex justify-between items-start mb-2">
        <div class="flex-1">
          <div class="flex items-center space-x-2">
            <span class="font-medium text-gray-900 dark:text-gray-100">${field.label}</span>
            ${requiredBadge}
          </div>
          <div class="text-sm text-gray-500 dark:text-gray-400 mt-1">${field.type} • ${field.name}</div>
        </div>
        <div class="flex space-x-2">
          <button class="text-sm text-gray-400 hover:text-gray-600 dark:hover:text-gray-200" onclick="event.stopPropagation(); formBuilder.duplicateField('${field.id}')">
            Copy
          </button>
          <button class="text-sm text-red-400 hover:text-red-600 dark:hover:text-red-200" onclick="event.stopPropagation(); formBuilder.deleteField('${field.id}')">
            Delete
          </button>
        </div>
      </div>
      <div class="preview-area">
        ${this.renderFieldPreview(field)}
      </div>
    `;
    
    return fieldDiv;
  }

  renderFieldPreview(field) {
    // This will render a preview of how the field will look
    const previewFunctions = {
      text: () => `<input type="text" placeholder="${field.placeholder || field.label}" class="w-full p-2 border border-gray-300 rounded text-sm" readonly />`,
      number: () => `<input type="number" placeholder="${field.label}" class="w-full p-2 border border-gray-300 rounded text-sm" readonly />`,
      date: () => `<input type="date" class="w-full p-2 border border-gray-300 rounded text-sm" readonly />`,
      textarea: () => `<textarea placeholder="${field.placeholder || field.label}" class="w-full p-2 border border-gray-300 rounded text-sm" rows="${field.rows || 3}" readonly></textarea>`,
      select: () => {
        const options = (field.options || []).map(opt => `<option>${opt}</option>`).join('');
        return `<select class="w-full p-2 border border-gray-300 rounded text-sm" disabled><option>Select ${field.label}</option>${options}</select>`;
      },
      radio: () => {
        const radios = (field.options || []).map(opt => 
          `<label class="flex items-center space-x-2 text-sm"><input type="radio" name="preview_${field.id}" disabled /><span>${opt}</span></label>`
        ).join('');
        return `<div class="space-y-1">${radios}</div>`;
      },
      checkbox: () => `<label class="flex items-center space-x-2 text-sm"><input type="checkbox" disabled /><span>${field.label}</span></label>`,
    };

    const renderFn = previewFunctions[field.type];
    return renderFn ? renderFn() : `<div class="text-gray-500 text-sm">${field.type} field</div>`;
  }

  selectField(fieldId) {
    // Remove previous selection
    document.querySelectorAll('.form-field').forEach(el => {
      el.classList.remove('border-indigo-500', 'bg-indigo-50', 'dark:bg-indigo-900/20');
    });
    
    // Highlight selected field
    const fieldElement = document.querySelector(`[data-field-id="${fieldId}"]`);
    if (fieldElement) {
      fieldElement.classList.add('border-indigo-500', 'bg-indigo-50', 'dark:bg-indigo-900/20');
    }
    
    this.currentFieldId = fieldId;
    this.showFieldProperties(fieldId);
  }

  showFieldProperties(fieldId) {
    const field = this.findField(fieldId);
    if (!field) return;

    const propertiesPanel = document.getElementById('field-properties');
    propertiesPanel.innerHTML = this.renderFieldProperties(field);
    
    // Attach event listeners for property changes
    this.attachPropertyListeners(fieldId);
  }

  findField(fieldId) {
    if (!this.formSchema.sections) return null;
    
    for (const section of this.formSchema.sections) {
      const field = section.fields.find(f => f.id === fieldId);
      if (field) return field;
    }
    return null;
  }

  renderFieldProperties(field) {
    let html = `
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Label</label>
          <input type="text" name="label" value="${field.label}" class="mt-1 block w-full border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-gray-800 dark:text-gray-100">
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Field Name</label>
          <input type="text" name="name" value="${field.name}" class="mt-1 block w-full border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-gray-800 dark:text-gray-100">
        </div>
    `;

    // Add type-specific properties
    if (field.type === 'text' || field.type === 'textarea') {
      html += `
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Placeholder</label>
          <input type="text" name="placeholder" value="${field.placeholder || ''}" class="mt-1 block w-full border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-gray-800 dark:text-gray-100">
        </div>
      `;
    }

    if (field.type === 'textarea') {
      html += `
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Rows</label>
          <input type="number" name="rows" value="${field.rows || 3}" min="1" max="10" class="mt-1 block w-full border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-gray-800 dark:text-gray-100">
        </div>
      `;
    }

    if (['select', 'multiselect', 'radio'].includes(field.type)) {
      const optionsText = (field.options || []).join('\n');
      html += `
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Options (one per line)</label>
          <textarea name="options" rows="4" class="mt-1 block w-full border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-gray-800 dark:text-gray-100">${optionsText}</textarea>
        </div>
      `;
    }

    if (field.type === 'number') {
      html += `
        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Min Value</label>
            <input type="number" name="min" value="${field.min || ''}" class="mt-1 block w-full border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-gray-800 dark:text-gray-100">
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Max Value</label>
            <input type="number" name="max" value="${field.max || ''}" class="mt-1 block w-full border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm dark:bg-gray-800 dark:text-gray-100">
          </div>
        </div>
      `;
    }

    html += `
        <div class="flex items-center">
          <input type="checkbox" name="required" ${field.required ? 'checked' : ''} class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded">
          <label class="ml-2 block text-sm text-gray-900 dark:text-gray-100">Required field</label>
        </div>
      </div>
    `;

    return html;
  }

  attachPropertyListeners(fieldId) {
    const propertiesPanel = document.getElementById('field-properties');
    const inputs = propertiesPanel.querySelectorAll('input, textarea, select');
    
    inputs.forEach(input => {
      input.addEventListener('input', (e) => {
        this.updateFieldProperty(fieldId, e.target.name, e.target.value, e.target.type === 'checkbox' ? e.target.checked : undefined);
      });
    });
  }

  updateFieldProperty(fieldId, property, value, checked) {
    const field = this.findField(fieldId);
    if (!field) return;

    if (property === 'required') {
      field[property] = checked;
    } else if (property === 'options') {
      field[property] = value.split('\n').filter(opt => opt.trim());
    } else if (property === 'rows' || property === 'min' || property === 'max') {
      field[property] = value ? parseInt(value) : null;
    } else {
      field[property] = value;
    }

    // Re-render the form canvas to show changes
    this.renderFormCanvas();
    this.selectField(fieldId); // Re-select the field
  }

  duplicateField(fieldId) {
    const field = this.findField(fieldId);
    if (!field) return;

    this.fieldCounter++;
    const newField = {
      ...field,
      id: `field_${this.fieldCounter}`,
      name: `${field.type}_${this.fieldCounter}`,
      label: `${field.label} (Copy)`
    };

    // Find the section containing this field and add the duplicate
    for (const section of this.formSchema.sections) {
      const fieldIndex = section.fields.findIndex(f => f.id === fieldId);
      if (fieldIndex !== -1) {
        section.fields.splice(fieldIndex + 1, 0, newField);
        break;
      }
    }

    this.renderFormCanvas();
  }

  deleteField(fieldId) {
    if (!confirm('Are you sure you want to delete this field?')) return;

    for (const section of this.formSchema.sections) {
      const fieldIndex = section.fields.findIndex(f => f.id === fieldId);
      if (fieldIndex !== -1) {
        section.fields.splice(fieldIndex, 1);
        break;
      }
    }

    // Clear properties panel if this field was selected
    if (this.currentFieldId === fieldId) {
      this.currentFieldId = null;
      const propertiesPanel = document.getElementById('field-properties');
      propertiesPanel.innerHTML = `
        <div class="text-center text-gray-500 dark:text-gray-400 py-8">
          <svg class="mx-auto h-8 w-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          <p class="mt-2 text-sm">Select a field to edit its properties</p>
        </div>
      `;
    }

    this.renderFormCanvas();
  }

  editSection(sectionId) {
    const section = this.formSchema.sections.find(s => s.id === sectionId);
    if (!section) return;

    const newName = prompt('Enter section name:', section.name);
    if (newName && newName.trim()) {
      section.name = newName.trim();
      this.renderFormCanvas();
    }
  }

  deleteSection(sectionId) {
    const section = this.formSchema.sections.find(s => s.id === sectionId);
    if (!section) return;

    if (!confirm(`Are you sure you want to delete the section "${section.name}" and all its fields?`)) return;

    const sectionIndex = this.formSchema.sections.findIndex(s => s.id === sectionId);
    if (sectionIndex !== -1) {
      this.formSchema.sections.splice(sectionIndex, 1);
      this.renderFormCanvas();
    }
  }

  async saveForm() {
    if (!this.updateUrl) {
      alert('Update URL not configured');
      return;
    }

    const saveBtn = document.getElementById('save-form-btn');
    const originalText = saveBtn.innerHTML;
    
    // Show loading state
    saveBtn.disabled = true;
    saveBtn.innerHTML = `
      <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      Saving...
    `;

    try {
      const response = await fetch(this.updateUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
        },
        body: JSON.stringify({ form_schema: this.formSchema })
      });

      if (response.ok) {
        const result = await response.json();
        if (result.success) {
          // Show success message
          this.showNotification('Form saved successfully!', 'success');
        } else {
          throw new Error(result.message || 'Failed to save form');
        }
      } else {
        throw new Error('Server error');
      }
    } catch (error) {
      console.error('Error saving form:', error);
      this.showNotification('Error saving form: ' + error.message, 'error');
    } finally {
      // Restore button state
      saveBtn.disabled = false;
      saveBtn.innerHTML = originalText;
    }
  }

  showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `fixed top-4 right-4 z-50 px-4 py-3 rounded-md shadow-lg text-sm font-medium transition-all duration-300 ${
      type === 'success' ? 'bg-green-100 text-green-800 border border-green-200' :
      type === 'error' ? 'bg-red-100 text-red-800 border border-red-200' :
      'bg-blue-100 text-blue-800 border border-blue-200'
    }`;
    
    notification.textContent = message;
    document.body.appendChild(notification);

    // Remove after 3 seconds
    setTimeout(() => {
      notification.style.opacity = '0';
      notification.style.transform = 'translateX(100%)';
      setTimeout(() => {
        if (notification.parentNode) {
          notification.parentNode.removeChild(notification);
        }
      }, 300);
    }, 3000);
  }
}

// Initialize form builder when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  if (window.formBuilderConfig) {
    window.formBuilder = new FormBuilder();
  }
});