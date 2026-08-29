# Siloed Orchestration: Private Compliance Intelligence Pipeline

A reference implementation and architectural blueprint for **fully local, zero-egress AI automation** in regulated environments. This repository demonstrates a NIST SP 800-171 Revision 2 readiness gap-analysis pipeline using the complete 110-requirement corpus currently incorporated into the CMMC Level 2 assessment model.

The design combines deterministic sanitization, embedding-based knowledge retrieval, constrained local language-model generation, and auditable file handoffs without requiring an external AI API.


> > **Scope and standards note:** This repository provides an educational readiness-analysis reference implementation. It does not perform an official CMMC assessment, create a CMMC certification, calculate an authoritative SPRS score, or replace legal, contractual, compliance, or C3PAO guidance.
>
> As of August 2026, the CMMC Level 2 model incorporates the 110 requirements from NIST SP 800-171 Revision 2. NIST has published Revision 3, but users must verify the requirements stated in their applicable solicitation, contract, regulation, and current Department of Defense guidance before relying on any assessment baseline.


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

##Privacy and Source-Control Boundaries

The `.gitignore` configuration excludes the local compliance database, configuration files, sanitized working files, generated data artifacts, environment files, and other designated runtime content from normal Git tracking.

A `.gitignore` file reduces the risk of accidental inclusion, but it is not a security control that guarantees sensitive material cannot enter source control. Users should also:

* Inspect staged files before every commit
* Use synthetic data for demonstrations and testing
* Scan commits for credentials, secrets, regulated data, and client identifiers
* Protect branches and require peer review where appropriate
* Store secrets in an approved secrets-management system
* Remove sensitive information before processing
* Maintain separate environments for public demonstrations and client work

No employer, client, student, patient, or production-derived information should be placed in this public repository.


## Extending

- The control corpus lives in `controls_data.py` (all 110 Rev 2 requirements
  with structural asserts). Swap or extend it and rebuild the database.
- Swap `llama3` for any Ollama-served model via `GEN_MODEL`.
- Point the same pattern at other frameworks (CIS, HIPAA Security Rule, ISO
  27001) by replacing the control corpus.

  ## Privacy and Independence Statement

This is an independently developed educational and architectural project. It contains synthetic examples and generalized security patterns. It does not contain confidential employer information, proprietary client documentation, controlled unclassified information, or operational data from any organization.

The views and materials presented here are those of the author and do not represent any employer, client, educational institution, government agency, assessor, or certification body.

## Author

**James D. McClain, MBA**

Enterprise AI | Secure Infrastructure | Cybersecurity Governance | Zero Trust | Workforce Transformation

[View the complete GitHub portfolio](https://github.com/jdmc-services)
