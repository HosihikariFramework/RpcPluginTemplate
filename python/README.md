# RPC plugin template — Python runtime

A minimal out-of-process Python plugin. RpcProvider starts the command from `manifest.json` and
speaks line-delimited JSON-RPC 2.0 over stdio; unloading means the child process exits.

## Requirements

Python 3.8 or newer on `PATH`. The manifest command uses `python3`; on Windows change it to
`python` (or `py -3`) in `extraInfo.command`.

## Deploy

1. Copy this directory into your server as `plugins/MyPythonPlugin/`. The directory name must equal
   `manifest.json` `name`.
2. Change `manifest.json` `name`, rename `MyPythonPlugin.conf` to match, and update the entry or
   `extraInfo.command` if the layout changes.
3. Install the shim variant for the server and the RPC provider, then restart:

   ```powershell
   lip install github.com/HosihikariFramework/Shim#levilamina   # or #endstone
   lip install github.com/HosihikariFramework/RpcProvider
   ```

For the self-hosted Linux carrier, install the suffix-less shim package and start the server through
`hosihikari-server`; providers and plugins still live under `plugins/`.

## Files

- `manifest.json` — `provider: rpc`; `command` is a JSON array encoded as a string
  (`python3 ./hosihikari.py ./main.py`).
- `main.py` — the plugin; module-level `on_load(ctx)`, `on_enable(ctx)`, `on_disable(ctx)` and
  `on_unload(ctx)` are the hooks.
- `hosihikari.py` — the Python binding copied from RpcProvider's `bindings/python/`. Refresh it when
  the provider is upgraded.
- `MyPythonPlugin.conf` — package defaults.

## Protocol

`hosihikari.py` owns stdout: it carries only JSON-RPC frames. `print` goes to stderr, and plugins
should use `ctx.log_info` / `ctx.log_warn` / `ctx.log_error` for logging.

The context exposes `name`, `data_directory`, `package_directory`, `config(key)`, `config_object`,
`log_info` / `log_warn` / `log_error`, `write_data(file, text)`, `publish(topic, json)`,
`subscribe(topic, fn, sync=False)`, `run_later(seconds, fn)` and `run_every(seconds, fn)`. See the
[out-of-process guide](https://hosihikariframework.github.io/authoring-rpc/).

## Licence

MIT-0, see [LICENSE.md](LICENSE.md).
