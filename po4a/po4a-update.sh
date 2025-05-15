#!/usr/bin/env sh

set -e

#  执行目录为项目根目录
cp pack.toml README.md tutorial.ipkg translation/
cp -r src/Solutions/* translation/src/Solutions/
cp -r src/Data/* translation/src/Data/
cp -r src/Text/* translation/src/Text/

cd po4a && po4a  -v ./po4a.cfg