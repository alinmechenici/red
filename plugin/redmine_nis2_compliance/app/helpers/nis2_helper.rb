module Nis2Helper
  # Compliance score badge with color coding
  def compliance_score_badge(score)
    return content_tag(:span, 'N/A', class: 'label label-secondary') if score.nil?

    level_class = case score
                  when 90..100 then 'label-success'
                  when 70..89 then 'label-warning'
                  when 50..69 then 'label-orange'
                  else 'label-danger'
                  end

    content_tag(:span, "#{number_to_percentage(score, precision: 1)}", class: "label #{level_class}")
  end

  # Implementation status badge
  def implementation_status_badge(status)
    label = Nis2Control::IMPLEMENTATION_STATUSES[status] || status.to_s.humanize
    css_class = case status
                when 'not_implemented' then 'label-danger'
                when 'partially_implemented' then 'label-warning'
                when 'implemented' then 'label-success'
                when 'not_applicable' then 'label-secondary'
                else 'label-default'
                end

    content_tag(:span, label, class: "label #{css_class}")
  end

  # Priority badge
  def priority_badge(priority)
    label = Nis2Control::PRIORITIES[priority] || priority.to_s.humanize
    css_class = case priority
                when 'critical' then 'label-critical'
                when 'high' then 'label-high'
                when 'medium' then 'label-medium'
                when 'low' then 'label-low'
                else 'label-default'
                end

    content_tag(:span, label, class: "label #{css_class}")
  end

  # Gap analysis status badge
  def gap_analysis_status_badge(gap_analysis)
    content_tag(:span, gap_analysis.status_label, class: "label #{gap_analysis.status_badge_class}")
  end

  # Compliance level description
  def compliance_level_description(score)
    return 'Not yet assessed' if score.nil?

    case score
    when 90..100
      'Excellent compliance level. Minor improvements may be needed.'
    when 70..89
      'Good compliance level with some gaps. Action plan recommended.'
    when 50..69
      'Significant gaps identified. Immediate action required.'
    else
      'Critical gaps identified. Urgent remediation needed.'
    end
  end

  # Progress bar
  def compliance_progress_bar(score, options = {})
    return '' if score.nil?

    width = [score.to_i, 100].min
    bar_class = case score
                when 90..100 then 'progress-bar-success'
                when 70..89 then 'progress-bar-warning'
                when 50..69 then 'progress-bar-orange'
                else 'progress-bar-danger'
                end

    content_tag(:div, class: 'progress') do
      content_tag(:div, class: "progress-bar #{bar_class}", style: "width: #{width}%", role: 'progressbar') do
        "#{number_to_percentage(score, precision: 0)}"
      end
    end
  end

  # Category icon
  def category_icon(category)
    icon_class = case category
                 when 'risk_management' then 'icon-security'
                 when 'corporate_accountability' then 'icon-people'
                 when 'reporting_obligations' then 'icon-file'
                 when 'business_continuity' then 'icon-reload'
                 else 'icon-help'
                 end

    content_tag(:span, '', class: icon_class)
  end

  # Format category name
  def category_name(category)
    Nis2Control::CATEGORIES[category] || category.to_s.humanize
  end

  # Days until target date with color coding
  def days_until_badge(target_date)
    return '' if target_date.nil?

    days = (target_date - Date.today).to_i

    if days < 0
      content_tag(:span, "#{days.abs} days overdue", class: 'label label-danger')
    elsif days == 0
      content_tag(:span, 'Due today', class: 'label label-warning')
    elsif days <= 7
      content_tag(:span, "#{days} days left", class: 'label label-warning')
    elsif days <= 30
      content_tag(:span, "#{days} days left", class: 'label label-info')
    else
      content_tag(:span, "#{days} days left", class: 'label label-default')
    end
  end

  # Check if NIS2 module is enabled for project
  def nis2_enabled_for_project?(project)
    project.module_enabled?(:nis2_compliance)
  end

  # Get plugin setting
  def nis2_setting(key)
    Setting.plugin_redmine_nis2_compliance[key]
  end

  # Check if plugin setting is enabled
  def nis2_setting_enabled?(key)
    nis2_setting(key) == '1'
  end
end
