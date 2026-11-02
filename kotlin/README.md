# RPC plugin template — Kotlin/JVM runtime

A minimal out-of-process Kotlin plugin running on the JVM. RpcLoader starts the command from
`manifest.json` and speaks line-delimited JSON-RPC 2.0 over stdio; unloading means the child process
exits.

## Requirements

- JDK 21 or newer at runtime.
- JDK 21 or newer and `kotlinc` on `PATH` at build time.

## Build

```sh
./build.sh
```

On Windows:

```powershell
./build.ps1
```

The build compiles the Java binding, compiles the Kotlin plugin with the Kotlin runtime, and adds the
binding classes to `plugin.jar`. `plugin.jar` is the only artifact the server needs.

## Deploy

1. Copy this directory into your server as `plugins/MyKotlinPlugin/`. The directory name must equal
   `manifest.json` `name`.
2. Change `manifest.json` `name`, rename `MyKotlinPlugin.conf` to match, and update the entry or
   `extraInfo.command` if the layout changes, including the plugin class in the command.
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
  (`java -cp ./plugin.jar hosihikari.Binding myplugin.MyKotlinPlugin`).
- `src/MyKotlinPlugin.kt` — the plugin; it implements `hosihikari.Plugin`.
- `hosihikari/` — the Java binding copied from RpcLoader's `protocol/java/hosihikari/`. Refresh it
  when the loader is upgraded.
- `build.sh`, `build.ps1` — build scripts.
- `MyKotlinPlugin.conf` — package defaults.

## Protocol

The binding owns stdout: it carries only JSON-RPC frames. `System.out` is redirected to stderr, and
plugins should use `context.logInfo` / `context.logWarn` / `context.logError` for logging.

Hooks return `HookResult.allow()` or `HookResult.refuse(reason)`. `Context` provides `name()`,
`dataDirectory()`, `packageDirectory()`, `config(key)`, `configObject()`,
`logInfo` / `logWarn` / `logError`, `writeData(file, text)`, `publish(topic, json)`,
`subscribe(topic, handler[, sync])`, `scheduleOnce(millis, work)` and `schedulePeriodic(millis, work)`. See the
[out-of-process guide](https://hoshi.srcz.one/framework/develop/authoring-rpc/).

## Licence

MIT-0, see [LICENSE.md](LICENSE.md).
