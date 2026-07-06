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