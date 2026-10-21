# RPC 插件模板 —— Python 运行时

星光框架的最小进程外 Python 插件。RpcLoader 启动清单里的命令，通过行分隔 JSON-RPC 2.0 over
stdio 通信；卸载就是让子进程退出。

## 要求

`PATH` 上要有 Python 3.8 或更新版本。清单命令使用 `python3`；Windows 上请在
`extraInfo.command` 里改成 `python`（或 `py -3`）。

## 部署

1. 把本目录复制到服务端，改名为 `plugins/MyPythonPlugin/`。目录名必须与 `manifest.json` 的
   `name` 一致。
2. 改 `manifest.json` 的 `name`，把 `MyPythonPlugin.conf` 改成同名；调整布局时同步修改入口或
   `extraInfo.command`。
3. 按服务端安装 Shim 变体与 RPC Loader，再重启：

   ```powershell
   lip install github.com/HosihikariFramework/HostingShim#levilamina   # 或 #endstone
   lip install github.com/HosihikariFramework/RpcLoader
   ```

自持态 Linux 用无后缀 Shim 包，并通过 `hosihikari-server` 启动；加载器与插件仍然放在
`plugins/` 下。

## 文件

- `manifest.json` —— `loader: rpc`；`command` 是编码成字符串的 JSON 数组
  （`python3 ./hosihikari.py ./main.py`）。
- `main.py` —— 插件本体；模块级的 `on_load(ctx)`、`on_enable(ctx)`、`on_disable(ctx)` 与
  `on_unload(ctx)` 就是钩子。
- `hosihikari.py` —— 从 RpcLoader 的 `bindings/python/` 拷来的 Python 绑定；升级 Loader 时
  同步更新。
- `hosihikari.pyi` —— 绑定的类型存根，与 `hosihikari.py` 放在一起。
- `MyPythonPlugin.conf` —— 包内默认配置。

## 协议

`hosihikari.py` 独占 stdout，只走 JSON-RPC 帧。`print` 走 stderr；插件日志请用 `ctx.log_info` /
`ctx.log_warn` / `ctx.log_error`。

上下文提供 `name`、`data_directory`、`package_directory`、`config(key)`、`config_object`、
`log_info` / `log_warn` / `log_error`、`write_data(file, text)`、`publish(topic, json)`、
`subscribe(topic, fn, sync=False)`、`schedule_once(seconds, fn)` 与 `schedule_periodic(seconds, fn)`。见
[进程外文档](https://hosihikariframework.github.io/zh/authoring-rpc/)。

## 许可

MIT-0，见 [LICENSE.md](LICENSE.md)。
