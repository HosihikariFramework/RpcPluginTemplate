# RpcPluginTemplate —— RPC 插件模板

星光框架的进程外插件模板。RpcLoader 启动清单里的命令，通过行分隔 JSON-RPC 2.0 over stdio
通信；卸载就是让子进程退出。每个目录都是一个完整的插件包，自带清单、绑定副本、配置与说明。

## 模板

- [`node-typescript/`](node-typescript/) —— **RPC 插件模板 —— Node.js/TypeScript 运行时**
- [`python/`](python/) —— **RPC 插件模板 —— Python 运行时**
- [`kotlin/`](kotlin/) —— **RPC 插件模板 —— Kotlin/JVM 运行时**

## 使用

1. 把所选运行时目录复制到服务端，改名为 `plugins/<插件名>/`；目录名必须与 `manifest.json`
   里的 `name` 一致。
2. 改 `manifest.json` 的 `name`，把 `.conf` 文件改成同名；调整布局时同步修改入口或
   `extraInfo.command`。
3. 需要构建的运行时先构建，然后按服务端安装 Shim 变体与 RPC Loader：

   ```powershell
   lip install github.com/HosihikariFramework/HostingShim#levilamina   # 或 #endstone
   lip install github.com/HosihikariFramework/RpcLoader
   ```

4. 重启服务端。Loader 会在包目录里启动清单中的命令。

自持态 Linux 用无后缀 Shim 包，并通过 `hosihikari-server` 启动；加载器与插件仍然放在
`plugins/` 下。

各模板中的 `hosihikari.mjs`、`hosihikari.py`、`hosihikari/` 来自 RpcLoader 的绑定目录；
升级 Loader 时同步更新。

## 协议

绑定独占 stdout，只走 JSON-RPC 帧；stderr 是文本日志。插件日志请用上下文提供的日志方法。
上下文提供数据目录、包目录、配置读取、数据写入、事件发布/订阅与定时器。见
[进程外文档](https://hosihikariframework.github.io/zh/authoring-rpc/)。

## 许可

MIT-0，见 [LICENSE.md](LICENSE.md)。
