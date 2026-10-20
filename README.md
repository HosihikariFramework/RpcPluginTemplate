# RpcPluginTemplate

A minimal out-of-process Node plugin for the Hosihikari framework. RpcProvider starts the command
from the manifest and speaks line-delimited JSON-RPC 2.0 over stdio; unloading means the child
process exits.

## Use it

1. Copy this repository into your server as `plugins/MyRpcPlugin/`.
2. Rename the plugin: change `manifest.json` `name`, rename `MyRpcPlugin.conf`, and rename the
   entry file or command if you like. The package directory name must equal the manifest `name`.
3. Install the shim variant for the server and the RPC provider; Node.js 20+ must be on `PATH`:

   ```powershell
   lip install github.com/HosihikariFramework/Shim#levilamina   # or #endstone / #endstone_linux
   lip install github.com/HosihikariFramework/RpcProvider
   ```

4. Restart the server. The provider starts `node ./hosihikari.mjs ./main.mjs` in the package
   directory.

For the self-hosted Linux carrier, install the suffix-less shim package and start the server through
`hosihikari-server`; providers and plugins still live under `plugins/`.

## Files

- `manifest.json` — `provider: rpc`; `command` is a JSON array encoded as a string.
- `main.mjs` — the default-exported plugin object.
- `hosihikari.mjs` — the Node binding copied from RpcProvider's `bindings/node/`. Refresh it when
  the provider is upgraded.
- `MyRpcPlugin.conf` — package defaults.

## Protocol

`hosihikari.mjs` owns stdout: it carries only JSON-RPC frames. `console.log` is redirected to
stderr, and plugins should use `ctx.logInfo` / `ctx.logWarn` / `ctx.logError` for logging.

The context exposes the data directory, package directory, configuration lookup, data writes,
event publishing/subscribing, and timers. See the
[out-of-process guide](https://hosihikariframework.github.io/authoring-rpc/).
