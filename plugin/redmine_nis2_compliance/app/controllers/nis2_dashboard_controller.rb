class Nis2DashboardController < ApplicationController
  before_action :find_project
  before_action :authorize

  def index
    @gap_analyses = Nis2GapAnalysis.for_project(@project.id)
                                   .active
                                   .recent
                                   .limit(5)

    @latest_analysis = @gap_analyses.completed.first

    if @latest_analysis
      load_dashboard_data
    else
      @show_empty_state = true
    end

    # Audit log
    Nis2AuditLog.log(
      user: User.current,
      action: 'viewed',
      auditable: @project,
      ip_address: request.remote_ip
    ) if User.current.present?
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def load_dashboard_data
    @compliance_score = @latest_analysis.overall_compliance_score

    @compliance_by_category = {
      'Risk Management' => @latest_analysis.risk_management_score,
      'Corporate Accountability' => @latest_analysis.accountability_score,
      'Reporting Obligations' => @latest_analysis.reporting_score,
      'Business Continuity' => @latest_analysis.business_continuity_score
    }.compact

    @critical_gaps = @latest_analysis.critical_gaps.limit(10)
    @gaps_by_status = @latest_analysis.gaps_by_status
    @trend_data = calculate_trend_data
    @overdue_count = @latest_analysis.overdue_assessments.count
  end

  def calculate_trend_data
    Nis2GapAnalysis.for_project(@project.id)
                   .completed
                   .order(:assessment_date)
                   .limit(12)
                   .pluck(:assessment_date, :overall_compliance_score)
  end
end
