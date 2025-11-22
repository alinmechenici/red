class CreateNis2Tables < ActiveRecord::Migration[6.1]
  def change
    # NIS2 Controls - Catalog of compliance requirements
    create_table :nis2_controls do |t|
      t.string :control_id, null: false, limit: 50
      t.string :category, null: false, limit: 50
      t.string :domain, limit: 100
      t.string :title, null: false
      t.text :description
      t.text :requirement_text
      t.text :implementation_guidance
      t.text :verification_methods
      t.text :evidence_types
      t.text :iso27001_mapping
      t.string :priority, default: 'medium', limit: 20
      t.integer :effort_estimate
      t.string :typical_implementation_time, limit: 50
      t.integer :position
      t.boolean :is_active, default: true
      t.timestamps
    end
    add_index :nis2_controls, :control_id, unique: true
    add_index :nis2_controls, :category
    add_index :nis2_controls, :priority
    add_index :nis2_controls, :position

    # Gap Analyses - Assessment instances
    create_table :nis2_gap_analyses do |t|
      t.references :project, null: false, foreign_key: true, index: true
      t.string :name, null: false
      t.text :description
      t.string :status, default: 'draft', limit: 20
      t.date :assessment_date
      t.references :assessor, foreign_key: { to_table: :users }, index: true
      t.references :reviewer, foreign_key: { to_table: :users }, index: true
      t.decimal :overall_compliance_score, precision: 5, scale: 2
      t.decimal :risk_management_score, precision: 5, scale: 2
      t.decimal :accountability_score, precision: 5, scale: 2
      t.decimal :reporting_score, precision: 5, scale: 2
      t.decimal :business_continuity_score, precision: 5, scale: 2
      t.date :target_completion_date
      t.date :reviewed_at
      t.timestamps
    end
    add_index :nis2_gap_analyses, :status
    add_index :nis2_gap_analyses, :assessment_date
    add_index :nis2_gap_analyses, [:project_id, :created_at]

    # Control Assessments - Individual control evaluations within a gap analysis
    create_table :nis2_control_assessments do |t|
      t.references :gap_analysis, null: false, foreign_key: { to_table: :nis2_gap_analyses }, index: true
      t.references :control, null: false, foreign_key: { to_table: :nis2_controls }, index: true
      t.string :implementation_status, default: 'not_implemented', limit: 30
      t.decimal :compliance_score, precision: 5, scale: 2
      t.text :implementation_details
      t.text :gap_description
      t.text :impact_assessment
      t.text :root_cause
      t.text :recommendations
      t.string :priority, limit: 20
      t.references :responsible_user, foreign_key: { to_table: :users }, index: true
      t.date :target_completion_date
      t.date :actual_completion_date
      t.references :linked_issue, foreign_key: { to_table: :issues }, index: true
      t.decimal :estimated_effort_days, precision: 5, scale: 1
      t.decimal :estimated_cost, precision: 10, scale: 2
      t.timestamps
    end
    add_index :nis2_control_assessments, :implementation_status
    add_index :nis2_control_assessments, :priority
    add_index :nis2_control_assessments, :target_completion_date
    add_index :nis2_control_assessments, [:gap_analysis_id, :control_id],
              unique: true,
              name: 'index_assessments_on_gap_and_control'

    # Evidence - Supporting documentation for assessments
    create_table :nis2_evidence do |t|
      t.string :title, null: false
      t.text :description
      t.string :evidence_type, limit: 50
      t.references :attachment, foreign_key: true, index: true
      t.string :related_type, limit: 50
      t.integer :related_id
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }, index: true
      t.date :valid_until
      t.boolean :is_approved, default: false
      t.references :approved_by, foreign_key: { to_table: :users }, index: true
      t.date :approved_at
      t.timestamps
    end
    add_index :nis2_evidence, [:related_type, :related_id]
    add_index :nis2_evidence, :evidence_type
    add_index :nis2_evidence, :valid_until

    # Audit Logs - Compliance audit trail
    create_table :nis2_audit_logs do |t|
      t.references :user, foreign_key: true, index: true
      t.string :action, null: false, limit: 50
      t.string :auditable_type, limit: 50
      t.integer :auditable_id
      t.text :changes
      t.string :ip_address, limit: 45
      t.string :user_agent
      t.timestamps
    end
    add_index :nis2_audit_logs, [:auditable_type, :auditable_id]
    add_index :nis2_audit_logs, :action
    add_index :nis2_audit_logs, :created_at
  end
end
