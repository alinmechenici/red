class Nis2AuditLog < ActiveRecord::Base
  self.table_name = 'nis2_audit_logs'

  # Associations
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  # Validations
  validates :action, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_date_range, ->(start_date, end_date) {
    where(created_at: start_date.beginning_of_day..end_date.end_of_day)
  }
  scope :for_type, ->(type) { where(auditable_type: type) }

  # Constants
  ACTIONS = %w[
    created updated deleted viewed exported
    approved rejected submitted reviewed archived
    assigned unassigned completed reopened
  ].freeze

  # Instance methods
  def action_label
    action.to_s.humanize
  end

  def user_name
    user&.name || 'System'
  end

  def auditable_name
    return 'N/A' unless auditable.present?

    case auditable_type
    when 'Nis2GapAnalysis'
      auditable.name
    when 'Nis2Control'
      auditable.title
    when 'Nis2ControlAssessment'
      auditable.control.title
    else
      "#{auditable_type} ##{auditable_id}"
    end
  rescue
    "#{auditable_type} ##{auditable_id}"
  end

  def changes_hash
    return {} if changes.blank?
    JSON.parse(changes) rescue {}
  end

  # Class methods
  def self.log(user:, action:, auditable: nil, changes: nil, ip_address: nil, user_agent: nil)
    create(
      user: user,
      action: action.to_s,
      auditable: auditable,
      changes: changes.is_a?(Hash) ? changes.to_json : changes,
      ip_address: ip_address,
      user_agent: user_agent
    )
  rescue => e
    Rails.logger.error "Failed to create audit log: #{e.message}"
    nil
  end

  def self.actions_for_select
    ACTIONS.map { |a| [a.humanize, a] }
  end

  def self.cleanup_old_logs(days = 365)
    where('created_at < ?', days.days.ago).delete_all
  end
end
