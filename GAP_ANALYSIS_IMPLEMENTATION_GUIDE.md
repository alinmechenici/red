# NIS2 Gap Analysis Module - Implementation Guide

## Quick Start: Building the Gap Analysis Module

This guide provides step-by-step instructions for implementing the Gap Analysis module as the foundation of the NIS2 Compliance Plugin for Redmine.

---

## Phase 1: Plugin Foundation (Week 1)

### 1.1 Create Plugin Structure

```bash
cd /path/to/redmine/plugins
mkdir redmine_nis2_compliance
cd redmine_nis2_compliance
```

### 1.2 Initialize Plugin (init.rb)

```ruby
# init.rb
Redmine::Plugin.register :redmine_nis2_compliance do
  name 'Redmine NIS2 Compliance Plugin'
  author 'Your Organization'
  description 'Comprehensive NIS2 compliance management for Redmine'
  version '0.1.0'
  url 'https://github.com/yourorg/redmine_nis2_compliance'
  author_url 'https://yourcompany.com'

  # Register as a project module
  project_module :nis2_compliance do
    permission :view_nis2_compliance, {
      nis2_dashboard: [:index],
      nis2_gap_analyses: [:index, :show],
      nis2_controls: [:index, :show]
    }
    permission :manage_nis2_gap_analysis, {
      nis2_gap_analyses: [:new, :create, :edit, :update, :destroy],
      nis2_assessments: [:create, :update, :destroy]
    }
    permission :manage_nis2_controls, {
      nis2_controls: [:new, :create, :edit, :update, :destroy]
    }
    permission :export_nis2_reports, {
      nis2_reports: [:show, :export]
    }
  end

  # Add menu items
  menu :project_menu, :nis2_compliance,
       { controller: 'nis2_dashboard', action: 'index' },
       caption: 'NIS2 Compliance',
       after: :activity,
       param: :project_id

  menu :admin_menu, :nis2_controls,
       { controller: 'nis2_controls', action: 'index' },
       caption: 'NIS2 Controls'

  # Settings
  settings default: {
    'enable_auto_issue_creation' => true,
    'gap_analysis_reminder_days' => 90,
    'compliance_threshold' => 70
  }, partial: 'settings/nis2_settings'
end

# Load hooks
require_dependency 'redmine_nis2_compliance/hooks'
```

### 1.3 Create Directory Structure

```bash
mkdir -p app/{controllers,models,views,helpers}
mkdir -p app/views/{nis2_dashboard,nis2_gap_analyses,nis2_controls,nis2_assessments}
mkdir -p lib/redmine_nis2_compliance/{patches,services}
mkdir -p db/migrate
mkdir -p assets/{stylesheets,javascripts,images}
mkdir -p config/locales
mkdir -p test/{unit,functional,integration}
```

---

## Phase 2: Database Schema (Week 1)

### 2.1 Create Migration for Core Tables

