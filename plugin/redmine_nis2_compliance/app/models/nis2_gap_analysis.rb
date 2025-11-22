class Nis2GapAnalysis < ActiveRecord::Base
  self.table_name = 'nis2_gap_analyses'

  # Associations
  belongs_to :project
  belongs_to :assessor, class_name: 'User', foreign_key: 'assessor_id'
  belongs_to :reviewer, class_name: 'User', foreign_key: 'reviewer_id', optional: true
  has_many :control_assessments, class_name: 'Nis2ControlAssessment',
           foreign_key: 'gap_analysis_id', dependent: :destroy
  has_many :controls, through: :control_assessments, source: :control
  has_many :evidence, through: :control_assessments

  # Validations
  validates :project, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :status, inclusion: { in: %w[draft in_progress completed reviewed archived] }
  validates :assessor, presence: true
  validates :overall_compliance_score, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    allow_nil: true
  }

  # Callbacks
  after_create :initialize_assessments
  before_save :calculate_scores

  # Scopes
  scope :active, -> { where.not(status: 'archived') }
  scope :completed, -> { where(status: ['completed', 'reviewed']) }
  scope :for_project, ->(project_id) { where(project_id: project_id) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }

  # Status constants
  STATUSES = {
    'draft' => 'Draft',
    'in_progress' => 'In Progress',
    'completed' => 'Completed',
    'reviewed' => 'Reviewed',
    'archived' => 'Archived'
  }.freeze

  COMPLIANCE_LEVELS = {
    'compliant' => { label: 'Compliant', min: 90, max: 100, class: 'success' },
    'substantial_gaps' => { label: 'Substantial Gaps', min: 70, max: 89, class: 'warning' },
    'significant_gaps' => { label: 'Significant Gaps', min: 50, max: 69, class: 'orange' },
    'critical_gaps' => { label: 'Critical Gaps', min: 0, max: 49, class: 'danger' }
  }.freeze

  # Instance methods
  def status_label
    STATUSES[status] || status.to_s.humanize
  end

  def status_badge_class
    case status
    when 'draft' then 'label-secondary'
    when 'in_progress' then 'label-info'
    when 'completed' then 'label-success'
    when 'reviewed' then 'label-primary'
    when 'archived' then 'label-dark'
    else 'label-default'
    end
  end

  def compliance_level
    return 'unknown' if overall_compliance_score.nil?

    COMPLIANCE_LEVELS.each do |key, config|
      return key if overall_compliance_score >= config[:min] && overall_compliance_score <= config[:max]
    end
    'unknown'
  end

  def compliance_level_label
    level = compliance_level
    return 'Not Assessed' if level == 'unknown'
    COMPLIANCE_LEVELS[level][:label]
  end

  def compliance_badge_class
    level = compliance_level
    return 'label-secondary' if level == 'unknown'
    "label-#{COMPLIANCE_LEVELS[level][:class]}"
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

  def all_gaps
    control_assessments.where(implementation_status: ['not_implemented', 'partially_implemented'])
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

  def overdue_assessments
    control_assessments.where('target_completion_date < ?', Date.today)
                       .where(actual_completion_date: nil)
  end

  def can_be_reviewed?
    status == 'completed' && overall_compliance_score.present?
  end

  def mark_as_reviewed!(user)
    update(
      status: 'reviewed',
      reviewer: user,
      reviewed_at: Date.today
    )
  end

  def archive!
    update(status: 'archived')
  end

  # Class methods
  def self.statuses_for_select
    STATUSES.map { |k, v| [v, k] }
  end

  private

  def initialize_assessments
    Nis2Control.active.ordered.each do |control|
      control_assessments.create(control: control)
    end
  end

  def calculate_scores
    # Calculate overall score
    assessments = control_assessments.where.not(implementation_status: 'not_applicable')
    if assessments.any?
      self.overall_compliance_score = assessments.average(:compliance_score)&.round(2)
    end

    # Calculate category scores
    %w[risk_management corporate_accountability reporting_obligations business_continuity].each do |category|
      category_assessments = control_assessments.joins(:control)
                                                .where(nis2_controls: { category: category })
                                                .where.not(implementation_status: 'not_applicable')

      if category_assessments.any?
        score = category_assessments.average(:compliance_score)&.round(2)
        send("#{category}_score=", score)
      end
    end
  end
end
