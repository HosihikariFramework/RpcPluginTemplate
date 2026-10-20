# RpcPluginTemplate — RPC plugin templates

Out-of-process plugin templates for the Hosihikari framework. RpcProvider starts the command from
`manifest.json` and speaks line-delimited JSON-RPC 2.0 over stdio; unloading means the child process
exits. Each directory is a complete plugin package with its own manifest, binding copy,
configuration, and README.

## Templates

- [`node-typescript/`](node-typescript/) — **RPC plugin template — Node.js/TypeScript runtime**
- [`python/`](python/) — **RPC plugin template — Python runtime**
- [`kotlin/`](kotlin/) — **RPC plugin template — Kotlin/JVM runtime**

## Using a template

1. Copy the runtime directory into your server as `plugins/<PluginName>/`; the directory name must
   match `name` in `manifest.json`.
2. Rename the plugin in `manifest.json`, rename the `.conf` file to match, and adjust the entry or
   `extraInfo.command` when you change the layout.
3. Build the plugin where the runtime requires it, then install the shim variant for the server and
   the RPC provider:

   ```powershell
   lip install github.com/HosihikariFramework/Shim#levilamina   # or #endstone / #endstone_linux
   lip install github.com/HosihikariFramework/RpcProvider
   ```

4. Restart the server. The provider starts the command from the package directory.

For the self-hosted Linux carrier, install the suffix-less shim package and start the server through
`hosihikari-server`; providers and plugins still live under `plugins/`.

The bindings under `node-typescript/hosihikari.mjs`, `python/hosihikari.py`, and `kotlin/hosihikari/`
are copied from RpcProvider. Refresh them when the provider is upgraded.

## Protocol

The binding owns stdout: it carries only JSON-RPC frames, while stderr is text logging. Plugins use
the context logging methods. The context exposes the data directory, package directory,
configuration lookup, data writes, event publishing/subscribing, and timers. See the
[out-of-process guide](https://hosihikariframework.github.io/authoring-rpc/).

## Licence

MIT-0, see [LICENSE.md](LICENSE.md).
