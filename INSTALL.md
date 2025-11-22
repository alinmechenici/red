# NIS2 Compliance Plugin - Installation Guide

Complete installation guide for the Redmine NIS2 Compliance Plugin.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Database Migration](#database-migration)
4. [Seeding Control Library](#seeding-control-library)
5. [Plugin Activation](#plugin-activation)
6. [Configuration](#configuration)
7. [Verification](#verification)
8. [Post-Installation Setup](#post-installation-setup)
9. [Upgrading](#upgrading)
10. [Uninstallation](#uninstallation)
11. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### System Requirements

**Redmine Version**:
- Redmine 5.0.x or higher ✅
- Redmine 5.1.x ✅
- Redmine 6.0.x ✅
- Redmine 6.1.x ✅

**Ruby Version**:
- Ruby 3.0 or higher
- Bundler 2.x

**Database**:
- PostgreSQL 12+ (recommended)
- MySQL 8.0+ (supported)
- MariaDB 10.5+ (supported)

**Server**:
- Passenger, Puma, or Thin
- 2GB RAM minimum (4GB+ recommended)
- 500MB free disk space

### Check Your Redmine Version

```bash
cd /path/to/redmine
cat VERSION
# or
bundle exec rails runner "puts Redmine::VERSION::STRING"
```

### Check Your Ruby Version

```bash
ruby -v
# Should show: ruby 3.0.0 or higher
```

---

## Installation

### Method 1: Install from Git Repository (Recommended for Development)

#### Step 1: Navigate to Redmine Plugins Directory

```bash
cd /path/to/redmine/plugins
```

#### Step 2: Clone the Plugin Repository

```bash
# For production
git clone https://github.com/yourorg/redmine_nis2_compliance.git

# For development (specific branch)
git clone -b develop https://github.com/yourorg/redmine_nis2_compliance.git

# For a specific version
git clone -b v1.0.0 https://github.com/yourorg/redmine_nis2_compliance.git
```

#### Step 3: Verify Plugin Directory

```bash
ls -la redmine_nis2_compliance/
# Should show: init.rb and other plugin files
```

The plugin directory **must** be named `redmine_nis2_compliance` (exact name).

### Method 2: Install from Release Archive

#### Step 1: Download Release

```bash
cd /path/to/redmine/plugins
wget https://github.com/yourorg/redmine_nis2_compliance/archive/v1.0.0.tar.gz
```

#### Step 2: Extract Archive

```bash
tar -xzf v1.0.0.tar.gz
mv redmine_nis2_compliance-1.0.0 redmine_nis2_compliance
```

#### Step 3: Verify

```bash
ls -la redmine_nis2_compliance/
```

---

## Database Migration

### Step 1: Install Plugin Dependencies

```bash
cd /path/to/redmine
bundle install --without development test
```

**Note**: If you encounter dependency conflicts:

```bash
bundle update
bundle install
```

### Step 2: Run Database Migrations

This creates the necessary database tables for the plugin.

```bash
# For production
bundle exec rake redmine:plugins:migrate NAME=redmine_nis2_compliance RAILS_ENV=production

# For development
bundle exec rake redmine:plugins:migrate NAME=redmine_nis2_compliance RAILS_ENV=development
```

**Expected Output**:
```
== CreateNis2Tables: migrating ================================================
-- create_table(:nis2_controls)
   -> 0.0123s
-- create_table(:nis2_gap_analyses)
   -> 0.0089s
-- create_table(:nis2_control_assessments)
   -> 0.0156s
-- create_table(:nis2_evidence)
   -> 0.0078s
-- create_table(:nis2_audit_logs)
   -> 0.0092s
== CreateNis2Tables: migrated (0.0538s) =======================================
```

### Step 3: Verify Migration

```bash
bundle exec rails console

# In Rails console:
Nis2Control.count
# Should return: 0 (we'll seed data next)

Nis2GapAnalysis.count
# Should return: 0

exit
```

---

## Seeding Control Library

The plugin comes with a pre-configured library of 100+ NIS2 controls.

### Step 1: Run Seed Task

```bash
cd /path/to/redmine

# For production
bundle exec rake redmine_nis2:seed_controls RAILS_ENV=production

# For development
bundle exec rake redmine_nis2:seed_controls RAILS_ENV=development
```

**Expected Output**:
```
Seeding NIS2 control library...
  - Risk Management controls: 45 created
  - Corporate Accountability controls: 18 created
  - Reporting Obligations controls: 22 created
  - Business Continuity controls: 28 created
Successfully seeded 113 NIS2 controls
```

### Step 2: Verify Seed Data

```bash
bundle exec rails console

# In Rails console:
Nis2Control.count
# Should return: 113 (or your specific count)

Nis2Control.first
# Should show a control object

Nis2Control.by_category('risk_management').count
# Should show count for that category

exit
```

### Alternative: Manual Seed (If Rake Task Unavailable)

If the rake task is not yet implemented, you can seed manually:

```bash
bundle exec rails console

# In Rails console:
load '/path/to/redmine/plugins/redmine_nis2_compliance/db/seeds/nis2_controls.rb'
Nis2ControlsSeeder.seed!
exit
```

---

## Plugin Activation

### Step 1: Restart Redmine

**For Passenger**:
```bash
touch /path/to/redmine/tmp/restart.txt
```

**For Puma/Thin (systemd)**:
```bash
sudo systemctl restart redmine
```

**For Puma/Thin (manual)**:
```bash
# Stop
pkill -f puma  # or pkill -f thin

# Start
cd /path/to/redmine
bundle exec puma -e production -d
# or
bundle exec thin start -e production -d
```

### Step 2: Verify Plugin is Loaded

1. Log in to Redmine as Administrator
2. Navigate to: **Administration** → **Plugins**
3. Verify "Redmine NIS2 Compliance Plugin" appears in the list

**Expected Display**:
```
Redmine NIS2 Compliance Plugin
Author: Your Organization
Version: 0.1.0
Description: Comprehensive NIS2 compliance management for Redmine
```

If you see the plugin, installation was successful! ✅

### Step 3: Enable in Projects

The NIS2 Compliance module must be enabled per project.

#### Enable for a New Project:

1. **Projects** → **New Project**
2. Under **Modules**, check ☑️ **NIS2 Compliance**
3. Click **Create**

#### Enable for an Existing Project:

1. Go to your project
2. **Settings** → **Modules** tab
3. Check ☑️ **NIS2 Compliance**
4. Click **Save**

#### Verify Module is Active:

1. Go to your project
2. You should see **NIS2 Compliance** in the project menu
3. Click it to access the dashboard

---

## Configuration

### Step 1: Plugin Settings (Global)

1. **Administration** → **Plugins**
2. Click **Configure** next to "Redmine NIS2 Compliance Plugin"

**Available Settings**:

| Setting | Description | Default |
|---------|-------------|---------|
| **Enable Auto Issue Creation** | Automatically create Redmine issues for gap remediation tasks | ✅ Enabled |
| **Gap Analysis Reminder (days)** | Send reminder emails N days before gap analysis target date | 90 days |
| **Compliance Threshold (%)** | Minimum compliance score to be considered "compliant" | 70% |
| **Enable Audit Logging** | Log all actions for compliance audit trail | ✅ Enabled |
| **Default Assessment Reviewer** | User who reviews gap analyses by default | (None) |

3. Configure settings as needed
4. Click **Apply**

### Step 2: Permissions (Roles)

Configure which roles can access NIS2 features.

1. **Administration** → **Roles and permissions**
2. Select a role (e.g., "Manager")
3. Scroll to **NIS2 Compliance** section

**Available Permissions**:

- ☑️ **View NIS2 compliance** - View dashboards and reports
- ☑️ **Manage NIS2 gap analysis** - Create and edit gap analyses
- ☑️ **Manage NIS2 controls** - Edit control library (admin only)
- ☑️ **Export NIS2 reports** - Generate and export reports
- ☑️ **View NIS2 audit log** - View compliance audit trail

**Recommended Permission Setup**:

| Role | View | Manage Gap Analysis | Manage Controls | Export Reports | View Audit Log |
|------|------|---------------------|-----------------|----------------|----------------|
| **Admin** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Manager** | ✅ | ✅ | ❌ | ✅ | ✅ |
| **Developer** | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Reporter** | ✅ | ❌ | ❌ | ❌ | ❌ |

4. Click **Save**

### Step 3: Email Notifications (Optional)

Configure email notifications for NIS2 events.

1. **Administration** → **Settings** → **Email notifications**
2. Enable relevant event notifications:
   - Gap analysis assigned
   - Gap analysis completed
   - Gap remediation overdue
   - Critical gap identified
   - Incident reported
   - Risk threshold exceeded

---

## Verification

### Test 1: Access Dashboard

1. Go to a project with NIS2 Compliance enabled
2. Click **NIS2 Compliance** in the project menu
3. You should see the dashboard (even if empty)

**Expected**: Dashboard displays with "No gap analysis yet" message

### Test 2: Create Gap Analysis

1. In the dashboard, click **Create Gap Analysis**
2. Fill in:
   - **Name**: "Initial NIS2 Assessment"
   - **Description**: "First assessment to identify gaps"
   - **Assessment Date**: (Today's date)
3. Click **Create**

**Expected**: Redirects to gap analysis page showing all 113 controls

### Test 3: Assess a Control

1. In the gap analysis, click on a control (e.g., "NIS2-RM-03: Multi-Factor Authentication")
2. Select **Implementation Status**: "Partially Implemented"
3. Add **Gap Description**: "MFA not enforced for all users"
4. Add **Recommendations**: "Deploy MFA to all user accounts"
5. Set **Target Date**: (30 days from now)
6. Click **Save**

**Expected**: Assessment saved, compliance score calculated

### Test 4: View Dashboard

1. Return to NIS2 Dashboard
2. Should now show:
   - Overall compliance score
   - Compliance by category
   - Critical gaps (if any)

**Expected**: Dashboard populated with assessment data ✅

---

## Post-Installation Setup

### Step 1: Customize Control Library (Optional)

If you need to add organization-specific controls:

1. **Administration** → **NIS2 Controls**
2. Click **New Control**
3. Fill in control details
4. Click **Create**

### Step 2: Import Existing Assessments (Optional)

If migrating from another tool:

1. Prepare CSV/JSON with assessment data
2. Use import rake task:

```bash
bundle exec rake redmine_nis2:import_assessments FILE=/path/to/data.csv RAILS_ENV=production
```

### Step 3: Configure Integrations (Optional)

**SIEM Integration**:
- Configure webhook URL in plugin settings
- Test incident auto-creation

**Document Management**:
- Link to SharePoint/Confluence for evidence storage

**Notification Services**:
- Configure Slack/Teams webhooks for alerts

---

## Upgrading

### Upgrade from v0.x to v1.x

#### Step 1: Backup Database

```bash
# PostgreSQL
pg_dump -U redmine redmine_production > backup_$(date +%Y%m%d).sql

# MySQL
mysqldump -u redmine -p redmine_production > backup_$(date +%Y%m%d).sql
```

#### Step 2: Backup Plugin Data

```bash
cd /path/to/redmine/plugins
tar -czf redmine_nis2_compliance_backup_$(date +%Y%m%d).tar.gz redmine_nis2_compliance/
```

#### Step 3: Pull Latest Version

```bash
cd /path/to/redmine/plugins/redmine_nis2_compliance
git fetch --all
git checkout v1.0.0  # or latest version tag
```

#### Step 4: Install Dependencies

```bash
cd /path/to/redmine
bundle install --without development test
```

#### Step 5: Run Migrations

```bash
bundle exec rake redmine:plugins:migrate NAME=redmine_nis2_compliance RAILS_ENV=production
```

#### Step 6: Restart Redmine

```bash
touch /path/to/redmine/tmp/restart.txt
# or
sudo systemctl restart redmine
```

#### Step 7: Verify Upgrade

1. **Administration** → **Plugins**
2. Check version number updated
3. Test core functionality

---

## Uninstallation

### Step 1: Backup Data (Optional)

If you want to preserve NIS2 data:

```bash
# Export gap analyses
bundle exec rake redmine_nis2:export_all_data FILE=/backup/nis2_data.json RAILS_ENV=production
```

### Step 2: Rollback Database Migrations

```bash
cd /path/to/redmine
bundle exec rake redmine:plugins:migrate NAME=redmine_nis2_compliance VERSION=0 RAILS_ENV=production
```

**Expected Output**:
```
== DropNis2Tables: reverting ==================================================
-- drop_table(:nis2_audit_logs)
   -> 0.0021s
-- drop_table(:nis2_evidence)
   -> 0.0018s
-- drop_table(:nis2_control_assessments)
   -> 0.0023s
-- drop_table(:nis2_gap_analyses)
   -> 0.0019s
-- drop_table(:nis2_controls)
   -> 0.0017s
== DropNis2Tables: reverted (0.0098s) =========================================
```

### Step 3: Remove Plugin Directory

```bash
cd /path/to/redmine/plugins
rm -rf redmine_nis2_compliance
```

### Step 4: Restart Redmine

```bash
touch /path/to/redmine/tmp/restart.txt
```

### Step 5: Verify Removal

1. **Administration** → **Plugins**
2. "Redmine NIS2 Compliance Plugin" should no longer appear

---

## Troubleshooting

### Issue 1: Plugin Not Appearing in Admin → Plugins

**Symptoms**: Plugin doesn't show in plugins list after installation

**Possible Causes & Solutions**:

1. **Plugin directory name is wrong**
   ```bash
   cd /path/to/redmine/plugins
   ls -la
   # Directory MUST be named: redmine_nis2_compliance
   # If different, rename it:
   mv redmine_nis2_compliance-1.0.0 redmine_nis2_compliance
   ```

2. **Redmine not restarted**
   ```bash
   touch /path/to/redmine/tmp/restart.txt
   # Wait 30 seconds, then refresh browser
   ```

3. **init.rb missing or has errors**
   ```bash
   cat /path/to/redmine/plugins/redmine_nis2_compliance/init.rb
   # Should start with: Redmine::Plugin.register :redmine_nis2_compliance
   ```

4. **Check Redmine logs**
   ```bash
   tail -f /path/to/redmine/log/production.log
   # Look for plugin loading errors
   ```

### Issue 2: Database Migration Fails

**Symptoms**: Error during `rake redmine:plugins:migrate`

**Solutions**:

1. **Check database connection**
   ```bash
   bundle exec rails console
   ActiveRecord::Base.connection.active?
   # Should return: true
   ```

2. **Check database user permissions**
   ```sql
   -- PostgreSQL
   GRANT ALL PRIVILEGES ON DATABASE redmine_production TO redmine;

   -- MySQL
   GRANT ALL PRIVILEGES ON redmine_production.* TO 'redmine'@'localhost';
   ```

3. **Roll back and retry**
   ```bash
   bundle exec rake redmine:plugins:migrate NAME=redmine_nis2_compliance VERSION=0 RAILS_ENV=production
   bundle exec rake redmine:plugins:migrate NAME=redmine_nis2_compliance RAILS_ENV=production
   ```

4. **Check for existing tables**
   ```bash
   bundle exec rails dbconsole
   \dt nis2_*  # PostgreSQL
   SHOW TABLES LIKE 'nis2_%';  # MySQL
   # If tables exist, drop them first
   ```

### Issue 3: Seed Task Not Found

**Symptoms**: `rake aborted! Don't know how to build task 'redmine_nis2:seed_controls'`

**Solutions**:

1. **Load tasks manually**
   ```bash
   bundle exec rake -T | grep nis2
   # Lists all available NIS2 tasks
   ```

2. **Check lib/tasks directory**
   ```bash
   ls -la /path/to/redmine/plugins/redmine_nis2_compliance/lib/tasks/
   # Should contain: nis2_tasks.rake
   ```

3. **Seed manually via console**
   ```bash
   bundle exec rails console
   load 'plugins/redmine_nis2_compliance/db/seeds/nis2_controls.rb'
   Nis2ControlsSeeder.seed!
   exit
   ```

### Issue 4: Module Not Appearing in Project Settings

**Symptoms**: "NIS2 Compliance" checkbox not in Project → Settings → Modules

**Solutions**:

1. **Verify plugin is registered as project module**
   ```bash
   bundle exec rails console
   Redmine::Plugin.find(:redmine_nis2_compliance).project_modules
   # Should return: [:nis2_compliance]
   ```

2. **Clear cache**
   ```bash
   bundle exec rake tmp:cache:clear RAILS_ENV=production
   touch tmp/restart.txt
   ```

3. **Check permissions**
   - Log in as Administrator
   - Only admins can see all modules

### Issue 5: 500 Error When Accessing Dashboard

**Symptoms**: Internal Server Error when clicking NIS2 Compliance menu

**Solutions**:

1. **Check logs**
   ```bash
   tail -f log/production.log
   # Look for stack trace
   ```

2. **Verify database tables exist**
   ```bash
   bundle exec rails dbconsole
   \d nis2_controls  # PostgreSQL
   DESCRIBE nis2_controls;  # MySQL
   ```

3. **Check for missing migrations**
   ```bash
   bundle exec rake redmine:plugins:migrate:status
   # All migrations should show "up"
   ```

4. **Verify seed data**
   ```bash
   bundle exec rails console
   Nis2Control.count
   # Should be > 0
   ```

### Issue 6: Permissions Not Working

**Symptoms**: Users can't access features despite having permissions

**Solutions**:

1. **Clear session cache**
   - Log out and log back in
   - Or clear browser cookies

2. **Verify role permissions**
   - **Administration** → **Roles and permissions**
   - Check that role has required permissions
   - Save role again to refresh

3. **Check project membership**
   - User must be a member of the project
   - **Project** → **Settings** → **Members**
   - Add user with appropriate role

4. **Enable module in project**
   - **Project** → **Settings** → **Modules**
   - ✅ Check "NIS2 Compliance"

### Issue 7: Assets Not Loading (CSS/JS)

**Symptoms**: Dashboard looks broken, no styling

**Solutions**:

1. **Precompile assets**
   ```bash
   bundle exec rake redmine:plugins:assets RAILS_ENV=production
   ```

2. **Check asset paths**
   ```bash
   ls -la public/plugin_assets/redmine_nis2_compliance/
   # Should contain: stylesheets/, javascripts/, images/
   ```

3. **Clear browser cache**
   - Hard refresh: Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)

4. **Check server logs for 404s**
   ```bash
   grep "404" log/production.log | grep nis2
   ```

### Issue 8: Bundle Install Fails

**Symptoms**: Dependency conflicts during `bundle install`

**Solutions**:

1. **Update bundler**
   ```bash
   gem install bundler
   bundler -v
   ```

2. **Update Gemfile.lock**
   ```bash
   bundle update
   ```

3. **Install specific gems**
   ```bash
   bundle install --without development test
   ```

4. **Check Ruby version**
   ```bash
   ruby -v
   # Must be 3.0 or higher
   ```

---

## Getting Help

### Official Resources

- **Documentation**: https://github.com/yourorg/redmine_nis2_compliance/wiki
- **Issue Tracker**: https://github.com/yourorg/redmine_nis2_compliance/issues
- **Discussions**: https://github.com/yourorg/redmine_nis2_compliance/discussions

### Community Support

- **Redmine Forums**: https://www.redmine.org/projects/redmine/boards
- **Stack Overflow**: Tag questions with `redmine` and `nis2`

### Commercial Support

For priority support, training, or custom development:
- Email: support@yourcompany.com
- Website: https://yourcompany.com/support

---

## Appendix: Installation Checklist

Use this checklist to ensure complete installation:

### Pre-Installation
- [ ] Redmine 5.0+ or 6.0+ installed
- [ ] Ruby 3.0+ installed
- [ ] Database (PostgreSQL/MySQL) configured
- [ ] Server (Passenger/Puma) running
- [ ] Admin access to Redmine

### Installation Steps
- [ ] Navigated to `plugins/` directory
- [ ] Cloned/extracted plugin to `redmine_nis2_compliance/`
- [ ] Verified `init.rb` exists
- [ ] Ran `bundle install`
- [ ] Ran database migrations successfully
- [ ] Ran seed task successfully
- [ ] Restarted Redmine server

### Verification
- [ ] Plugin appears in Admin → Plugins
- [ ] Version number displays correctly
- [ ] Plugin settings accessible
- [ ] Permissions configured for roles
- [ ] Module enabled in a test project
- [ ] Dashboard accessible
- [ ] Can create gap analysis
- [ ] Can assess controls
- [ ] Dashboard populates with data

### Optional
- [ ] Customized control library
- [ ] Configured email notifications
- [ ] Set up integrations (SIEM, etc.)
- [ ] Imported existing data
- [ ] Trained users

---

## Next Steps

Now that the plugin is installed, proceed to:

1. **[User Guide](USER_GUIDE.md)** - Learn how to use the plugin
2. **[Administrator Guide](ADMIN_GUIDE.md)** - Configure and manage the plugin
3. **[NIS2 Compliance Guide](NIS2_COMPLIANCE_GUIDE.md)** - Understand NIS2 requirements

---

**Installation Guide Version**: 1.0
**Last Updated**: 2025-11-22
**Plugin Version**: 0.1.0+

**Need Help?** Open an issue at: https://github.com/yourorg/redmine_nis2_compliance/issues
