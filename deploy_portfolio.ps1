# ============================================================
# deploy_portfolio.ps1  (v2 — all corrections applied)
# NIST SP 800-171 Rev 2 Local Compliance Assessment Pipeline
# Automated workspace generator — run from an EMPTY directory.
#
# Corrections integrated in this version:
#   1. BOM-free UTF-8 writer (fixes broken .gitignore and JSON
#      parsing under Windows PowerShell 5.1)
#   2. Full 110-requirement NIST SP 800-171 Rev 2 corpus in a
#      dedicated controls_data.py module
#   3. utf-8-sig reads for user-supplied JSON (BOM tolerant)
#   4. TOP_K = 8 similarity neighborhood for the 110-control space
#   5. git init -b main (no stderr redirection issues)
# ============================================================
$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $fullPath = Join-Path (Get-Location).Path $Path
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $enc)
}

Write-Host "== Preflight checks ==" -ForegroundColor Cyan

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git is not installed or not on PATH. Install Git and re-run."
}
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "Python is not installed or not on PATH. Install Python 3.10+ and re-run."
}

$existing = Get-ChildItem -Force | Where-Object { $_.Name -ne (Split-Path $PSCommandPath -Leaf) }
if ($existing.Count -gt 0) {
    Write-Warning "Directory is not empty. Existing files will be preserved; generated files will overwrite same-named files."
}

Write-Host "== Initializing local Git repository ==" -ForegroundColor Cyan
git init -b main | Out-Null

Write-Host "== Creating directory structure ==" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path "data"    | Out-Null   # runtime artifacts (results JSON)
New-Item -ItemType Directory -Force -Path "samples" | Out-Null   # sample input for demos

# ------------------------------------------------------------
# controls_data.py — full 110-requirement Rev 2 corpus
# ------------------------------------------------------------
Write-Host "== Writing controls_data.py (full 110-requirement Rev 2 corpus) ==" -ForegroundColor Cyan
$controls = @'
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
'@
Write-Utf8NoBom "controls_data.py" $controls

# ------------------------------------------------------------
# sanitize.py — Agent 1: The Sanitizer
# ------------------------------------------------------------
Write-Host "== Writing sanitize.py ==" -ForegroundColor Cyan
$sanitize = @'
"""
sanitize.py — Agent 1: The Sanitizer.
Deterministic, regex-based credential/token stripper.
Reads config.json, writes cleaned_config.json.
Two-pass strategy:
  Pass 1: key-based redaction (any JSON key matching SENSITIVE_KEY_PATTERN)
  Pass 2: value-based redaction (secret-shaped strings anywhere in values)
"""

import json
import re
import sys
from pathlib import Path

REDACTED = "[REDACTED]"

SENSITIVE_KEY_PATTERN = re.compile(
    r"(password|passwd|pwd|secret|token|api[_-]?key|access[_-]?key|"
    r"private[_-]?key|credential|connection[_-]?string|client[_-]?secret|"
    r"auth|bearer|cert|passphrase)",
    re.IGNORECASE,
)

VALUE_PATTERNS = [
    # AWS access key IDs
    re.compile(r"\b(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}\b"),
    # AWS secret-key-shaped 40-char base64-ish strings following key=/: assignment
    re.compile(r"(?i)(aws_secret[_a-z]*\s*[:=]\s*)['\"]?[A-Za-z0-9/+=]{40}['\"]?"),
    # Bearer tokens
    re.compile(r"(?i)bearer\s+[A-Za-z0-9\-._~+/]{16,}=*"),
    # JWTs
    re.compile(r"\beyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\b"),
    # PEM private key blocks
    re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----[\s\S]*?-----END [A-Z ]*PRIVATE KEY-----"),
    # Inline key=value credentials
    re.compile(r"(?i)\b(password|pwd|secret|token|apikey|api_key)\s*[:=]\s*[^\s;,'\"]{4,}"),
    # Connection strings with embedded credentials (user:pass@host)
    re.compile(r"(?i)\b[a-z][a-z0-9+.-]*://[^\s/:@]+:[^\s/@]+@[^\s]+"),
    # GitHub tokens
    re.compile(r"\bgh[pousr]_[A-Za-z0-9]{20,}\b"),
    # Slack tokens
    re.compile(r"\bxox[baprs]-[A-Za-z0-9-]{10,}\b"),
]


