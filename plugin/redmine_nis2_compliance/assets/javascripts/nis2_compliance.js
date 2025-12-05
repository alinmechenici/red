/* NIS2 Compliance Plugin JavaScript */

(function() {
  'use strict';

  // Initialize when DOM is ready
  document.addEventListener('DOMContentLoaded', function() {
    initNis2Plugin();
  });

  function initNis2Plugin() {
    initAssessmentForm();
    initConfirmDialogs();
    initTooltips();
  }

  // Assessment form dynamic behavior
  function initAssessmentForm() {
    var statusSelect = document.querySelector('.implementation-status-select');
    if (!statusSelect) return;

    var detailsSection = document.querySelector('.implementation-details-section');
    var gapSection = document.querySelector('.gap-section');
    var completionSection = document.querySelector('.completion-section');

    statusSelect.addEventListener('change', function() {
      var status = this.value;

      // Show/hide details section
      if (status === 'not_applicable') {
        if (detailsSection) detailsSection.style.display = 'none';
      } else {
        if (detailsSection) detailsSection.style.display = 'block';
      }

      // Show/hide gap section
      if (status === 'not_implemented' || status === 'partially_implemented') {
        if (gapSection) gapSection.style.display = 'block';
      } else {
        if (gapSection) gapSection.style.display = 'none';
      }

      // Show/hide completion section
      if (status === 'implemented') {
        if (completionSection) completionSection.style.display = 'block';
      } else {
        if (completionSection) completionSection.style.display = 'none';
      }
    });
  }

  // Add confirmation dialogs for destructive actions
  function initConfirmDialogs() {
    var deleteLinks = document.querySelectorAll('a[data-confirm]');
    deleteLinks.forEach(function(link) {
      link.addEventListener('click', function(e) {
        var message = this.getAttribute('data-confirm');
        if (!confirm(message)) {
          e.preventDefault();
          e.stopPropagation();
          return false;
        }
      });
    });
  }

  // Simple tooltips
  function initTooltips() {
    var tooltipElements = document.querySelectorAll('[data-tooltip]');
    tooltipElements.forEach(function(element) {
      element.setAttribute('title', element.getAttribute('data-tooltip'));
    });
  }

  // Utility function to show/hide elements
  window.nis2ToggleElement = function(id) {
    var element = document.getElementById(id);
    if (element) {
      element.style.display = element.style.display === 'none' ? 'block' : 'none';
    }
  };

  // Utility function to calculate compliance score display
  window.nis2UpdateComplianceDisplay = function(score) {
    var gauges = document.querySelectorAll('.compliance-gauge');
    gauges.forEach(function(gauge) {
      var fill = gauge.querySelector('.gauge-fill');
      if (fill) {
        fill.style.width = score + '%';
      }
      var text = gauge.querySelector('.gauge-text');
      if (text) {
        text.textContent = Math.round(score) + '%';
      }
    });
  };

})();
