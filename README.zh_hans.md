# RpcPluginTemplate

星光框架的最小进程外 Node 插件模板。RpcProvider 启动清单里的命令，通过行分隔 JSON-RPC 2.0 over stdio
通信；卸载就是让子进程退出。

## 使用

1. 把本仓复制到服务端，目录名用 `plugins/MyRpcPlugin/`。
2. 改名：改 `manifest.json` 的 `name`，重命名 `MyRpcPlugin.conf`，入口文件或命令也可以按需改。
   包目录名必须与清单里的 `name` 一致。
3. 按服务端安装 Shim 变体与 RPC Provider；Node.js 20+ 必须在 `PATH` 上：

   ```powershell
   lip install github.com/HosihikariFramework/Shim#levilamina   # 或 #endstone / #endstone_linux
   lip install github.com/HosihikariFramework/RpcProvider
   ```

4. 重启服务端。Provider 会在包目录里启动 `node ./hosihikari.mjs ./main.mjs`。

自持态 Linux 用无后缀 Shim 包，并通过 `hosihikari-server` 启动；Provider 与插件仍然放在 `plugins/` 下。

## 文件

- `manifest.json` —— `provider: rpc`；`command` 是编码成字符串的 JSON 数组。
- `main.mjs` —— 默认导出的插件对象。
- `hosihikari.mjs` —— 从 RpcProvider 的 `bindings/node/` 拷来的 Node 绑定；升级 Provider 时同步更新。
- `MyRpcPlugin.conf` —— 包内默认配置。

## 协议

`hosihikari.mjs` 独占 stdout，只走 JSON-RPC 帧。`console.log` 已被改道 stderr；插件日志请用
`ctx.logInfo` / `ctx.logWarn` / `ctx.logError`。

上下文提供数据目录、包目录、配置读取、数据写入、事件发布/订阅与定时器。见[进程外文档](https://hosihikariframework.github.io/zh/authoring-rpc/)。
