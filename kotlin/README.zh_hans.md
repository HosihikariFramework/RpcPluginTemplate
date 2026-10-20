# RPC 插件模板 —— Kotlin/JVM 运行时

星光框架的最小进程外 Kotlin 插件，运行在 JVM 上。RpcProvider 启动清单里的命令，通过行分隔
JSON-RPC 2.0 over stdio 通信；卸载就是让子进程退出。

## 要求

- 运行时需要 JDK 21 或更新版本。
- 构建时需要 JDK 21 或更新版本，且 `PATH` 上有 `kotlinc`。

## 构建

```sh
./build.sh
```

Windows 上：

```powershell
./build.ps1
```

构建会编译 Java 绑定、连同 Kotlin 运行时编译 Kotlin 插件，并把绑定类加进 `plugin.jar`。
服务端只需要 `plugin.jar` 这一个产物。

## 部署

1. 把本目录复制到服务端，改名为 `plugins/MyKotlinPlugin/`。目录名必须与 `manifest.json` 的
   `name` 一致。
2. 改 `manifest.json` 的 `name`，把 `MyKotlinPlugin.conf` 改成同名；调整布局时同步修改入口或
   `extraInfo.command`，包括命令里的插件类名。
3. 构建后按服务端安装 Shim 变体与 RPC Provider，再重启：

   ```powershell
   lip install github.com/HosihikariFramework/Shim#levilamina   # 或 #endstone / #endstone_linux
   lip install github.com/HosihikariFramework/RpcProvider
   ```

自持态 Linux 用无后缀 Shim 包，并通过 `hosihikari-server` 启动；Provider 与插件仍然放在
`plugins/` 下。

## 文件

- `manifest.json` —— `provider: rpc`；`command` 是编码成字符串的 JSON 数组
  （`java -cp ./plugin.jar hosihikari.Binding myplugin.MyKotlinPlugin`）。
- `src/MyKotlinPlugin.kt` —— 插件本体；实现 `hosihikari.Plugin`。
- `hosihikari/` —— 从 RpcProvider 的 `bindings/java/hosihikari/` 拷来的 Java 绑定；升级
  Provider 时同步更新。
- `build.sh`、`build.ps1` —— 构建脚本。
- `MyKotlinPlugin.conf` —— 包内默认配置。

## 协议

绑定独占 stdout，只走 JSON-RPC 帧。`System.out` 已被改道 stderr；插件日志请用 `context.logInfo` /
`context.logWarn` / `context.logError`。

钩子返回 `HookResult.allow()` 或 `HookResult.refuse(reason)`。`Context` 提供 `name()`、
`dataDirectory()`、`packageDirectory()`、`config(key)`、`configObject()`、
`logInfo` / `logWarn` / `logError`、`writeData(file, text)`、`publish(topic, json)`、
`subscribe(topic, handler[, sync])`、`runLater(millis, work)` 与 `runEvery(millis, work)`。见
[进程外文档](https://hosihikariframework.github.io/zh/authoring-rpc/)。

## 许可

MIT-0，见 [LICENSE.md](LICENSE.md)。
