class Nis2GapAnalysesController < ApplicationController
  before_action :find_project
  before_action :find_gap_analysis, only: [:show, :edit, :update, :destroy, :review, :export]
  before_action :authorize

  def index
    @gap_analyses = Nis2GapAnalysis.for_project(@project.id)
                                   .active
                                   .includes(:assessor, :reviewer)
                                   .order(created_at: :desc)
                                   .page(params[:page])
                                   .per(25)
  end

  def show
    @assessments_by_category = @gap_analysis.control_assessments
                                            .joins(:control)
                                            .includes(:control, :responsible_user)
                                            .order('nis2_controls.category, nis2_controls.position')
                                            .group_by { |a| a.control.category }

    @progress = @gap_analysis.progress_percentage
    @critical_gaps_count = @gap_analysis.critical_gaps.count
    @high_gaps_count = @gap_analysis.high_priority_gaps.count

    # Audit log
    Nis2AuditLog.log(
      user: User.current,
      action: 'viewed',
      auditable: @gap_analysis,
      ip_address: request.remote_ip
    )
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
    @gap_analysis.assessor ||= User.current

    if @gap_analysis.save
      # Audit log
      Nis2AuditLog.log(
        user: User.current,
        action: 'created',
        auditable: @gap_analysis,
        changes: { name: @gap_analysis.name, status: @gap_analysis.status }.to_json,
        ip_address: request.remote_ip
      )

      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'show', id: @gap_analysis, project_id: @project
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    old_status = @gap_analysis.status
    old_score = @gap_analysis.overall_compliance_score

    if @gap_analysis.update(gap_analysis_params)
      # Audit log
      changes = {}
      changes[:status] = [old_status, @gap_analysis.status] if old_status != @gap_analysis.status
      changes[:score] = [old_score, @gap_analysis.overall_compliance_score] if old_score != @gap_analysis.overall_compliance_score

      Nis2AuditLog.log(
        user: User.current,
        action: 'updated',
        auditable: @gap_analysis,
        changes: changes.to_json,
        ip_address: request.remote_ip
      ) if changes.any?

      flash[:notice] = l(:notice_successful_update)
      redirect_to action: 'show', id: @gap_analysis, project_id: @project
    else
      render action: 'edit'
    end
  end

  def destroy
    if @gap_analysis.destroy
      Nis2AuditLog.log(
        user: User.current,
        action: 'deleted',
        auditable_type: 'Nis2GapAnalysis',
        auditable_id: @gap_analysis.id,
        changes: { name: @gap_analysis.name }.to_json,
        ip_address: request.remote_ip
      )

      flash[:notice] = l(:notice_successful_delete)
    else
      flash[:error] = 'Could not delete gap analysis'
    end
    redirect_to action: 'index', project_id: @project
  end

  def review
    if @gap_analysis.can_be_reviewed?
      if @gap_analysis.mark_as_reviewed!(User.current)
        Nis2AuditLog.log(
          user: User.current,
          action: 'reviewed',
          auditable: @gap_analysis,
          ip_address: request.remote_ip
        )

        flash[:notice] = 'Gap analysis has been reviewed and approved'
      else
        flash[:error] = 'Failed to review gap analysis'
      end
    else
      flash[:error] = 'Gap analysis cannot be reviewed at this time'
    end
    redirect_to action: 'show', id: @gap_analysis, project_id: @project
  end

  def export
    respond_to do |format|
      format.html do
        @export_mode = true
        render layout: 'nis2_export'
      end

      format.pdf do
        # TODO: Implement PDF generation
        flash[:error] = 'PDF export not yet implemented'
        redirect_to action: 'show', id: @gap_analysis, project_id: @project
      end

      format.csv do
        send_data generate_csv,
                  filename: "gap_analysis_#{@gap_analysis.id}_#{Date.today}.csv",
                  type: 'text/csv'
      end
    end

    Nis2AuditLog.log(
      user: User.current,
      action: 'exported',
      auditable: @gap_analysis,
      changes: { format: params[:format] }.to_json,
      ip_address: request.remote_ip
    )
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_gap_analysis
    @gap_analysis = Nis2GapAnalysis.find(params[:id])
    render_404 unless @gap_analysis.project_id == @project.id
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def gap_analysis_params
    params.require(:nis2_gap_analysis).permit(
      :name, :description, :status, :assessment_date,
      :target_completion_date, :reviewer_id
    )
  end

  def generate_csv
    require 'csv'
    CSV.generate do |csv|
      csv << ['Control ID', 'Control Title', 'Category', 'Status', 'Compliance Score', 'Gap Description', 'Priority', 'Responsible', 'Target Date']

      @gap_analysis.control_assessments.includes(:control, :responsible_user).each do |assessment|
        csv << [
          assessment.control.control_id,
          assessment.control.title,
          assessment.control.category_name,
          assessment.implementation_status_label,
          assessment.compliance_score,
          assessment.gap_description,
          assessment.priority,
          assessment.responsible_user&.name,
          assessment.target_completion_date
        ]
      end
    end
  end
end
