# RpcPluginTemplate — RPC plugin templates

Out-of-process plugin templates for the Hosihikari framework. RpcLoader starts `pack.command` from
`hosihikari.json` and speaks line-delimited JSON-RPC 2.0 over stdio; unloading means the child process
exits. Each directory is a complete plugin package with its own manifest, protocol definition,
configuration, and README.

## Templates

- [`node-typescript/`](node-typescript/) — **RPC plugin template — Node.js/TypeScript runtime**
- [`python/`](python/) — **RPC plugin template — Python runtime**
- [`kotlin/`](kotlin/) — **RPC plugin template — Kotlin/JVM runtime**

## Using a template

1. Copy the runtime directory into your server as `plugins/<PluginName>/`; the directory name must
   match `name` in `hosihikari.json`.
2. Rename the plugin in `hosihikari.json`, rename the `.conf` file to match, and adjust the entry or
   `pack.command` when you change the layout.
3. Build the plugin where the runtime requires it, pack it (`pwsh ./pack.ps1` or `bash ./pack.sh` in
   the runtime directory), then install the carrier bundle and the RPC loader with Seiko:

   ```powershell
   sk init                                  # once per server root
   sk add hosihikari-hosting-levilamina     # LeviLamina
   # or: sk add hosihikari-hosting-endstone
   # or: sk add hosihikari-hosting-selfhosted
   sk add hosihikari-rpc
   ```

4. Restart the server. The loader starts the command from the package directory.

For the self-hosted carriers, `sk add hosihikari-hosting-selfhosted` selects Windows or Linux; start the server through `hosihikari-server` (`hosihikari-server.exe` on Windows). Loaders and plugins still live under `plugins/`.

The protocol definitions under `node-typescript/hosihikari.mjs`, `python/hosihikari.py`, and `kotlin/hosihikari/`
are copied from RpcLoader. Refresh them when the loader is upgraded; they must match
`protocol/` in the loader repository byte for byte.

`hosihikari.json` is the only manifest in the source tree. The packer generates the LeviLamina
`manifest.json` envelope from it, so a generated copy left in the package directory is an output.
A package still on the 1.x `manifest.json` migrates in the same `pack` command; `pack.ps1 -MigrateOnly`
(`pack.sh --migrate-only`) rewrites just the metadata.

Hooks may be async. `undefined` / `true` allow; `false` or `{ allowed: false, diagnostic: { code, severity, message } }`
refuse; a thrown exception is a fault.

## Protocol

The protocol definition owns stdout: it carries only JSON-RPC frames, while stderr is text logging. Plugins use
the context logging methods. The context exposes the data directory, package directory,
configuration lookup, data writes, event publishing/subscribing, and timers. See the
[out-of-process guide](https://hoshi.srcz.one/framework/develop/authoring-rpc/).

## Licence

MIT-0, see [LICENSE.md](LICENSE.md).
