# RPC plugin template — Node.js/TypeScript runtime

A minimal out-of-process Node plugin written in TypeScript. RpcLoader starts the command from
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
3. Build, install the carrier bundle and the RPC loader with Seiko, and restart:

   ```powershell
   sk init                                  # once per server root
   sk add hosihikari-hosting-levilamina     # LeviLamina
   # or: sk add hosihikari-hosting-endstone
   # or: sk add hosihikari-hosting-selfhosted
   sk add hosihikari-rpc
   ```

For the self-hosted carriers, `sk add hosihikari-hosting-selfhosted` selects Windows or Linux; start the server through `hosihikari-server` (`hosihikari-server.exe` on Windows). Loaders and plugins still live under `plugins/`.

## Files

- `manifest.json` — `loader: rpc`; `command` is a JSON array encoded as a string
  (`node ./hosihikari.mjs ./dist/main.js`).
- `src/main.ts` — the plugin; the default export implements the hooks.
- `hosihikari.d.ts` — context and hook types for the protocol definition.
- `hosihikari.mjs` — the Node protocol definition copied from RpcLoader's `protocol/node/`. Refresh it when
  the loader is upgraded.
- `tsconfig.json`, `package.json` — TypeScript build configuration.
- `MyNodePlugin.conf` — package defaults.

## Protocol

`hosihikari.mjs` owns stdout: it carries only JSON-RPC frames. `console.log` is redirected to
stderr, and plugins should use `ctx.logInfo` / `ctx.logWarn` / `ctx.logError` for logging.

The context exposes the data directory, package directory, configuration lookup, data writes,
event publishing/subscribing, and timers. See the
[out-of-process guide](https://hoshi.srcz.one/framework/develop/authoring-rpc/).

## Licence

MIT-0, see [LICENSE.md](LICENSE.md).
