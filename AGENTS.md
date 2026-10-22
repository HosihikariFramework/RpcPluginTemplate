# AGENTS.md

Out-of-process plugin templates for the Hosihikari Framework: Node.js/TypeScript, Python, and
Kotlin/JVM packages that speak line-delimited JSON-RPC 2.0 over stdio.

## Repository map

- `node-typescript/` — Node.js package, binding copy, build output.
- `python/` — Python package and binding copy.
- `kotlin/` — Kotlin/JVM package, binding copy, and build script.
- `.github/handshake.py` — loads each package through RpcLoader and checks the hello handshake.
- `.github/workflows/verify.yml` — manifest, binding-drift, build, and handshake checks.

## Build and verify

```bash
(cd node-typescript && npm ci && npm run build)
python3 -m py_compile python/main.py python/hosihikari.py
(cd kotlin && ./build.sh)
```

Each directory is a complete plugin package. Copy it to `plugins/<PluginName>/`, keep the directory
name equal to the manifest `name`, and install `RpcLoader`.

## Invariants

- Binding copies must match `RpcLoader/bindings/` byte for byte; the verify workflow diffs them.
- Manifest `extraInfo.command` is an argument list, never a shell string.
- Under Endstone, use an absolute runtime path; the CLI replaces the child `PATH`.
- Keep the three runtime directories behaviorally equivalent.
- Public default branches are protected. Work on a branch, open a pull request, and squash merge.

## Context

- [Out-of-process guide](https://hf.srcz.one/authoring-rpc/).
- [RpcLoader](https://github.com/HosihikariFramework/RpcLoader).