def _scrub_string(value: str) -> str:
    for pattern in VALUE_PATTERNS:
        value = pattern.sub(REDACTED, value)
    return value


def _walk(node):
    """Recursively redact sensitive keys and secret-shaped values."""
    if isinstance(node, dict):
        cleaned = {}
        for key, val in node.items():
            if SENSITIVE_KEY_PATTERN.search(str(key)):
                cleaned[key] = REDACTED
            else:
                cleaned[key] = _walk(val)
        return cleaned
    if isinstance(node, list):
        return [_walk(item) for item in node]
    if isinstance(node, str):
        return _scrub_string(node)
    return node


def sanitize(input_path: str = "config.json",
             output_path: str = "cleaned_config.json") -> dict:
    """Sanitize input_path and write output_path. Returns stats dict."""
    src = Path(input_path)
    if not src.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")

    # utf-8-sig strips a BOM if present and reads plain UTF-8 identically.
    raw_text = src.read_text(encoding="utf-8-sig")
    data = json.loads(raw_text)
    cleaned = _walk(data)

    cleaned_text = json.dumps(cleaned, indent=2, ensure_ascii=False)
    Path(output_path).write_text(cleaned_text, encoding="utf-8")

    redaction_count = cleaned_text.count(REDACTED)
    stats = {
        "input": str(src),
        "output": output_path,
        "redactions": redaction_count,
        "bytes_in": len(raw_text.encode("utf-8")),
        "bytes_out": len(cleaned_text.encode("utf-8")),
    }
    return stats


if __name__ == "__main__":
    in_file = sys.argv[1] if len(sys.argv) > 1 else "config.json"
    result = sanitize(in_file)
    print(json.dumps(result, indent=2))
'@
Write-Utf8NoBom "sanitize.py" $sanitize

# ------------------------------------------------------------
# database_setup.py — Knowledge layer initialization
# ------------------------------------------------------------
Write-Host "== Writing database_setup.py ==" -ForegroundColor Cyan
$dbsetup = @'
"""
database_setup.py — Knowledge layer initialization.
Creates a persistent ChromaDB collection and embeds the full NIST SP 800-171
Rev 2 corpus (110 requirements, imported from controls_data.py) using
nomic-embed-text served by local Ollama.

Requires: Ollama running on localhost:11434 with `ollama pull nomic-embed-text`.
Expect the one-time build to take roughly 2-3 minutes for 110 controls.
"""

import sys
import requests
import chromadb

from controls_data import CONTROLS

OLLAMA_URL = "http://localhost:11434"
EMBED_MODEL = "nomic-embed-text"
DB_PATH = "compliance_db"
COLLECTION = "nist_800_171"


def get_embedding(text: str) -> list:
    """Fetch an embedding vector from local Ollama."""
    resp = requests.post(
        f"{OLLAMA_URL}/api/embeddings",
        json={"model": EMBED_MODEL, "prompt": text},
        timeout=60,
    )
    resp.raise_for_status()
    return resp.json()["embedding"]


def check_ollama() -> bool:
    try:
        r = requests.get(f"{OLLAMA_URL}/api/tags", timeout=5)
        return r.status_code == 200
    except requests.RequestException:
        return False


