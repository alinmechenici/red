class Nis2Evidence < ActiveRecord::Base
  self.table_name = 'nis2_evidence'

  # Associations
  belongs_to :attachment, optional: true
  belongs_to :uploaded_by, class_name: 'User', foreign_key: 'uploaded_by'
  belongs_to :approved_by, class_name: 'User', optional: true
  belongs_to :related, polymorphic: true, optional: true

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :uploaded_by, presence: true
  validates :evidence_type, inclusion: {
    in: %w[document screenshot log certificate policy procedure report audit other],
    allow_blank: true
  }

  # Scopes
  scope :approved, -> { where(is_approved: true) }
  scope :pending_approval, -> { where(is_approved: false) }
  scope :by_type, ->(type) { where(evidence_type: type) }
  scope :for_control, -> { where(related_type: 'Nis2Control') }
  scope :for_assessment, -> { where(related_type: 'Nis2ControlAssessment') }
  scope :valid, -> { where('valid_until IS NULL OR valid_until >= ?', Date.today) }
  scope :expired, -> { where('valid_until < ?', Date.today) }

  # Constants
  EVIDENCE_TYPES = {
    'document' => 'Document',
    'screenshot' => 'Screenshot',
    'log' => 'Log File',
    'certificate' => 'Certificate',
    'policy' => 'Policy Document',
    'procedure' => 'Procedure',
    'report' => 'Report',
    'audit' => 'Audit Report',
    'other' => 'Other'
  }.freeze

  # Instance methods
  def evidence_type_label
    EVIDENCE_TYPES[evidence_type] || evidence_type.to_s.humanize
  end

  def is_expired?
    valid_until.present? && valid_until < Date.today
  end

  def is_valid?
    valid_until.nil? || valid_until >= Date.today
  end

  def approve!(user)
    update(
      is_approved: true,
      approved_by: user,
      approved_at: Date.today
    )
  end

  def revoke_approval!
    update(
      is_approved: false,
      approved_by: nil,
      approved_at: nil
    )
  end

  def file_name
    attachment&.filename || 'No file'
  end

  def file_size
    attachment&.filesize || 0
  end

  # Class methods
  def self.evidence_types_for_select
    EVIDENCE_TYPES.map { |k, v| [v, k] }
  end
end