```ruby
# db/migrate/001_create_nis2_tables.rb
class CreateNis2Tables < ActiveRecord::Migration[6.1]
  def change
    # Controls (NIS2 requirements catalog)
    create_table :nis2_controls do |t|
      t.string :control_id, null: false, index: true
      t.string :category, null: false
      t.string :domain
      t.string :title, null: false
      t.text :description
      t.text :requirement_text
      t.text :implementation_guidance
      t.text :verification_methods
      t.text :evidence_types
      t.text :iso27001_mapping
      t.string :priority, default: 'medium'
      t.integer :effort_estimate
      t.string :typical_implementation_time
      t.integer :position
      t.boolean :is_active, default: true
      t.timestamps
    end

    # Gap Analyses
    create_table :nis2_gap_analyses do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :status, default: 'draft'
      t.date :assessment_date
      t.references :assessor, foreign_key: { to_table: :users }
      t.references :reviewer, foreign_key: { to_table: :users }
      t.decimal :overall_compliance_score, precision: 5, scale: 2
      t.decimal :risk_management_score, precision: 5, scale: 2
      t.decimal :accountability_score, precision: 5, scale: 2
      t.decimal :reporting_score, precision: 5, scale: 2
      t.decimal :business_continuity_score, precision: 5, scale: 2
      t.date :target_completion_date
      t.date :reviewed_at
      t.timestamps
    end

    # Control Assessments (gap analysis findings per control)
    create_table :nis2_control_assessments do |t|
      t.references :gap_analysis, null: false, foreign_key: { to_table: :nis2_gap_analyses }
      t.references :control, null: false, foreign_key: { to_table: :nis2_controls }
      t.string :implementation_status, default: 'not_implemented'
      t.decimal :compliance_score, precision: 5, scale: 2
      t.text :implementation_details
      t.text :gap_description
      t.text :impact_assessment
      t.text :root_cause
      t.text :recommendations
      t.string :priority
      t.references :responsible_user, foreign_key: { to_table: :users }
      t.date :target_completion_date
      t.date :actual_completion_date
      t.references :linked_issue, foreign_key: { to_table: :issues }
      t.decimal :estimated_effort_days, precision: 5, scale: 1
      t.decimal :estimated_cost, precision: 10, scale: 2
      t.timestamps
    end

    # Evidence
    create_table :nis2_evidence do |t|
      t.string :title, null: false
      t.text :description
      t.string :evidence_type
      t.references :attachment, foreign_key: true
      t.string :related_type
      t.integer :related_id
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }
      t.date :valid_until
      t.boolean :is_approved, default: false
      t.references :approved_by, foreign_key: { to_table: :users }
      t.date :approved_at
      t.timestamps
    end
    add_index :nis2_evidence, [:related_type, :related_id]

    # Audit Logs
    create_table :nis2_audit_logs do |t|
      t.references :user, foreign_key: true
      t.string :action, null: false
      t.string :auditable_type
      t.integer :auditable_id
      t.text :changes
      t.string :ip_address
      t.string :user_agent
      t.timestamps
    end
    add_index :nis2_audit_logs, [:auditable_type, :auditable_id]
    add_index :nis2_audit_logs, :created_at
  end
end
```

### 2.2 Run Migration

```bash
cd /path/to/redmine
rake redmine:plugins:migrate NAME=redmine_nis2_compliance RAILS_ENV=production
```

---

## Phase 3: Models (Week 2)

### 3.1 Control Model

```ruby
# app/models/nis2_control.rb
class Nis2Control < ActiveRecord::Base
  unloadable

  # Validations
  validates :control_id, presence: true, uniqueness: true
  validates :category, presence: true, inclusion: {
    in: %w[risk_management corporate_accountability reporting_obligations business_continuity]
  }
  validates :title, presence: true
  validates :priority, inclusion: { in: %w[critical high medium low] }

  # Serialization
  serialize :implementation_guidance, Array
  serialize :verification_methods, Array
  serialize :evidence_types, Array
  serialize :iso27001_mapping, Array

  # Associations
  has_many :control_assessments, class_name: 'Nis2ControlAssessment', foreign_key: 'control_id'
  has_many :gap_analyses, through: :control_assessments

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :critical, -> { where(priority: 'critical') }
  scope :ordered, -> { order(:position, :control_id) }

  # Category constants
  CATEGORIES = {
    'risk_management' => 'Risk Management',
    'corporate_accountability' => 'Corporate Accountability',
    'reporting_obligations' => 'Reporting Obligations',
    'business_continuity' => 'Business Continuity'
  }.freeze

  PRIORITIES = {
    'critical' => 'Critical',
    'high' => 'High',
    'medium' => 'Medium',
    'low' => 'Low'
  }.freeze

  # Methods
  def category_name
    CATEGORIES[category]
  end

  def priority_label
    PRIORITIES[priority]
  end

  def priority_badge_class
    case priority
    when 'critical' then 'badge-critical'
    when 'high' then 'badge-high'
    when 'medium' then 'badge-medium'
    when 'low' then 'badge-low'
    else 'badge-default'
    end
  end

  def iso27001_controls
    iso27001_mapping.join(', ')
  end
end
```

### 3.2 Gap Analysis Model

