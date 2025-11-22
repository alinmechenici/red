# Redmine NIS2 Compliance Plugin

Comprehensive NIS2 Directive compliance management plugin for Redmine.

## Version

0.1.0 - Initial MVP Release

## Features

- **Gap Analysis Module**: Conduct systematic NIS2 compliance assessments
- **Control Library**: Pre-loaded with 19+ NIS2 compliance controls
- **Risk Management**: Track and manage cybersecurity risks
- **Incident Response**: Log and track security incidents
- **Compliance Dashboard**: Real-time compliance scoring and visualization
- **Audit Trail**: Complete audit logging for compliance evidence
- **Evidence Management**: Upload and track compliance evidence
- **Automatic Issue Creation**: Generate Redmine issues for gap remediation

## Requirements

- Redmine 5.0.0 or higher
- Ruby 3.0 or higher
- PostgreSQL 12+ or MySQL 8.0+

## Installation

1. Copy this plugin directory to `/path/to/redmine/plugins/`
2. Run database migrations:
   ```bash
   bundle exec rake redmine:plugins:migrate NAME=redmine_nis2_compliance RAILS_ENV=production
   ```
3. Seed the NIS2 controls library:
   ```bash
   bundle exec rake redmine_nis2:seed_controls RAILS_ENV=production
   ```
4. Restart Redmine
5. Enable the "NIS2 Compliance" module in project settings

## Quick Start

1. Go to a project
2. Enable "NIS2 Compliance" module in Project Settings → Modules
3. Click "NIS2 Compliance" in the project menu
4. Click "Create Gap Analysis" to start your first assessment

## NIS2 Controls Included

This plugin includes 19 pre-configured NIS2 compliance controls across 4 categories:

### Risk Management (9 controls)
- Risk Assessment Methodology
- Network Security Controls
- Multi-Factor Authentication (MFA)
- Cryptography and Data Protection
- Supply Chain Security
- Security Awareness and Training
- Vulnerability Management
- Patch Management
- Security Monitoring and Logging

### Corporate Accountability (3 controls)
- Management Oversight and Responsibility
- Security Policies and Procedures
- Resource Allocation for Cybersecurity

### Reporting Obligations (3 controls)
- Incident Detection Capabilities
- 24-Hour Initial Notification Process
- 72-Hour Detailed Incident Report

### Business Continuity (4 controls)
- Business Impact Analysis
- Backup and Recovery Procedures
- Crisis Management Plan
- Business Continuity Testing

## Usage

### Conducting a Gap Analysis

1. Create a new gap analysis
2. Assess each control's implementation status
3. Document gaps and assign remediation tasks
4. Track progress and generate reports

### Assessment Workflow

```
Create Gap Analysis → Assess Controls → Document Gaps →
Assign Remediation → Create Issues → Track Progress → Review & Approve
```

## Permissions

- **View NIS2 compliance**: View dashboards and reports
- **Manage NIS2 gap analysis**: Create and edit gap analyses
- **Manage NIS2 controls**: Edit control library (admin only)
- **Export NIS2 reports**: Generate and export reports
- **View NIS2 audit log**: View compliance audit trail

## Rake Tasks

```bash
# Seed controls library
bundle exec rake redmine_nis2:seed_controls

# Show plugin statistics
bundle exec rake redmine_nis2:stats

# Export controls to YAML
bundle exec rake redmine_nis2:export_controls

# Cleanup old audit logs
bundle exec rake redmine_nis2:cleanup_audit_logs[365]
```

## Configuration

Plugin settings are available in **Administration → Plugins → Configure**.

## Support

For installation instructions, see [INSTALL.md](../../INSTALL.md) in the repository root.

For complete design documentation, see [NIS2_PLUGIN_DESIGN.md](../../NIS2_PLUGIN_DESIGN.md).

## License

GPL v2

## Version History

- **0.1.0** (2025-11-22): Initial MVP release
  - Core gap analysis functionality
  - 19 NIS2 controls pre-loaded
  - Dashboard and reporting
  - Audit logging
