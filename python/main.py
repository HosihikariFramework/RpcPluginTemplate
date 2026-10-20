import os


def _write(ctx, name, text):
    with open(os.path.join(ctx.data_directory, name), "w", encoding="utf-8") as stream:
        stream.write(text)


def on_load(ctx):
    _write(ctx, "loaded.txt", "loaded")
    ctx.log_info(f"MyPythonPlugin loaded from {ctx.package_directory}")


def on_enable(ctx):
    greeting = ctx.config("greeting")
    _write(ctx, "enabled.txt", str(greeting or ""))
    ctx.log_info(f"enabled, greeting={greeting}")


def on_disable(ctx):
    return True


def on_unload(ctx):
    pass
