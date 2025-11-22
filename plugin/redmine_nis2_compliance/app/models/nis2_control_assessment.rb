class Nis2ControlAssessment < ActiveRecord::Base
  self.table_name = 'nis2_control_assessments'

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
  after_create :log_creation

  # Scopes
  scope :not_implemented, -> { where(implementation_status: 'not_implemented') }
  scope :partially_implemented, -> { where(implementation_status: 'partially_implemented') }
  scope :implemented, -> { where(implementation_status: 'implemented') }
  scope :not_applicable, -> { where(implementation_status: 'not_applicable') }
  scope :with_gaps, -> { where(implementation_status: ['not_implemented', 'partially_implemented']) }
  scope :critical, -> { joins(:control).where(nis2_controls: { priority: 'critical' }) }
  scope :high_priority, -> { joins(:control).where(nis2_controls: { priority: ['critical', 'high'] }) }
  scope :overdue, -> { where('target_completion_date < ?', Date.today).where(actual_completion_date: nil) }
  scope :completed, -> { where.not(actual_completion_date: nil) }
  scope :pending, -> { where(actual_completion_date: nil) }

  # Constants
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

  # Instance methods
  def implementation_status_label
    IMPLEMENTATION_STATUSES[implementation_status] || implementation_status.to_s.humanize
  end

  def status_badge_class
    case implementation_status
    when 'not_implemented' then 'label-danger'
    when 'partially_implemented' then 'label-warning'
    when 'implemented' then 'label-success'
    when 'not_applicable' then 'label-secondary'
    else 'label-default'
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

  def priority_badge_class
    case priority
    when 'critical' then 'label-critical'
    when 'high' then 'label-high'
    when 'medium' then 'label-medium'
    when 'low' then 'label-low'
    else 'label-default'
    end
  end

  def create_remediation_issue!
    return linked_issue if linked_issue.present?
    return nil unless gap_analysis.project.present?
    return nil unless has_gap?

    issue = Issue.new(
      project: gap_analysis.project,
      tracker: default_tracker,
      subject: "NIS2: #{control.title}",
      description: remediation_issue_description,
      assigned_to: responsible_user,
      due_date: target_completion_date,
      priority: issue_priority,
      author: User.current
    )

    if issue.save
      self.linked_issue = issue
      save
    end

    issue
  end

  def mark_completed!
    update(
      actual_completion_date: Date.today,
      implementation_status: 'implemented'
    )
  end

  # Class methods
  def self.implementation_statuses_for_select
    IMPLEMENTATION_STATUSES.map { |k, v| [v, k] }
  end

  def self.priorities_for_select
    PRIORITIES.map { |k, v| [v, k] }
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

  def log_creation
    Nis2AuditLog.create(
      user: User.current,
      action: 'created',
      auditable: self,
      changes: { status: implementation_status }.to_json,
      ip_address: User.current.remote_ip
    ) if User.current.present?
  rescue => e
    Rails.logger.error "Failed to log assessment creation: #{e.message}"
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

      ### Impact Assessment
      #{impact_assessment}

      ### Root Cause
      #{root_cause}

      ### Recommendations
      #{recommendations}

      ### Implementation Guidance
      #{control.implementation_guidance_list.map { |g| "- #{g}" }.join("\n")}

      ### Verification Methods
      #{control.verification_methods_list.map { |v| "- #{v}" }.join("\n")}

      ### Evidence Required
      #{control.evidence_types_list.map { |e| "- #{e}" }.join("\n")}

      ---
      *This issue was automatically created from Gap Analysis: #{gap_analysis.name}*
      *Assessment ID: ##{id}*
    DESC
  end

  def default_tracker
    Tracker.find_by(name: 'Task') || Tracker.first
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
