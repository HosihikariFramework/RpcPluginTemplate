#!/usr/bin/env python3
"""Send one hello to an RPC binding and check the response.

Usage: handshake.py <expected-name> <command> [args...]
The caller runs this from the plugin package directory and creates ./data first.
"""

import json
import subprocess
import sys

expected = sys.argv[1]
command = sys.argv[2:]

process = subprocess.Popen(
    command,
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True,
    encoding="utf-8",
)
request = {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "hosihikari/hello",
    "params": {
        "name": expected,
        "dataDirectory": "./data",
        "packageDirectory": ".",
        "config": {"greeting": "hello from CI"},
    },
}

assert process.stdin is not None
process.stdin.write(json.dumps(request) + "\n")
process.stdin.flush()

assert process.stdout is not None
while True:
    line = process.stdout.readline()
    if not line:
        stderr = process.stderr.read() if process.stderr is not None else ""
        raise SystemExit(f"no response; stderr:\n{stderr}")
    message = json.loads(line)
    if message.get("id") == 1:
        response = message
        break

if "error" in response:
    raise SystemExit(f"binding error: {response['error']}")
if response.get("result", {}).get("name") != expected:
    raise SystemExit(f"unexpected response: {response}")

process.stdin.close()
process.wait(timeout=10)
stderr = process.stderr.read() if process.stderr is not None else ""
if process.returncode != 0:
    raise SystemExit(f"binding exited with {process.returncode}; stderr:\n{stderr}")
