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