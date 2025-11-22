class Nis2AssessmentsController < ApplicationController
  before_action :find_project
  before_action :find_gap_analysis
  before_action :find_assessment, only: [:edit, :update, :create_issue]
  before_action :authorize

  def edit
    @control = @assessment.control
  end

  def update
    old_status = @assessment.implementation_status

    if @assessment.update(assessment_params)
      # Auto-create issue if enabled and has gap
      if setting_enabled?('enable_auto_issue_creation') && @assessment.has_gap? && @assessment.linked_issue.nil?
        @assessment.create_remediation_issue!
      end

      # Audit log
      Nis2AuditLog.log(
        user: User.current,
        action: 'updated',
        auditable: @assessment,
        changes: { status: [old_status, @assessment.implementation_status] }.to_json,
        ip_address: request.remote_ip
      )

      flash[:notice] = l(:notice_successful_update)
      redirect_to controller: 'nis2_gap_analyses', action: 'show',
                  id: @gap_analysis, project_id: @project
    else
      @control = @assessment.control
      render action: 'edit'
    end
  end

  def create_issue
    if @assessment.linked_issue.present?
      flash[:warning] = 'Issue already exists for this assessment'
      redirect_to controller: 'issues', action: 'show', id: @assessment.linked_issue
      return
    end

    issue = @assessment.create_remediation_issue!

    if issue && issue.persisted?
      flash[:notice] = "Remediation issue ##{issue.id} created successfully"
      redirect_to controller: 'issues', action: 'show', id: issue
    else
      flash[:error] = 'Failed to create remediation issue'
      redirect_to controller: 'nis2_gap_analyses', action: 'show',
                  id: @gap_analysis, project_id: @project
    end
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_gap_analysis
    @gap_analysis = if params[:gap_analysis_id]
                      Nis2GapAnalysis.find(params[:gap_analysis_id])
                    elsif params[:nis2_gap_analysis_id]
                      Nis2GapAnalysis.find(params[:nis2_gap_analysis_id])
                    end
    render_404 unless @gap_analysis
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_assessment
    @assessment = Nis2ControlAssessment.find(params[:id])
    render_404 unless @assessment.gap_analysis_id == @gap_analysis.id
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def assessment_params
    params.require(:nis2_control_assessment).permit(
      :implementation_status,
      :implementation_details,
      :gap_description,
      :impact_assessment,
      :root_cause,
      :recommendations,
      :priority,
      :responsible_user_id,
      :target_completion_date,
      :actual_completion_date,
      :estimated_effort_days,
      :estimated_cost
    )
  end

  def setting_enabled?(setting)
    Setting.plugin_redmine_nis2_compliance[setting] == '1'
  end
end
