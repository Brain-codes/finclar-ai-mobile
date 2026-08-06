#!/usr/bin/env python3
"""Push docs/FLOWS.md into the shared Google Doc.

Converts the markdown to HTML and uploads it as the Doc's body via the Drive
API. Drive converts the HTML back into native Docs content, so headings, tables,
bold and lists survive — and the document keeps its ID, URL and comments.
"""

import io
import os
import sys
from datetime import datetime, timezone

import markdown
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.http import MediaIoBaseUpload

SCOPES = ["https://www.googleapis.com/auth/drive"]
SOURCE = "docs/FLOWS.md"

CSS = """
body { font-family: Arial, sans-serif; font-size: 11pt; line-height: 1.5; }
h1 { font-size: 22pt; } h2 { font-size: 16pt; } h3 { font-size: 13pt; }
table { border-collapse: collapse; }
th, td { border: 1px solid #cccccc; padding: 6px 10px; text-align: left; }
th { background: #f2f2f2; }
code { font-family: 'Courier New', monospace; background: #f5f5f5; }
"""


def main() -> int:
    doc_id = os.environ.get("GOOGLE_DOC_ID")
    creds_json = os.environ.get("GOOGLE_SERVICE_ACCOUNT_JSON")

    if not doc_id:
        print("GOOGLE_DOC_ID is not set", file=sys.stderr)
        return 1
    if not creds_json:
        print("GOOGLE_SERVICE_ACCOUNT_JSON is not set", file=sys.stderr)
        return 1
    if not os.path.exists(SOURCE):
        print(f"{SOURCE} not found", file=sys.stderr)
        return 1

    with open(SOURCE, encoding="utf-8") as f:
        body = f.read()

    stamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    sha = os.environ.get("GITHUB_SHA", "local")[:7]
    footer = (
        f"\n\n---\n\n*Auto-generated from `docs/FLOWS.md` — "
        f"last synced {stamp} (commit `{sha}`). "
        f"Edits made directly in this document will be overwritten.*\n"
    )

    html = markdown.markdown(
        body + footer,
        extensions=["tables", "fenced_code", "sane_lists", "attr_list"],
    )
    page = f"<html><head><meta charset='utf-8'><style>{CSS}</style></head><body>{html}</body></html>"

    import json

    creds = service_account.Credentials.from_service_account_info(
        json.loads(creds_json), scopes=SCOPES
    )
    drive = build("drive", "v3", credentials=creds)

    media = MediaIoBaseUpload(
        io.BytesIO(page.encode("utf-8")), mimetype="text/html", resumable=False
    )
    drive.files().update(
        fileId=doc_id, media_body=media, supportsAllDrives=True
    ).execute()

    print(f"Synced {SOURCE} → https://docs.google.com/document/d/{doc_id}/edit")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