```ruby
# app/models/nis2_gap_analysis.rb
class Nis2GapAnalysis < ActiveRecord::Base
  unloadable

  # Associations
  belongs_to :project
  belongs_to :assessor, class_name: 'User', foreign_key: 'assessor_id'
  belongs_to :reviewer, class_name: 'User', foreign_key: 'reviewer_id', optional: true
  has_many :control_assessments, class_name: 'Nis2ControlAssessment',
           foreign_key: 'gap_analysis_id', dependent: :destroy
  has_many :controls, through: :control_assessments, source: :control

  # Validations
  validates :project, presence: true
  validates :name, presence: true
  validates :status, inclusion: { in: %w[draft in_progress completed reviewed archived] }
  validates :assessor, presence: true

  # Callbacks
  after_create :initialize_assessments
  before_save :calculate_scores

  # Scopes
  scope :active, -> { where.not(status: 'archived') }
  scope :completed, -> { where(status: ['completed', 'reviewed']) }
  scope :for_project, ->(project_id) { where(project_id: project_id) }
  scope :recent, -> { order(created_at: :desc) }

  # Status constants
  STATUSES = {
    'draft' => 'Draft',
    'in_progress' => 'In Progress',
    'completed' => 'Completed',
    'reviewed' => 'Reviewed',
    'archived' => 'Archived'
  }.freeze

  # Methods
  def status_label
    STATUSES[status]
  end

  def status_badge_class
    case status
    when 'draft' then 'badge-secondary'
    when 'in_progress' then 'badge-info'
    when 'completed' then 'badge-success'
    when 'reviewed' then 'badge-primary'
    when 'archived' then 'badge-dark'
    else 'badge-default'
    end
  end

  def compliance_level
    return 'unknown' if overall_compliance_score.nil?

    case overall_compliance_score
    when 90..100 then 'compliant'
    when 70..89 then 'substantial_gaps'
    when 50..69 then 'significant_gaps'
    else 'critical_gaps'
    end
  end

  def compliance_level_label
    {
      'compliant' => 'Compliant',
      'substantial_gaps' => 'Substantial Gaps',
      'significant_gaps' => 'Significant Gaps',
      'critical_gaps' => 'Critical Gaps',
      'unknown' => 'Not Assessed'
    }[compliance_level]
  end

  def compliance_badge_class
    case compliance_level
    when 'compliant' then 'badge-success'
    when 'substantial_gaps' then 'badge-warning'
    when 'significant_gaps' then 'badge-orange'
    when 'critical_gaps' then 'badge-danger'
    else 'badge-secondary'
    end
  end

  def progress_percentage
    total = control_assessments.count
    return 0 if total.zero?

    assessed = control_assessments.where.not(implementation_status: nil).count
    (assessed.to_f / total * 100).round
  end

  def critical_gaps
    control_assessments.joins(:control)
                       .where(nis2_controls: { priority: 'critical' })
                       .where.not(implementation_status: 'implemented')
                       .order('nis2_controls.position')
  end

  def high_priority_gaps
    control_assessments.joins(:control)
                       .where(nis2_controls: { priority: 'high' })
                       .where.not(implementation_status: 'implemented')
                       .order('nis2_controls.position')
  end

  def gaps_by_status
    control_assessments.group(:implementation_status).count
  end

  def gaps_by_category
    control_assessments.joins(:control)
                       .group('nis2_controls.category')
                       .average(:compliance_score)
  end

  def total_remediation_effort
    control_assessments.sum(:estimated_effort_days) || 0
  end

  def total_estimated_cost
    control_assessments.sum(:estimated_cost) || 0
  end

  private

  def initialize_assessments
    Nis2Control.active.each do |control|
      control_assessments.create(control: control)
    end
  end

  def calculate_scores
    # Overall score
    assessments = control_assessments.where.not(implementation_status: 'not_applicable')
    if assessments.any?
      self.overall_compliance_score = assessments.average(:compliance_score)
    end

    # Category scores
    %w[risk_management corporate_accountability reporting_obligations business_continuity].each do |category|
      category_assessments = control_assessments.joins(:control)
                                                .where(nis2_controls: { category: category })
                                                .where.not(implementation_status: 'not_applicable')

      if category_assessments.any?
        score = category_assessments.average(:compliance_score)
        send("#{category}_score=", score)
      end
    end
  end
end
```

### 3.3 Control Assessment Model

