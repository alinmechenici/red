# NIS2 Controls Seed Data
# This file contains the pre-configured library of NIS2 compliance controls

puts "Seeding NIS2 control library..."

controls_data = [
  # === RISK MANAGEMENT CONTROLS ===
  {
    control_id: 'NIS2-RM-01',
    category: 'risk_management',
    domain: 'risk_assessment',
    title: 'Cybersecurity Risk Assessment Methodology',
    description: 'Establish and maintain a comprehensive cybersecurity risk assessment methodology',
    requirement_text: 'Organizations must implement policies and procedures for comprehensive risk analysis and information system security, taking into account the state of the art and latest industry standards.',
    implementation_guidance: [
      'Document risk assessment methodology aligned with ISO 27001 or NIST framework',
      'Define risk criteria including likelihood and impact scales',
      'Establish risk appetite and tolerance levels',
      'Conduct annual comprehensive risk assessments',
      'Maintain and continuously update risk register',
      'Include third-party and supply chain risks in assessments'
    ],
    verification_methods: [
      'Review risk assessment methodology document',
      'Review recent risk assessment reports and findings',
      'Interview risk management team',
      'Verify risk register is current and complete'
    ],
    evidence_types: [
      'Risk assessment methodology document',
      'Risk register with current risks',
      'Risk assessment reports',
      'Risk treatment plans'
    ],
    iso27001_mapping: ['A.5.7', 'A.8.2', 'A.8.3'],
    priority: 'critical',
    effort_estimate: 40,
    typical_implementation_time: '8-12 weeks',
    position: 1
  },
  {
    control_id: 'NIS2-RM-02',
    category: 'risk_management',
    domain: 'network_security',
    title: 'Network Security Controls',
    description: 'Implement comprehensive security measures for network infrastructure',
    requirement_text: 'Measures shall be taken to protect network and information systems from cyber threats through appropriate and proportionate technical and organizational measures.',
    implementation_guidance: [
      'Deploy next-generation firewalls with intrusion detection/prevention',
      'Implement network segmentation and micro-segmentation',
      'Enable secure network protocols (TLS 1.3, SSH v2)',
      'Monitor network traffic for anomalies and threats',
      'Conduct regular vulnerability scanning',
      'Implement DDoS protection mechanisms'
    ],
    verification_methods: [
      'Review network architecture diagrams',
      'Test firewall rules and policies',
      'Review IDS/IPS logs and alerts',
      'Conduct penetration testing'
    ],
    evidence_types: [
      'Network diagrams',
      'Firewall configurations',
      'IDS/IPS reports',
      'Vulnerability scan reports',
      'Penetration test results'
    ],
    iso27001_mapping: ['A.8.20', 'A.8.21', 'A.8.22'],
    priority: 'critical',
    effort_estimate: 60,
    typical_implementation_time: '12-16 weeks',
    position: 2
  },
  {
    control_id: 'NIS2-RM-03',
    category: 'risk_management',
    domain: 'access_control',
    title: 'Multi-Factor Authentication (MFA)',
    description: 'Implement MFA for all user access to critical systems',
    requirement_text: 'Organizations must implement multi-factor authentication for access to network and information systems. Alternative authentication measures are required where MFA is not technically feasible.',
    implementation_guidance: [
      'Deploy MFA solution supporting multiple methods (hardware tokens, software tokens, biometrics)',
      'Enforce MFA for all administrative access',
      'Implement MFA for remote access (VPN, SSH, RDP)',
      'Provide alternative strong authentication for legacy systems',
      'Document and formally approve all MFA exceptions',
      'Implement conditional access policies based on risk'
    ],
    verification_methods: [
      'Test MFA enforcement across systems',
      'Review MFA configuration and policies',
      'Review exception list and approvals',
      'Test user enrollment process'
    ],
    evidence_types: [
      'MFA configuration screenshots',
      'Authentication policy document',
      'Exception approval documentation',
      'User access logs showing MFA usage'
    ],
    iso27001_mapping: ['A.5.15', 'A.5.17', 'A.8.5'],
    priority: 'critical',
    effort_estimate: 30,
    typical_implementation_time: '4-8 weeks',
    position: 3
  },
  {
    control_id: 'NIS2-RM-04',
    category: 'risk_management',
    domain: 'cryptography',
    title: 'Cryptography and Data Protection',
    description: 'Implement cryptographic controls to protect sensitive data',
    requirement_text: 'Appropriate encryption and cryptographic controls must be used to protect the confidentiality and integrity of data in transit and at rest.',
    implementation_guidance: [
      'Encrypt all sensitive data at rest using AES-256 or equivalent',
      'Use TLS 1.3 or higher for data in transit',
      'Implement full disk encryption for endpoints',
      'Establish key management procedures',
      'Use approved cryptographic algorithms only',
      'Regularly review and update cryptographic standards'
    ],
    verification_methods: [
      'Review encryption implementation',
      'Test TLS configuration',
      'Review key management procedures',
      'Verify approved algorithms in use'
    ],
    evidence_types: [
      'Encryption policy',
      'SSL/TLS scan results',
      'Key management procedures',
      'Cryptography standards document'
    ],
    iso27001_mapping: ['A.8.24'],
    priority: 'critical',
    effort_estimate: 40,
    typical_implementation_time: '6-10 weeks',
    position: 4
  },
  {
    control_id: 'NIS2-RM-05',
    category: 'risk_management',
    domain: 'supply_chain',
    title: 'Supply Chain Security',
    description: 'Manage cybersecurity risks from suppliers and service providers',
    requirement_text: 'Organizations must address cybersecurity in their relationships with suppliers and service providers, particularly those providing ICT services.',
    implementation_guidance: [
      'Conduct security assessments of critical suppliers',
      'Include security requirements in vendor contracts',
      'Monitor third-party security posture',
      'Implement vendor risk management program',
      'Require security certifications (ISO 27001, SOC 2)',
      'Conduct regular vendor audits'
    ],
    verification_methods: [
      'Review vendor assessment reports',
      'Review vendor contracts for security clauses',
      'Interview procurement team',
      'Review vendor risk register'
    ],
    evidence_types: [
      'Vendor assessment questionnaires',
      'Vendor contracts with security clauses',
      'Third-party certifications',
      'Vendor audit reports'
    ],
    iso27001_mapping: ['A.5.19', 'A.5.20', 'A.5.21', 'A.5.22'],
    priority: 'high',
    effort_estimate: 50,
    typical_implementation_time: '8-12 weeks',
    position: 5
  },
  {
    control_id: 'NIS2-RM-06',
    category: 'risk_management',
    domain: 'awareness',
    title: 'Security Awareness and Training',
    description: 'Provide comprehensive cybersecurity awareness training to all personnel',
    requirement_text: 'Personnel must receive appropriate training to identify and respond to cybersecurity threats and incidents.',
    implementation_guidance: [
      'Develop mandatory security awareness training program',
      'Provide role-specific security training',
      'Conduct annual refresher training',
      'Implement phishing simulation campaigns',
      'Track training completion rates',
      'Test effectiveness of training programs'
    ],
    verification_methods: [
      'Review training curriculum',
      'Review training completion records',
      'Review phishing simulation results',
      'Interview staff on security awareness'
    ],
    evidence_types: [
      'Training materials and curriculum',
      'Training completion certificates',
      'Phishing simulation reports',
      'Training effectiveness metrics'
    ],
    iso27001_mapping: ['A.6.3'],
    priority: 'high',
    effort_estimate: 30,
    typical_implementation_time: '4-6 weeks',
    position: 6
  },
  {
    control_id: 'NIS2-RM-07',
    category: 'risk_management',
    domain: 'vulnerability_management',
    title: 'Vulnerability Management',
    description: 'Identify, assess, and remediate security vulnerabilities',
    requirement_text: 'Organizations must implement processes to identify, assess, prioritize and remediate security vulnerabilities in a timely manner.',
    implementation_guidance: [
      'Conduct automated vulnerability scanning (monthly minimum)',
      'Implement vulnerability assessment procedures',
      'Prioritize vulnerabilities based on risk',
      'Define SLAs for remediation (critical: 7 days, high: 30 days)',
      'Track and report remediation progress',
      'Conduct annual penetration testing'
    ],
    verification_methods: [
      'Review vulnerability scan reports',
      'Review remediation tracking',
      'Test vulnerability scanning coverage',
      'Review penetration test results'
    ],
    evidence_types: [
      'Vulnerability scan reports',
      'Remediation tracking records',
      'Penetration test reports',
      'Vulnerability management policy'
    ],
    iso27001_mapping: ['A.8.8'],
    priority: 'high',
    effort_estimate: 35,
    typical_implementation_time: '6-8 weeks',
    position: 7
  },
  {
    control_id: 'NIS2-RM-08',
    category: 'risk_management',
    domain: 'patch_management',
    title: 'Patch Management',
    description: 'Implement timely patching of systems and applications',
    requirement_text: 'Security patches must be applied in a timely manner to address known vulnerabilities.',
    implementation_guidance: [
      'Establish patch management policy and procedures',
      'Define patching SLAs (critical: 7 days, high: 30 days)',
      'Implement automated patch deployment where possible',
      'Test patches before production deployment',
      'Monitor patch compliance',
      'Maintain patch status inventory'
    ],
    verification_methods: [
      'Review patch management policy',
      'Review patch compliance reports',
      'Test patch deployment process',
      'Verify patching SLAs are met'
    ],
    evidence_types: [
      'Patch management policy',
      'Patch compliance reports',
      'Patch deployment logs',
      'Patch testing procedures'
    ],
    iso27001_mapping: ['A.8.8'],
    priority: 'high',
    effort_estimate: 25,
    typical_implementation_time: '4-6 weeks',
    position: 8
  },
  {
    control_id: 'NIS2-RM-09',
    category: 'risk_management',
    domain: 'monitoring',
    title: 'Security Monitoring and Logging',
    description: 'Implement continuous security monitoring and event logging',
    requirement_text: 'Organizations must implement security monitoring to detect, prevent, and respond to cybersecurity incidents.',
    implementation_guidance: [
      'Deploy Security Information and Event Management (SIEM) system',
      'Centralize log collection from all critical systems',
      'Implement real-time alerting for security events',
      'Retain logs for minimum 12 months',
      'Monitor for indicators of compromise (IOC)',
      'Implement 24/7 security monitoring'
    ],
    verification_methods: [
      'Review SIEM configuration',
      'Test alerting mechanisms',
      'Review log retention policies',
      'Verify monitoring coverage'
    ],
    evidence_types: [
      'SIEM architecture documentation',
      'Security monitoring reports',
      'Alert configurations',
      'Log retention policy'
    ],
    iso27001_mapping: ['A.8.15', 'A.8.16'],
    priority: 'critical',
    effort_estimate: 50,
    typical_implementation_time: '8-12 weeks',
    position: 9
  },

  # === CORPORATE ACCOUNTABILITY CONTROLS ===
  {
    control_id: 'NIS2-CA-01',
    category: 'corporate_accountability',
    domain: 'governance',
    title: 'Management Oversight and Responsibility',
    description: 'Management body must approve cybersecurity measures and oversee implementation',
    requirement_text: 'The management body must approve the cybersecurity risk-management measures and oversee their implementation, and must be trained to identify cybersecurity risks.',
    implementation_guidance: [
      'Establish board-level cybersecurity committee',
      'Provide cybersecurity training to senior management',
      'Include cybersecurity in board meeting agendas (quarterly minimum)',
      'Document management approval of security measures',
      'Assign clear cybersecurity responsibilities to executives',
      'Implement management KPIs for cybersecurity'
    ],
    verification_methods: [
      'Review board meeting minutes',
      'Review management training records',
      'Interview executive management',
      'Review governance documentation'
    ],
    evidence_types: [
      'Board meeting minutes with cybersecurity discussions',
      'Management training certificates',
      'Governance framework document',
      'Management responsibility matrix'
    ],
    iso27001_mapping: ['A.5.1'],
    priority: 'critical',
    effort_estimate: 20,
    typical_implementation_time: '4-6 weeks',
    position: 10
  },
  {
    control_id: 'NIS2-CA-02',
    category: 'corporate_accountability',
    domain: 'policies',
    title: 'Security Policies and Procedures',
    description: 'Develop and maintain comprehensive cybersecurity policies',
    requirement_text: 'Organizations must establish, document, and maintain comprehensive cybersecurity policies covering all aspects of information security.',
    implementation_guidance: [
      'Develop information security policy suite',
      'Document all security procedures',
      'Establish policy review cycle (annual minimum)',
      'Obtain management approval for all policies',
      'Communicate policies to all staff',
      'Track policy acknowledgments'
    ],
    verification_methods: [
      'Review policy documentation',
      'Verify policy approval signatures',
      'Review policy communication records',
      'Check policy acknowledgment tracking'
    ],
    evidence_types: [
      'Information security policies',
      'Policy approval documentation',
      'Policy acknowledgment records',
      'Policy review schedule'
    ],
    iso27001_mapping: ['A.5.1'],
    priority: 'high',
    effort_estimate: 30,
    typical_implementation_time: '6-8 weeks',
    position: 11
  },
  {
    control_id: 'NIS2-CA-03',
    category: 'corporate_accountability',
    domain: 'resources',
    title: 'Resource Allocation for Cybersecurity',
    description: 'Allocate adequate resources for cybersecurity measures',
    requirement_text: 'Organizations must allocate appropriate financial and human resources to implement and maintain cybersecurity measures.',
    implementation_guidance: [
      'Establish dedicated cybersecurity budget',
      'Hire or assign qualified security personnel',
      'Provide resources for security tools and technologies',
      'Budget for training and awareness programs',
      'Allocate resources for incident response',
      'Review and adjust resource allocation annually'
    ],
    verification_methods: [
      'Review cybersecurity budget',
      'Review organizational structure',
      'Interview security team',
      'Verify staffing levels'
    ],
    evidence_types: [
      'Cybersecurity budget documentation',
      'Organizational charts showing security roles',
      'Job descriptions for security positions',
      'Resource allocation reports'
    ],
    iso27001_mapping: ['A.5.1'],
    priority: 'high',
    effort_estimate: 15,
    typical_implementation_time: '2-4 weeks',
    position: 12
  },

  # === REPORTING OBLIGATIONS CONTROLS ===
  {
    control_id: 'NIS2-RO-01',
    category: 'reporting_obligations',
    domain: 'detection',
    title: 'Incident Detection Capabilities',
    description: 'Implement capabilities to detect cybersecurity incidents',
    requirement_text: 'Organizations must have appropriate technical and organizational measures to promptly detect cybersecurity incidents.',
    implementation_guidance: [
      'Implement SIEM or security monitoring solution',
      'Deploy endpoint detection and response (EDR)',
      'Establish security operations center (SOC) or equivalent',
      'Define incident detection criteria',
      'Implement automated threat detection',
      'Conduct regular threat hunting activities'
    ],
    verification_methods: [
      'Review monitoring capabilities',
      'Test incident detection',
      'Review SOC procedures',
      'Verify detection coverage'
    ],
    evidence_types: [
      'SIEM/monitoring documentation',
      'Incident detection procedures',
      'SOC playbooks',
      'Detection capability assessments'
    ],
    iso27001_mapping: ['A.5.24', 'A.5.25'],
    priority: 'critical',
    effort_estimate: 45,
    typical_implementation_time: '8-10 weeks',
    position: 13
  },
  {
    control_id: 'NIS2-RO-02',
    category: 'reporting_obligations',
    domain: 'notification',
    title: '24-Hour Initial Notification Process',
    description: 'Implement process for initial notification within 24 hours',
    requirement_text: 'Significant incidents must be reported to the competent authority or CSIRT within 24 hours of becoming aware of the incident.',
    implementation_guidance: [
      'Establish incident notification procedures',
      'Define criteria for significant incidents',
      'Create notification templates',
      'Establish contact list for authorities',
      'Implement 24/7 incident response capability',
      'Test notification process regularly'
    ],
    verification_methods: [
      'Review notification procedures',
      'Review incident classification criteria',
      'Test notification process',
      'Review past notifications'
    ],
    evidence_types: [
      'Incident notification procedures',
      'Incident classification matrix',
      'Notification templates',
      'Test exercise reports'
    ],
    iso27001_mapping: ['A.5.24', 'A.5.26'],
    priority: 'critical',
    effort_estimate: 25,
    typical_implementation_time: '4-6 weeks',
    position: 14
  },
  {
    control_id: 'NIS2-RO-03',
    category: 'reporting_obligations',
    domain: 'notification',
    title: '72-Hour Detailed Incident Report',
    description: 'Submit detailed incident report within 72 hours',
    requirement_text: 'A detailed incident report must be submitted within 72 hours, including initial assessment of severity and impact.',
    implementation_guidance: [
      'Develop detailed incident report template',
      'Establish incident investigation procedures',
      'Define impact assessment methodology',
      'Assign incident response team roles',
      'Implement incident tracking system',
      'Practice report generation through exercises'
    ],
    verification_methods: [
      'Review report templates',
      'Review investigation procedures',
      'Test report generation process',
      'Review past incident reports'
    ],
    evidence_types: [
      'Incident report templates',
      'Investigation procedures',
      'Impact assessment methodology',
      'Sample incident reports'
    ],
    iso27001_mapping: ['A.5.26'],
    priority: 'critical',
    effort_estimate: 20,
    typical_implementation_time: '3-5 weeks',
    position: 15
  },

  # === BUSINESS CONTINUITY CONTROLS ===
  {
    control_id: 'NIS2-BC-01',
    category: 'business_continuity',
    domain: 'planning',
    title: 'Business Impact Analysis',
    description: 'Conduct business impact analysis for critical services',
    requirement_text: 'Organizations must identify critical business functions and assess the impact of disruptions.',
    implementation_guidance: [
      'Identify all critical business functions',
      'Determine maximum tolerable downtime (MTD)',
      'Define recovery time objectives (RTO)',
      'Define recovery point objectives (RPO)',
      'Assess dependencies and resources',
      'Update BIA annually or when significant changes occur'
    ],
    verification_methods: [
      'Review BIA documentation',
      'Interview business function owners',
      'Verify RTO/RPO definitions',
      'Review dependency mappings'
    ],
    evidence_types: [
      'Business impact analysis report',
      'Critical function inventory',
      'RTO/RPO documentation',
      'Dependency maps'
    ],
    iso27001_mapping: ['A.5.29', 'A.5.30'],
    priority: 'high',
    effort_estimate: 35,
    typical_implementation_time: '6-8 weeks',
    position: 16
  },
  {
    control_id: 'NIS2-BC-02',
    category: 'business_continuity',
    domain: 'backup',
    title: 'Backup and Recovery Procedures',
    description: 'Implement robust backup and recovery capabilities',
    requirement_text: 'Organizations must implement backup solutions and test recovery procedures regularly.',
    implementation_guidance: [
      'Implement 3-2-1 backup strategy (3 copies, 2 media types, 1 offsite)',
      'Automate backup processes',
      'Encrypt backup data',
      'Test restore procedures quarterly',
      'Document backup and recovery procedures',
      'Monitor backup success rates'
    ],
    verification_methods: [
      'Review backup configuration',
      'Test restore procedures',
      'Review backup logs',
      'Verify offsite backup storage'
    ],
    evidence_types: [
      'Backup policy and procedures',
      'Backup configuration documentation',
      'Restore test reports',
      'Backup monitoring reports'
    ],
    iso27001_mapping: ['A.8.13'],
    priority: 'critical',
    effort_estimate: 30,
    typical_implementation_time: '4-6 weeks',
    position: 17
  },
  {
    control_id: 'NIS2-BC-03',
    category: 'business_continuity',
    domain: 'crisis',
    title: 'Crisis Management Plan',
    description: 'Develop and maintain crisis management procedures',
    requirement_text: 'Organizations must have procedures in place to effectively manage and respond to crises.',
    implementation_guidance: [
      'Develop crisis management plan',
      'Establish crisis management team',
      'Define communication protocols',
      'Create crisis response playbooks',
      'Conduct annual crisis simulations',
      'Maintain crisis contact lists'
    ],
    verification_methods: [
      'Review crisis management plan',
      'Review team composition',
      'Review exercise reports',
      'Test communication channels'
    ],
    evidence_types: [
      'Crisis management plan',
      'Team roster with contact information',
      'Crisis exercise reports',
      'Communication protocols'
    ],
    iso27001_mapping: ['A.5.29'],
    priority: 'high',
    effort_estimate: 30,
    typical_implementation_time: '5-7 weeks',
    position: 18
  },
  {
    control_id: 'NIS2-BC-04',
    category: 'business_continuity',
    domain: 'testing',
    title: 'Business Continuity Testing',
    description: 'Regular testing of business continuity and disaster recovery plans',
    requirement_text: 'Business continuity plans must be tested at least annually to ensure effectiveness.',
    implementation_guidance: [
      'Develop BC/DR testing schedule',
      'Conduct tabletop exercises',
      'Perform technical recovery tests',
      'Document test results and findings',
      'Update plans based on test results',
      'Involve all relevant stakeholders in tests'
    ],
    verification_methods: [
      'Review test schedule',
      'Review test reports',
      'Observe test exercises',
      'Verify plan updates from test findings'
    ],
    evidence_types: [
      'BC/DR test schedule',
      'Test exercise reports',
      'After-action reports',
      'Updated plans showing improvements'
    ],
    iso27001_mapping: ['A.5.30'],
    priority: 'high',
    effort_estimate: 25,
    typical_implementation_time: '4-6 weeks',
    position: 19
  }
]

# Seed the controls
created_count = 0
updated_count = 0

controls_data.each do |control_data|
  control = Nis2Control.find_or_initialize_by(control_id: control_data[:control_id])

  if control.new_record?
    control.attributes = control_data
    if control.save
      created_count += 1
    else
      puts "  ERROR: Failed to create #{control_data[:control_id]}: #{control.errors.full_messages.join(', ')}"
    end
  else
    control.attributes = control_data
    if control.save
      updated_count += 1
    else
      puts "  ERROR: Failed to update #{control_data[:control_id]}: #{control.errors.full_messages.join(', ')}"
    end
  end
end

puts "Seed completed:"
puts "  - Created: #{created_count} controls"
puts "  - Updated: #{updated_count} controls"
puts "  - Total: #{Nis2Control.count} controls in database"
puts ""
puts "Controls by category:"
Nis2Control.by_category_stats.each do |category, count|
  puts "  - #{Nis2Control::CATEGORIES[category]}: #{count}"
end
puts ""
puts "Controls by priority:"
Nis2Control.by_priority_stats.each do |priority, count|
  puts "  - #{Nis2Control::PRIORITIES[priority]}: #{count}"
end
