#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

rm -rf classes
rm -f plugin.jar
mkdir -p classes

javac --release 21 -d classes hosihikari/*.java
kotlinc -jvm-target 21 -cp classes -include-runtime -d plugin.jar src/MyKotlinPlugin.kt
jar uf plugin.jar -C classes .
rm -rf classes
