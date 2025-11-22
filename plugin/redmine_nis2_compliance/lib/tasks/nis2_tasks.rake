namespace :redmine_nis2 do
  desc 'Seed NIS2 controls library'
  task seed_controls: :environment do
    puts "Loading NIS2 controls seed data..."
    load File.join(File.dirname(__FILE__), '../../db/seeds.rb')
    puts "Done!"
  end

  desc 'Reset and reseed NIS2 controls (WARNING: This will delete all controls)'
  task reset_controls: :environment do
    print "This will DELETE all existing controls. Are you sure? (yes/no): "
    confirmation = STDIN.gets.chomp

    if confirmation.downcase == 'yes'
      puts "Deleting existing controls..."
      Nis2Control.delete_all
      puts "Reseeding controls..."
      Rake::Task['redmine_nis2:seed_controls'].invoke
    else
      puts "Cancelled."
    end
  end

  desc 'Show NIS2 plugin statistics'
  task stats: :environment do
    puts "\n=== NIS2 Plugin Statistics ==="
    puts "Controls: #{Nis2Control.count}"
    puts "  - Active: #{Nis2Control.active.count}"
    puts "  - Inactive: #{Nis2Control.where(is_active: false).count}"
    puts "\nBy Category:"
    Nis2Control.by_category_stats.each do |category, count|
      puts "  - #{Nis2Control::CATEGORIES[category]}: #{count}"
    end
    puts "\nBy Priority:"
    Nis2Control.by_priority_stats.each do |priority, count|
      puts "  - #{Nis2Control::PRIORITIES[priority]}: #{count}"
    end
    puts "\nGap Analyses: #{Nis2GapAnalysis.count}"
    puts "  - Draft: #{Nis2GapAnalysis.where(status: 'draft').count}"
    puts "  - In Progress: #{Nis2GapAnalysis.where(status: 'in_progress').count}"
    puts "  - Completed: #{Nis2GapAnalysis.where(status: 'completed').count}"
    puts "  - Reviewed: #{Nis2GapAnalysis.where(status: 'reviewed').count}"
    puts "\nAssessments: #{Nis2ControlAssessment.count}"
    puts "  - Not Implemented: #{Nis2ControlAssessment.not_implemented.count}"
    puts "  - Partially Implemented: #{Nis2ControlAssessment.partially_implemented.count}"
    puts "  - Implemented: #{Nis2ControlAssessment.implemented.count}"
    puts "\nEvidence: #{Nis2Evidence.count}"
    puts "Audit Logs: #{Nis2AuditLog.count}"
    puts "============================\n\n"
  end

  desc 'Cleanup old audit logs (default: older than 365 days)'
  task :cleanup_audit_logs, [:days] => :environment do |t, args|
    days = (args[:days] || 365).to_i
    puts "Deleting audit logs older than #{days} days..."
    deleted = Nis2AuditLog.cleanup_old_logs(days)
    puts "Deleted #{deleted} audit log entries."
  end

  desc 'Export NIS2 controls to YAML'
  task export_controls: :environment do
    require 'yaml'

    controls = Nis2Control.all.map do |c|
      {
        'control_id' => c.control_id,
        'category' => c.category,
        'domain' => c.domain,
        'title' => c.title,
        'description' => c.description,
        'requirement_text' => c.requirement_text,
        'implementation_guidance' => c.implementation_guidance,
        'verification_methods' => c.verification_methods,
        'evidence_types' => c.evidence_types,
        'iso27001_mapping' => c.iso27001_mapping,
        'priority' => c.priority,
        'effort_estimate' => c.effort_estimate,
        'typical_implementation_time' => c.typical_implementation_time,
        'position' => c.position
      }
    end

    filename = "nis2_controls_export_#{Time.now.strftime('%Y%m%d_%H%M%S')}.yml"
    File.write(filename, controls.to_yaml)
    puts "Exported #{controls.count} controls to #{filename}"
  end
end
