require 'redmine'

Redmine::Plugin.register :redmine_nis2_compliance do
  name 'Redmine NIS2 Compliance Plugin'
  author 'NIS2 Compliance Team'
  description 'Comprehensive NIS2 Directive compliance management for Redmine'
  version '0.1.0'
  url 'https://github.com/yourorg/redmine_nis2_compliance'
  author_url 'https://yourcompany.com'

  # Minimum Redmine version required
  requires_redmine version_or_higher: '5.0.0'

  # Register as a project module
  project_module :nis2_compliance do
    permission :view_nis2_compliance, {
      nis2_dashboard: [:index],
      nis2_gap_analyses: [:index, :show],
      nis2_controls: [:index, :show],
      nis2_assessments: [:show]
    }, read: true

    permission :manage_nis2_gap_analysis, {
      nis2_gap_analyses: [:new, :create, :edit, :update, :destroy, :review, :export],
      nis2_assessments: [:edit, :update, :create_issue]
    }

    permission :manage_nis2_controls, {
      nis2_controls: [:new, :create, :edit, :update, :destroy]
    }

    permission :export_nis2_reports, {
      nis2_reports: [:index, :show, :export]
    }

    permission :view_nis2_audit_log, {
      nis2_audit_logs: [:index, :show]
    }, read: true
  end

  # Add menu items to project menu
  menu :project_menu, :nis2_compliance,
       { controller: 'nis2_dashboard', action: 'index' },
       caption: 'NIS2 Compliance',
       after: :activity,
       param: :project_id,
       if: Proc.new { |p| p.module_enabled?(:nis2_compliance) }

  # Add menu items to admin menu
  menu :admin_menu, :nis2_controls,
       { controller: 'nis2_controls', action: 'index' },
       caption: 'NIS2 Controls',
       html: { class: 'icon icon-nis2-controls' }

  # Plugin settings
  settings default: {
    'enable_auto_issue_creation' => '1',
    'gap_analysis_reminder_days' => '90',
    'compliance_threshold' => '70',
    'enable_audit_logging' => '1',
    'default_reviewer_id' => nil,
    'notification_emails' => '',
    'critical_gap_notification' => '1',
    'overdue_reminder_frequency' => 'weekly'
  }, partial: 'settings/nis2_settings'
end

# Load hooks
require_dependency 'redmine_nis2_compliance/hooks'
