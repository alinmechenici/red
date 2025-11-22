module RedmineNis2Compliance
  class Hooks < Redmine::Hook::ViewListener
    # Add NIS2 compliance information to project overview page
    render_on :view_projects_show_left,
              partial: 'hooks/nis2_compliance/project_overview'

    # Add NIS2 links to project settings sidebar
    render_on :view_projects_settings_members_table_header,
              partial: 'hooks/nis2_compliance/settings_link'

    # Add CSS and JavaScript to all pages
    def view_layouts_base_html_head(context={})
      stylesheet_link_tag('nis2_compliance', plugin: 'redmine_nis2_compliance') +
      javascript_include_tag('nis2_compliance', plugin: 'redmine_nis2_compliance')
    end
  end
end
