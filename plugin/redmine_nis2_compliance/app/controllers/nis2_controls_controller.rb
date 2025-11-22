class Nis2ControlsController < ApplicationController
  layout 'admin'
  before_action :require_admin, except: [:index, :show]
  before_action :find_control, only: [:show, :edit, :update, :destroy]

  def index
    @controls = Nis2Control.active
                           .includes(:control_assessments)
                           .order(:category, :position)
                           .page(params[:page])
                           .per(50)

    @category = params[:category]
    @controls = @controls.by_category(@category) if @category.present?

    @priority = params[:priority]
    @controls = @controls.by_priority(@priority) if @priority.present?

    @stats = {
      total: Nis2Control.active.count,
      by_category: Nis2Control.by_category_stats,
      by_priority: Nis2Control.by_priority_stats
    }
  end

  def show
    @gap_analyses_using_control = @control.control_assessments
                                          .includes(:gap_analysis)
                                          .limit(10)
  end

  def new
    @control = Nis2Control.new(
      category: params[:category],
      priority: 'medium',
      is_active: true
    )
  end

  def create
    @control = Nis2Control.new(control_params)

    if @control.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to action: 'show', id: @control
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @control.update(control_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to action: 'show', id: @control
    else
      render action: 'edit'
    end
  end

  def destroy
    if @control.control_assessments.any?
      flash[:error] = 'Cannot delete control that is used in gap analyses'
      redirect_to action: 'show', id: @control
    elsif @control.update(is_active: false)
      flash[:notice] = 'Control has been deactivated'
      redirect_to action: 'index'
    else
      flash[:error] = 'Failed to deactivate control'
      redirect_to action: 'show', id: @control
    end
  end

  private

  def find_control
    @control = Nis2Control.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def control_params
    params.require(:nis2_control).permit(
      :control_id,
      :category,
      :domain,
      :title,
      :description,
      :requirement_text,
      :priority,
      :effort_estimate,
      :typical_implementation_time,
      :position,
      :is_active,
      implementation_guidance: [],
      verification_methods: [],
      evidence_types: [],
      iso27001_mapping: []
    )
  end
end
