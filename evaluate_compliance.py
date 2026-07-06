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