```ruby
# app/models/nis2_control_assessment.rb
class Nis2ControlAssessment < ActiveRecord::Base
  unloadable

  # Associations
  belongs_to :gap_analysis, class_name: 'Nis2GapAnalysis', foreign_key: 'gap_analysis_id'
  belongs_to :control, class_name: 'Nis2Control', foreign_key: 'control_id'
  belongs_to :responsible_user, class_name: 'User', optional: true
  belongs_to :linked_issue, class_name: 'Issue', optional: true
  has_many :evidence, as: :related, class_name: 'Nis2Evidence'

  # Validations
  validates :gap_analysis, presence: true
  validates :control, presence: true
  validates :implementation_status, inclusion: {
    in: %w[not_implemented partially_implemented implemented not_applicable]
  }
  validates :compliance_score, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }, allow_nil: true

  # Callbacks
  before_save :calculate_compliance_score
  before_save :auto_set_priority
  after_save :update_gap_analysis_scores

  # Scopes
  scope :not_implemented, -> { where(implementation_status: 'not_implemented') }
  scope :partially_implemented, -> { where(implementation_status: 'partially_implemented') }
  scope :implemented, -> { where(implementation_status: 'implemented') }
  scope :not_applicable, -> { where(implementation_status: 'not_applicable') }
  scope :with_gaps, -> { where(implementation_status: ['not_implemented', 'partially_implemented']) }
  scope :critical, -> { joins(:control).where(nis2_controls: { priority: 'critical' }) }
  scope :overdue, -> { where('target_completion_date < ?', Date.today).where(actual_completion_date: nil) }

  # Implementation status constants
  IMPLEMENTATION_STATUSES = {
    'not_implemented' => 'Not Implemented',
    'partially_implemented' => 'Partially Implemented',
    'implemented' => 'Implemented',
    'not_applicable' => 'Not Applicable'
  }.freeze

  PRIORITIES = {
    'critical' => 'Critical',
    'high' => 'High',
    'medium' => 'Medium',
    'low' => 'Low'
  }.freeze

  # Methods
  def implementation_status_label
    IMPLEMENTATION_STATUSES[implementation_status]
  end

  def status_badge_class
    case implementation_status
    when 'not_implemented' then 'badge-danger'
    when 'partially_implemented' then 'badge-warning'
    when 'implemented' then 'badge-success'
    when 'not_applicable' then 'badge-secondary'
    else 'badge-default'
    end
  end

  def has_gap?
    ['not_implemented', 'partially_implemented'].include?(implementation_status)
  end

  def is_overdue?
    target_completion_date.present? &&
    target_completion_date < Date.today &&
    actual_completion_date.nil?
  end

  def priority_label
    PRIORITIES[priority] || 'Medium'
  end

  def create_remediation_issue
    return if linked_issue.present?
    return unless gap_analysis.project.present?

    issue = Issue.new(
      project: gap_analysis.project,
      tracker: Tracker.find_by(name: 'Task') || Tracker.first,
      subject: "NIS2: #{control.title}",
      description: remediation_issue_description,
      assigned_to: responsible_user,
      due_date: target_completion_date,
      priority: issue_priority
    )

    if issue.save
      self.linked_issue = issue
      save
    end

    issue
  end

  private

  def calculate_compliance_score
    return if implementation_status == 'not_applicable'

    self.compliance_score = case implementation_status
                           when 'not_implemented' then 0
                           when 'partially_implemented' then 50
                           when 'implemented' then 100
                           else 0
                           end
  end

  def auto_set_priority
    return if priority.present?

    # Priority based on control priority and implementation gap
    self.priority = if control.priority == 'critical' && has_gap?
                      'critical'
                    elsif control.priority == 'high' || (control.priority == 'critical' && !has_gap?)
                      'high'
                    elsif control.priority == 'medium' || has_gap?
                      'medium'
                    else
                      'low'
                    end
  end

  def update_gap_analysis_scores
    gap_analysis.save if gap_analysis.present?
  end

  def remediation_issue_description
    <<~DESC
      ## NIS2 Control Gap Remediation

      **Control ID**: #{control.control_id}
      **Category**: #{control.category_name}
      **Priority**: #{control.priority_label}

      ### Requirement
      #{control.requirement_text}

      ### Current Status
      #{implementation_status_label}

      ### Gap Description
      #{gap_description}

      ### Recommendations
      #{recommendations}

      ### Implementation Guidance
      #{control.implementation_guidance.join("\n- ")}

      ### Verification Methods
      #{control.verification_methods.join("\n- ")}

      ### Evidence Required
      #{control.evidence_types.join("\n- ")}

      ---
      *This issue was automatically created from Gap Analysis: #{gap_analysis.name}*
      *Link: [View Assessment](#)*
    DESC
  end

  def issue_priority
    priority_mapping = {
      'critical' => 'Immediate',
      'high' => 'High',
      'medium' => 'Normal',
      'low' => 'Low'
    }

    IssuePriority.find_by(name: priority_mapping[priority]) || IssuePriority.default
  end
end
```

---

## Phase 4: Controllers (Week 3)

### 4.1 Dashboard Controller

