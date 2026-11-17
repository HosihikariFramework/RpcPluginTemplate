# RPC plugin template — Python runtime

A minimal out-of-process Python plugin. RpcLoader starts `pack.command` from `hosihikari.json` and
speaks line-delimited JSON-RPC 2.0 over stdio; unloading means the child process exits.

## Requirements

Python 3.8 or newer on `PATH`. `pack.command` uses `python3`; on Windows change it to
`python` (or `py -3`).

## Deploy

1. Keep this directory outside the server while you work on it. The package directory name
   must equal `hosihikari.json` `name`.
2. Change `hosihikari.json` `name`, rename `MyPythonPlugin.conf` to match, and update the entry or
   `pack.command` if the layout changes.
3. Pack (`pwsh ./pack.ps1` or `bash ./pack.sh`), copy `dist/MyPythonPlugin/` into the server as
   `plugins/MyPythonPlugin/`, install the carrier bundle and the RPC loader with Seiko, then
   restart:

   ```powershell
   sk init                                  # once per server root
   sk add hosihikari-hosting-levilamina     # LeviLamina
   # or: sk add hosihikari-hosting-endstone
   # or: sk add hosihikari-hosting-selfhosted
   sk add hosihikari-rpc
   ```

For the self-hosted carriers, `sk add hosihikari-hosting-selfhosted` selects Windows or Linux; start the server through `hosihikari-server` (`hosihikari-server.exe` on Windows). Loaders and plugins still live under `plugins/`.

## Files

- `hosihikari.json` — `loader: rpc`; `pack.command` is the argument vector
  (`python3 ./hosihikari.py ./main.py`). The packer writes the `manifest.json` envelope.
- `pack.ps1` / `pack.sh` — run the framework packer; `dist/MyPythonPlugin/` is the installable package.
- `main.py` — the plugin; module-level `on_load(ctx)`, `on_enable(ctx)`, `on_disable(ctx)` and
  `on_unload(ctx)` are the hooks.
- `hosihikari.py` — the Python protocol definition copied from RpcLoader's `protocol/python/`. Refresh it when
  the loader is upgraded.
- `hosihikari.pyi` — type stubs for the protocol definition; keep it beside `hosihikari.py`.
- `MyPythonPlugin.conf` — package defaults.

## Protocol

`hosihikari.py` owns stdout: it carries only JSON-RPC frames. `print` goes to stderr, and plugins
should use `ctx.log_info` / `ctx.log_warn` / `ctx.log_error` for logging.

A hook returns `None` / `True` to allow, `False` or
`{"allowed": False, "diagnostic": {"code", "severity", "message"}}` to refuse; a raised exception is
a fault.

The context exposes `name`, `data_directory`, `package_directory`, `config(key)`, `config_object`,
`log_info` / `log_warn` / `log_error`, `write_data(file, text)`, `publish(topic, json)`,
`subscribe(topic, fn, sync=False)`, `schedule_once(seconds, fn)` and `schedule_periodic(seconds, fn)`. See the
[out-of-process guide](https://hoshi.srcz.one/framework/develop/authoring-rpc/).

## Licence

MIT-0, see [LICENSE.md](LICENSE.md).
