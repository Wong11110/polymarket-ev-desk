from __future__ import annotations

import argparse
import json
import mimetypes
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode, urlparse
from urllib.request import Request, urlopen


GAMMA_EVENTS_URL = "https://gamma-api.polymarket.com/events"
CLOB_PRICE_HISTORY_URL = "https://clob.polymarket.com/prices-history"


class AppHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, directory: str | None = None, **kwargs):
        self.web_root = Path(directory or ".").resolve()
        super().__init__(*args, directory=str(self.web_root), **kwargs)

    def end_headers(self) -> None:
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Referrer-Policy", "strict-origin-when-cross-origin")
        if self.path.startswith("/assets/") or self.path.startswith("/icons/"):
            self.send_header("Cache-Control", "public, max-age=31536000, immutable")
        else:
            self.send_header("Cache-Control", "no-cache")
        super().end_headers()

    def do_GET(self) -> None:
        if self.path.startswith("/api/polymarket/events"):
            self._proxy_json(GAMMA_EVENTS_URL)
            return
        if self.path.startswith("/api/polymarket/prices-history"):
            self._proxy_json(CLOB_PRICE_HISTORY_URL)
            return
        super().do_GET()

    def translate_path(self, path: str) -> str:
        parsed_path = urlparse(path).path
        candidate = Path(super().translate_path(parsed_path))
        if candidate.exists() and candidate.is_file():
            return str(candidate)
        return str(self.web_root / "index.html")

    def _proxy_json(self, base_url: str) -> None:
        query = urlparse(self.path).query
        upstream = f"{base_url}?{query}" if query else base_url
        request = Request(
            upstream,
            headers={
                "Accept": "application/json",
                "User-Agent": "polymarket-ev-desk/0.1",
            },
        )
        try:
            with urlopen(request, timeout=12) as response:
                body = response.read()
                status = response.status
        except HTTPError as exc:
            body = exc.read() or json.dumps({"error": str(exc)}).encode()
            status = exc.code
        except URLError as exc:
            body = json.dumps({"error": str(exc)}).encode()
            status = 502

        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Cache-Control", "no-cache")
        self.end_headers()
        self.wfile.write(body)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", default=8601, type=int)
    parser.add_argument("--directory", default="web")
    args = parser.parse_args()

    mimetypes.add_type("application/wasm", ".wasm")
    server = ThreadingHTTPServer((args.host, args.port), lambda *handler_args, **handler_kwargs: AppHandler(
        *handler_args,
        directory=args.directory,
        **handler_kwargs,
    ))
    print(f"Serving {Path(args.directory).resolve()} on http://{args.host}:{args.port}")
    server.serve_forever()


if __name__ == "__main__":
    main()
