#!/usr/bin/env bash
# Pack this runtime package with the framework's packer. The packer writes the
# LeviLamina manifest.json envelope next to hosihikari.json.
#
# A package still on the 1.x manifest.json migrates first, in the same command.
# Run `bash ./pack.sh --migrate-only` to rewrite the metadata and stop there.
#
# Build first (npm ci && npm run build): the packer copies the working tree.
# Requires a sibling PluginManager checkout, or HOSIHIKARI_PLUGINMANAGER.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
core=${HOSIHIKARI_PLUGINMANAGER:-"$(cd "$here/../.." && pwd)/PluginManager"}
tool="$core/tools/Pack/Hosihikari.Plugin.Pack.csproj"
if [ ! -f "$tool" ]; then
    echo "Core packer not found: $tool. Run with a sibling Hosihikari.PluginManager checkout, or set HOSIHIKARI_PLUGINMANAGER." >&2
    exit 1
fi

# 旧包在包根上还留着 manifest.json；migrate 就地换掉（ADR-0058）。
if [ -f "$here/manifest.json" ]; then
    if [ -f "$here/hosihikari.json" ]; then
        echo 'manifest.json and hosihikari.json both exist; delete the stale manifest.json first' >&2
        exit 1
    fi

    dotnet run --project "$tool" -c Release -- migrate "$here"
    echo 'migrated manifest.json to hosihikari.json; review it before packing'
    if [ "${1:-}" = "--migrate-only" ]; then
        exit 0
    fi
elif [ "${1:-}" = "--migrate-only" ]; then
    echo 'nothing to migrate: hosihikari.json is already in place'
    exit 0
fi

# 打包器拒绝输出目录与源目录相交；先复制到临时目录，排除仓库元数据与旧产物。
# 这里的 dist/ 同时是 TypeScript 的构建输出（dist/main.js）与打包输出；只带它的文件，
# 上次留下的包目录（dist/<名字>/）不带，否则每打一次就多嵌一层。
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
# 只从暂存根挑条目：BSD tar 没有 --anchored，而裸 --exclude=bin 会把 node_modules 里的同名目录也裁掉。
(cd "$here" && for entry in * .[!.]*; do
    [ -e "$entry" ] || continue
    case "$entry" in .git|dist|data|bin|obj) continue;; esac
    printf '%s\n' "$entry"
done | tar -cf - -T -) | (cd "$stage" && tar -xf -)
mkdir -p "$stage/dist"
# 编译产物可能带子目录；只排除上次打包留下的 dist/<名字>/，否则每打一次就多嵌一层。
# 名字交给 JSON 解析器读：缩进或单行写法都不该影响打包。相对路径进 require，
# Git Bash 的 /c/... 绝对路径在 Windows 的 node 里解析不了。
package_name=$(cd "$here" && node -p "require('./hosihikari.json').name")
if [ -z "$package_name" ]; then
    echo "cannot read name from $here/hosihikari.json" >&2
    exit 1
fi
(cd "$here/dist" && tar -cf - .) | (cd "$stage/dist" && tar -xf -)
rm -rf "$stage/dist/$package_name"

dotnet run --project "$tool" -c Release -- pack-plugin "$stage" "$here/hosihikari.json" "$here/dist"
