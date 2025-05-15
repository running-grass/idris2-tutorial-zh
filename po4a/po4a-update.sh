#!/usr/bin/env sh

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

cd "${ROOT_DIR}"
    
#  执行目录为项目根目录
cp pack.toml README.md tutorial.ipkg translation/
cp -r src/Solutions/* translation/src/Solutions/
cp -r src/Data/* translation/src/Data/
cp -r src/Text/* translation/src/Text/

cd po4a && po4a  -v ./po4a.cfg