```ruby
# app/controllers/nis2_dashboard_controller.rb
class Nis2DashboardController < ApplicationController
  unloadable

  before_action :find_project
  before_action :authorize

  def index
    @gap_analyses = Nis2GapAnalysis.for_project(@project.id).recent.limit(5)
    @latest_analysis = @gap_analyses.completed.first

    if @latest_analysis
      @compliance_score = @latest_analysis.overall_compliance_score
      @compliance_by_category = {
        'Risk Management' => @latest_analysis.risk_management_score,
        'Corporate Accountability' => @latest_analysis.accountability_score,
        'Reporting Obligations' => @latest_analysis.reporting_score,
        'Business Continuity' => @latest_analysis.business_continuity_score
      }
      @critical_gaps = @latest_analysis.critical_gaps.limit(10)
      @gaps_by_status = @latest_analysis.gaps_by_status
    end

    @trend_data = calculate_trend_data
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def calculate_trend_data
    Nis2GapAnalysis.for_project(@project.id)
                   .completed
                   .order(:assessment_date)
                   .pluck(:assessment_date, :overall_compliance_score)
  end
end
```

### 4.2 Gap Analysis Controller

```ruby
# app/controllers/nis2_gap_analyses_controller.rb
class Nis2GapAnalysesController < ApplicationController
  unloadable

  before_action :find_project
  before_action :find_gap_analysis, only: [:show, :edit, :update, :destroy, :review, :export]
  before_action :authorize

  def index
    @gap_analyses = Nis2GapAnalysis.for_project(@project.id)
                                   .active
                                   .includes(:assessor, :reviewer)
                                   .order(created_at: :desc)
  end

  def show
    @assessments_by_category = @gap_analysis.control_assessments
                                            .joins(:control)
                                            .group_by { |a| a.control.category }
    @progress = @gap_analysis.progress_percentage
  end

  def new
    @gap_analysis = Nis2GapAnalysis.new(
      project: @project,
      assessor: User.current,
      assessment_date: Date.today,
      status: 'draft'
    )
  end

  def create
    @gap_analysis = Nis2GapAnalysis.new(gap_analysis_params)
    @gap_analysis.project = @project
    @gap_analysis.assessor = User.current

    if @gap_analysis.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'show', id: @gap_analysis
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @gap_analysis.update(gap_analysis_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to action: 'show', id: @gap_analysis
    else
      render action: 'edit'
    end
  end

  def destroy
    @gap_analysis.destroy
    flash[:notice] = l(:notice_successful_delete)
    redirect_to action: 'index', project_id: @project
  end

  def review
    if @gap_analysis.update(status: 'reviewed', reviewer: User.current, reviewed_at: Date.today)
      flash[:notice] = 'Gap analysis has been reviewed'
      redirect_to action: 'show', id: @gap_analysis
    else
      flash[:error] = 'Failed to review gap analysis'
      redirect_to action: 'show', id: @gap_analysis
    end
  end

  def export
    respond_to do |format|
      format.pdf do
        pdf = Nis2Reports::GapAnalysisPdf.new(@gap_analysis)
        send_data pdf.render,
                  filename: "gap_analysis_#{@gap_analysis.id}_#{Date.today}.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end

      format.html do
        render layout: 'nis2_report'
      end
    end
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_gap_analysis
    @gap_analysis = Nis2GapAnalysis.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def gap_analysis_params
    params.require(:nis2_gap_analysis).permit(
      :name, :description, :status, :assessment_date,
      :target_completion_date, :reviewer_id
    )
  end
end
```

---

## Phase 5: Views (Week 4)

### 5.1 Dashboard View

