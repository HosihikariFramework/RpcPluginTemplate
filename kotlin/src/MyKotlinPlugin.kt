package myplugin

import hosihikari.Context
import hosihikari.HookResult
import hosihikari.Plugin

class MyKotlinPlugin : Plugin {
    override fun onLoad(context: Context) {
        context.writeData("loaded.txt", "loaded")
        context.logInfo("MyKotlinPlugin loaded from " + context.packageDirectory())
    }

    override fun onEnable(context: Context): HookResult {
        val greeting = context.config("greeting") ?: ""
        context.writeData("enabled.txt", greeting)
        context.logInfo("enabled, greeting=$greeting")
        return HookResult.allow()
    }

    override fun onDisable(context: Context): HookResult = HookResult.allow()

    override fun onUnload(context: Context) {
    }
}
