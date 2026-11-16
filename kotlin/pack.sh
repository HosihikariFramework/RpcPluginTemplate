#!/usr/bin/env bash
# Pack this runtime package with the framework's packer. The packer writes the
# LeviLamina manifest.json envelope next to hosihikari.json.
#
# A package still on the 1.x manifest.json migrates first, in the same command.
# Run `bash ./pack.sh --migrate-only` to rewrite the metadata and stop there.
#
# Build first (./build.sh or ./build.ps1): the packer copies the working tree.
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
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
(cd "$here" && tar -cf - --exclude=.git --exclude=dist --exclude=data --exclude=bin --exclude=obj .) |
    (cd "$stage" && tar -xf -)

dotnet run --project "$tool" -c Release -- pack-plugin "$stage" "$here/hosihikari.json" "$here/dist"