def build_database(db_path: str = DB_PATH) -> dict:
    """Embed all 110 controls into a persistent ChromaDB collection."""
    if not check_ollama():
        raise ConnectionError(
            "Ollama is not reachable at localhost:11434. "
            "Start Ollama and run: ollama pull nomic-embed-text"
        )

    client = chromadb.PersistentClient(path=db_path)
    # Recreate for idempotent rebuilds
    try:
        client.delete_collection(COLLECTION)
    except Exception:
        pass
    collection = client.create_collection(
        name=COLLECTION,
        metadata={"hnsw:space": "cosine"},
    )

    ids, docs, metas, vectors = [], [], [], []
    for i, ctrl in enumerate(CONTROLS, start=1):
        doc = f"NIST SP 800-171 {ctrl['id']} ({ctrl['family']}): {ctrl['text']}"
        vectors.append(get_embedding(doc))
        ids.append(ctrl["id"])
        docs.append(doc)
        metas.append({"family": ctrl["family"], "control_id": ctrl["id"]})
        print(f"  embedded {i}/{len(CONTROLS)}: {ctrl['id']}")

    collection.add(ids=ids, documents=docs, metadatas=metas, embeddings=vectors)
    return {"collection": COLLECTION, "controls_embedded": collection.count(), "path": db_path}


if __name__ == "__main__":
    stats = build_database()
    print(stats)
    sys.exit(0)
'@
Write-Utf8NoBom "database_setup.py" $dbsetup

# ------------------------------------------------------------
# evaluate_compliance.py — Agent 2: The Mapping Specialist
# ------------------------------------------------------------
Write-Host "== Writing evaluate_compliance.py ==" -ForegroundColor Cyan
$evaluate = @'
"""
evaluate_compliance.py — Agent 2: The Mapping Specialist.
Flattens cleaned_config.json into semantic statements, embeds each via
Ollama nomic-embed-text, and queries the ChromaDB control vector space.
Aggregates max cosine similarity per control and buckets into
Evidence Found / Partial Signal / Gap.
Writes data/compliance_results.json.
"""

import json
from pathlib import Path

import chromadb

from database_setup import (
    get_embedding, check_ollama, CONTROLS, DB_PATH, COLLECTION,
)

RESULTS_PATH = "data/compliance_results.json"
TOP_K = 8                  # similarity neighborhood per statement (110-control space)
COVERED_THRESHOLD = 0.62   # similarity >= this -> Evidence Found
PARTIAL_THRESHOLD = 0.45   # similarity >= this -> Partial Signal


def flatten_config(node, prefix="") -> list:
    """Convert nested JSON into human-readable statements for embedding."""
    statements = []
    if isinstance(node, dict):
        for key, val in node.items():
            path = f"{prefix}.{key}" if prefix else key
            if isinstance(val, (dict, list)):
                statements.extend(flatten_config(val, path))
            else:
                statements.append(f"Configuration setting {path} is set to: {val}")
    elif isinstance(node, list):
        for i, item in enumerate(node):
            path = f"{prefix}[{i}]"
            if isinstance(item, (dict, list)):
                statements.extend(flatten_config(item, path))
            else:
                statements.append(f"Configuration setting {path} contains: {item}")
    return statements


