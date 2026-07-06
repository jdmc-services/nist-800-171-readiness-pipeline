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