#!/usr/bin/env python3

from __future__ import annotations

import shutil
import subprocess
import sys


DEFAULT_TYPES = ["A", "AAAA", "MX", "NS", "CNAME"]
ALLOWED_TYPES = set(DEFAULT_TYPES) | {"SOA"}
DEFAULT_SERVER = None


def _run(cmd: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, text=True, capture_output=True)


def _dig_section(name: str, rtype: str, section: str, server: str | None) -> str:
    cmd = ["dig"]
    if server:
        cmd.append(f"@{server}")

    cmd += ["+noall", section, name, rtype]  # section: +answer or +authority
    p = _run(cmd)
    if p.returncode != 0:
        err = (p.stderr or "").strip()
        raise RuntimeError(err or f"dig failed: {' '.join(cmd)}")

    return (p.stdout or "").strip()


def _parse_zone_lines(text: str) -> list[dict]:
    rows: list[dict] = []
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith(";"):
            continue

        # split into at most 5 pieces so "value" can contain spaces (SOA)
        parts = line.split(None, 4)
        if len(parts) < 5:
            continue

        name, ttl, cls, rtype, value = parts
        row = {"name": name, "ttl": ttl, "cls": cls, "rtype": rtype}

        if rtype == "SOA":
            soa_parts = value.split()
            if len(soa_parts) == 7:
                row["mname"] = soa_parts[0]
                row["rname"] = soa_parts[1]
                row["serial"] = soa_parts[2]
                row["refresh"] = soa_parts[3]
                row["retry"] = soa_parts[4]
                row["expire"] = soa_parts[5]
                row["minimum"] = soa_parts[6]
            else:
                row["value"] = value  # fallback
        elif rtype == "MX":
            mx_parts = value.split(None, 1)
            if len(mx_parts) == 2:
                row["priority"] = mx_parts[0]
                row["value"] = mx_parts[1]
            else:
                row["priority"] = ""
                row["value"] = value
        else:
            row["value"] = value

        rows.append(row)

    return rows


def _query_rows(domain: str, rtype: str, server: str | None) -> list[dict]:
    ans = _dig_section(domain, rtype, "+answer", server)
    rows = _parse_zone_lines(ans)
    if rows:
        return rows

    auth = _dig_section(domain, rtype, "+authority", server)
    return _parse_zone_lines(auth)


def _format_table_generic(rows: list[list[str]], headers: list[str]) -> str:
    all_rows = [headers, *rows]
    widths = [max(len(str(r[i])) for r in all_rows) for i in range(len(headers))]

    lines = []
    for r in all_rows:
        parts = []
        for i, val in enumerate(r):
            if headers[i] in ("TTL", "PRIORITY"):
                parts.append(f"{val:>{widths[i]}}")
            else:
                parts.append(f"{val:<{widths[i]}}")
        lines.append("  ".join(parts))

    return "\n".join(lines)


def _format_mx_table(rows: list[dict]) -> str:
    headers = ["NAME", "TTL", "CLASS", "TYPE", "PRIORITY", "VALUE"]
    data = [[r["name"], r["ttl"], r["cls"], r["rtype"], r.get("priority", ""), r.get("value", "")] for r in rows]
    return _format_table_generic(data, headers)


def _format_soa_table(rows: list[dict]) -> str:
    headers = ["NAME", "TTL", "CLASS", "TYPE", "MNAME", "RNAME", "SERIAL", "REFRESH", "RETRY", "EXPIRE", "MINIMUM"]
    data = []

    for r in rows:
        if "mname" in r:
            data.append([r["name"], r["ttl"], r["cls"], r["rtype"], r["mname"], r["rname"], r["serial"], r["refresh"], r["retry"], r["expire"], r["minimum"]])
        else:
            data.append([r["name"], r["ttl"], r["cls"], r["rtype"], r.get("value", ""), "", "", "", "", "", ""])

    return _format_table_generic(data, headers)


def _format_standard_table(rows: list[dict]) -> str:
    headers = ["NAME", "TTL", "CLASS", "TYPE", "VALUE"]
    data = [[r["name"], r["ttl"], r["cls"], r["rtype"], r.get("value", "")] for r in rows]
    return _format_table_generic(data, headers)


def _format_all_tables(all_rows: list[dict]) -> str:
    mx_rows = [r for r in all_rows if r["rtype"] == "MX"]
    soa_rows = [r for r in all_rows if r["rtype"] == "SOA"]
    standard_rows = [r for r in all_rows if r["rtype"] not in ("MX", "SOA")]

    tables = []
    if standard_rows:
        tables.append(_format_standard_table(standard_rows))
    if mx_rows:
        tables.append(_format_mx_table(mx_rows))
    if soa_rows:
        tables.append(_format_soa_table(soa_rows))

    return "\n\n".join(tables)


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("usage: dns_table.py <domain> [@server] [A AAAA MX NS CNAME ...]", file=sys.stderr)
        return 2

    domain = argv[1]
    server: str | None = DEFAULT_SERVER
    types: list[str] = []

    for arg in argv[2:]:
        if arg.startswith("@"):
            server = arg[1:]
        else:
            types.append(arg.upper())

    if not types:
        types = DEFAULT_TYPES

    bad = [t for t in types if t not in ALLOWED_TYPES]
    if bad:
        print(f"unsupported types: {', '.join(bad)} (allowed: {', '.join(DEFAULT_TYPES)})", file=sys.stderr)
        return 2

    if shutil.which("dig") is None:
        print("error: `dig` not found in PATH (install dnsutils/bind-tools)", file=sys.stderr)
        return 127

    all_rows: list[dict] = []
    for t in types:
        all_rows.extend(_query_rows(domain, t, server))

    print(_format_all_tables(all_rows))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
