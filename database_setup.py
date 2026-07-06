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