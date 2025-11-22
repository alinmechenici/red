class Nis2Control < ActiveRecord::Base
  self.table_name = 'nis2_controls'

  # Validations
  validates :control_id, presence: true, uniqueness: true
  validates :category, presence: true, inclusion: {
    in: %w[risk_management corporate_accountability reporting_obligations business_continuity]
  }
  validates :title, presence: true
  validates :priority, inclusion: { in: %w[critical high medium low] }

  # Serialization for array/hash fields
  serialize :implementation_guidance, Array
  serialize :verification_methods, Array
  serialize :evidence_types, Array
  serialize :iso27001_mapping, Array

  # Associations
  has_many :control_assessments, class_name: 'Nis2ControlAssessment', foreign_key: 'control_id', dependent: :destroy
  has_many :gap_analyses, through: :control_assessments
  has_many :evidence, as: :related, class_name: 'Nis2Evidence'

  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :critical, -> { where(priority: 'critical') }
  scope :high_priority, -> { where(priority: ['critical', 'high']) }
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

  IMPLEMENTATION_STATUSES = {
    'not_implemented' => 'Not Implemented',
    'partially_implemented' => 'Partially Implemented',
    'implemented' => 'Implemented',
    'not_applicable' => 'Not Applicable'
  }.freeze

  # Instance methods
  def category_name
    CATEGORIES[category] || category.to_s.humanize
  end

  def priority_label
    PRIORITIES[priority] || priority.to_s.humanize
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

  def iso27001_controls
    return '' if iso27001_mapping.blank?
    iso27001_mapping.join(', ')
  end

  def implementation_guidance_list
    return [] if implementation_guidance.blank?
    implementation_guidance.is_a?(Array) ? implementation_guidance : [implementation_guidance]
  end

  def verification_methods_list
    return [] if verification_methods.blank?
    verification_methods.is_a?(Array) ? verification_methods : [verification_methods]
  end

  def evidence_types_list
    return [] if evidence_types.blank?
    evidence_types.is_a?(Array) ? evidence_types : [evidence_types]
  end

  # Class methods
  def self.categories_for_select
    CATEGORIES.map { |k, v| [v, k] }
  end

  def self.priorities_for_select
    PRIORITIES.map { |k, v| [v, k] }
  end

  def self.implementation_statuses_for_select
    IMPLEMENTATION_STATUSES.map { |k, v| [v, k] }
  end

  def self.by_category_stats
    active.group(:category).count
  end

  def self.by_priority_stats
    active.group(:priority).count
  end
end
