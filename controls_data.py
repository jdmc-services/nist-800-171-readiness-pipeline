"""
controls_data.py — Complete NIST SP 800-171 Revision 2 security requirement
corpus: all 110 requirements across 14 families. NIST publications are U.S.
Government works. Rev 2 is the current CMMC Level 2 assessment baseline
(per DoD class deviation; Rev 3 is not yet authorized for CMMC or SPRS).
"""

CONTROLS = [
    # ---- 3.1 Access Control (22) ----
    {"id": "3.1.1",  "family": "Access Control", "text": "Limit system access to authorized users, processes acting on behalf of authorized users, and devices including other systems."},
    {"id": "3.1.2",  "family": "Access Control", "text": "Limit system access to the types of transactions and functions that authorized users are permitted to execute."},
    {"id": "3.1.3",  "family": "Access Control", "text": "Control the flow of CUI in accordance with approved authorizations."},
    {"id": "3.1.4",  "family": "Access Control", "text": "Separate the duties of individuals to reduce the risk of malevolent activity without collusion."},
    {"id": "3.1.5",  "family": "Access Control", "text": "Employ the principle of least privilege, including for specific security functions and privileged accounts."},
    {"id": "3.1.6",  "family": "Access Control", "text": "Use non-privileged accounts or roles when accessing nonsecurity functions."},
    {"id": "3.1.7",  "family": "Access Control", "text": "Prevent non-privileged users from executing privileged functions and capture the execution of such functions in audit logs."},
    {"id": "3.1.8",  "family": "Access Control", "text": "Limit unsuccessful logon attempts."},
    {"id": "3.1.9",  "family": "Access Control", "text": "Provide privacy and security notices consistent with applicable CUI rules."},
    {"id": "3.1.10", "family": "Access Control", "text": "Use session lock with pattern-hiding displays to prevent access and viewing of data after a period of inactivity."},
    {"id": "3.1.11", "family": "Access Control", "text": "Terminate automatically a user session after a defined condition."},
    {"id": "3.1.12", "family": "Access Control", "text": "Monitor and control remote access sessions."},
    {"id": "3.1.13", "family": "Access Control", "text": "Employ cryptographic mechanisms to protect the confidentiality of remote access sessions."},
    {"id": "3.1.14", "family": "Access Control", "text": "Route remote access via managed access control points."},
    {"id": "3.1.15", "family": "Access Control", "text": "Authorize remote execution of privileged commands and remote access to security-relevant information."},
    {"id": "3.1.16", "family": "Access Control", "text": "Authorize wireless access prior to allowing such connections."},
    {"id": "3.1.17", "family": "Access Control", "text": "Protect wireless access using authentication and encryption."},
    {"id": "3.1.18", "family": "Access Control", "text": "Control connection of mobile devices."},
    {"id": "3.1.19", "family": "Access Control", "text": "Encrypt CUI on mobile devices and mobile computing platforms."},
    {"id": "3.1.20", "family": "Access Control", "text": "Verify and control or limit connections to and use of external systems."},
    {"id": "3.1.21", "family": "Access Control", "text": "Limit use of portable storage devices on external systems."},
    {"id": "3.1.22", "family": "Access Control", "text": "Control CUI posted or processed on publicly accessible systems."},
    # ---- 3.2 Awareness and Training (3) ----
    {"id": "3.2.1",  "family": "Awareness and Training", "text": "Ensure that managers, systems administrators, and users of organizational systems are made aware of the security risks associated with their activities and of the applicable policies, standards, and procedures related to the security of those systems."},
    {"id": "3.2.2",  "family": "Awareness and Training", "text": "Ensure that personnel are trained to carry out their assigned information security-related duties and responsibilities."},
    {"id": "3.2.3",  "family": "Awareness and Training", "text": "Provide security awareness training on recognizing and reporting potential indicators of insider threat."},
    # ---- 3.3 Audit and Accountability (9) ----
    {"id": "3.3.1",  "family": "Audit and Accountability", "text": "Create and retain system audit logs and records to the extent needed to enable the monitoring, analysis, investigation, and reporting of unlawful or unauthorized system activity."},
    {"id": "3.3.2",  "family": "Audit and Accountability", "text": "Ensure that the actions of individual system users can be uniquely traced to those users so they can be held accountable for their actions."},
    {"id": "3.3.3",  "family": "Audit and Accountability", "text": "Review and update logged events."},
    {"id": "3.3.4",  "family": "Audit and Accountability", "text": "Alert in the event of an audit logging process failure."},
    {"id": "3.3.5",  "family": "Audit and Accountability", "text": "Correlate audit record review, analysis, and reporting processes for investigation and response to indications of unlawful, unauthorized, suspicious, or unusual activity."},
    {"id": "3.3.6",  "family": "Audit and Accountability", "text": "Provide audit record reduction and report generation to support on-demand analysis and reporting."},
    {"id": "3.3.7",  "family": "Audit and Accountability", "text": "Provide a system capability that compares and synchronizes internal system clocks with an authoritative source to generate time stamps for audit records."},
    {"id": "3.3.8",  "family": "Audit and Accountability", "text": "Protect audit information and audit logging tools from unauthorized access, modification, and deletion."},
    {"id": "3.3.9",  "family": "Audit and Accountability", "text": "Limit management of audit logging functionality to a subset of privileged users."},
    # ---- 3.4 Configuration Management (9) ----
    {"id": "3.4.1",  "family": "Configuration Management", "text": "Establish and maintain baseline configurations and inventories of organizational systems including hardware, software, firmware, and documentation throughout the respective system development life cycles."},
    {"id": "3.4.2",  "family": "Configuration Management", "text": "Establish and enforce security configuration settings for information technology products employed in organizational systems."},
    {"id": "3.4.3",  "family": "Configuration Management", "text": "Track, review, approve or disapprove, and log changes to organizational systems."},
    {"id": "3.4.4",  "family": "Configuration Management", "text": "Analyze the security impact of changes prior to implementation."},
    {"id": "3.4.5",  "family": "Configuration Management", "text": "Define, document, approve, and enforce physical and logical access restrictions associated with changes to organizational systems."},
    {"id": "3.4.6",  "family": "Configuration Management", "text": "Employ the principle of least functionality by configuring organizational systems to provide only essential capabilities."},
    {"id": "3.4.7",  "family": "Configuration Management", "text": "Restrict, disable, or prevent the use of nonessential programs, functions, ports, protocols, and services."},
    {"id": "3.4.8",  "family": "Configuration Management", "text": "Apply deny-by-exception blacklisting policy to prevent the use of unauthorized software or deny-all permit-by-exception whitelisting policy to allow the execution of authorized software."},
    {"id": "3.4.9",  "family": "Configuration Management", "text": "Control and monitor user-installed software."},
    # ---- 3.5 Identification and Authentication (11) ----
    {"id": "3.5.1",  "family": "Identification and Authentication", "text": "Identify system users, processes acting on behalf of users, and devices."},
    {"id": "3.5.2",  "family": "Identification and Authentication", "text": "Authenticate or verify the identities of users, processes, or devices as a prerequisite to allowing access to organizational systems."},
    {"id": "3.5.3",  "family": "Identification and Authentication", "text": "Use multifactor authentication for local and network access to privileged accounts and for network access to non-privileged accounts."},
    {"id": "3.5.4",  "family": "Identification and Authentication", "text": "Employ replay-resistant authentication mechanisms for network access to privileged and non-privileged accounts."},
    {"id": "3.5.5",  "family": "Identification and Authentication", "text": "Prevent reuse of identifiers for a defined period."},
    {"id": "3.5.6",  "family": "Identification and Authentication", "text": "Disable identifiers after a defined period of inactivity."},
    {"id": "3.5.7",  "family": "Identification and Authentication", "text": "Enforce a minimum password complexity and change of characters when new passwords are created."},
    {"id": "3.5.8",  "family": "Identification and Authentication", "text": "Prohibit password reuse for a specified number of generations."},
    {"id": "3.5.9",  "family": "Identification and Authentication", "text": "Allow temporary password use for system logons with an immediate change to a permanent password."},
    {"id": "3.5.10", "family": "Identification and Authentication", "text": "Store and transmit only cryptographically-protected passwords."},
    {"id": "3.5.11", "family": "Identification and Authentication", "text": "Obscure feedback of authentication information."},
    # ---- 3.6 Incident Response (3) ----
    {"id": "3.6.1",  "family": "Incident Response", "text": "Establish an operational incident-handling capability for organizational systems that includes preparation, detection, analysis, containment, recovery, and user response activities."},
    {"id": "3.6.2",  "family": "Incident Response", "text": "Track, document, and report incidents to designated officials and authorities both internal and external to the organization."},
    {"id": "3.6.3",  "family": "Incident Response", "text": "Test the organizational incident response capability."},
    # ---- 3.7 Maintenance (6) ----
    {"id": "3.7.1",  "family": "Maintenance", "text": "Perform maintenance on organizational systems."},
    {"id": "3.7.2",  "family": "Maintenance", "text": "Provide controls on the tools, techniques, mechanisms, and personnel used to conduct system maintenance."},
    {"id": "3.7.3",  "family": "Maintenance", "text": "Ensure equipment removed for off-site maintenance is sanitized of any CUI."},
    {"id": "3.7.4",  "family": "Maintenance", "text": "Check media containing diagnostic and test programs for malicious code before the media are used in organizational systems."},
    {"id": "3.7.5",  "family": "Maintenance", "text": "Require multifactor authentication to establish nonlocal maintenance sessions via external network connections and terminate such connections when nonlocal maintenance is complete."},
    {"id": "3.7.6",  "family": "Maintenance", "text": "Supervise the maintenance activities of maintenance personnel without required access authorization."},
    # ---- 3.8 Media Protection (9) ----
    {"id": "3.8.1",  "family": "Media Protection", "text": "Protect, physically control, and securely store system media containing CUI, both paper and digital."},
    {"id": "3.8.2",  "family": "Media Protection", "text": "Limit access to CUI on system media to authorized users."},
    {"id": "3.8.3",  "family": "Media Protection", "text": "Sanitize or destroy system media containing CUI before disposal or release for reuse."},
    {"id": "3.8.4",  "family": "Media Protection", "text": "Mark media with necessary CUI markings and distribution limitations."},
    {"id": "3.8.5",  "family": "Media Protection", "text": "Control access to media containing CUI and maintain accountability for media during transport outside of controlled areas."},
    {"id": "3.8.6",  "family": "Media Protection", "text": "Implement cryptographic mechanisms to protect the confidentiality of CUI stored on digital media during transport unless otherwise protected by alternative physical safeguards."},
    {"id": "3.8.7",  "family": "Media Protection", "text": "Control the use of removable media on system components."},
    {"id": "3.8.8",  "family": "Media Protection", "text": "Prohibit the use of portable storage devices when such devices have no identifiable owner."},
    {"id": "3.8.9",  "family": "Media Protection", "text": "Protect the confidentiality of backup CUI at storage locations."},
    # ---- 3.9 Personnel Security (2) ----
    {"id": "3.9.1",  "family": "Personnel Security", "text": "Screen individuals prior to authorizing access to organizational systems containing CUI."},
    {"id": "3.9.2",  "family": "Personnel Security", "text": "Ensure that organizational systems containing CUI are protected during and after personnel actions such as terminations and transfers."},
    # ---- 3.10 Physical Protection (6) ----
    {"id": "3.10.1", "family": "Physical Protection", "text": "Limit physical access to organizational systems, equipment, and the respective operating environments to authorized individuals."},
    {"id": "3.10.2", "family": "Physical Protection", "text": "Protect and monitor the physical facility and support infrastructure for organizational systems."},
    {"id": "3.10.3", "family": "Physical Protection", "text": "Escort visitors and monitor visitor activity."},
    {"id": "3.10.4", "family": "Physical Protection", "text": "Maintain audit logs of physical access."},
    {"id": "3.10.5", "family": "Physical Protection", "text": "Control and manage physical access devices."},
    {"id": "3.10.6", "family": "Physical Protection", "text": "Enforce safeguarding measures for CUI at alternate work sites."},
    # ---- 3.11 Risk Assessment (3) ----
    {"id": "3.11.1", "family": "Risk Assessment", "text": "Periodically assess the risk to organizational operations, organizational assets, and individuals, resulting from the operation of organizational systems and the associated processing, storage, or transmission of CUI."},
    {"id": "3.11.2", "family": "Risk Assessment", "text": "Scan for vulnerabilities in organizational systems and applications periodically and when new vulnerabilities affecting those systems and applications are identified."},
    {"id": "3.11.3", "family": "Risk Assessment", "text": "Remediate vulnerabilities in accordance with risk assessments."},
    # ---- 3.12 Security Assessment (4) ----
    {"id": "3.12.1", "family": "Security Assessment", "text": "Periodically assess the security controls in organizational systems to determine if the controls are effective in their application."},
    {"id": "3.12.2", "family": "Security Assessment", "text": "Develop and implement plans of action designed to correct deficiencies and reduce or eliminate vulnerabilities in organizational systems."},
    {"id": "3.12.3", "family": "Security Assessment", "text": "Monitor security controls on an ongoing basis to ensure the continued effectiveness of the controls."},
    {"id": "3.12.4", "family": "Security Assessment", "text": "Develop, document, and periodically update system security plans that describe system boundaries, system environments of operation, how security requirements are implemented, and the relationships with or connections to other systems."},
    # ---- 3.13 System and Communications Protection (16) ----
    {"id": "3.13.1", "family": "System and Communications Protection", "text": "Monitor, control, and protect communications, meaning information transmitted or received by organizational systems, at the external boundaries and key internal boundaries of organizational systems."},
    {"id": "3.13.2", "family": "System and Communications Protection", "text": "Employ architectural designs, software development techniques, and systems engineering principles that promote effective information security within organizational systems."},
    {"id": "3.13.3", "family": "System and Communications Protection", "text": "Separate user functionality from system management functionality."},
    {"id": "3.13.4", "family": "System and Communications Protection", "text": "Prevent unauthorized and unintended information transfer via shared system resources."},
    {"id": "3.13.5", "family": "System and Communications Protection", "text": "Implement subnetworks for publicly accessible system components that are physically or logically separated from internal networks."},
    {"id": "3.13.6", "family": "System and Communications Protection", "text": "Deny network communications traffic by default and allow network communications traffic by exception, that is, deny all and permit by exception."},
    {"id": "3.13.7", "family": "System and Communications Protection", "text": "Prevent remote devices from simultaneously establishing non-remote connections with organizational systems and communicating via some other connection to resources in external networks, known as split tunneling."},
    {"id": "3.13.8", "family": "System and Communications Protection", "text": "Implement cryptographic mechanisms to prevent unauthorized disclosure of CUI during transmission unless otherwise protected by alternative physical safeguards."},
    {"id": "3.13.9", "family": "System and Communications Protection", "text": "Terminate network connections associated with communications sessions at the end of the sessions or after a defined period of inactivity."},
    {"id": "3.13.10","family": "System and Communications Protection", "text": "Establish and manage cryptographic keys for cryptography employed in organizational systems."},
    {"id": "3.13.11","family": "System and Communications Protection", "text": "Employ FIPS-validated cryptography when used to protect the confidentiality of CUI."},
    {"id": "3.13.12","family": "System and Communications Protection", "text": "Prohibit remote activation of collaborative computing devices and provide indication of devices in use to users present at the device."},
    {"id": "3.13.13","family": "System and Communications Protection", "text": "Control and monitor the use of mobile code."},
    {"id": "3.13.14","family": "System and Communications Protection", "text": "Control and monitor the use of Voice over Internet Protocol technologies."},
    {"id": "3.13.15","family": "System and Communications Protection", "text": "Protect the authenticity of communications sessions."},
    {"id": "3.13.16","family": "System and Communications Protection", "text": "Protect the confidentiality of CUI at rest."},
    # ---- 3.14 System and Information Integrity (7) ----
    {"id": "3.14.1", "family": "System and Information Integrity", "text": "Identify, report, and correct system flaws in a timely manner."},
    {"id": "3.14.2", "family": "System and Information Integrity", "text": "Provide protection from malicious code at designated locations within organizational systems."},
    {"id": "3.14.3", "family": "System and Information Integrity", "text": "Monitor system security alerts and advisories and take action in response."},
    {"id": "3.14.4", "family": "System and Information Integrity", "text": "Update malicious code protection mechanisms when new releases are available."},
    {"id": "3.14.5", "family": "System and Information Integrity", "text": "Perform periodic scans of organizational systems and real-time scans of files from external sources as files are downloaded, opened, or executed."},
    {"id": "3.14.6", "family": "System and Information Integrity", "text": "Monitor organizational systems, including inbound and outbound communications traffic, to detect attacks and indicators of potential attacks."},
    {"id": "3.14.7", "family": "System and Information Integrity", "text": "Identify unauthorized use of organizational systems."},
]

# Structural guards: fail fast if the corpus is ever edited incompletely.
assert len(CONTROLS) == 110, f"Expected 110 Rev 2 requirements, found {len(CONTROLS)}"
assert len({c["id"] for c in CONTROLS}) == 110, "Duplicate control IDs detected"