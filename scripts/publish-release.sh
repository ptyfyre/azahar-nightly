#!/usr/bin/env bash
set -euo pipefail

TAG_NAME="${TAG_NAME:?}"
SHORT_SHA="${SHORT_SHA:?}"
BUILD_DATE="${BUILD_DATE:?}"

RELEASE_TITLE="Azahar Nightly (${BUILD_DATE}, ${SHORT_SHA})"
[ "${GITHUB_EVENT_NAME:-}" = "workflow_dispatch" ] && RELEASE_TITLE="${RELEASE_TITLE} (Manual)"

RELEASE_FILES=()
while IFS= read -r -d '' f; do
    RELEASE_FILES+=("$f")
done < <(find release-files/ -type f -print0)

echo "Publishing release '${RELEASE_TITLE}' with tag '${TAG_NAME}'"
echo "Attaching ${#RELEASE_FILES[@]} file(s)."

gh release create "$TAG_NAME" \
    --title "$RELEASE_TITLE" \
    --notes-file changelog.md \
    "${RELEASE_FILES[@]}"

echo "Release published: ${TAG_NAME}"
