#!/usr/bin/env bash
set -euo pipefail

FULL_SHA="${FULL_SHA:?}"

mkdir -p release-files

for ext in AppImage 7z zip tar.gz apk dmg tar.xz; do
    find build-artifacts/ -type f -name "*.${ext}" -exec cp -v {} release-files/ \;
done

echo "$FULL_SHA" > release-files/azahar-sha.txt

echo ""
echo "=== Files staged for release ==="
ls -lh release-files/

if [ "$(find release-files/ -type f ! -name 'azahar-sha.txt' | wc -l)" -eq 0 ]; then
    echo "::warning::No distributable artifacts were found. The release will only contain azahar-sha.txt."
fi
