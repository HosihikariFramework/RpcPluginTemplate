# RPC plugin template — Node.js/TypeScript runtime

A minimal out-of-process Node plugin written in TypeScript. RpcProvider starts the command from
`manifest.json` and speaks line-delimited JSON-RPC 2.0 over stdio; unloading means the child process
exits.

## Requirements

- Node.js 20 or newer at runtime.
- Node.js and npm at build time.

## Build

```sh
npm install
npm run build
```

The build writes `dist/main.js`, which is the entry the manifest command runs. `npm run check`
type-checks without emitting.

## Deploy

1. Copy this directory into your server as `plugins/MyNodePlugin/`. The directory name must equal
   `manifest.json` `name`.
2. Change `manifest.json` `name`, rename `MyNodePlugin.conf` to match, and update the entry or
   `extraInfo.command` if the layout changes.
3. Build, install the shim variant for the server and the RPC provider, and restart:

   ```powershell
   lip install github.com/HosihikariFramework/Shim#levilamina   # or #endstone / #endstone_linux
   lip install github.com/HosihikariFramework/RpcProvider
   ```

For the self-hosted Linux carrier, install the suffix-less shim package and start the server through
`hosihikari-server`; providers and plugins still live under `plugins/`.

## Files

- `manifest.json` — `provider: rpc`; `command` is a JSON array encoded as a string
  (`node ./hosihikari.mjs ./dist/main.js`).
- `src/main.ts` — the plugin; the default export implements the hooks.
- `hosihikari.d.ts` — context and hook types for the binding.
- `hosihikari.mjs` — the Node binding copied from RpcProvider's `bindings/node/`. Refresh it when
  the provider is upgraded.
- `tsconfig.json`, `package.json` — TypeScript build configuration.
- `MyNodePlugin.conf` — package defaults.

## Protocol

`hosihikari.mjs` owns stdout: it carries only JSON-RPC frames. `console.log` is redirected to
stderr, and plugins should use `ctx.logInfo` / `ctx.logWarn` / `ctx.logError` for logging.

The context exposes the data directory, package directory, configuration lookup, data writes,
event publishing/subscribing, and timers. See the
[out-of-process guide](https://hosihikariframework.github.io/authoring-rpc/).

## Licence

MIT-0, see [LICENSE.md](LICENSE.md).
