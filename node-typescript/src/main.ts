import fs from 'node:fs';
import path from 'node:path';

const write = (ctx: RpcPluginContext, name: string, text: string): void => {
  fs.writeFileSync(path.join(ctx.dataDirectory, name), text);
};

const plugin: RpcPlugin = {
  onLoad(ctx) {
    write(ctx, 'loaded.txt', 'loaded');
    ctx.logInfo(`MyNodePlugin loaded from ${ctx.packageDirectory}`);
  },

  onEnable(ctx) {
    const greeting = ctx.config('greeting');
    write(ctx, 'enabled.txt', greeting ?? '');
    ctx.logInfo(`enabled, greeting=${greeting}`);
  },

  onDisable() {
    return true;
  },

  onUnload() {},
};

export default plugin;
