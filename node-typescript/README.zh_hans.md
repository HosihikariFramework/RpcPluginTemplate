# RPC 插件模板 —— Node.js/TypeScript 运行时

星光框架的最小进程外 Node 插件，用 TypeScript 编写。RpcLoader 启动清单里的命令，通过行分隔
JSON-RPC 2.0 over stdio 通信；卸载就是让子进程退出。

## 要求

- 运行时需要 Node.js 20 或更新版本。
- 构建时需要 Node.js 与 npm。

## 构建

```sh
npm install
npm run build
```

构建产物是 `dist/main.js`，也就是清单命令运行的入口。`npm run check` 只做类型检查，不产出文件。

## 部署

1. 把本目录复制到服务端，改名为 `plugins/MyNodePlugin/`。目录名必须与 `manifest.json` 的
   `name` 一致。
2. 改 `manifest.json` 的 `name`，把 `MyNodePlugin.conf` 改成同名；调整布局时同步修改入口或
   `extraInfo.command`。
3. 构建后按服务端安装 Shim 变体与 RPC Loader，再重启：

   ```powershell
   lip install github.com/HosihikariFramework/Shim#levilamina   # 或 #endstone
   lip install github.com/HosihikariFramework/RpcProvider
   ```

自持态 Linux 用无后缀 Shim 包，并通过 `hosihikari-server` 启动；加载器与插件仍然放在
`plugins/` 下。

## 文件

- `manifest.json` —— `loader: rpc`；`command` 是编码成字符串的 JSON 数组
  （`node ./hosihikari.mjs ./dist/main.js`）。
- `src/main.ts` —— 插件本体；默认导出实现各钩子。
- `hosihikari.d.ts` —— 绑定的上下文与钩子类型。
- `hosihikari.mjs` —— 从 RpcLoader 的 `bindings/node/` 拷来的 Node 绑定；升级 Loader 时
  同步更新。
- `tsconfig.json`、`package.json` —— TypeScript 构建配置。
- `MyNodePlugin.conf` —— 包内默认配置。

## 协议

`hosihikari.mjs` 独占 stdout，只走 JSON-RPC 帧。`console.log` 已被改道 stderr；插件日志请用
`ctx.logInfo` / `ctx.logWarn` / `ctx.logError`。

上下文提供数据目录、包目录、配置读取、数据写入、事件发布/订阅与定时器。见
[进程外文档](https://hosihikariframework.github.io/zh/authoring-rpc/)。

## 许可

MIT-0，见 [LICENSE.md](LICENSE.md)。