def evaluate(config_path: str = "cleaned_config.json",
             results_path: str = RESULTS_PATH) -> dict:
    if not check_ollama():
        raise ConnectionError("Ollama is not reachable at localhost:11434.")

    src = Path(config_path)
    if not src.exists():
        raise FileNotFoundError(
            f"{config_path} not found. Run sanitize.py first."
        )

    # utf-8-sig is BOM tolerant; identical to utf-8 for clean files.
    config = json.loads(src.read_text(encoding="utf-8-sig"))
    statements = flatten_config(config)
    if not statements:
        raise ValueError("Sanitized config produced no statements to evaluate.")

    client = chromadb.PersistentClient(path=DB_PATH)
    collection = client.get_collection(COLLECTION)

    # best similarity + supporting evidence per control
    best = {c["id"]: {"similarity": 0.0, "evidence": None} for c in CONTROLS}

    for stmt in statements:
        vector = get_embedding(stmt)
        hits = collection.query(
            query_embeddings=[vector],
            n_results=min(TOP_K, collection.count()),
        )
        for ctrl_id, distance in zip(hits["ids"][0], hits["distances"][0]):
            similarity = 1.0 - distance  # cosine space
            if similarity > best[ctrl_id]["similarity"]:
                best[ctrl_id] = {"similarity": similarity, "evidence": stmt}

    results = []
    for ctrl in CONTROLS:
        score = best[ctrl["id"]]["similarity"]
        if score >= COVERED_THRESHOLD:
            status = "Evidence Found"
        elif score >= PARTIAL_THRESHOLD:
            status = "Partial Signal"
        else:
            status = "Gap"
        results.append({
            "control_id": ctrl["id"],
            "family": ctrl["family"],
            "requirement": ctrl["text"],
            "status": status,
            "similarity": round(score, 4),
            "evidence": best[ctrl["id"]]["evidence"] if status != "Gap" else None,
        })

    summary = {
        "total_controls": len(results),
        "evidence_found": sum(1 for r in results if r["status"] == "Evidence Found"),
        "partial_signal": sum(1 for r in results if r["status"] == "Partial Signal"),
        "gaps": sum(1 for r in results if r["status"] == "Gap"),
        "statements_evaluated": len(statements),
    }
    payload = {"summary": summary, "results": results}

    out = Path(results_path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return payload


if __name__ == "__main__":
    data = evaluate()
    print(json.dumps(data["summary"], indent=2))
'@
Write-Utf8NoBom "evaluate_compliance.py" $evaluate

# ------------------------------------------------------------
# generate_report.py — Agent 3: The Artifact Generator
# ------------------------------------------------------------
Write-Host "== Writing generate_report.py ==" -ForegroundColor Cyan
$report = @'
"""
generate_report.py — Agent 3: The Artifact Generator.
Feeds the structured compliance results (never raw config) to local
Llama 3 via Ollama and returns a strictly 3-sentence executive summary.
"""

import json
import re
from pathlib import Path

import requests

OLLAMA_URL = "http://localhost:11434"
GEN_MODEL = "llama3"
RESULTS_PATH = "data/compliance_results.json"
REPORT_PATH = "data/executive_summary.txt"

SYSTEM_PROMPT = (
    "You are a NIST SP 800-171 compliance analyst writing for a non-technical "
    "executive audience. You will receive gap-analysis statistics. Respond with "
    "EXACTLY three sentences and nothing else: sentence one states overall "
    "readiness posture using the actual counts provided; sentence two names the "
    "control families with the most gaps; sentence three gives the single "
    "highest-impact remediation priority. Do not invent control IDs or numbers "
    "not present in the data. No preamble, no bullet points, no headers."
)


def _first_three_sentences(text: str) -> str:
    sentences = re.split(r"(?<=[.!?])\s+", text.strip())
    return " ".join(sentences[:3]).strip()


def generate_summary(results_path: str = RESULTS_PATH,
                     report_path: str = REPORT_PATH) -> str:
    src = Path(results_path)
    if not src.exists():
        raise FileNotFoundError(
            f"{results_path} not found. Run evaluate_compliance.py first."
        )
    payload = json.loads(src.read_text(encoding="utf-8"))
    summary = payload["summary"]

    gap_families = {}
    for r in payload["results"]:
        if r["status"] == "Gap":
            gap_families[r["family"]] = gap_families.get(r["family"], 0) + 1
    worst = sorted(gap_families.items(), key=lambda kv: kv[1], reverse=True)[:3]

    user_prompt = (
        f"Assessment data: {summary['total_controls']} controls evaluated. "
        f"Evidence Found: {summary['evidence_found']}. "
        f"Partial Signal: {summary['partial_signal']}. "
        f"Gaps: {summary['gaps']}. "
        f"Families with most gaps: {json.dumps(worst)}. "
        f"Write the 3-sentence executive summary now."
    )

    resp = requests.post(
        f"{OLLAMA_URL}/api/generate",
        json={
            "model": GEN_MODEL,
            "system": SYSTEM_PROMPT,
            "prompt": user_prompt,
            "stream": False,
            "options": {"temperature": 0.2, "num_predict": 300},
        },
        timeout=300,
    )
    resp.raise_for_status()
    raw = resp.json().get("response", "").strip()
    final = _first_three_sentences(raw)

    Path(report_path).parent.mkdir(parents=True, exist_ok=True)
    Path(report_path).write_text(final, encoding="utf-8")
    return final


if __name__ == "__main__":
    print(generate_summary())
'@
Write-Utf8NoBom "generate_report.py" $report

# ------------------------------------------------------------
# app.py — Streamlit presentation layer
# ------------------------------------------------------------
Write-Host "== Writing app.py ==" -ForegroundColor Cyan
$app = @'
"""
app.py — Streamlit presentation layer.
Sidebar: live status monitor (Ollama, ChromaDB, artifact presence).
Main: file upload -> sanitize -> evaluate -> generate report, with
results table, coverage metrics, and executive summary panel.
Run: streamlit run app.py
"""

import json
from pathlib import Path

import pandas as pd
import requests
import streamlit as st

from sanitize import sanitize
from database_setup import build_database, check_ollama, DB_PATH, COLLECTION
from evaluate_compliance import evaluate, RESULTS_PATH
from generate_report import generate_summary, REPORT_PATH

st.set_page_config(
    page_title="NIST 800-171 Readiness Pipeline",
    page_icon="\U0001F6E1\uFE0F",
    layout="wide",
)

GREEN = "\U0001F7E2"
YELLOW = "\U0001F7E1"
RED = "\U0001F534"
WHITE = "\u26AA"

STATUS_COLORS = {"Evidence Found": GREEN, "Partial Signal": YELLOW, "Gap": RED}


def chroma_status():
    try:
        import chromadb
        client = chromadb.PersistentClient(path=DB_PATH)
        col = client.get_collection(COLLECTION)
        return True, col.count()
    except Exception:
        return False, 0


def ollama_models():
    try:
        r = requests.get("http://localhost:11434/api/tags", timeout=5)
        return [m["name"] for m in r.json().get("models", [])]
    except Exception:
        return []


# ---------------- Sidebar: status monitor ----------------
with st.sidebar:
    st.header("System Status")

    ollama_ok = check_ollama()
    st.write((GREEN if ollama_ok else RED) + " Ollama inference engine")
    if ollama_ok:
        models = ollama_models()
        st.caption("Models: " + (", ".join(models) if models else "none pulled"))

    db_ok, ctrl_count = chroma_status()
    st.write((GREEN if db_ok else RED) + f" ChromaDB ({ctrl_count} controls)")

    for label, path in [
        ("Sanitized config", "cleaned_config.json"),
        ("Evaluation results", RESULTS_PATH),
        ("Executive summary", REPORT_PATH),
    ]:
        st.write((GREEN if Path(path).exists() else WHITE) + f" {label}")

    st.divider()
    if st.button("Initialize / Rebuild Control Database", use_container_width=True):
        with st.spinner("Embedding all 110 NIST SP 800-171 Rev 2 controls locally (2-3 min)..."):
            try:
                stats = build_database()
                st.success(f"Embedded {stats['controls_embedded']} controls.")
                st.rerun()
            except Exception as exc:
                st.error(str(exc))

    st.caption(
        "All processing is local. No data leaves this machine. "
        "Readiness analysis only - not a certified CMMC assessment."
    )

# ---------------- Main workflow ----------------
st.title("NIST SP 800-171 Compliance Readiness Pipeline")
st.markdown(
    "Upload a system configuration export (`config.json`). The pipeline "
    "sanitizes credentials, maps settings to NIST SP 800-171 Rev 2 controls via "
    "local vector similarity, and drafts an executive summary with local Llama 3."
)

uploaded = st.file_uploader("Upload config.json", type=["json"])
if uploaded is not None:
    Path("config.json").write_bytes(uploaded.getvalue())
    st.success("config.json staged for processing.")

col1, col2, col3 = st.columns(3)

with col1:
    if st.button("Step 1: Sanitize", use_container_width=True,
                 disabled=not Path("config.json").exists()):
        try:
            stats = sanitize()
            st.success(f"Redacted {stats['redactions']} sensitive values.")
        except Exception as exc:
            st.error(str(exc))

with col2:
    if st.button("Step 2: Evaluate Compliance", use_container_width=True,
                 disabled=not Path("cleaned_config.json").exists()):
        with st.spinner("Embedding statements and querying control space..."):
            try:
                evaluate()
                st.success("Evaluation complete.")
            except Exception as exc:
                st.error(str(exc))

with col3:
    if st.button("Step 3: Generate Executive Summary", use_container_width=True,
                 disabled=not Path(RESULTS_PATH).exists()):
        with st.spinner("Local Llama 3 drafting summary..."):
            try:
                generate_summary()
                st.success("Summary generated.")
            except Exception as exc:
                st.error(str(exc))

st.divider()

# ---------------- Results dashboard ----------------
if Path(RESULTS_PATH).exists():
    payload = json.loads(Path(RESULTS_PATH).read_text(encoding="utf-8"))
    summ = payload["summary"]

    m1, m2, m3, m4 = st.columns(4)
    m1.metric("Controls Evaluated", summ["total_controls"])
    m2.metric("Evidence Found", summ["evidence_found"])
    m3.metric("Partial Signal", summ["partial_signal"])
    m4.metric("Gaps", summ["gaps"])

    if Path(REPORT_PATH).exists():
        st.subheader("Executive Summary")
        st.info(Path(REPORT_PATH).read_text(encoding="utf-8"))

    st.subheader("Control-Level Detail")
    df = pd.DataFrame(payload["results"])
    df["status"] = df["status"].map(lambda s: f"{STATUS_COLORS[s]} {s}")
    families = ["All"] + sorted(df["family"].unique().tolist())
    pick = st.selectbox("Filter by control family", families)
    if pick != "All":
        df = df[df["family"] == pick]
    st.dataframe(
        df[["control_id", "family", "requirement", "status", "similarity", "evidence"]],
        use_container_width=True,
        hide_index=True,
    )

    st.download_button(
        "Download full results (JSON)",
        data=json.dumps(payload, indent=2),
        file_name="compliance_results.json",
        mime="application/json",
    )
else:
    st.info("Run the pipeline steps above to populate the dashboard.")
'@
Write-Utf8NoBom "app.py" $app

# ------------------------------------------------------------
# README.md
# ------------------------------------------------------------
Write-Host "== Writing README.md ==" -ForegroundColor Cyan
$readme = @'
# Siloed Orchestration: Private Compliance Intelligence Pipeline

A production-grade architectural blueprint for **fully local, zero-egress AI
automation** in regulated environments. This repository implements a NIST SP
800-171 Rev 2 readiness gap-analysis pipeline (full 110-requirement corpus,
the current CMMC Level 2 assessment baseline) as a reference pattern for
private corporate automation and multi-agent systems: deterministic
sanitization at the perimeter, embedding-based knowledge retrieval, and
constrained local LLM artifact generation - with no external API dependency
at any layer.

> **Scope note:** This tool performs readiness gap analysis. It is not a
> substitute for a CMMC C3PAO assessment or an official SPRS self-assessment.
> CMMC currently assesses against NIST SP 800-171 Revision 2 per DoD class
> deviation; Rev 3 is not yet authorized for CMMC or SPRS scoring.

## Architecture

```
config.json --> sanitize.py --> cleaned_config.json
                                       |
                     Ollama (nomic-embed-text, localhost:11434)
                                       |
                    evaluate_compliance.py <--> ChromaDB (compliance_db/)
                                       |
                        data/compliance_results.json
                                       |
                     generate_report.py --> Llama 3 (local)
                                       |
                            app.py (Streamlit UI)
```

Every arrow is a local file handoff or a localhost socket. The trust boundary
is the machine itself.

## Quick Start

1. Install [Ollama](https://ollama.com), then:
   ```
   ollama pull nomic-embed-text
   ollama pull llama3
   ```
2. Create environment and install dependencies:
   ```
   python -m venv .venv
   .venv\Scripts\activate
   pip install -r requirements.txt
   ```
3. Launch:
   ```
   streamlit run app.py
   ```
4. In the sidebar, click **Initialize / Rebuild Control Database** (one-time,
   roughly 2-3 minutes for all 110 controls). Upload
   `samples/sample_config.json` (or a real export) and run the three pipeline
   steps.

## Multi-Agent Design

| Agent | Module | Mechanism | LLM? |
|---|---|---|---|
| Sanitizer | `sanitize.py` | Two-pass regex redaction (key-based + value-based) | No |
| Mapping Specialist | `evaluate_compliance.py` | Cosine similarity vs. control vector space | Embeddings only |
| Artifact Generator | `generate_report.py` | Constrained 3-sentence generation from structured stats | Llama 3, local |

Only structured, sanitized statistics ever reach the generative model.

Note on interpretation: procedural requirements (visitor escort, media
marking, personnel screening) will typically report as gaps against a pure
configuration export. That is correct behavior - the tool shows what
configuration evidence cannot prove, which is exactly what feeds a POA&M.

## Hybrid Web Deployment (Presentation / Inference Split)

The Streamlit layer is the only component eligible for web exposure. The
inference and vector layers must remain on the private host. Recommended
pattern:

**Option A - Cloudflare Tunnel (recommended).** Run Streamlit locally, then
publish it through an authenticated, encrypted outbound-only tunnel:

1. Install `cloudflared` on the local host and authenticate:
   `cloudflared tunnel login`
2. Create and route the tunnel:
   ```
   cloudflared tunnel create compliance-portal
   cloudflared tunnel route dns compliance-portal portal.yourdomain.com
   ```
3. Config (`~/.cloudflared/config.yml`):
   ```yaml
   tunnel: compliance-portal
   credentials-file: /path/to/<tunnel-id>.json
   ingress:
     - hostname: portal.yourdomain.com
       service: http://localhost:8501
     - service: http_status:404
   ```
4. Enforce authentication with **Cloudflare Access**: create an Access
   application for `portal.yourdomain.com` with an email/IdP allow-list, so
   every request is identity-checked *before* it reaches the tunnel.
5. Run: `cloudflared tunnel run compliance-portal`

No inbound firewall ports are opened; the tunnel is outbound-initiated and
TLS-encrypted end to end. Ollama and ChromaDB stay bound to localhost and are
never exposed.

**Option B - SSH reverse tunnel to a public VPS/host.** If you control a
public Linux server: `ssh -N -R 8501:localhost:8501 user@public-host`, then
reverse-proxy `public-host:8501` behind nginx with HTTPS (Let's Encrypt) and
HTTP basic auth or OAuth2-proxy. Same principle: only the presentation port
transits; inference stays home.

**Shared-hosting note (e.g., HostGator):** shared cPanel hosting cannot run
persistent Python processes like Streamlit. Use the public site purely as the
**marketing/landing layer** (static PHP/HTML) that links to the
Cloudflare-Access-protected portal URL. Presentation on the web, computation
in the silo.

## Privacy Boundaries

`.gitignore` blacklists `compliance_db/`, `config.json`,
`cleaned_config.json`, all `data/` artifacts, and environment files. Client-
derived material can never enter source control.

## Extending

- The control corpus lives in `controls_data.py` (all 110 Rev 2 requirements
  with structural asserts). Swap or extend it and rebuild the database.
- Swap `llama3` for any Ollama-served model via `GEN_MODEL`.
- Point the same pattern at other frameworks (CIS, HIPAA Security Rule, ISO
  27001) by replacing the control corpus.
'@
Write-Utf8NoBom "README.md" $readme

# ------------------------------------------------------------
# requirements.txt
# ------------------------------------------------------------
Write-Host "== Writing requirements.txt ==" -ForegroundColor Cyan
$reqs = @'
streamlit>=1.35
chromadb>=0.5
requests>=2.31
pandas>=2.0
'@
Write-Utf8NoBom "requirements.txt" $reqs

# ------------------------------------------------------------
# samples/sample_config.json
# ------------------------------------------------------------
Write-Host "== Writing samples/sample_config.json ==" -ForegroundColor Cyan
$sample = @'
{
  "organization": "Sample Defense Subcontractor LLC",
  "identity": {
    "mfa_enforced": true,
    "mfa_scope": "all privileged accounts and remote network access",
    "password_policy": "14 character minimum with complexity rules enforced",
    "password_storage": "passwords stored as salted bcrypt hashes",
    "admin_api_key": "AKIAIOSFODNN7EXAMPLE"
  },
  "access_control": {
    "least_privilege_model": "role-based access with quarterly entitlement reviews",
    "session_lock_minutes": 15,
    "remote_access": "VPN with monitored and logged sessions"
  },
  "logging": {
    "siem": "centralized audit log retention for 12 months",
    "user_attribution": "unique user IDs required, shared accounts disabled"
  },
  "network": {
    "dmz": "public web servers logically separated in DMZ subnet",
    "encryption_in_transit": "TLS 1.2+ enforced for all CUI transmission",
    "encryption_at_rest": "BitLocker full disk encryption on all endpoints",
    "db_connection": "postgres://svc_account:SuperSecret99@db.internal:5432/app"
  },
  "vulnerability_management": {
    "scanning": "authenticated Nessus scans weekly",
    "patching_sla": "critical vulnerabilities remediated within 14 days"
  },
  "incident_response": {
    "plan": "documented IR plan with containment and recovery phases",
    "reporting": "incidents reported to designated officials within 72 hours"
  }
}
'@
Write-Utf8NoBom "samples/sample_config.json" $sample

# ------------------------------------------------------------
# .gitignore
# ------------------------------------------------------------
Write-Host "== Writing .gitignore ==" -ForegroundColor Cyan
$gitignore = @'
# ---- Data privacy boundary: client-derived artifacts NEVER enter git ----
compliance_db/
config.json
cleaned_config.json
data/
!samples/sample_config.json

# ---- Environment & secrets ----
.env
.env.*
*.pem
*.key
.streamlit/secrets.toml

# ---- Python ----
.venv/
venv/
__pycache__/
*.py[cod]
*.egg-info/
.pytest_cache/

# ---- OS / editor ----
.DS_Store
Thumbs.db
.vscode/
.idea/
'@
Write-Utf8NoBom ".gitignore" $gitignore

# ------------------------------------------------------------
# Initial commit and next-step instructions
# ------------------------------------------------------------
Write-Host "== Creating initial commit ==" -ForegroundColor Cyan
git add .
git commit -m "Initial commit: Siloed Orchestration NIST 800-171 Rev 2 readiness pipeline (110 controls)" | Out-Null

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Green
Write-Host " Workspace deployed successfully." -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS" -ForegroundColor Yellow
Write-Host "1. Create the Python environment:"
Write-Host "     python -m venv .venv"
Write-Host "     .venv\Scripts\activate"
Write-Host "     pip install -r requirements.txt"
Write-Host ""
Write-Host "2. Ensure Ollama models are present:"
Write-Host "     ollama pull nomic-embed-text"
Write-Host "     ollama pull llama3"
Write-Host ""
Write-Host "3. Launch the dashboard:"
Write-Host "     streamlit run app.py"
Write-Host ""
Write-Host "4. Link to GitHub (create the empty repo on GitHub first):"
Write-Host "     git remote add origin https://github.com/<your-account>/<repo-name>.git"
Write-Host "     git push -u origin main"
Write-Host "==============================================================="