```erb
<!-- app/views/nis2_dashboard/index.html.erb -->
<div class="nis2-dashboard">
  <h2><%= l(:label_nis2_dashboard) %></h2>

  <% if @latest_analysis %>
    <div class="dashboard-summary">
      <div class="row">
        <!-- Overall Compliance -->
        <div class="col-md-3">
          <div class="widget compliance-widget">
            <h3><%= l(:label_overall_compliance) %></h3>
            <div class="compliance-score <%= @latest_analysis.compliance_badge_class %>">
              <%= number_to_percentage(@compliance_score, precision: 1) %>
            </div>
            <p class="compliance-level">
              <%= @latest_analysis.compliance_level_label %>
            </p>
          </div>
        </div>

        <!-- Compliance by Category -->
        <div class="col-md-9">
          <div class="widget">
            <h3><%= l(:label_compliance_by_category) %></h3>
            <table class="category-scores">
              <% @compliance_by_category.each do |category, score| %>
                <tr>
                  <td class="category-name"><%= category %></td>
                  <td class="category-bar">
                    <div class="progress">
                      <div class="progress-bar <%= compliance_bar_class(score) %>"
                           style="width: <%= score %>%">
                        <%= number_to_percentage(score, precision: 0) %>
                      </div>
                    </div>
                  </td>
                </tr>
              <% end %>
            </table>
          </div>
        </div>
      </div>

      <!-- Critical Gaps -->
      <div class="widget">
        <h3><%= l(:label_critical_gaps) %></h3>
        <% if @critical_gaps.any? %>
          <table class="list gaps">
            <thead>
              <tr>
                <th><%= l(:field_control_id) %></th>
                <th><%= l(:field_title) %></th>
                <th><%= l(:field_status) %></th>
                <th><%= l(:field_responsible) %></th>
                <th><%= l(:field_target_date) %></th>
              </tr>
            </thead>
            <tbody>
              <% @critical_gaps.each do |assessment| %>
                <tr class="<%= cycle('odd', 'even') %>">
                  <td><%= link_to assessment.control.control_id,
                              controller: 'nis2_assessments',
                              action: 'edit',
                              id: assessment %></td>
                  <td><%= assessment.control.title %></td>
                  <td><span class="<%= assessment.status_badge_class %>">
                      <%= assessment.implementation_status_label %>
                      </span></td>
                  <td><%= assessment.responsible_user ? assessment.responsible_user.name : '-' %></td>
                  <td class="<%= 'overdue' if assessment.is_overdue? %>">
                      <%= format_date(assessment.target_completion_date) %>
                      </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        <% else %>
          <p class="nodata"><%= l(:label_no_critical_gaps) %></p>
        <% end %>
      </div>
    </div>
  <% else %>
    <div class="nodata">
      <p><%= l(:label_no_gap_analysis_yet) %></p>
      <%= link_to l(:button_create_gap_analysis),
                  { controller: 'nis2_gap_analyses', action: 'new' },
                  class: 'btn btn-primary' %>
    </div>
  <% end %>
</div>
```

---

## Phase 6: Seed Data (Week 4)

### 6.1 NIS2 Controls Seed File

```ruby
# db/seeds/nis2_controls.rb
module Nis2ControlsSeeder
  def self.seed!
    controls = [
      # RISK MANAGEMENT CONTROLS
      {
        control_id: 'NIS2-RM-01',
        category: 'risk_management',
        domain: 'risk_assessment',
        title: 'Cybersecurity Risk Assessment Methodology',
        description: 'Establish and maintain a comprehensive risk assessment methodology',
        requirement_text: 'Organizations must implement policies and procedures for comprehensive risk analysis and information system security, taking into account the state of the art.',
        implementation_guidance: [
          'Document risk assessment methodology',
          'Define risk criteria (likelihood and impact scales)',
          'Establish risk appetite and tolerance levels',
          'Conduct annual risk assessments',
          'Update risk register continuously'
        ],
        verification_methods: [
          'Review risk assessment methodology document',
          'Review recent risk assessment reports',
          'Interview risk management team'
        ],
        evidence_types: [
          'Risk assessment methodology document',
          'Risk register',
          'Risk assessment reports'
        ],
        iso27001_mapping: ['A.5.7', 'A.8.2'],
        priority: 'critical',
        position: 1
      },
      {
        control_id: 'NIS2-RM-02',
        category: 'risk_management',
        domain: 'network_security',
        title: 'Network Security Controls',
        description: 'Implement security measures for network infrastructure',
        requirement_text: 'Measures shall be taken to protect network and information systems from cyber threats through appropriate and proportionate technical and organizational measures.',
        implementation_guidance: [
          'Deploy firewalls and intrusion detection/prevention systems',
          'Implement network segmentation',
          'Enable secure network protocols (TLS 1.2+)',
          'Monitor network traffic for anomalies',
          'Regular vulnerability scanning'
        ],
        verification_methods: [
          'Review network architecture diagrams',
          'Test firewall rules',
          'Review IDS/IPS logs'
        ],
        evidence_types: [
          'Network diagrams',
          'Firewall configurations',
          'IDS/IPS reports'
        ],
        iso27001_mapping: ['A.8.20', 'A.8.21', 'A.8.22'],
        priority: 'critical',
        position: 2
      },
      {
        control_id: 'NIS2-RM-03',
        category: 'risk_management',
        domain: 'access_control',
        title: 'Multi-Factor Authentication (MFA)',
        description: 'Implement MFA for all user access to critical systems',
        requirement_text: 'Organizations must implement multi-factor authentication for access to network and information systems. Alternative authentication measures are required where MFA is not feasible.',
        implementation_guidance: [
          'Deploy MFA solution for all users',
          'Enforce MFA for administrative access',
          'Implement MFA for remote access (VPN, SSH)',
          'Provide alternative authentication for legacy systems',
          'Document and approve MFA exceptions'
        ],
        verification_methods: [
          'Test MFA enforcement',
          'Review MFA configuration',
          'Review exception list and approvals'
        ],
        evidence_types: [
          'MFA configuration screenshots',
          'Authentication policy',
          'Exception approvals'
        ],
        iso27001_mapping: ['A.5.15', 'A.5.17', 'A.8.5'],
        priority: 'critical',
        position: 3
      },
      # Add more controls here...
      # For brevity, showing structure. Full seed would have 100-150 controls
    ]

    controls.each do |control_data|
      Nis2Control.find_or_create_by(control_id: control_data[:control_id]) do |control|
        control.attributes = control_data
      end
    end

    puts "Seeded #{controls.count} NIS2 controls"
  end
end

# Run with: Nis2ControlsSeeder.seed!
```

