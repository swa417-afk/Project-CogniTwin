"""Export OpenAPI schema to backend/openapi.json

Run from backend/ (after installing requirements):
  python export_openapi.py
"""

import json
from pathlib import Path

from app.main import app


def main() -> None:
    schema = app.openapi()
    out_path = Path(__file__).parent / "openapi.json"
    out_path.write_text(json.dumps(schema, indent=2), encoding="utf-8")
    print(f"Wrote {out_path}")


if __name__ == "__main__":
    main()