---

## Phase 7: Routes (Week 4)

### 7.1 Routes Configuration

```ruby
# config/routes.rb
RedmineApp::Application.routes.draw do
  # NIS2 routes scoped to projects
  resources :projects do
    # Dashboard
    get 'nis2', to: 'nis2_dashboard#index', as: 'nis2_dashboard'

    # Gap Analyses
    resources :nis2_gap_analyses, path: 'nis2/gap_analyses' do
      member do
        post 'review'
        get 'export'
      end

      # Control Assessments (nested)
      resources :nis2_assessments, path: 'assessments', only: [:edit, :update]
    end
  end

  # Admin routes (global control management)
  scope '/admin' do
    resources :nis2_controls, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  end
end
```

---

## Next Steps

1. **Implement Core Models** (Week 2)
   - Complete model validations and associations
   - Write unit tests for models

2. **Build Controllers** (Week 3)
   - Implement CRUD operations
   - Add authorization checks
   - Write functional tests

3. **Create Views** (Week 4)
   - Design dashboard and forms
   - Add CSS styling
   - Implement JavaScript for interactivity

4. **Seed Control Library** (Week 4)
   - Complete all 100-150 NIS2 controls
   - Test seeding process
   - Validate control data

5. **Testing & Refinement** (Week 5-6)
   - Comprehensive testing
   - Bug fixes
   - UI/UX improvements

---

## Key Features Checklist

- [ ] Plugin initialization (init.rb)
- [ ] Database migrations
- [ ] Core models (Control, GapAnalysis, ControlAssessment)
- [ ] Controllers (Dashboard, GapAnalyses, Assessments)
- [ ] Views (Dashboard, index, show, edit, new)
- [ ] Routes configuration
- [ ] Permissions and authorization
- [ ] Control library seed data (100+ controls)
- [ ] Evidence upload functionality
- [ ] Auto-create Redmine issues from gaps
- [ ] Gap analysis report generation (PDF)
- [ ] Compliance score calculation
- [ ] Dashboard visualizations
- [ ] Unit tests (>80% coverage)
- [ ] Functional tests
- [ ] User documentation

---

## Resources

**Redmine Plugin Development**:
- [Plugin Tutorial](https://www.redmine.org/projects/redmine/wiki/plugin_tutorial)
- [Plugin Internals](https://www.redmine.org/projects/redmine/wiki/Plugin_Internals)
- [Hooks](https://www.redmine.org/projects/redmine/wiki/hooks)

**NIS2 Compliance**:
- [NIS2 Directive Official Text](https://eur-lex.europa.eu/eli/dir/2022/2555)
- [ENISA NIS2 Guidelines](https://www.enisa.europa.eu/)
- [NIS2 Gap Analysis Best Practices](https://www.kiteworks.com/best-practices-checklist-nis-2-gap-analysis/)

---

**Document Version**: 1.0
**Last Updated**: 2025-11-22
